package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ltcmsystem.entity.TeamPermission;
import com.ltcmsystem.entity.TeamRole;
import com.ltcmsystem.entity.TeamRolePermission;
import com.ltcmsystem.entity.TeamUserRole;
import com.ltcmsystem.mapper.TeamPermissionMapper;
import com.ltcmsystem.mapper.TeamRoleMapper;
import com.ltcmsystem.mapper.TeamRolePermissionMapper;
import com.ltcmsystem.mapper.TeamUserRoleMapper;
import com.ltcmsystem.service.TeamPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamPermissionServiceImpl implements TeamPermissionService {

    private final TeamRoleMapper teamRoleMapper;
    private final TeamUserRoleMapper teamUserRoleMapper;
    private final TeamPermissionMapper teamPermissionMapper;
    private final TeamRolePermissionMapper teamRolePermissionMapper;

    @Override
    public Set<String> getUserPermissions(Long teamId, Long userId) {
        LambdaQueryWrapper<TeamUserRole> userRoleWrapper = new LambdaQueryWrapper<>();
        userRoleWrapper.eq(TeamUserRole::getTeamId, teamId)
                        .eq(TeamUserRole::getUserId, userId);
        List<TeamUserRole> userRoles = teamUserRoleMapper.selectList(userRoleWrapper);
        
        if (userRoles.isEmpty()) {
            return Set.of();
        }
        
        List<Long> roleIds = userRoles.stream().map(TeamUserRole::getRoleId).collect(Collectors.toList());
        
        LambdaQueryWrapper<TeamRolePermission> rolePermWrapper = new LambdaQueryWrapper<>();
        rolePermWrapper.in(TeamRolePermission::getRoleId, roleIds);
        List<TeamRolePermission> rolePermissions = teamRolePermissionMapper.selectList(rolePermWrapper);
        
        if (rolePermissions.isEmpty()) {
            return Set.of();
        }
        
        List<Long> permissionIds = rolePermissions.stream()
                .map(TeamRolePermission::getPermissionId)
                .distinct()
                .collect(Collectors.toList());
        
        List<TeamPermission> permissions = teamPermissionMapper.selectBatchIds(permissionIds);
        
        return permissions.stream()
                .map(TeamPermission::getPermissionCode)
                .collect(Collectors.toSet());
    }

    @Override
    public boolean hasPermission(Long teamId, Long userId, String permissionCode) {
        Set<String> permissions = getUserPermissions(teamId, userId);
        return permissions.contains(permissionCode);
    }

    @Override
    public boolean isTeamMember(Long teamId, Long userId) {
        LambdaQueryWrapper<TeamUserRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TeamUserRole::getTeamId, teamId)
                .eq(TeamUserRole::getUserId, userId);
        return teamUserRoleMapper.selectCount(wrapper) > 0;
    }

    @Override
    public String getUserRoleCode(Long teamId, Long userId) {
        LambdaQueryWrapper<TeamUserRole> userRoleWrapper = new LambdaQueryWrapper<>();
        userRoleWrapper.eq(TeamUserRole::getTeamId, teamId)
                        .eq(TeamUserRole::getUserId, userId);
        List<TeamUserRole> userRoles = teamUserRoleMapper.selectList(userRoleWrapper);
        
        if (userRoles.isEmpty()) {
            return null;
        }
        
        TeamUserRole userRole = userRoles.get(0);
        TeamRole role = teamRoleMapper.selectById(userRole.getRoleId());
        return role != null ? role.getRoleCode() : null;
    }

    @Override
    @Transactional
    public void initTeamRoles(Long teamId) {
        String[][] roles = {
            {"OWNER", "所有者", "团队所有者，拥有全部权限"},
            {"ADMIN", "管理员", "团队管理员，管理团队和任务"},
            {"MEMBER", "普通成员", "团队普通成员，参与任务协作"},
            {"GUEST", "访客", "团队访客，仅可查看"}
        };
        
        List<TeamRole> roleList = new ArrayList<>();
        for (String[] role : roles) {
            TeamRole teamRole = new TeamRole();
            teamRole.setTeamId(teamId);
            teamRole.setRoleCode(role[0]);
            teamRole.setRoleName(role[1]);
            teamRole.setDescription(role[2]);
            roleList.add(teamRole);
        }
        roleList.forEach(teamRoleMapper::insert);
        
        List<TeamPermission> allPermissions = teamPermissionMapper.selectList(null);
        Map<String, Long> permCodeToId = allPermissions.stream()
                .collect(Collectors.toMap(TeamPermission::getPermissionCode, TeamPermission::getId));
        
        List<TeamRole> createdRoles = teamRoleMapper.selectList(
            new LambdaQueryWrapper<TeamRole>().eq(TeamRole::getTeamId, teamId)
        );
        Map<String, Long> roleCodeToId = createdRoles.stream()
                .collect(Collectors.toMap(TeamRole::getRoleCode, TeamRole::getId));
        
        Map<String, List<String>> rolePermissions = new HashMap<>();
        rolePermissions.put("OWNER", Arrays.asList(
            "task:view", "task:create", "task:edit", "task:delete", "task:public",
            "team:view", "team:edit", "team:delete", "team:invite", "team:remove", "team:role"
        ));
        rolePermissions.put("ADMIN", Arrays.asList(
            "task:view", "task:create", "task:edit", "task:delete", "task:public",
            "team:view", "team:edit", "team:invite", "team:remove", "team:role"
        ));
        rolePermissions.put("MEMBER", Arrays.asList(
            "task:view", "task:create", "task:edit", "team:view"
        ));
        rolePermissions.put("GUEST", Arrays.asList(
            "task:view", "team:view"
        ));
        
        for (Map.Entry<String, List<String>> entry : rolePermissions.entrySet()) {
            Long roleId = roleCodeToId.get(entry.getKey());
            if (roleId == null) continue;
            for (String permCode : entry.getValue()) {
                Long permId = permCodeToId.get(permCode);
                if (permId == null) continue;
                TeamRolePermission rp = new TeamRolePermission();
                rp.setRoleId(roleId);
                rp.setPermissionId(permId);
                teamRolePermissionMapper.insert(rp);
            }
        }
    }

    @Override
    @Transactional
    public void assignRole(Long teamId, Long userId, String roleCode) {
        LambdaQueryWrapper<TeamRole> roleWrapper = new LambdaQueryWrapper<>();
        roleWrapper.eq(TeamRole::getTeamId, teamId)
                    .eq(TeamRole::getRoleCode, roleCode);
        TeamRole role = teamRoleMapper.selectOne(roleWrapper);
        
        if (role == null) {
            throw new RuntimeException("角色不存在");
        }
        
        LambdaQueryWrapper<TeamUserRole> userRoleWrapper = new LambdaQueryWrapper<>();
        userRoleWrapper.eq(TeamUserRole::getTeamId, teamId)
                        .eq(TeamUserRole::getUserId, userId);
        teamUserRoleMapper.delete(userRoleWrapper);
        
        TeamUserRole userRole = new TeamUserRole();
        userRole.setTeamId(teamId);
        userRole.setUserId(userId);
        userRole.setRoleId(role.getId());
        teamUserRoleMapper.insert(userRole);
    }

    @Override
    public List<Long> getAdminUserIds(Long teamId) {
        LambdaQueryWrapper<TeamRole> roleWrapper = new LambdaQueryWrapper<>();
        roleWrapper.eq(TeamRole::getTeamId, teamId)
                    .in(TeamRole::getRoleCode, "OWNER", "ADMIN");
        List<TeamRole> adminRoles = teamRoleMapper.selectList(roleWrapper);
        if (adminRoles.isEmpty()) {
            return List.of();
        }
        List<Long> roleIds = adminRoles.stream().map(TeamRole::getId).collect(Collectors.toList());
        LambdaQueryWrapper<TeamUserRole> userRoleWrapper = new LambdaQueryWrapper<>();
        userRoleWrapper.in(TeamUserRole::getRoleId, roleIds);
        List<TeamUserRole> userRoles = teamUserRoleMapper.selectList(userRoleWrapper);
        return userRoles.stream()
                .map(TeamUserRole::getUserId)
                .distinct()
                .collect(Collectors.toList());
    }
}
