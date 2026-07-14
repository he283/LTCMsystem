package com.ltcmsystem.common;

import lombok.Getter;

@Getter
public enum TaskPriorityEnum {

    HIGH("高"),
    MEDIUM("中"),
    LOW("低");

    private final String desc;

    TaskPriorityEnum(String desc) {
        this.desc = desc;
    }
}
