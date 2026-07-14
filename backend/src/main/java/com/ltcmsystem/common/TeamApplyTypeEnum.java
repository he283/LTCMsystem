package com.ltcmsystem.common;

import lombok.Getter;

@Getter
public enum TeamApplyTypeEnum {

    JOIN("加入申请"),
    LEAVE("退出申请");

    private final String desc;

    TeamApplyTypeEnum(String desc) {
        this.desc = desc;
    }
}
