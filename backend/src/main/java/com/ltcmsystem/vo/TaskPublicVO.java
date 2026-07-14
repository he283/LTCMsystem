package com.ltcmsystem.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class TaskPublicVO {
    private Long id;
    private String taskCode;
    private String title;
    private String publicDesc;
    private String teamName;
    private String teamCode;
    private String priority;
    private String status;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime dueDate;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
