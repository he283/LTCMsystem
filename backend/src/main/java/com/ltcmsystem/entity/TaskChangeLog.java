package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("task_change_log")
public class TaskChangeLog extends BaseEntity {
    private Long taskId;
    private String fieldName;
    private String fieldLabel;
    private String oldValue;
    private String newValue;
    private Long operatorId;
    private String operatorName;
}
