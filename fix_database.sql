-- 修复数据库缺失的字段
USE LTCMsystem;

-- 给 team_member 表添加缺失的字段
ALTER TABLE team_member 
ADD COLUMN IF NOT EXISTS create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 验证字段是否添加成功
DESCRIBE team_member;
