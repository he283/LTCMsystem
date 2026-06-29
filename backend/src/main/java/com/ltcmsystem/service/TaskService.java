package com.ltcmsystem.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.dto.MemberTaskStatsDTO;
import com.ltcmsystem.entity.Task;
import java.util.List;

public interface TaskService extends IService<Task> {
    List<Task> getUserTasks(Long userId);
    List<Task> getTeamTasks(Long teamId);
    Task createTask(Task task);
    Task updateTask(Long id, Task task);
    void deleteTask(Long id);
    List<MemberTaskStatsDTO> getTeamMemberStats(Long teamId);
}
