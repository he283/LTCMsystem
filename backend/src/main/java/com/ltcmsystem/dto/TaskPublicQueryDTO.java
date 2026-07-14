package com.ltcmsystem.dto;

import lombok.Data;

@Data
public class TaskPublicQueryDTO {
    private String keyword;
    private String priority;
    private String status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
