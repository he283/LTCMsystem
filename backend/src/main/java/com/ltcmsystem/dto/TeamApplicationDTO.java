package com.ltcmsystem.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TeamApplicationDTO {

    @NotBlank(message = "申请类型不能为空")
    private String applyType;

    private String applyReason;

    private String teamCode;

    private Long teamId;
}
