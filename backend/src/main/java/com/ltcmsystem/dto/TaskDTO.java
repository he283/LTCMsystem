package com.ltcmsystem.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

@Data
public class TaskDTO {
    @NotBlank(message = "任务标题不能为空")
    private String title;

    private String description;
    private String status;
    private String priority;
    private LocalDateTime dueDate;
    private Long assigneeId;
    private Long teamId;
}
