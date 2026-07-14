package com.ltcmsystem.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.entity.TeamApplication;

public interface TeamApplicationService extends IService<TeamApplication> {
    TeamApplication applyJoin(String teamCode, String applyReason, Long userId);
    TeamApplication applyLeave(Long teamId, String applyReason, Long userId);
    IPage<TeamApplication> getApplications(Long teamId, String status, Integer pageNum, Integer pageSize, Long currentUserId);
    void handleApplication(Long id, String status, String handleRemark, Long handlerId);
}
