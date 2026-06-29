package com.ltcmsystem.controller;

import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.InviteMemberDTO;
import com.ltcmsystem.dto.TeamDTO;
import com.ltcmsystem.dto.TeamMemberDTO;
import com.ltcmsystem.entity.Team;
import com.ltcmsystem.service.TeamService;
import com.ltcmsystem.util.UserContext;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/teams")
public class TeamController {

    private final TeamService teamService;

    public TeamController(TeamService teamService) {
        this.teamService = teamService;
    }

    @GetMapping("/my")
    public Result<List<Team>> getMyTeams() {
        Long userId = UserContext.getUserId();
        List<Team> teams = teamService.getUserTeams(userId);
        return Result.success(teams);
    }

    @PostMapping
    public Result<Team> createTeam(@Valid @RequestBody TeamDTO teamDTO) {
        Long userId = UserContext.getUserId();
        Team team = new Team();
        team.setName(teamDTO.getName());
        team.setDescription(teamDTO.getDescription());
        Team created = teamService.createTeam(team, userId);
        return Result.success(created);
    }

    @PostMapping("/{teamId}/join")
    public Result<Void> joinTeam(@PathVariable Long teamId) {
        Long userId = UserContext.getUserId();
        teamService.joinTeam(teamId, userId);
        return Result.success();
    }

    @DeleteMapping("/{teamId}")
    public Result<Void> deleteTeam(@PathVariable Long teamId) {
        Long userId = UserContext.getUserId();
        teamService.deleteTeam(teamId, userId);
        return Result.success();
    }

    @PostMapping("/{teamId}/invite")
    public Result<Void> inviteMember(@PathVariable Long teamId, @Valid @RequestBody InviteMemberDTO inviteDTO) {
        Long userId = UserContext.getUserId();
        teamService.inviteMember(teamId, inviteDTO.getUsername(), userId);
        return Result.success();
    }

    @DeleteMapping("/{teamId}/members/{memberId}")
    public Result<Void> removeMember(@PathVariable Long teamId, @PathVariable Long memberId) {
        Long userId = UserContext.getUserId();
        teamService.removeMember(teamId, memberId, userId);
        return Result.success();
    }

    @GetMapping("/{teamId}/members")
    public Result<List<TeamMemberDTO>> getTeamMembers(@PathVariable Long teamId) {
        List<TeamMemberDTO> members = teamService.getTeamMembers(teamId);
        return Result.success(members);
    }

    @GetMapping("/{teamId}/members/me")
    public Result<TeamMemberDTO> getMyTeamRole(@PathVariable Long teamId) {
        Long userId = UserContext.getUserId();
        TeamMemberDTO member = teamService.getTeamMember(teamId, userId);
        return Result.success(member);
    }
}
