package com.ltcmsystem.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.dto.TeamMemberDTO;
import com.ltcmsystem.entity.Team;
import java.util.List;

public interface TeamService extends IService<Team> {
    List<Team> getUserTeams(Long userId);
    Team createTeam(Team team, Long userId);
    void joinTeam(Long teamId, Long userId);
    void deleteTeam(Long teamId, Long userId);
    void inviteMember(Long teamId, String username, Long currentUserId);
    void removeMember(Long teamId, Long memberId, Long currentUserId);
    List<TeamMemberDTO> getTeamMembers(Long teamId);
    TeamMemberDTO getTeamMember(Long teamId, Long userId);
}
