package com.ltcmsystem.controller;

import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.MemberTaskStatsDTO;
import com.ltcmsystem.dto.TaskDTO;
import com.ltcmsystem.dto.TaskPublicDTO;
import com.ltcmsystem.entity.Task;
import com.ltcmsystem.entity.TaskChangeLog;
import com.ltcmsystem.service.TaskChangeLogService;
import com.ltcmsystem.service.TaskService;
import com.ltcmsystem.service.TeamPermissionService;
import com.ltcmsystem.util.UserContext;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Objects;

@RestController
@RequestMapping("/api/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;
    private final TeamPermissionService teamPermissionService;
    private final TaskChangeLogService taskChangeLogService;

    @GetMapping("/my")
    public Result<List<Task>> getMyTasks() {
        Long userId = UserContext.getUserId();
        List<Task> tasks = taskService.getUserTasks(userId);
        return Result.success(tasks);
    }

    @GetMapping("/team/{teamId}")
    public Result<List<Task>> getTeamTasks(@PathVariable Long teamId) {
        Long userId = UserContext.getUserId();
        if (!teamPermissionService.hasPermission(teamId, userId, "task:view")) {
            return Result.error(403, "没有查看团队任务的权限");
        }
        List<Task> tasks = taskService.getTeamTasks(teamId);
        return Result.success(tasks);
    }

    @GetMapping("/team/{teamId}/stats")
    public Result<List<MemberTaskStatsDTO>> getTeamMemberStats(@PathVariable Long teamId) {
        Long userId = UserContext.getUserId();
        if (!teamPermissionService.hasPermission(teamId, userId, "team:view")) {
            return Result.error(403, "没有查看团队统计的权限");
        }
        List<MemberTaskStatsDTO> stats = taskService.getTeamMemberStats(teamId);
        return Result.success(stats);
    }

    @PostMapping
    public Result<Task> createTask(@Valid @RequestBody TaskDTO taskDTO) {
        Long userId = UserContext.getUserId();
        
        if (taskDTO.getTeamId() != null) {
            if (!teamPermissionService.hasPermission(taskDTO.getTeamId(), userId, "task:create")) {
                return Result.error(403, "没有创建团队任务的权限");
            }
        }
        
        Task task = new Task();
        task.setTitle(taskDTO.getTitle());
        task.setDescription(taskDTO.getDescription());
        task.setStatus(taskDTO.getStatus());
        task.setPriority(taskDTO.getPriority());
        task.setDueDate(taskDTO.getDueDate());
        task.setCreatorId(userId);
        task.setAssigneeId(taskDTO.getAssigneeId());
        task.setTeamId(taskDTO.getTeamId());
        Task created = taskService.createTask(task);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    public Result<Task> updateTask(@PathVariable Long id, @RequestBody TaskDTO taskDTO) {
        Long userId = UserContext.getUserId();
        Task existTask = taskService.getById(id);
        if (existTask == null) {
            return Result.error(404, "任务不存在");
        }
        
        if (existTask.getTeamId() != null) {
            if (!teamPermissionService.hasPermission(existTask.getTeamId(), userId, "task:edit")) {
                return Result.error(403, "没有编辑任务的权限");
            }
        } else if (!existTask.getCreatorId().equals(userId)) {
            return Result.error(403, "只能编辑自己的个人任务");
        }
        
        Task task = new Task();
        task.setTitle(taskDTO.getTitle());
        task.setDescription(taskDTO.getDescription());
        task.setStatus(taskDTO.getStatus());
        task.setPriority(taskDTO.getPriority());
        task.setDueDate(taskDTO.getDueDate());
        task.setAssigneeId(taskDTO.getAssigneeId());
        Task updated = taskService.updateTask(id, task);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteTask(@PathVariable Long id) {
        Long userId = UserContext.getUserId();
        Task existTask = taskService.getById(id);
        if (existTask == null) {
            return Result.error(404, "任务不存在");
        }
        
        if (existTask.getTeamId() != null) {
            if (!teamPermissionService.hasPermission(existTask.getTeamId(), userId, "task:delete")) {
                return Result.error(403, "没有删除任务的权限");
            }
        } else if (!existTask.getCreatorId().equals(userId)) {
            return Result.error(403, "只能删除自己的个人任务");
        }
        
        taskService.deleteTask(id);
        return Result.success();
    }

    @PutMapping("/{id}/public")
    public Result<Void> togglePublic(@PathVariable Long id, @RequestBody TaskPublicDTO taskPublicDTO) {
        Long userId = UserContext.getUserId();
        if (userId == null) {
            return Result.error(401, "请先登录");
        }
        taskService.togglePublic(id, userId, taskPublicDTO);
        return Result.success();
    }

    @GetMapping("/{id}/change-logs")
    public Result<List<TaskChangeLog>> getTaskChangeLogs(@PathVariable Long id) {
        Long userId = UserContext.getUserId();
        Task existTask = taskService.getById(id);
        if (existTask == null) {
            return Result.error(404, "任务不存在");
        }

        if (existTask.getTeamId() != null) {
            if (!teamPermissionService.hasPermission(existTask.getTeamId(), userId, "task:view")) {
                return Result.error(403, "没有查看任务的权限");
            }
        } else if (!existTask.getCreatorId().equals(userId) && !Objects.equals(existTask.getAssigneeId(), userId)) {
            return Result.error(403, "只能查看自己的个人任务");
        }

        List<TaskChangeLog> logs = taskChangeLogService.getTaskChangeLogs(id);
        return Result.success(logs);
    }
}
