package com.ltcmsystem.common;

import lombok.Getter;

@Getter
public enum TaskStatusEnum {

    PENDING_ASSIGN("待分配"),
    IN_PROGRESS("进行中"),
    PENDING_REVIEW("待评审"),
    DONE("已完成"),
    CANCELLED("已取消");

    private final String desc;

    TaskStatusEnum(String desc) {
        this.desc = desc;
    }
}
