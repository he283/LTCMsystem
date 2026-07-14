package com.ltcmsystem.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.entity.TaskChangeLog;
import java.util.List;

public interface TaskChangeLogService extends IService<TaskChangeLog> {
    void logChange(Long taskId, String fieldName, String fieldLabel, String oldValue, String newValue, Long operatorId, String operatorName);
    List<TaskChangeLog> getTaskChangeLogs(Long taskId);
}
