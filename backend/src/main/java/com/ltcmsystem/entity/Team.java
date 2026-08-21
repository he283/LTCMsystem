package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("team")
public class Team extends BaseEntity {
    private String teamCode;
    private String name;
    private String description;
    private Long creatorId;

    @TableField(exist = false)
    private String creatorNickname;

    /** 当前登录用户在该团队的角色（ADMIN=管理 / MEMBER=成员，由 getUserTeams 填充） */
    @TableField(exist = false)
    private String role;
}
