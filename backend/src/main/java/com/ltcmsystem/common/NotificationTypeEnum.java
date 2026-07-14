package com.ltcmsystem.common;

import lombok.Getter;

@Getter
public enum NotificationTypeEnum {

    SYSTEM("系统通知"),
    TASK("任务通知"),
    TEAM_APPLY("团队申请通知"),
    TEAM_APPROVE("审批结果通知");

    private final String desc;

    NotificationTypeEnum(String desc) {
        this.desc = desc;
    }
}
