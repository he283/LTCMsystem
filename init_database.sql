-- 创建数据库
CREATE DATABASE IF NOT EXISTS LTCMsystem DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE LTCMsystem;

-- 用户表
CREATE TABLE IF NOT EXISTS user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  nickname VARCHAR(50),
  email VARCHAR(100),
  avatar VARCHAR(255),
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0
);

-- 团队表
CREATE TABLE IF NOT EXISTS team (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(500),
  creator_id BIGINT NOT NULL,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0
);

-- 团队成员表
CREATE TABLE IF NOT EXISTS team_member (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  team_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  role VARCHAR(20) DEFAULT 'MEMBER',
  join_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0,
  UNIQUE (team_id, user_id)
);

-- 任务表
CREATE TABLE IF NOT EXISTS task (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'TODO',
  priority VARCHAR(20) DEFAULT 'MEDIUM',
  due_date TIMESTAMP NULL,
  creator_id BIGINT NOT NULL,
  assignee_id BIGINT,
  team_id BIGINT,
  is_public TINYINT DEFAULT 0,
  public_desc VARCHAR(500),
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0
);

-- 团队角色表
CREATE TABLE IF NOT EXISTS team_role (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  team_id BIGINT NOT NULL,
  role_code VARCHAR(50) NOT NULL,
  role_name VARCHAR(50) NOT NULL,
  description VARCHAR(200),
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0,
  UNIQUE (team_id, role_code)
);

-- 团队用户-角色关联表
CREATE TABLE IF NOT EXISTS team_user_role (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  team_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0,
  UNIQUE (team_id, user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 团队权限表
CREATE TABLE IF NOT EXISTS team_permission (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  permission_code VARCHAR(100) NOT NULL UNIQUE,
  permission_name VARCHAR(100) NOT NULL,
  description VARCHAR(200),
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 团队角色-权限关联表
CREATE TABLE IF NOT EXISTS team_role_permission (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  role_id BIGINT NOT NULL,
  permission_id BIGINT NOT NULL,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0,
  UNIQUE (role_id, permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入测试数据
-- 密码都是: 123456 (BCrypt加密)
INSERT INTO user (username, password, nickname, email) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '管理员', 'admin@example.com'),
('user1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '张三', 'zhangsan@example.com'),
('user2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '李四', 'lisi@example.com');

INSERT INTO team (name, description, creator_id) VALUES
('产品研发组', '负责产品研发工作', 1),
('学生项目组', '毕业设计项目组', 2);

INSERT INTO team_member (team_id, user_id, role) VALUES
(1, 1, 'ADMIN'),
(1, 2, 'MEMBER'),
(1, 3, 'MEMBER'),
(2, 2, 'ADMIN'),
(2, 3, 'MEMBER');

INSERT INTO task (title, description, status, priority, creator_id, assignee_id, team_id, is_public, public_desc) VALUES
('完成需求分析', '完成项目需求分析文档', 'DONE', 'HIGH', 1, 1, 1, 1, '产品研发组需求分析已完成，包含完整的功能规格说明书'),
('开发用户模块', '开发用户登录注册功能', 'IN_PROGRESS', 'HIGH', 1, 2, 1, 1, '用户认证模块开发中，支持JWT令牌认证'),
('编写测试用例', '编写系统测试用例', 'TODO', 'MEDIUM', 2, 3, 1, 0, NULL),
('完成毕业设计', '完成毕业设计论文', 'IN_PROGRESS', 'HIGH', 2, 2, 2, 0, NULL);

-- 预置团队权限
INSERT INTO team_permission (permission_code, permission_name, description) VALUES
('task:view', '查看任务', '查看团队任务列表和详情'),
('task:create', '创建任务', '在团队中创建新任务'),
('task:edit', '编辑任务', '编辑团队任务信息'),
('task:delete', '删除任务', '删除团队任务'),
('task:public', '设置公开', '设置任务是否公开到广场'),
('team:view', '查看团队', '查看团队信息和成员列表'),
('team:edit', '编辑团队', '编辑团队基本信息'),
('team:delete', '解散团队', '解散团队'),
('team:invite', '邀请成员', '邀请新成员加入团队'),
('team:remove', '移除成员', '移除团队成员'),
('team:role', '角色管理', '管理团队成员角色');

-- 预置团队角色（团队1：产品研发组）
INSERT INTO team_role (team_id, role_code, role_name, description) VALUES
(1, 'OWNER', '所有者', '团队所有者，拥有全部权限'),
(1, 'ADMIN', '管理员', '团队管理员，管理团队和任务'),
(1, 'MEMBER', '普通成员', '团队普通成员，参与任务协作'),
(1, 'GUEST', '访客', '团队访客，仅可查看');

-- 预置团队角色（团队2：学生项目组）
INSERT INTO team_role (team_id, role_code, role_name, description) VALUES
(2, 'OWNER', '所有者', '团队所有者，拥有全部权限'),
(2, 'ADMIN', '管理员', '团队管理员，管理团队和任务'),
(2, 'MEMBER', '普通成员', '团队普通成员，参与任务协作'),
(2, 'GUEST', '访客', '团队访客，仅可查看');

-- 角色-权限关联（所有者：全部权限）
INSERT INTO team_role_permission (role_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11),
(5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8), (5, 9), (5, 10), (5, 11);

-- 角色-权限关联（管理员：除解散团队外的所有权限）
INSERT INTO team_role_permission (role_id, permission_id) VALUES
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 9), (2, 10), (2, 11),
(6, 1), (6, 2), (6, 3), (6, 4), (6, 5), (6, 6), (6, 7), (6, 9), (6, 10), (6, 11);

-- 角色-权限关联（普通成员：查看和创建编辑任务）
INSERT INTO team_role_permission (role_id, permission_id) VALUES
(3, 1), (3, 2), (3, 3), (3, 6),
(7, 1), (7, 2), (7, 3), (7, 6);

-- 角色-权限关联（访客：仅查看）
INSERT INTO team_role_permission (role_id, permission_id) VALUES
(4, 1), (4, 6),
(8, 1), (8, 6);

-- 用户-角色关联
-- 团队1：admin是所有者，user1是管理员，user2是普通成员
INSERT INTO team_user_role (team_id, user_id, role_id) VALUES
(1, 1, 1),
(1, 2, 2),
(1, 3, 3),
-- 团队2：user1是所有者，user2是普通成员
(2, 2, 5),
(2, 3, 7);
