package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.dto.OperationLogQueryDTO;
import com.ltcmsystem.entity.OperationLog;
import com.ltcmsystem.mapper.OperationLogMapper;
import com.ltcmsystem.service.OperationLogService;
import com.ltcmsystem.vo.OperationLogVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OperationLogServiceImpl extends ServiceImpl<OperationLogMapper, OperationLog> implements OperationLogService {

    @Override
    public void logOperation(Long userId, String username, String nickname, String operationType,
                             String operationDesc, String module, Long targetId, String targetName,
                             String ipAddress, String userAgent) {
        OperationLog log = new OperationLog();
        log.setUserId(userId);
        log.setUsername(username);
        log.setNickname(nickname);
        log.setOperationType(operationType);
        log.setOperationDesc(operationDesc);
        log.setModule(module);
        log.setTargetId(targetId);
        log.setTargetName(targetName);
        log.setIpAddress(ipAddress);
        log.setUserAgent(userAgent);
        save(log);
    }

    @Override
    public IPage<OperationLogVO> getOperationLogs(OperationLogQueryDTO queryDTO) {
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();

        if (queryDTO.getUserId() != null) {
            wrapper.eq(OperationLog::getUserId, queryDTO.getUserId());
        }
        if (queryDTO.getUsername() != null && !queryDTO.getUsername().isEmpty()) {
            wrapper.like(OperationLog::getUsername, queryDTO.getUsername());
        }
        if (queryDTO.getOperationType() != null && !queryDTO.getOperationType().isEmpty()) {
            wrapper.eq(OperationLog::getOperationType, queryDTO.getOperationType());
        }
        if (queryDTO.getModule() != null && !queryDTO.getModule().isEmpty()) {
            wrapper.eq(OperationLog::getModule, queryDTO.getModule());
        }
        if (queryDTO.getStartTime() != null) {
            wrapper.ge(OperationLog::getCreateTime, queryDTO.getStartTime());
        }
        if (queryDTO.getEndTime() != null) {
            wrapper.le(OperationLog::getCreateTime, queryDTO.getEndTime());
        }

        wrapper.orderByDesc(OperationLog::getCreateTime);

        Integer pageNum = queryDTO.getPageNum() != null ? queryDTO.getPageNum() : 1;
        Integer pageSize = queryDTO.getPageSize() != null ? queryDTO.getPageSize() : 10;

        Page<OperationLog> page = new Page<>(pageNum, pageSize);
        IPage<OperationLog> logPage = page(page, wrapper);

        List<OperationLog> logs = logPage.getRecords();
        List<OperationLogVO> voList = new ArrayList<>();

        for (OperationLog log : logs) {
            OperationLogVO vo = new OperationLogVO();
            BeanUtils.copyProperties(log, vo);
            voList.add(vo);
        }

        Page<OperationLogVO> resultPage = new Page<>(logPage.getCurrent(), logPage.getSize(), logPage.getTotal());
        resultPage.setRecords(voList);
        return resultPage;
    }
}
