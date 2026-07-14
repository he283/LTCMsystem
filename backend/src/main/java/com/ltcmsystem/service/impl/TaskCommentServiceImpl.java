package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.entity.Task;
import com.ltcmsystem.entity.TaskComment;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.mapper.TaskCommentMapper;
import com.ltcmsystem.mapper.TaskMapper;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.TaskCommentService;
import com.ltcmsystem.service.TeamPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskCommentServiceImpl extends ServiceImpl<TaskCommentMapper, TaskComment> implements TaskCommentService {

    private final TaskCommentMapper taskCommentMapper;
    private final TaskMapper taskMapper;
    private final UserMapper userMapper;
    private final TeamPermissionService teamPermissionService;

    @Override
    public IPage<TaskComment> getCommentsByTaskId(Long taskId, Integer pageNum, Integer pageSize) {
        LambdaQueryWrapper<TaskComment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TaskComment::getTaskId, taskId)
               .orderByDesc(TaskComment::getCreateTime);
        Page<TaskComment> page = new Page<>(pageNum, pageSize);
        IPage<TaskComment> resultPage = taskCommentMapper.selectPage(page, wrapper);

        List<TaskComment> records = resultPage.getRecords();
        if (!records.isEmpty()) {
            List<Long> userIds = records.stream()
                    .map(TaskComment::getUserId)
                    .distinct()
                    .collect(Collectors.toList());
            List<User> users = userMapper.selectBatchIds(userIds);
            Map<Long, User> userMap = users.stream()
                    .collect(Collectors.toMap(User::getId, u -> u));
            for (TaskComment comment : records) {
                User user = userMap.get(comment.getUserId());
                if (user != null) {
                    comment.setUsername(user.getUsername());
                    comment.setNickname(user.getNickname());
                    comment.setAvatar(user.getAvatar());
                }
            }
        }

        return resultPage;
    }

    @Override
    @Transactional
    public TaskComment addComment(Long taskId, Long userId, String content) {
        Task task = taskMapper.selectById(taskId);
        if (task == null) {
            throw new RuntimeException("任务不存在");
        }

        if (task.getTeamId() != null) {
            if (!teamPermissionService.isTeamMember(task.getTeamId(), userId)) {
                throw new RuntimeException("只有团队成员可以评论");
            }
            Set<String> permissions = teamPermissionService.getUserPermissions(task.getTeamId(), userId);
            if (!permissions.contains("task:create") && !permissions.contains("task:edit")) {
                throw new RuntimeException("没有发表评论的权限");
            }
        } else if (!task.getCreatorId().equals(userId)) {
            throw new RuntimeException("只有任务创建者可以评论个人任务");
        }

        if (content == null || content.trim().isEmpty()) {
            throw new RuntimeException("评论内容不能为空");
        }
        if (content.length() > 2000) {
            throw new RuntimeException("评论内容不能超过2000字");
        }

        TaskComment comment = new TaskComment();
        comment.setTaskId(taskId);
        comment.setUserId(userId);
        comment.setContent(content.trim());
        taskCommentMapper.insert(comment);

        User user = userMapper.selectById(userId);
        if (user != null) {
            comment.setUsername(user.getUsername());
            comment.setNickname(user.getNickname());
            comment.setAvatar(user.getAvatar());
        }

        return comment;
    }

    @Override
    @Transactional
    public void deleteComment(Long commentId, Long userId) {
        TaskComment comment = taskCommentMapper.selectById(commentId);
        if (comment == null) {
            throw new RuntimeException("评论不存在");
        }

        Task task = taskMapper.selectById(comment.getTaskId());
        boolean canDelete = false;

        if (comment.getUserId().equals(userId)) {
            canDelete = true;
        } else if (task != null && task.getTeamId() != null) {
            if (teamPermissionService.hasPermission(task.getTeamId(), userId, "task:delete")) {
                canDelete = true;
            }
        }

        if (!canDelete) {
            throw new RuntimeException("没有删除评论的权限");
        }

        taskCommentMapper.deleteById(commentId);
    }
}
