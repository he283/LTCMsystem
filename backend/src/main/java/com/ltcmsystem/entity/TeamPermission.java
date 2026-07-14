package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("team_permission")
public class TeamPermission extends BaseEntity {
    private String permissionCode;
    private String permissionName;
    private String description;
}
