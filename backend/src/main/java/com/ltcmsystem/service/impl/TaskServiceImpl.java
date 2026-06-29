package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.dto.MemberTaskStatsDTO;
import com.ltcmsystem.dto.TeamMemberDTO;
import com.ltcmsystem.entity.Task;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.mapper.TaskMapper;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.TaskService;
import com.ltcmsystem.service.TeamService;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class TaskServiceImpl extends ServiceImpl<TaskMapper, Task> implements TaskService {

    private final UserMapper userMapper;
    private final TeamService teamService;

    public TaskServiceImpl(UserMapper userMapper, TeamService teamService) {
        this.userMapper = userMapper;
        this.teamService = teamService;
    }

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
            task.setStatus("TODO");
        }
        if (task.getPriority() == null) {
            task.setPriority("MEDIUM");
        }
        save(task);
        return task;
    }

    @Override
    public Task updateTask(Long id, Task task) {
        task.setId(id);
        updateById(task);
        return getById(id);
    }

    @Override
    public void deleteTask(Long id) {
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
            int todo = 0, inProgress = 0, done = 0;

            for (Task task : memberTasks) {
                switch (task.getStatus()) {
                    case "TODO" -> todo++;
                    case "IN_PROGRESS" -> inProgress++;
                    case "DONE" -> done++;
                }
            }

            stats.setTotalTasks(total);
            stats.setTodoTasks(todo);
            stats.setInProgressTasks(inProgress);
            stats.setDoneTasks(done);
            stats.setCompletionRate(total > 0 ? (done * 100.0 / total) : 0);

            result.add(stats);
        }

        return result;
    }
}
