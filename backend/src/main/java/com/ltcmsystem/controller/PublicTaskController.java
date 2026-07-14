package com.ltcmsystem.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.TaskPublicQueryDTO;
import com.ltcmsystem.entity.TaskComment;
import com.ltcmsystem.service.TaskCommentService;
import com.ltcmsystem.service.TaskService;
import com.ltcmsystem.vo.TaskPublicVO;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/public/tasks")
public class PublicTaskController {

    private final TaskService taskService;
    private final TaskCommentService taskCommentService;

    public PublicTaskController(TaskService taskService, TaskCommentService taskCommentService) {
        this.taskService = taskService;
        this.taskCommentService = taskCommentService;
    }

    @GetMapping
    public Result<IPage<TaskPublicVO>> getPublicTasks(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String priority,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        TaskPublicQueryDTO queryDTO = new TaskPublicQueryDTO();
        queryDTO.setKeyword(keyword);
        queryDTO.setPriority(priority);
        queryDTO.setStatus(status);
        queryDTO.setPageNum(pageNum);
        queryDTO.setPageSize(pageSize);
        IPage<TaskPublicVO> page = taskService.getPublicTasks(queryDTO);
        return Result.success(page);
    }

    @GetMapping("/{id}")
    public Result<TaskPublicVO> getPublicTaskDetail(@PathVariable Long id) {
        TaskPublicVO vo = taskService.getPublicTaskDetail(id);
        if (vo == null) {
            return Result.error(404, "任务不存在或未公开");
        }
        return Result.success(vo);
    }

    @GetMapping("/{id}/comments")
    public Result<IPage<TaskComment>> getPublicTaskComments(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "20") Integer pageSize) {
        TaskPublicVO vo = taskService.getPublicTaskDetail(id);
        if (vo == null) {
            return Result.error(404, "任务不存在或未公开");
        }
        IPage<TaskComment> page = taskCommentService.getCommentsByTaskId(id, pageNum, pageSize);
        return Result.success(page);
    }
}
