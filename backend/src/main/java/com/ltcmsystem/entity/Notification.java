package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("notification")
public class Notification extends BaseEntity {
    private Long userId;
    private String type;
    private String title;
    private String content;
    private String relatedType;
    private Long relatedId;
    private Integer isRead;
    private LocalDateTime readTime;
}
