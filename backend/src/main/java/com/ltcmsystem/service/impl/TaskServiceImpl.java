package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.common.OperationTypeEnum;
import com.ltcmsystem.common.TaskStatusEnum;
import com.ltcmsystem.dto.MemberTaskStatsDTO;
import com.ltcmsystem.dto.TeamMemberDTO;
import com.ltcmsystem.dto.TaskPublicDTO;
import com.ltcmsystem.dto.TaskPublicQueryDTO;
import com.ltcmsystem.entity.Task;
import com.ltcmsystem.entity.Team;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.exception.BusinessException;
import com.ltcmsystem.mapper.TaskMapper;
import com.ltcmsystem.mapper.TeamMapper;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.NotificationService;
import com.ltcmsystem.service.OperationLogService;
import com.ltcmsystem.service.TaskChangeLogService;
import com.ltcmsystem.service.TaskService;
import com.ltcmsystem.service.TeamPermissionService;
import com.ltcmsystem.service.TeamService;
import com.ltcmsystem.util.IpUtil;
import com.ltcmsystem.util.UserContext;
import com.ltcmsystem.vo.TaskPublicVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskServiceImpl extends ServiceImpl<TaskMapper, Task> implements TaskService {

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(TaskServiceImpl.class);

    private static final Map<String, List<String>> STATUS_TRANSITIONS = new HashMap<>();

    static {
        STATUS_TRANSITIONS.put(TaskStatusEnum.PENDING_ASSIGN.name(),
                Arrays.asList(TaskStatusEnum.IN_PROGRESS.name(), TaskStatusEnum.CANCELLED.name()));
        STATUS_TRANSITIONS.put(TaskStatusEnum.IN_PROGRESS.name(),
                Arrays.asList(TaskStatusEnum.PENDING_REVIEW.name(), TaskStatusEnum.CANCELLED.name()));
        STATUS_TRANSITIONS.put(TaskStatusEnum.PENDING_REVIEW.name(),
                Arrays.asList(TaskStatusEnum.IN_PROGRESS.name(), TaskStatusEnum.DONE.name()));
        STATUS_TRANSITIONS.put(TaskStatusEnum.DONE.name(), Collections.emptyList());
        STATUS_TRANSITIONS.put(TaskStatusEnum.CANCELLED.name(), Collections.emptyList());
    }

    private final UserMapper userMapper;
    private final TeamService teamService;
    private final TeamMapper teamMapper;
    private final TeamPermissionService teamPermissionService;
    private final TaskChangeLogService taskChangeLogService;
    private final OperationLogService operationLogService;
    private final NotificationService notificationService;

    @Override
    public List<Task> getUserTasks(Long userId) {
        LambdaQueryWrapper<Task> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.eq(Task::getCreatorId, userId).or().eq(Task::getAssigneeId, userId))
               .orderByDesc(Task::getCreateTime);
        return list(wrapper);
    }

    @Override
    public List<Task> getTeamTasks(Long teamId) {
        LambdaQueryWrapper<Task> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Task::getTeamId, teamId)
               .orderByDesc(Task::getCreateTime);
        return list(wrapper);
    }

    @Override
    public Task createTask(Task task) {
        if (task.getStatus() == null) {
            task.setStatus(TaskStatusEnum.PENDING_ASSIGN.name());
        }
        if (task.getPriority() == null) {
            task.setPriority("MEDIUM");
        }
        save(task);

        // 生成 task_code
        String taskCode = generateTaskCode(task.getId());
        task.setTaskCode(taskCode);
        updateById(task);

        Long operatorId = UserContext.getUserId();
        String operatorName = getOperatorName(operatorId);
        taskChangeLogService.logChange(task.getId(), "CREATE", "创建任务", null, "创建任务", operatorId, operatorName);

        logOperation(operatorId, OperationTypeEnum.TASK_CREATE, OperationTypeEnum.TASK_CREATE.getDesc(),
                task.getId(), task.getTitle());

        // 分配通知：创建任务时若有负责人且不是自己，通知负责人
        notifyAssignee(task.getId(), task.getTitle(), null, task.getAssigneeId(), operatorId);

        return task;
    }

    private String generateTaskCode(Long taskId) {
        String randomPart = UUID.randomUUID().toString().replace("-", "").substring(0, 4).toUpperCase();
        return "TK" + String.format("%06d", taskId) + randomPart;
    }

    @Override
    public Task updateTask(Long id, Task task) {
        Task oldTask = getById(id);
        if (oldTask == null) {
            throw new BusinessException("任务不存在");
        }

        if (task.getStatus() != null && !task.getStatus().equals(oldTask.getStatus())) {
            validateStatusTransition(oldTask.getStatus(), task.getStatus());
        }

        task.setId(id);
        updateById(task);

        Task newTask = getById(id);
        logTaskChanges(oldTask, newTask);

        Long operatorId = UserContext.getUserId();
        logOperation(operatorId, OperationTypeEnum.TASK_UPDATE, OperationTypeEnum.TASK_UPDATE.getDesc(),
                newTask.getId(), newTask.getTitle());

        // 分配通知：负责人变化时通知新负责人（不是自己才发）
        notifyAssignee(newTask.getId(), newTask.getTitle(), oldTask.getAssigneeId(), newTask.getAssigneeId(), operatorId);

        return newTask;
    }

    /** 任务分配通知：oldAssignee → newAssignee 变化（或初次分配）时，给新负责人发通知 */
    private void notifyAssignee(Long taskId, String title, Long oldAssigneeId, Long newAssigneeId, Long operatorId) {
        try {
            if (newAssigneeId == null) return;
            if (newAssigneeId.equals(oldAssigneeId)) return;  // 负责人没变
            if (newAssigneeId.equals(operatorId)) return;     // 自己分配给自己不通知
            String teamName = "";
            Task t = getById(taskId);
            if (t != null && t.getTeamId() != null) {
                Team team = teamMapper.selectById(t.getTeamId());
                if (team != null) teamName = team.getName();
            }
            String content = "您被分配了任务「" + title + "」" +
                    (teamName.isEmpty() ? "" : "（团队：" + teamName + "）") + "，请及时处理。";
            notificationService.sendNotification(newAssigneeId, "TASK_ASSIGN", "新任务分配",
                    content, "TASK", taskId);
        } catch (Exception e) {
            log.warn("发送任务分配通知失败: taskId={}", taskId, e);
        }
    }

    private void validateStatusTransition(String oldStatus, String newStatus) {
        List<String> allowedTransitions = STATUS_TRANSITIONS.get(oldStatus);
        if (allowedTransitions == null || !allowedTransitions.contains(newStatus)) {
            throw new BusinessException("任务状态不允许从 " + oldStatus + " 变更为 " + newStatus);
        }
    }

    private void logTaskChanges(Task oldTask, Task newTask) {
        Long operatorId = UserContext.getUserId();
        String operatorName = getOperatorName(operatorId);
        Long taskId = newTask.getId();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        if (!Objects.equals(oldTask.getStatus(), newTask.getStatus())) {
            taskChangeLogService.logChange(taskId, "status", "状态",
                    oldTask.getStatus(), newTask.getStatus(), operatorId, operatorName);
        }

        if (!Objects.equals(oldTask.getPriority(), newTask.getPriority())) {
            taskChangeLogService.logChange(taskId, "priority", "优先级",
                    oldTask.getPriority(), newTask.getPriority(), operatorId, operatorName);
        }

        if (!Objects.equals(oldTask.getAssigneeId(), newTask.getAssigneeId())) {
            String oldAssigneeName = oldTask.getAssigneeId() != null ? getUserName(oldTask.getAssigneeId()) : null;
            String newAssigneeName = newTask.getAssigneeId() != null ? getUserName(newTask.getAssigneeId()) : null;
            taskChangeLogService.logChange(taskId, "assigneeId", "负责人",
                    oldAssigneeName, newAssigneeName, operatorId, operatorName);
        }

        if (!Objects.equals(oldTask.getDueDate(), newTask.getDueDate())) {
            String oldDueDate = oldTask.getDueDate() != null ? oldTask.getDueDate().format(formatter) : null;
            String newDueDate = newTask.getDueDate() != null ? newTask.getDueDate().format(formatter) : null;
            taskChangeLogService.logChange(taskId, "dueDate", "截止日期",
                    oldDueDate, newDueDate, operatorId, operatorName);
        }

        if (!Objects.equals(oldTask.getTitle(), newTask.getTitle())) {
            taskChangeLogService.logChange(taskId, "title", "标题",
                    oldTask.getTitle(), newTask.getTitle(), operatorId, operatorName);
        }

        if (!Objects.equals(oldTask.getDescription(), newTask.getDescription())) {
            taskChangeLogService.logChange(taskId, "description", "描述",
                    oldTask.getDescription(), newTask.getDescription(), operatorId, operatorName);
        }
    }

    private String getOperatorName(Long userId) {
        if (userId == null) {
            return null;
        }
        return getUserName(userId);
    }

    private String getUserName(Long userId) {
        if (userId == null) {
            return null;
        }
        User user = userMapper.selectById(userId);
        if (user == null) {
            return null;
        }
        return user.getNickname() != null ? user.getNickname() : user.getUsername();
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
                "task",
                targetId,
                targetName,
                ipAddress,
                userAgent
        );
    }

    @Override
    public void deleteTask(Long id) {
        Task task = getById(id);
        if (task != null) {
            Long operatorId = UserContext.getUserId();
            logOperation(operatorId, OperationTypeEnum.TASK_DELETE, OperationTypeEnum.TASK_DELETE.getDesc(),
                    task.getId(), task.getTitle());
        }
        removeById(id);
    }

    @Override
    public List<MemberTaskStatsDTO> getTeamMemberStats(Long teamId) {
        // 获取团队所有成员
        List<TeamMemberDTO> members = teamService.getTeamMembers(teamId);
        if (members.isEmpty()) {
            return List.of();
        }

        // 获取团队所有任务
        List<Task> tasks = getTeamTasks(teamId);

        // 获取成员用户信息
        List<Long> userIds = members.stream().map(TeamMemberDTO::getUserId).collect(Collectors.toList());
        List<User> users = userMapper.selectBatchIds(userIds);
        Map<Long, User> userMap = users.stream().collect(Collectors.toMap(User::getId, u -> u));

        // 按被指派人分组统计
        Map<Long, List<Task>> tasksByMember = tasks.stream()
                .filter(t -> t.getAssigneeId() != null)
                .collect(Collectors.groupingBy(Task::getAssigneeId));

        // 组装统计结果
        List<MemberTaskStatsDTO> result = new ArrayList<>();
        for (TeamMemberDTO member : members) {
            MemberTaskStatsDTO stats = new MemberTaskStatsDTO();
            stats.setUserId(member.getUserId());
            stats.setUsername(member.getUsername());
            stats.setNickname(member.getNickname());

            List<Task> memberTasks = tasksByMember.getOrDefault(member.getUserId(), List.of());
            int total = memberTasks.size();
            int pendingAssign = 0, inProgress = 0, pendingReview = 0, done = 0, cancelled = 0;

            for (Task task : memberTasks) {
                switch (task.getStatus()) {
                    case "PENDING_ASSIGN" -> pendingAssign++;
                    case "IN_PROGRESS" -> inProgress++;
                    case "PENDING_REVIEW" -> pendingReview++;
                    case "DONE" -> done++;
                    case "CANCELLED" -> cancelled++;
                }
            }

            stats.setTotalTasks(total);
            stats.setPendingAssignTasks(pendingAssign);
            stats.setInProgressTasks(inProgress);
            stats.setPendingReviewTasks(pendingReview);
            stats.setDoneTasks(done);
            stats.setCancelledTasks(cancelled);
            stats.setCompletionRate(total > 0 ? (done * 100.0 / total) : 0);

            result.add(stats);
        }

        return result;
    }

    @Override
    public IPage<TaskPublicVO> getPublicTasks(TaskPublicQueryDTO queryDTO) {
        LambdaQueryWrapper<Task> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Task::getIsPublic, 1);
        
        if (queryDTO.getKeyword() != null && !queryDTO.getKeyword().isEmpty()) {
            wrapper.and(w -> w.like(Task::getTitle, queryDTO.getKeyword())
                    .or().like(Task::getPublicDesc, queryDTO.getKeyword()));
        }
        if (queryDTO.getPriority() != null && !queryDTO.getPriority().isEmpty()) {
            wrapper.eq(Task::getPriority, queryDTO.getPriority());
        }
        if (queryDTO.getStatus() != null && !queryDTO.getStatus().isEmpty()) {
            wrapper.eq(Task::getStatus, queryDTO.getStatus());
        }
        
        wrapper.orderByDesc(Task::getCreateTime);
        
        Page<Task> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        IPage<Task> taskPage = page(page, wrapper);
        
        List<Task> tasks = taskPage.getRecords();
        List<TaskPublicVO> voList = new ArrayList<>();
        
        if (!tasks.isEmpty()) {
            List<Long> teamIds = tasks.stream()
                    .map(Task::getTeamId)
                    .filter(Objects::nonNull)
                    .distinct()
                    .collect(Collectors.toList());
            
            Map<Long, String> teamNameMap = new HashMap<>();
            Map<Long, String> teamCodeMap = new HashMap<>();
            if (!teamIds.isEmpty()) {
                List<Team> teams = teamMapper.selectBatchIds(teamIds);
                teamNameMap = teams.stream()
                        .collect(Collectors.toMap(Team::getId, Team::getName));
                teamCodeMap = teams.stream()
                        .collect(Collectors.toMap(Team::getId, t -> t.getTeamCode() != null ? t.getTeamCode() : ""));
            }
            
            for (Task task : tasks) {
                TaskPublicVO vo = new TaskPublicVO();
                BeanUtils.copyProperties(task, vo);
                if (task.getTeamId() != null) {
                    vo.setTeamName(teamNameMap.get(task.getTeamId()));
                    vo.setTeamCode(teamCodeMap.get(task.getTeamId()));
                }
                voList.add(vo);
            }
        }
        
        Page<TaskPublicVO> resultPage = new Page<>(taskPage.getCurrent(), taskPage.getSize(), taskPage.getTotal());
        resultPage.setRecords(voList);
        return resultPage;
    }

    @Override
    public TaskPublicVO getPublicTaskDetail(Long id) {
        Task task = getById(id);
        if (task == null || task.getIsPublic() == null || task.getIsPublic() != 1) {
            return null;
        }
        
        TaskPublicVO vo = new TaskPublicVO();
        BeanUtils.copyProperties(task, vo);
        
        if (task.getTeamId() != null) {
            Team team = teamMapper.selectById(task.getTeamId());
            if (team != null) {
                vo.setTeamName(team.getName());
                vo.setTeamCode(team.getTeamCode());
            }
        }
        
        return vo;
    }

    @Override
    public void togglePublic(Long taskId, Long userId, TaskPublicDTO taskPublicDTO) {
        Task task = getById(taskId);
        if (task == null) {
            throw new RuntimeException("任务不存在");
        }
        
        if (task.getTeamId() == null) {
            throw new RuntimeException("个人任务不能设置公开");
        }
        
        if (!teamPermissionService.hasPermission(task.getTeamId(), userId, "task:public")) {
            throw new RuntimeException("没有设置任务公开的权限");
        }
        
        Task updateTask = new Task();
        updateTask.setId(taskId);
        updateTask.setIsPublic(taskPublicDTO.getIsPublic());
        if (taskPublicDTO.getIsPublic() == 1) {
            updateTask.setPublicDesc(taskPublicDTO.getPublicDesc());
        }
        updateById(updateTask);
    }
}
