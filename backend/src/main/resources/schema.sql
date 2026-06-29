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
  due_date TIMESTAMP,
  creator_id BIGINT NOT NULL,
  assignee_id BIGINT,
  team_id BIGINT,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted TINYINT DEFAULT 0
);

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

INSERT INTO task (title, description, status, priority, creator_id, assignee_id, team_id) VALUES
('完成需求分析', '完成项目需求分析文档', 'DONE', 'HIGH', 1, 1, 1),
('开发用户模块', '开发用户登录注册功能', 'IN_PROGRESS', 'HIGH', 1, 2, 1),
('编写测试用例', '编写系统测试用例', 'TODO', 'MEDIUM', 2, 3, 1),
('完成毕业设计', '完成毕业设计论文', 'IN_PROGRESS', 'HIGH', 2, 2, 2);
