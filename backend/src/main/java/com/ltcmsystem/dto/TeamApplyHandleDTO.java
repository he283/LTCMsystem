package com.ltcmsystem.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeamApplyHandleDTO {

    @NotBlank(message = "审批状态不能为空")
    private String status;

    private String handleRemark;
}
