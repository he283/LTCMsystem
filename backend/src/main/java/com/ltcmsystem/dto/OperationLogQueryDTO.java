package com.ltcmsystem.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class OperationLogQueryDTO {

    private Long userId;
    private String username;
    private String operationType;
    private String module;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
