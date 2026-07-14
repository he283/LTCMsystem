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
}
