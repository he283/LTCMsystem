package com.ltcmsystem.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class OperationLogVO {

    private Long id;
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

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
