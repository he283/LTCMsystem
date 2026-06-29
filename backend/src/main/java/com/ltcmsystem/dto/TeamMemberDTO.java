package com.ltcmsystem.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class TeamMemberDTO {
    private Long id;
    private Long userId;
    private String username;
    private String nickname;
    private String email;
    private String role;
    private LocalDateTime joinTime;
}
