package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("team_user_role")
public class TeamUserRole extends BaseEntity {
    private Long teamId;
    private Long userId;
    private Long roleId;
}
