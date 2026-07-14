package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.entity.Team;
import com.ltcmsystem.entity.TeamApplication;
import com.ltcmsystem.entity.TeamMember;
import com.ltcmsystem.entity.TeamUserRole;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.mapper.TeamApplicationMapper;
import com.ltcmsystem.mapper.TeamMapper;
import com.ltcmsystem.mapper.TeamMemberMapper;
import com.ltcmsystem.mapper.TeamUserRoleMapper;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.NotificationService;
import com.ltcmsystem.service.TeamApplicationService;
import com.ltcmsystem.service.TeamPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamApplicationServiceImpl extends ServiceImpl<TeamApplicationMapper, TeamApplication> implements TeamApplicationService {

    private final TeamApplicationMapper teamApplicationMapper;
    private final TeamMapper teamMapper;
    private final TeamMemberMapper teamMemberMapper;
    private final TeamPermissionService teamPermissionService;
    private final TeamUserRoleMapper teamUserRoleMapper;
    private final NotificationService notificationService;
    private final UserMapper userMapper;

    @Override
    @Transactional
    public TeamApplication applyJoin(String teamCode, String applyReason, Long userId) {
        LambdaQueryWrapper<Team> teamWrapper = new LambdaQueryWrapper<>();
        teamWrapper.eq(Team::getTeamCode, teamCode);
        Team team = teamMapper.selectOne(teamWrapper);
        if (team == null) {
            throw new RuntimeException("团队不存在");
        }

        LambdaQueryWrapper<TeamMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(TeamMember::getTeamId, team.getId())
                     .eq(TeamMember::getUserId, userId);
        TeamMember exist = teamMemberMapper.selectOne(memberWrapper);
        if (exist != null) {
            throw new RuntimeException("已在该团队中");
        }

        LambdaQueryWrapper<TeamApplication> appWrapper = new LambdaQueryWrapper<>();
        appWrapper.eq(TeamApplication::getTeamId, team.getId())
                  .eq(TeamApplication::getUserId, userId)
                  .eq(TeamApplication::getApplyType, "JOIN")
                  .eq(TeamApplication::getStatus, "PENDING");
        TeamApplication pending = teamApplicationMapper.selectOne(appWrapper);
        if (pending != null) {
            throw new RuntimeException("已有待审批的加入申请");
        }

        TeamApplication application = new TeamApplication();
        application.setTeamId(team.getId());
        application.setUserId(userId);
        application.setApplyType("JOIN");
        application.setStatus("PENDING");
        application.setApplyReason(applyReason);
        teamApplicationMapper.insert(application);

        // 给团队管理员/所有者发通知
        List<Long> adminIds = teamPermissionService.getAdminUserIds(team.getId());
        String teamName = team.getName();
        for (Long adminId : adminIds) {
            notificationService.sendNotification(
                adminId,
                "TEAM_APPLY",
                "新的加入申请",
                "有用户申请加入团队「" + teamName + "」，请及时处理",
                "APPLICATION",
                application.getId()
            );
        }

        return application;
    }

    @Override
    @Transactional
    public TeamApplication applyLeave(Long teamId, String applyReason, Long userId) {
        Team team = teamMapper.selectById(teamId);
        if (team == null) {
            throw new RuntimeException("团队不存在");
        }

        LambdaQueryWrapper<TeamMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(TeamMember::getTeamId, teamId)
                     .eq(TeamMember::getUserId, userId);
        TeamMember member = teamMemberMapper.selectOne(memberWrapper);
        if (member == null) {
            throw new RuntimeException("不在该团队中");
        }

        String roleCode = teamPermissionService.getUserRoleCode(teamId, userId);
        if ("OWNER".equals(roleCode)) {
            throw new RuntimeException("团队所有者不能退出，请先解散团队或转让所有权");
        }

        LambdaQueryWrapper<TeamApplication> appWrapper = new LambdaQueryWrapper<>();
        appWrapper.eq(TeamApplication::getTeamId, teamId)
                  .eq(TeamApplication::getUserId, userId)
                  .eq(TeamApplication::getApplyType, "LEAVE")
                  .eq(TeamApplication::getStatus, "PENDING");
        TeamApplication pending = teamApplicationMapper.selectOne(appWrapper);
        if (pending != null) {
            throw new RuntimeException("已有待审批的退出申请");
        }

        TeamApplication application = new TeamApplication();
        application.setTeamId(teamId);
        application.setUserId(userId);
        application.setApplyType("LEAVE");
        application.setStatus("PENDING");
        application.setApplyReason(applyReason);
        teamApplicationMapper.insert(application);

        // 给团队管理员/所有者发通知
        List<Long> adminIds = teamPermissionService.getAdminUserIds(teamId);
        String teamName = team.getName();
        for (Long adminId : adminIds) {
            notificationService.sendNotification(
                adminId,
                "TEAM_APPLY",
                "新的退出申请",
                "有成员申请退出团队「" + teamName + "」，请及时处理",
                "APPLICATION",
                application.getId()
            );
        }

        return application;
    }

    @Override
    public IPage<TeamApplication> getApplications(Long teamId, String status, Integer pageNum, Integer pageSize, Long currentUserId) {
        if (!teamPermissionService.hasPermission(teamId, currentUserId, "team:role")) {
            throw new RuntimeException("没有查看审批列表的权限");
        }

        LambdaQueryWrapper<TeamApplication> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TeamApplication::getTeamId, teamId);
        if (status != null && !status.isEmpty()) {
            wrapper.eq(TeamApplication::getStatus, status);
        }
        wrapper.orderByDesc(TeamApplication::getCreateTime);

        Page<TeamApplication> page = new Page<>(pageNum, pageSize);
        IPage<TeamApplication> resultPage = teamApplicationMapper.selectPage(page, wrapper);

        // 填充申请人昵称
        List<TeamApplication> records = resultPage.getRecords();
        if (!records.isEmpty()) {
            List<Long> userIds = records.stream()
                    .map(TeamApplication::getUserId)
                    .distinct()
                    .collect(Collectors.toList());
            List<User> users = userMapper.selectBatchIds(userIds);
            Map<Long, String> nameMap = users.stream()
                    .collect(Collectors.toMap(User::getId, u -> u.getNickname() != null ? u.getNickname() : u.getUsername()));
            for (TeamApplication app : records) {
                app.setApplicantName(nameMap.get(app.getUserId()));
            }
        }

        return resultPage;
    }

    @Override
    @Transactional
    public void handleApplication(Long id, String status, String handleRemark, Long handlerId) {
        TeamApplication application = teamApplicationMapper.selectById(id);
        if (application == null) {
            throw new RuntimeException("申请不存在");
        }
        if (!"PENDING".equals(application.getStatus())) {
            throw new RuntimeException("申请已处理");
        }
        if (!teamPermissionService.hasPermission(application.getTeamId(), handlerId, "team:role")) {
            throw new RuntimeException("没有审批权限");
        }

        application.setStatus(status);
        application.setHandleRemark(handleRemark);
        application.setHandlerId(handlerId);
        application.setHandleTime(LocalDateTime.now());
        teamApplicationMapper.updateById(application);

        Team team = teamMapper.selectById(application.getTeamId());
        String teamName = team != null ? team.getName() : "";

        if ("APPROVED".equals(status)) {
            if ("JOIN".equals(application.getApplyType())) {
                teamMemberMapper.physicalDeleteByTeamIdAndUserId(application.getTeamId(), application.getUserId());
                teamUserRoleMapper.physicalDeleteByTeamIdAndUserId(application.getTeamId(), application.getUserId());

                TeamMember member = new TeamMember();
                member.setTeamId(application.getTeamId());
                member.setUserId(application.getUserId());
                member.setRole("MEMBER");
                member.setJoinTime(LocalDateTime.now());
                teamMemberMapper.insert(member);
                teamPermissionService.assignRole(application.getTeamId(), application.getUserId(), "MEMBER");

                notificationService.sendNotification(
                    application.getUserId(),
                    "TEAM_APPROVE",
                    "加入申请已通过",
                    "您加入团队「" + teamName + "」的申请已通过",
                    "TEAM",
                    application.getTeamId()
                );
            } else if ("LEAVE".equals(application.getApplyType())) {
                teamMemberMapper.physicalDeleteByTeamIdAndUserId(application.getTeamId(), application.getUserId());
                teamUserRoleMapper.physicalDeleteByTeamIdAndUserId(application.getTeamId(), application.getUserId());

                notificationService.sendNotification(
                    application.getUserId(),
                    "TEAM_LEAVE_APPROVED",
                    "退出申请已通过",
                    "您退出团队「" + teamName + "」的申请已通过",
                    "TEAM",
                    application.getTeamId()
                );
            }
        } else if ("REJECTED".equals(status)) {
            if ("JOIN".equals(application.getApplyType())) {
                notificationService.sendNotification(
                    application.getUserId(),
                    "TEAM_JOIN_REJECTED",
                    "加入申请被拒绝",
                    "您加入团队「" + teamName + "」的申请被拒绝，原因：" + (handleRemark != null ? handleRemark : "无"),
                    "TEAM",
                    application.getTeamId()
                );
            } else if ("LEAVE".equals(application.getApplyType())) {
                notificationService.sendNotification(
                    application.getUserId(),
                    "TEAM_LEAVE_REJECTED",
                    "退出申请被拒绝",
                    "您退出团队「" + teamName + "」的申请被拒绝，原因：" + (handleRemark != null ? handleRemark : "无"),
                    "TEAM",
                    application.getTeamId()
                );
            }
        }
    }
}
