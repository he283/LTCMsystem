package com.ltcmsystem.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.entity.Notification;

public interface NotificationService extends IService<Notification> {
    void sendNotification(Long userId, String type, String title, String content, String relatedType, Long relatedId);
    IPage<Notification> getUserNotifications(Long userId, Integer pageNum, Integer pageSize);
    long getUnreadCount(Long userId);
    void markAsRead(Long notificationId, Long userId);
    void markAllAsRead(Long userId);
    void clearAll(Long userId);
}
