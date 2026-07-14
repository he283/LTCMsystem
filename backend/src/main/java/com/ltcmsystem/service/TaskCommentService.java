package com.ltcmsystem.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.entity.TaskComment;

public interface TaskCommentService extends IService<TaskComment> {
    IPage<TaskComment> getCommentsByTaskId(Long taskId, Integer pageNum, Integer pageSize);
    TaskComment addComment(Long taskId, Long userId, String content);
    void deleteComment(Long commentId, Long userId);
}
