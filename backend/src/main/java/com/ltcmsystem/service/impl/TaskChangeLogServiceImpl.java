package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.entity.TaskChangeLog;
import com.ltcmsystem.mapper.TaskChangeLogMapper;
import com.ltcmsystem.service.TaskChangeLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskChangeLogServiceImpl extends ServiceImpl<TaskChangeLogMapper, TaskChangeLog> implements TaskChangeLogService {

    private final TaskChangeLogMapper taskChangeLogMapper;

    @Override
    public void logChange(Long taskId, String fieldName, String fieldLabel, String oldValue, String newValue, Long operatorId, String operatorName) {
        TaskChangeLog log = new TaskChangeLog();
        log.setTaskId(taskId);
        log.setFieldName(fieldName);
        log.setFieldLabel(fieldLabel);
        log.setOldValue(oldValue);
        log.setNewValue(newValue);
        log.setOperatorId(operatorId);
        log.setOperatorName(operatorName);
        save(log);
    }

    @Override
    public List<TaskChangeLog> getTaskChangeLogs(Long taskId) {
        LambdaQueryWrapper<TaskChangeLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TaskChangeLog::getTaskId, taskId)
               .orderByAsc(TaskChangeLog::getCreateTime);
        return list(wrapper);
    }
}
