package com.ltcmsystem.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class TaskChangeLogVO {

    private Long id;
    private Long taskId;
    private String fieldName;
    private String fieldLabel;
    private String oldValue;
    private String newValue;
    private Long operatorId;
    private String operatorName;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
