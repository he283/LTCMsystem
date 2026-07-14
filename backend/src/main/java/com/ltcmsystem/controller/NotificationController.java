package com.ltcmsystem.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.ltcmsystem.common.Result;
import com.ltcmsystem.entity.Notification;
import com.ltcmsystem.service.NotificationService;
import com.ltcmsystem.util.UserContext;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public Result<IPage<Notification>> getMyNotifications(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        Long userId = UserContext.getUserId();
        IPage<Notification> page = notificationService.getUserNotifications(userId, pageNum, pageSize);
        return Result.success(page);
    }

    @GetMapping("/unread-count")
    public Result<Long> getUnreadCount() {
        Long userId = UserContext.getUserId();
        long count = notificationService.getUnreadCount(userId);
        return Result.success(count);
    }

    @PutMapping("/{id}/read")
    public Result<Void> markAsRead(@PathVariable Long id) {
        Long userId = UserContext.getUserId();
        notificationService.markAsRead(id, userId);
        return Result.success();
    }

    @PutMapping("/read-all")
    public Result<Void> markAllAsRead() {
        Long userId = UserContext.getUserId();
        notificationService.markAllAsRead(userId);
        return Result.success();
    }

    @DeleteMapping("/clear-all")
    public Result<Void> clearAll() {
        Long userId = UserContext.getUserId();
        notificationService.clearAll(userId);
        return Result.success();
    }
}
