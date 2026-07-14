package com.ltcmsystem.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.OperationLogQueryDTO;
import com.ltcmsystem.service.OperationLogService;
import com.ltcmsystem.vo.OperationLogVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/operation-logs")
@RequiredArgsConstructor
public class OperationLogController {

    private final OperationLogService operationLogService;

    @GetMapping
    public Result<IPage<OperationLogVO>> getOperationLogs(OperationLogQueryDTO queryDTO) {
        IPage<OperationLogVO> page = operationLogService.getOperationLogs(queryDTO);
        return Result.success(page);
    }
}
