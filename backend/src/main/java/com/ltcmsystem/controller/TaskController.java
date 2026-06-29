package com.ltcmsystem.controller;

import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.MemberTaskStatsDTO;
import com.ltcmsystem.dto.TaskDTO;
import com.ltcmsystem.entity.Task;
import com.ltcmsystem.service.TaskService;
import com.ltcmsystem.util.UserContext;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping("/my")
    public Result<List<Task>> getMyTasks() {
        Long userId = UserContext.getUserId();
        List<Task> tasks = taskService.getUserTasks(userId);
        return Result.success(tasks);
    }

    @GetMapping("/team/{teamId}")
    public Result<List<Task>> getTeamTasks(@PathVariable Long teamId) {
        List<Task> tasks = taskService.getTeamTasks(teamId);
        return Result.success(tasks);
    }

    @GetMapping("/team/{teamId}/stats")
    public Result<List<MemberTaskStatsDTO>> getTeamMemberStats(@PathVariable Long teamId) {
        List<MemberTaskStatsDTO> stats = taskService.getTeamMemberStats(teamId);
        return Result.success(stats);
    }

    @PostMapping
    public Result<Task> createTask(@Valid @RequestBody TaskDTO taskDTO) {
        Long userId = UserContext.getUserId();
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
        taskService.deleteTask(id);
        return Result.success();
    }
}
