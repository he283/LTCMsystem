package com.ltcmsystem.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ltcmsystem.entity.TeamMember;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface TeamMemberMapper extends BaseMapper<TeamMember> {

    @Delete("DELETE FROM team_member WHERE team_id = #{teamId} AND user_id = #{userId}")
    int physicalDeleteByTeamIdAndUserId(@Param("teamId") Long teamId, @Param("userId") Long userId);
}
