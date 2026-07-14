package com.ltcmsystem.common;

import lombok.Getter;

@Getter
public enum TeamApplyStatusEnum {

    PENDING("待审批"),
    APPROVED("已通过"),
    REJECTED("已拒绝");

    private final String desc;

    TeamApplyStatusEnum(String desc) {
        this.desc = desc;
    }
}
