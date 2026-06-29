package com.ltcmsystem.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;

@Data
public class TeamDTO {
    @NotBlank(message = "团队名称不能为空")
    private String name;

    private String description;
}
