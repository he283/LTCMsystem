package com.ltcmsystem.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.InviteMemberDTO;
import com.ltcmsystem.dto.TeamApplicationDTO;
import com.ltcmsystem.dto.TeamApplyHandleDTO;
import com.ltcmsystem.dto.TeamDTO;
import com.ltcmsystem.dto.TeamMemberDTO;
import com.ltcmsystem.entity.Team;
import com.ltcmsystem.entity.TeamApplication;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.TeamApplicationService;
import com.ltcmsystem.service.TeamService;
import com.ltcmsystem.util.UserContext;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/teams")
@RequiredArgsConstructor
public class TeamController {

    private final TeamService teamService;
    private final TeamApplicationService teamApplicationService;
    private final UserMapper userMapper;

    @GetMapping("/my")
    public Result<List<Team>> getMyTeams() {
        Long userId = UserContext.getUserId();
        List<Team> teams = teamService.getUserTeams(userId);
        fillCreatorNickname(teams);
        return Result.success(teams);
    }

    private void fillCreatorNickname(List<Team> teams) {
        if (teams == null || teams.isEmpty()) return;
        List<Long> creatorIds = teams.stream()
                .map(Team::getCreatorId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        if (creatorIds.isEmpty()) return;
        List<User> users = userMapper.selectBatchIds(creatorIds);
        Map<Long, String> nicknameMap = users.stream()
                .collect(Collectors.toMap(User::getId, u -> u.getNickname() != null ? u.getNickname() : u.getUsername()));
        for (Team team : teams) {
            if (team.getCreatorId() != null) {
                team.setCreatorNickname(nicknameMap.get(team.getCreatorId()));
            }
        }
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

    @PostMapping("/apply")
    public Result<TeamApplication> applyJoin(@Valid @RequestBody TeamApplicationDTO applyDTO) {
        Long userId = UserContext.getUserId();
        TeamApplication application = teamApplicationService.applyJoin(applyDTO.getTeamCode(), applyDTO.getApplyReason(), userId);
        return Result.success(application);
    }

    @PostMapping("/leave-apply")
    public Result<TeamApplication> applyLeave(@RequestBody TeamApplicationDTO applyDTO) {
        Long userId = UserContext.getUserId();
        TeamApplication application = teamApplicationService.applyLeave(applyDTO.getTeamId(), applyDTO.getApplyReason(), userId);
        return Result.success(application);
    }

    @GetMapping("/applications")
    public Result<IPage<TeamApplication>> getApplications(
            @RequestParam Long teamId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        Long userId = UserContext.getUserId();
        IPage<TeamApplication> page = teamApplicationService.getApplications(teamId, status, pageNum, pageSize, userId);
        return Result.success(page);
    }

    @PutMapping("/applications/{id}/handle")
    public Result<Void> handleApplication(@PathVariable Long id, @Valid @RequestBody TeamApplyHandleDTO handleDTO) {
        Long userId = UserContext.getUserId();
        teamApplicationService.handleApplication(id, handleDTO.getStatus(), handleDTO.getHandleRemark(), userId);
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
