package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("team_role_permission")
public class TeamRolePermission extends BaseEntity {
    private Long roleId;
    private Long permissionId;
}
