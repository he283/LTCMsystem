package com.ltcmsystem.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ltcmsystem.entity.TeamUserRole;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface TeamUserRoleMapper extends BaseMapper<TeamUserRole> {

    @Delete("DELETE FROM team_user_role WHERE team_id = #{teamId} AND user_id = #{userId}")
    int physicalDeleteByTeamIdAndUserId(@Param("teamId") Long teamId, @Param("userId") Long userId);
}
