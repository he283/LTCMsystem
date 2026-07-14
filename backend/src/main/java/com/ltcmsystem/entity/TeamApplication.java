package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("team_application")
public class TeamApplication extends BaseEntity {
    private Long teamId;
    private Long userId;
    private String applyType;
    private String status;
    private String applyReason;
    private Long handlerId;
    private String handlerName;
    private LocalDateTime handleTime;
    private String handleRemark;

    @TableField(exist = false)
    private String applicantName;

    @TableField(exist = false)
    private String teamName;
}
