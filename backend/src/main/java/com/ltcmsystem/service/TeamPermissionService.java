package com.ltcmsystem.service;

import java.util.List;
import java.util.Set;

public interface TeamPermissionService {
    Set<String> getUserPermissions(Long teamId, Long userId);
    boolean hasPermission(Long teamId, Long userId, String permissionCode);
    boolean isTeamMember(Long teamId, Long userId);
    String getUserRoleCode(Long teamId, Long userId);
    void initTeamRoles(Long teamId);
    void assignRole(Long teamId, Long userId, String roleCode);
    List<Long> getAdminUserIds(Long teamId);
}
