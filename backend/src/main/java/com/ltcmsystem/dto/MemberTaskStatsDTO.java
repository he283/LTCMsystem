package com.ltcmsystem.dto;

import lombok.Data;

@Data
public class MemberTaskStatsDTO {
    private Long userId;
    private String username;
    private String nickname;
    private int totalTasks;
    private int pendingAssignTasks;
    private int inProgressTasks;
    private int pendingReviewTasks;
    private int doneTasks;
    private int cancelledTasks;
    private double completionRate;
}
