package com.ltcmsystem.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.ltcmsystem.common.Result;
import com.ltcmsystem.entity.TaskComment;
import com.ltcmsystem.service.TaskCommentService;
import com.ltcmsystem.util.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tasks/{taskId}/comments")
@RequiredArgsConstructor
public class TaskCommentController {

    private final TaskCommentService taskCommentService;

    @GetMapping
    public Result<IPage<TaskComment>> getComments(
            @PathVariable Long taskId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "20") Integer pageSize) {
        IPage<TaskComment> page = taskCommentService.getCommentsByTaskId(taskId, pageNum, pageSize);
        return Result.success(page);
    }

    @PostMapping
    public Result<TaskComment> addComment(
            @PathVariable Long taskId,
            @RequestBody TaskComment comment) {
        Long userId = UserContext.getUserId();
        if (userId == null) {
            return Result.error(401, "请先登录");
        }
        TaskComment created = taskCommentService.addComment(taskId, userId, comment.getContent());
        return Result.success(created);
    }

    @DeleteMapping("/{commentId}")
    public Result<Void> deleteComment(
            @PathVariable Long taskId,
            @PathVariable Long commentId) {
        Long userId = UserContext.getUserId();
        if (userId == null) {
            return Result.error(401, "请先登录");
        }
        taskCommentService.deleteComment(commentId, userId);
        return Result.success();
    }
}
