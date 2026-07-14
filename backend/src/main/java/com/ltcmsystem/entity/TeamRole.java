package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("team_role")
public class TeamRole extends BaseEntity {
    private Long teamId;
    private String roleCode;
    private String roleName;
    private String description;
}
