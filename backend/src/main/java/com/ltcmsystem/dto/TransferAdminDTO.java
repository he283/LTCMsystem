package com.ltcmsystem.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TransferAdminDTO {

    @NotNull(message = "新管理员ID不能为空")
    private Long newAdminId;
}
