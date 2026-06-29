package com.ltcmsystem.dto;

import lombok.Data;

@Data
public class MemberTaskStatsDTO {
    private Long userId;
    private String username;
    private String nickname;
    private int totalTasks;
    private int todoTasks;
    private int inProgressTasks;
    private int doneTasks;
    private double completionRate;
}
