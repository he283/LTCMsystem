package com.ltcmsystem.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.dto.OperationLogQueryDTO;
import com.ltcmsystem.entity.OperationLog;
import com.ltcmsystem.vo.OperationLogVO;

public interface OperationLogService extends IService<OperationLog> {

    void logOperation(Long userId, String username, String nickname, String operationType,
                      String operationDesc, String module, Long targetId, String targetName,
                      String ipAddress, String userAgent);

    IPage<OperationLogVO> getOperationLogs(OperationLogQueryDTO queryDTO);
}
