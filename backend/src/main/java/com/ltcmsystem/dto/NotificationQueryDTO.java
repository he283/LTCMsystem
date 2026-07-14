package com.ltcmsystem.dto;

import lombok.Data;

@Data
public class NotificationQueryDTO {

    private Long userId;
    private String type;
    private Integer isRead;
}
