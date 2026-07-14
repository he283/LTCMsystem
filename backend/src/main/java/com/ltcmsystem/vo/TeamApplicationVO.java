package com.ltcmsystem.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class TeamApplicationVO {

    private Long id;
    private Long teamId;
    private String teamName;
    private String teamCode;
    private Long userId;
    private String username;
    private String nickname;
    private String applyType;
    private String status;
    private String applyReason;
    private Long handlerId;
    private String handlerName;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime handleTime;

    private String handleRemark;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
