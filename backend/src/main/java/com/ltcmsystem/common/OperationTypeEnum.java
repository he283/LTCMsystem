package com.ltcmsystem.common;

import lombok.Getter;

@Getter
public enum OperationTypeEnum {

    LOGIN("登录"),
    LOGOUT("登出"),
    TASK_CREATE("任务新增"),
    TASK_UPDATE("任务修改"),
    TASK_DELETE("任务删除"),
    TEAM_CREATE("团队新增"),
    TEAM_UPDATE("团队修改"),
    TEAM_DELETE("团队删除"),
    TEAM_JOIN("加入团队"),
    TEAM_LEAVE("退出团队"),
    TEAM_INVITE("邀请成员"),
    TEAM_REMOVE_MEMBER("移除成员");

    private final String desc;

    OperationTypeEnum(String desc) {
        this.desc = desc;
    }
}
