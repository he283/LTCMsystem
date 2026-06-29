package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.dto.TeamMemberDTO;
import com.ltcmsystem.entity.Team;
import com.ltcmsystem.entity.TeamMember;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.mapper.TeamMapper;
import com.ltcmsystem.mapper.TeamMemberMapper;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.TeamService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class TeamServiceImpl extends ServiceImpl<TeamMapper, Team> implements TeamService {

    private final TeamMemberMapper teamMemberMapper;
    private final UserMapper userMapper;

    public TeamServiceImpl(TeamMemberMapper teamMemberMapper, UserMapper userMapper) {
        this.teamMemberMapper = teamMemberMapper;
        this.userMapper = userMapper;
    }

    @Override
    public List<Team> getUserTeams(Long userId) {
        LambdaQueryWrapper<TeamMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TeamMember::getUserId, userId);
        List<TeamMember> members = teamMemberMapper.selectList(wrapper);
        List<Long> teamIds = members.stream().map(TeamMember::getTeamId).collect(Collectors.toList());
        if (teamIds.isEmpty()) {
            return List.of();
        }
        return listByIds(teamIds);
    }

    @Override
    @Transactional
    public Team createTeam(Team team, Long userId) {
        team.setCreatorId(userId);
        save(team);
        
        TeamMember member = new TeamMember();
        member.setTeamId(team.getId());
        member.setUserId(userId);
        member.setRole("ADMIN");
        teamMemberMapper.insert(member);
        
        return team;
    }

    @Override
    @Transactional
    public void joinTeam(Long teamId, Long userId) {
        LambdaQueryWrapper<TeamMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TeamMember::getTeamId, teamId)
               .eq(TeamMember::getUserId, userId);
        TeamMember exist = teamMemberMapper.selectOne(wrapper);
        if (exist != null) {
            throw new RuntimeException("已加入该团队");
        }
        
        TeamMember member = new TeamMember();
        member.setTeamId(teamId);
        member.setUserId(userId);
        member.setRole("MEMBER");
        teamMemberMapper.insert(member);
    }

    @Override
    @Transactional
    public void deleteTeam(Long teamId, Long userId) {
        // 验证权限
        Team team = getById(teamId);
        if (team == null) {
            throw new RuntimeException("团队不存在");
        }
        if (!team.getCreatorId().equals(userId)) {
            throw new RuntimeException("只有团队创建者可以解散团队");
        }
        
        // 删除团队成员
        LambdaQueryWrapper<TeamMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(TeamMember::getTeamId, teamId);
        teamMemberMapper.delete(memberWrapper);
        
        // 删除团队
        removeById(teamId);
    }

    @Override
    @Transactional
    public void inviteMember(Long teamId, String username, Long currentUserId) {
        // 验证当前用户是否有团队管理员权限
        TeamMember currentMember = getTeamMemberEntity(teamId, currentUserId);
        if (currentMember == null || !"ADMIN".equals(currentMember.getRole())) {
            throw new RuntimeException("只有团队管理员可以邀请成员");
        }
        
        // 查找被邀请用户
        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.eq(User::getUsername, username);
        User user = userMapper.selectOne(userWrapper);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        // 检查是否已是成员
        TeamMember existMember = getTeamMemberEntity(teamId, user.getId());
        if (existMember != null) {
            throw new RuntimeException("该用户已是团队成员");
        }
        
        // 添加成员
        TeamMember member = new TeamMember();
        member.setTeamId(teamId);
        member.setUserId(user.getId());
        member.setRole("MEMBER");
        teamMemberMapper.insert(member);
    }

    @Override
    @Transactional
    public void removeMember(Long teamId, Long memberId, Long currentUserId) {
        // 验证当前用户是否有团队管理员权限
        TeamMember currentMember = getTeamMemberEntity(teamId, currentUserId);
        if (currentMember == null || !"ADMIN".equals(currentMember.getRole())) {
            throw new RuntimeException("只有团队管理员可以移除成员");
        }
        
        // 不能移除自己
        if (memberId.equals(currentUserId)) {
            throw new RuntimeException("不能移除自己");
        }
        
        // 删除成员
        LambdaQueryWrapper<TeamMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TeamMember::getTeamId, teamId)
               .eq(TeamMember::getUserId, memberId);
        teamMemberMapper.delete(wrapper);
    }

    @Override
    public List<TeamMemberDTO> getTeamMembers(Long teamId) {
        LambdaQueryWrapper<TeamMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TeamMember::getTeamId, teamId);
        List<TeamMember> members = teamMemberMapper.selectList(wrapper);
        
        if (members.isEmpty()) {
            return List.of();
        }
        
        // 获取用户信息
        List<Long> userIds = members.stream().map(TeamMember::getUserId).collect(Collectors.toList());
        List<User> users = userMapper.selectBatchIds(userIds);
        Map<Long, User> userMap = users.stream().collect(Collectors.toMap(User::getId, u -> u));
        
        // 组装DTO
        List<TeamMemberDTO> result = new ArrayList<>();
        for (TeamMember member : members) {
            TeamMemberDTO dto = new TeamMemberDTO();
            dto.setId(member.getId());
            dto.setUserId(member.getUserId());
            dto.setRole(member.getRole());
            dto.setJoinTime(member.getJoinTime());
            
            User user = userMap.get(member.getUserId());
            if (user != null) {
                dto.setUsername(user.getUsername());
                dto.setNickname(user.getNickname());
                dto.setEmail(user.getEmail());
            }
            result.add(dto);
        }
        
        return result;
    }

    @Override
    public TeamMemberDTO getTeamMember(Long teamId, Long userId) {
        TeamMember member = getTeamMemberEntity(teamId, userId);
        if (member == null) {
            return null;
        }
        
        TeamMemberDTO dto = new TeamMemberDTO();
        dto.setId(member.getId());
        dto.setUserId(member.getUserId());
        dto.setRole(member.getRole());
        dto.setJoinTime(member.getJoinTime());
        
        User user = userMapper.selectById(userId);
        if (user != null) {
            dto.setUsername(user.getUsername());
            dto.setNickname(user.getNickname());
            dto.setEmail(user.getEmail());
        }
        
        return dto;
    }

    private TeamMember getTeamMemberEntity(Long teamId, Long userId) {
        LambdaQueryWrapper<TeamMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TeamMember::getTeamId, teamId)
               .eq(TeamMember::getUserId, userId);
        return teamMemberMapper.selectOne(wrapper);
    }
}
