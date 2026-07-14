package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.common.OperationTypeEnum;
import com.ltcmsystem.dto.TeamMemberDTO;
import com.ltcmsystem.entity.Team;
import com.ltcmsystem.entity.TeamMember;
import com.ltcmsystem.entity.TeamUserRole;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.mapper.TeamMapper;
import com.ltcmsystem.mapper.TeamMemberMapper;
import com.ltcmsystem.mapper.TeamUserRoleMapper;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.OperationLogService;
import com.ltcmsystem.service.TeamPermissionService;
import com.ltcmsystem.service.TeamService;
import com.ltcmsystem.util.IpUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamServiceImpl extends ServiceImpl<TeamMapper, Team> implements TeamService {

    private final TeamMemberMapper teamMemberMapper;
    private final UserMapper userMapper;
    private final TeamPermissionService teamPermissionService;
    private final TeamUserRoleMapper teamUserRoleMapper;
    private final OperationLogService operationLogService;

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

        String teamCode = generateTeamCode(team.getId());
        team.setTeamCode(teamCode);
        updateById(team);

        TeamMember member = new TeamMember();
        member.setTeamId(team.getId());
        member.setUserId(userId);
        member.setRole("ADMIN");
        teamMemberMapper.insert(member);

        teamPermissionService.initTeamRoles(team.getId());
        teamPermissionService.assignRole(team.getId(), userId, "OWNER");

        logOperation(userId, OperationTypeEnum.TEAM_CREATE, OperationTypeEnum.TEAM_CREATE.getDesc(),
                team.getId(), team.getName());

        return team;
    }

    private String generateTeamCode(Long teamId) {
        String idPart = String.format("%06d", teamId);
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        Random random = new Random();
        StringBuilder suffix = new StringBuilder();
        for (int i = 0; i < 4; i++) {
            suffix.append(chars.charAt(random.nextInt(chars.length())));
        }
        return "T" + idPart + suffix;
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
        
        teamPermissionService.assignRole(teamId, userId, "MEMBER");

        Team team = getById(teamId);
        if (team != null) {
            logOperation(userId, OperationTypeEnum.TEAM_JOIN, OperationTypeEnum.TEAM_JOIN.getDesc(),
                    teamId, team.getName());
        }
    }

    @Override
    @Transactional
    public void deleteTeam(Long teamId, Long userId) {
        Team team = getById(teamId);
        if (team == null) {
            throw new RuntimeException("团队不存在");
        }
        if (!team.getCreatorId().equals(userId)) {
            throw new RuntimeException("只有团队创建者可以解散团队");
        }

        logOperation(userId, OperationTypeEnum.TEAM_DELETE, OperationTypeEnum.TEAM_DELETE.getDesc(),
                teamId, team.getName());

        LambdaQueryWrapper<TeamMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(TeamMember::getTeamId, teamId);
        teamMemberMapper.delete(memberWrapper);
        
        removeById(teamId);
    }

    @Override
    @Transactional
    public void inviteMember(Long teamId, String username, Long currentUserId) {
        if (!teamPermissionService.hasPermission(teamId, currentUserId, "team:invite")) {
            throw new RuntimeException("没有邀请成员的权限");
        }
        
        LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
        userWrapper.eq(User::getUsername, username);
        User user = userMapper.selectOne(userWrapper);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        TeamMember existMember = getTeamMemberEntity(teamId, user.getId());
        if (existMember != null) {
            throw new RuntimeException("该用户已是团队成员");
        }
        
        TeamMember member = new TeamMember();
        member.setTeamId(teamId);
        member.setUserId(user.getId());
        member.setRole("MEMBER");
        teamMemberMapper.insert(member);
        
        teamPermissionService.assignRole(teamId, user.getId(), "MEMBER");

        Team team = getById(teamId);
        if (team != null) {
            logOperation(currentUserId, OperationTypeEnum.TEAM_INVITE,
                    OperationTypeEnum.TEAM_INVITE.getDesc() + ": " + username,
                    teamId, team.getName());
        }
    }

    @Override
    @Transactional
    public void removeMember(Long teamId, Long memberId, Long currentUserId) {
        if (!teamPermissionService.hasPermission(teamId, currentUserId, "team:remove")) {
            throw new RuntimeException("没有移除成员的权限");
        }
        
        if (memberId.equals(currentUserId)) {
            throw new RuntimeException("不能移除自己");
        }

        Team team = getById(teamId);
        User memberUser = userMapper.selectById(memberId);
        if (team != null && memberUser != null) {
            logOperation(currentUserId, OperationTypeEnum.TEAM_REMOVE_MEMBER,
                    OperationTypeEnum.TEAM_REMOVE_MEMBER.getDesc() + ": " + memberUser.getUsername(),
                    teamId, team.getName());
        }
        
        // 物理删除（关系表不需要逻辑删除，避免唯一键冲突）
        teamMemberMapper.physicalDeleteByTeamIdAndUserId(teamId, memberId);
        teamUserRoleMapper.physicalDeleteByTeamIdAndUserId(teamId, memberId);
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

    private void logOperation(Long userId, OperationTypeEnum operationType, String operationDesc,
                              Long targetId, String targetName) {
        if (userId == null) {
            return;
        }
        User user = userMapper.selectById(userId);
        if (user == null) {
            return;
        }
        String ipAddress = IpUtil.getClientIp();
        String userAgent = IpUtil.getUserAgent();
        operationLogService.logOperation(
                userId,
                user.getUsername(),
                user.getNickname(),
                operationType.name(),
                operationDesc,
                "team",
                targetId,
                targetName,
                ipAddress,
                userAgent
        );
    }
}
