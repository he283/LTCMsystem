package com.ltcmsystem.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ltcmsystem.entity.Task;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface TaskMapper extends BaseMapper<Task> {
}
