package com.ltcmsystem.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("operation_log")
public class OperationLog extends BaseEntity {

    private Long userId;
    private String username;
    private String nickname;
    private String operationType;
    private String operationDesc;
    private String module;
    private Long targetId;
    private String targetName;
    private String ipAddress;
    private String userAgent;
}
