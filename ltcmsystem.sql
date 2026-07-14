/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80040 (8.0.40)
 Source Host           : localhost:3306
 Source Schema         : ltcmsystem

 Target Server Type    : MySQL
 Target Server Version : 80040 (8.0.40)
 File Encoding         : 65001

 Date: 12/07/2026 23:11:35
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '接收人ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知类型：SYSTEM/TASK/TEAM_APPLY/TEAM_APPROVE',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '通知内容',
  `related_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联类型：TASK/TEAM/APPLICATION',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联ID',
  `is_read` tinyint NULL DEFAULT 0 COMMENT '是否已读：0-否，1-是',
  `read_time` timestamp NULL DEFAULT NULL COMMENT '读取时间',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_read`(`user_id` ASC, `is_read` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消息通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, 12, 'TEAM_JOIN_REJECTED', '加入申请被拒绝', '您加入团队「产品研发组」的申请被拒绝，原因：无', 'TEAM', 1, 1, '2026-07-12 17:32:43', '2026-07-12 17:32:33', '2026-07-12 17:32:33', 0);
INSERT INTO `notification` VALUES (2, 1, 'TEAM_APPLY', '新的加入申请', '有用户申请加入团队「产品研发组」，请及时处理', 'APPLICATION', 2, 1, '2026-07-12 17:33:44', '2026-07-12 17:33:36', '2026-07-12 20:14:02', 1);
INSERT INTO `notification` VALUES (3, 1, 'TEAM_APPLY', '新的加入申请', '有用户申请加入团队「产品研发组」，请及时处理', 'APPLICATION', 3, 1, '2026-07-12 17:36:08', '2026-07-12 17:34:44', '2026-07-12 20:14:02', 1);
INSERT INTO `notification` VALUES (4, 13, 'TEAM_APPROVE', '加入申请已通过', '您加入团队「产品研发组」的申请已通过', 'TEAM', 1, 1, '2026-07-12 17:35:36', '2026-07-12 17:35:14', '2026-07-12 20:38:26', 1);
INSERT INTO `notification` VALUES (5, 12, 'TEAM_APPROVE', '加入申请已通过', '您加入团队「产品研发组」的申请已通过', 'TEAM', 1, 1, '2026-07-12 19:17:10', '2026-07-12 19:14:15', '2026-07-12 19:14:15', 0);
INSERT INTO `notification` VALUES (6, 1, 'TEAM_APPLY', '新的退出申请', '有成员申请退出团队「产品研发组」，请及时处理', 'APPLICATION', 4, 1, '2026-07-12 19:16:23', '2026-07-12 19:15:13', '2026-07-12 20:14:02', 1);
INSERT INTO `notification` VALUES (7, 13, 'TEAM_LEAVE_APPROVED', '退出申请已通过', '您退出团队「产品研发组」的申请已通过', 'TEAM', 1, 0, NULL, '2026-07-12 19:15:34', '2026-07-12 20:38:26', 1);
INSERT INTO `notification` VALUES (8, 1, 'TEAM_APPLY', '新的加入申请', '有用户申请加入团队「产品研发组」，请及时处理', 'APPLICATION', 5, 1, '2026-07-12 19:17:38', '2026-07-12 19:17:31', '2026-07-12 20:14:02', 1);
INSERT INTO `notification` VALUES (9, 12, 'TEAM_APPROVE', '加入申请已通过', '您加入团队「产品研发组」的申请已通过', 'TEAM', 1, 1, '2026-07-12 20:31:44', '2026-07-12 19:17:55', '2026-07-12 20:31:44', 0);

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人账号',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人昵称',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型：LOGIN/LOGOUT/TASK_CREATE/TASK_UPDATE/TASK_DELETE/TEAM_CREATE/TEAM_UPDATE/TEAM_DELETE/TEAM_JOIN/TEAM_LEAVE',
  `operation_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作描述',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作模块：USER/TASK/TEAM',
  `target_id` bigint NULL DEFAULT NULL COMMENT '操作目标ID',
  `target_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作目标名称',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户代理',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `idx_module`(`module` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '全局操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES (1, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 12, '开发任务模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:39:44', '2026-07-12 16:39:44', 0);
INSERT INTO `operation_log` VALUES (2, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 2, '开发用户模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:40:37', '2026-07-12 16:40:37', 0);
INSERT INTO `operation_log` VALUES (3, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 12, '开发任务模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:41:36', '2026-07-12 16:41:36', 0);
INSERT INTO `operation_log` VALUES (4, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 2, '开发用户模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:42:33', '2026-07-12 16:42:33', 0);
INSERT INTO `operation_log` VALUES (5, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 5, '任务总结', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:43:31', '2026-07-12 16:43:31', 0);
INSERT INTO `operation_log` VALUES (6, 6, 'huang', '黄', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 16:45:41', '2026-07-12 16:45:41', 0);
INSERT INTO `operation_log` VALUES (7, 6, 'huang', '黄', 'TASK_UPDATE', '任务修改', 'task', 12, '开发任务模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 16:46:39', '2026-07-12 16:46:39', 0);
INSERT INTO `operation_log` VALUES (8, 6, 'huang', '黄', 'TASK_UPDATE', '任务修改', 'task', 12, '开发任务模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 16:47:52', '2026-07-12 16:47:52', 0);
INSERT INTO `operation_log` VALUES (9, 1, 'admin', '管理员', 'TEAM_REMOVE_MEMBER', '移除成员: wanwan', 'team', 1, '产品研发组', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:49:10', '2026-07-12 16:49:10', 0);
INSERT INTO `operation_log` VALUES (10, 12, 'wanwan', '晚晚', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 16:49:23', '2026-07-12 16:49:23', 0);
INSERT INTO `operation_log` VALUES (11, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 13, '编写团队模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:53:28', '2026-07-12 16:53:28', 0);
INSERT INTO `operation_log` VALUES (12, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 2, '开发用户模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:53:55', '2026-07-12 16:53:55', 0);
INSERT INTO `operation_log` VALUES (13, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 2, '开发用户模块', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 16:55:02', '2026-07-12 16:55:02', 0);
INSERT INTO `operation_log` VALUES (14, 13, 'xiaotiantian', '', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 17:34:29', '2026-07-12 17:34:29', 0);
INSERT INTO `operation_log` VALUES (15, 1, 'admin', '管理员', 'TEAM_REMOVE_MEMBER', '移除成员: wanwan', 'team', 1, '产品研发组', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 19:16:17', '2026-07-12 19:16:17', 0);
INSERT INTO `operation_log` VALUES (16, 12, 'wanwan', '晚晚', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 19:17:06', '2026-07-12 19:17:06', 0);
INSERT INTO `operation_log` VALUES (17, 13, 'xiaotiantian', '小甜甜', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 20:38:22', '2026-07-12 20:38:22', 0);
INSERT INTO `operation_log` VALUES (18, 6, 'huang', '黄', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 20:46:40', '2026-07-12 20:46:40', 0);
INSERT INTO `operation_log` VALUES (19, 1, 'admin', '管理员', 'TASK_UPDATE', '任务修改', 'task', 15, '位置预定', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0', '2026-07-12 20:48:28', '2026-07-12 20:48:28', 0);
INSERT INTO `operation_log` VALUES (20, 6, 'huang', '黄', 'TEAM_INVITE', '邀请成员: wanwan', 'team', 6, '制作国宴', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 20:49:18', '2026-07-12 20:49:18', 0);
INSERT INTO `operation_log` VALUES (21, 6, 'huang', '黄', 'TASK_CREATE', '任务新增', 'task', 16, '购买食材', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-07-12 20:51:13', '2026-07-12 20:51:13', 0);

-- ----------------------------
-- Table structure for task
-- ----------------------------
DROP TABLE IF EXISTS `task`;
CREATE TABLE `task`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'TODO',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'MEDIUM',
  `due_date` timestamp NULL DEFAULT NULL,
  `creator_id` bigint NOT NULL,
  `assignee_id` bigint NULL DEFAULT NULL,
  `team_id` bigint NULL DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  `is_public` tinyint NULL DEFAULT 0 COMMENT '是否公开',
  `public_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '对外公开简介',
  `task_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务唯一编号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_task_code`(`task_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task
-- ----------------------------
INSERT INTO `task` VALUES (1, '完成需求分析', '完成项目需求分析文档', 'DONE', 'HIGH', '2026-06-11 00:00:00', 1, 1, 1, '2026-05-22 19:55:51', '2026-05-23 20:30:32', 0, 1, '产品研发组需求分析已完成，包含完整的功能规格说明书', 'TK000001CD66');
INSERT INTO `task` VALUES (2, '开发用户模块', '开发用户登录注册功能', 'DONE', 'HIGH', '2026-05-26 00:00:00', 1, 3, 1, '2026-05-22 19:55:51', '2026-07-12 16:55:02', 0, 1, '用户认证模块开发中，支持JWT令牌认证', 'TK000002EBDD');
INSERT INTO `task` VALUES (3, '编写测试用例', '编写系统测试用例', 'DONE', 'HIGH', '2026-05-29 00:00:00', 2, 3, 1, '2026-05-22 19:55:51', '2026-05-30 20:50:10', 0, 0, NULL, 'TK0000030EA3');
INSERT INTO `task` VALUES (5, '任务总结', '任务总结', 'CANCELLED', 'HIGH', '2026-05-29 00:00:00', 1, NULL, NULL, '2026-05-23 20:10:08', '2026-07-12 16:43:31', 0, 0, NULL, 'TK000005BB7B');
INSERT INTO `task` VALUES (10, '提交作品', '暂无描述', 'DONE', 'MEDIUM', '2026-05-13 00:00:00', 1, 11, 1, '2026-05-30 19:30:49', '2026-07-12 14:03:57', 0, 1, '这是一个伟大的作品', 'TK000010C57B');
INSERT INTO `task` VALUES (12, '开发任务模块', '根据需求完成任务', 'PENDING_REVIEW', 'LOW', '2026-07-24 00:00:00', 1, 6, 1, '2026-06-06 21:57:55', '2026-07-12 16:47:52', 0, 1, '测试', 'TK0000120763');
INSERT INTO `task` VALUES (13, '编写团队模块', '', 'DONE', 'LOW', '2026-06-18 00:00:00', 1, 6, 1, '2026-06-06 22:00:48', '2026-07-12 16:53:28', 0, 0, NULL, 'TK0000138C0C');
INSERT INTO `task` VALUES (14, '产品销售', '把产品推给他人', 'IN_PROGRESS', 'LOW', '2026-07-16 00:00:00', 1, 1, 1, '2026-07-12 13:49:52', '2026-07-12 13:49:52', 0, 1, '测试能否推到广场', 'TK000014DD01');
INSERT INTO `task` VALUES (15, '位置预定', '预定国宴开设地点', 'IN_PROGRESS', 'HIGH', '2026-07-23 00:00:00', 6, 1, 6, '2026-07-12 14:22:25', '2026-07-12 20:48:28', 0, 1, '寻找酒店地点', 'TK000015E995');
INSERT INTO `task` VALUES (16, '购买食材', '买东西', 'PENDING_REVIEW', 'MEDIUM', '2026-07-31 00:00:00', 6, 12, 6, '2026-07-12 20:51:13', '2026-07-12 20:51:13', 0, 1, '国宴通常以冷盘开场，如“五香牛肉”、“水晶虾仁”、“清蒸鲈鱼”等，这些菜品刀工精细，造型美观，寓意吉祥。 冷盘之后是汤品，如“清汤燕菜”或“竹荪鸽蛋汤”，汤清味醇，尽显中餐汤品之精妙。 主菜方面，国宴常选用“ 北京烤鸭 ”、“ 东坡肉 ”、“宫保鸡丁”等经典名菜，但会进行改良以降低油腻感。 此外，“开水白菜”看似朴素，实则以顶级清汤为底，是川菜中的国宴级代表。', 'TK000016D260');

-- ----------------------------
-- Table structure for task_change_log
-- ----------------------------
DROP TABLE IF EXISTS `task_change_log`;
CREATE TABLE `task_change_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL,
  `field_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '变更字段名',
  `field_label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '变更字段显示名',
  `old_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '变更前值',
  `new_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '变更后值',
  `operator_id` bigint NOT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人名称',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_operator_id`(`operator_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务变更历史表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task_change_log
-- ----------------------------
INSERT INTO `task_change_log` VALUES (1, 2, 'status', '状态', 'IN_PROGRESS', 'PENDING_REVIEW', 1, '管理员', '2026-07-12 16:40:37', '2026-07-12 16:40:37', 0);
INSERT INTO `task_change_log` VALUES (2, 2, 'status', '状态', 'PENDING_REVIEW', 'DONE', 1, '管理员', '2026-07-12 16:42:33', '2026-07-12 16:42:33', 0);
INSERT INTO `task_change_log` VALUES (3, 5, 'status', '状态', 'PENDING_ASSIGN', 'CANCELLED', 1, '管理员', '2026-07-12 16:43:31', '2026-07-12 16:43:31', 0);
INSERT INTO `task_change_log` VALUES (4, 12, 'status', '状态', 'PENDING_ASSIGN', 'IN_PROGRESS', 6, '黄', '2026-07-12 16:46:39', '2026-07-12 16:46:39', 0);
INSERT INTO `task_change_log` VALUES (5, 12, 'status', '状态', 'IN_PROGRESS', 'PENDING_REVIEW', 6, '黄', '2026-07-12 16:47:52', '2026-07-12 16:47:52', 0);
INSERT INTO `task_change_log` VALUES (6, 13, 'priority', '优先级', 'MEDIUM', 'LOW', 1, '管理员', '2026-07-12 16:53:28', '2026-07-12 16:53:28', 0);
INSERT INTO `task_change_log` VALUES (7, 2, 'assigneeId', '负责人', '张三', '李四', 1, '管理员', '2026-07-12 16:53:55', '2026-07-12 16:53:55', 0);
INSERT INTO `task_change_log` VALUES (8, 2, 'dueDate', '截止日期', '2026-05-25 00:00:00', '2026-05-26 00:00:00', 1, '管理员', '2026-07-12 16:55:02', '2026-07-12 16:55:02', 0);
INSERT INTO `task_change_log` VALUES (9, 15, 'status', '状态', 'PENDING_ASSIGN', 'IN_PROGRESS', 1, '管理员', '2026-07-12 20:48:28', '2026-07-12 20:48:28', 0);
INSERT INTO `task_change_log` VALUES (10, 15, 'priority', '优先级', 'MEDIUM', 'HIGH', 1, '管理员', '2026-07-12 20:48:28', '2026-07-12 20:48:28', 0);
INSERT INTO `task_change_log` VALUES (11, 15, 'assigneeId', '负责人', '黄', '管理员', 1, '管理员', '2026-07-12 20:48:28', '2026-07-12 20:48:28', 0);
INSERT INTO `task_change_log` VALUES (12, 16, 'CREATE', '创建任务', NULL, '创建任务', 6, '黄', '2026-07-12 20:51:13', '2026-07-12 20:51:13', 0);

-- ----------------------------
-- Table structure for task_comment
-- ----------------------------
DROP TABLE IF EXISTS `task_comment`;
CREATE TABLE `task_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task_comment
-- ----------------------------
INSERT INTO `task_comment` VALUES (1, 15, 1, '这是我能看的吗', '2026-07-12 20:30:41', '2026-07-12 20:30:41', 0);
INSERT INTO `task_comment` VALUES (2, 2, 1, '来个尼格', '2026-07-12 20:33:17', '2026-07-12 20:33:17', 0);
INSERT INTO `task_comment` VALUES (3, 15, 6, '管理员来给我炒两个菜', '2026-07-12 20:47:08', '2026-07-12 20:47:08', 0);
INSERT INTO `task_comment` VALUES (4, 16, 1, '给我来两斤米酒', '2026-07-12 20:52:17', '2026-07-12 20:52:17', 0);
INSERT INTO `task_comment` VALUES (5, 16, 6, '没钱咋办', '2026-07-12 20:54:49', '2026-07-12 20:54:49', 0);

-- ----------------------------
-- Table structure for team
-- ----------------------------
DROP TABLE IF EXISTS `team`;
CREATE TABLE `team`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `creator_id` bigint NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  `team_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '团队唯一编号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_team_code`(`team_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team
-- ----------------------------
INSERT INTO `team` VALUES (1, '产品研发组', '负责产品研发工作', 1, '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0, 'T0000016949');
INSERT INTO `team` VALUES (6, '制作国宴', '这是一支制作国宴的团队', 6, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0, 'T000006C6A2');

-- ----------------------------
-- Table structure for team_application
-- ----------------------------
DROP TABLE IF EXISTS `team_application`;
CREATE TABLE `team_application`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `team_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `apply_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请类型：JOIN/LEAVE',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING' COMMENT '状态：PENDING/APPROVED/REJECTED',
  `apply_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '申请理由',
  `handler_id` bigint NULL DEFAULT NULL COMMENT '处理人ID',
  `handler_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理人名称',
  `handle_time` timestamp NULL DEFAULT NULL COMMENT '处理时间',
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理备注',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_team_id`(`team_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_team_user_apply`(`team_id` ASC, `user_id` ASC, `apply_type` ASC, `status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '团队加入退出申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team_application
-- ----------------------------
INSERT INTO `team_application` VALUES (1, 1, 12, 'JOIN', 'REJECTED', NULL, 1, NULL, '2026-07-12 17:32:33', NULL, '2026-07-12 17:14:11', '2026-07-12 17:14:11', 0);
INSERT INTO `team_application` VALUES (2, 1, 12, 'JOIN', 'APPROVED', NULL, 1, NULL, '2026-07-12 19:14:15', NULL, '2026-07-12 17:33:36', '2026-07-12 17:33:36', 0);
INSERT INTO `team_application` VALUES (3, 1, 13, 'JOIN', 'APPROVED', NULL, 1, NULL, '2026-07-12 17:35:14', NULL, '2026-07-12 17:34:44', '2026-07-12 17:34:44', 0);
INSERT INTO `team_application` VALUES (4, 1, 13, 'LEAVE', 'APPROVED', '不想干了', 1, NULL, '2026-07-12 19:15:34', NULL, '2026-07-12 19:15:13', '2026-07-12 19:15:13', 0);
INSERT INTO `team_application` VALUES (5, 1, 12, 'JOIN', 'APPROVED', NULL, 1, NULL, '2026-07-12 19:17:54', NULL, '2026-07-12 19:17:31', '2026-07-12 19:17:31', 0);

-- ----------------------------
-- Table structure for team_member
-- ----------------------------
DROP TABLE IF EXISTS `team_member`;
CREATE TABLE `team_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `team_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'MEMBER',
  `join_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `team_id`(`team_id` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team_member
-- ----------------------------
INSERT INTO `team_member` VALUES (1, 1, 1, 'ADMIN', '2026-05-22 19:55:51', 0, '2026-05-23 20:15:35', '2026-05-23 20:15:35');
INSERT INTO `team_member` VALUES (2, 1, 2, 'MEMBER', '2026-05-22 19:55:51', 0, '2026-05-23 20:15:35', '2026-05-23 20:15:35');
INSERT INTO `team_member` VALUES (3, 1, 3, 'MEMBER', '2026-05-22 19:55:51', 0, '2026-05-23 20:15:35', '2026-05-23 20:15:35');
INSERT INTO `team_member` VALUES (9, 1, 6, 'MEMBER', '2026-05-30 18:26:48', 0, '2026-05-30 18:26:49', '2026-05-30 18:26:49');
INSERT INTO `team_member` VALUES (16, 1, 11, 'MEMBER', '2026-06-06 21:52:38', 0, '2026-06-06 21:52:39', '2026-06-06 21:52:39');
INSERT INTO `team_member` VALUES (19, 6, 6, 'ADMIN', '2026-07-12 14:20:35', 0, '2026-07-12 14:20:36', '2026-07-12 14:20:36');
INSERT INTO `team_member` VALUES (20, 6, 1, 'MEMBER', '2026-07-12 14:20:53', 0, '2026-07-12 14:20:54', '2026-07-12 14:20:54');
INSERT INTO `team_member` VALUES (33, 1, 12, 'MEMBER', '2026-07-12 19:17:54', 0, '2026-07-12 19:17:54', '2026-07-12 19:17:54');
INSERT INTO `team_member` VALUES (34, 6, 12, 'MEMBER', '2026-07-12 20:49:17', 0, '2026-07-12 20:49:18', '2026-07-12 20:49:18');

-- ----------------------------
-- Table structure for team_permission
-- ----------------------------
DROP TABLE IF EXISTS `team_permission`;
CREATE TABLE `team_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `permission_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `permission_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permission_code`(`permission_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team_permission
-- ----------------------------
INSERT INTO `team_permission` VALUES (1, 'task:view', '查看任务', '查看团队任务列表和详情', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (2, 'task:create', '创建任务', '在团队中创建新任务', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (3, 'task:edit', '编辑任务', '编辑团队任务信息', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (4, 'task:delete', '删除任务', '删除团队任务', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (5, 'task:public', '设置公开', '设置任务是否公开到广场', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (6, 'team:view', '查看团队', '查看团队信息和成员列表', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (7, 'team:edit', '编辑团队', '编辑团队基本信息', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (8, 'team:delete', '解散团队', '解散团队', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (9, 'team:invite', '邀请成员', '邀请新成员加入团队', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (10, 'team:remove', '移除成员', '移除团队成员', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);
INSERT INTO `team_permission` VALUES (11, 'team:role', '角色管理', '管理团队成员角色', '2026-07-12 00:15:13', '2026-07-12 00:32:31', 0);

-- ----------------------------
-- Table structure for team_role
-- ----------------------------
DROP TABLE IF EXISTS `team_role`;
CREATE TABLE `team_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `team_id` bigint NOT NULL,
  `role_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_team_role`(`team_id` ASC, `role_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team_role
-- ----------------------------
INSERT INTO `team_role` VALUES (1, 1, 'OWNER', '所有者', '团队所有者，拥有全部权限', '2026-07-12 00:15:13', '2026-07-12 00:15:13', 0);
INSERT INTO `team_role` VALUES (2, 1, 'ADMIN', '管理员', '团队管理员，管理团队和任务', '2026-07-12 00:15:13', '2026-07-12 00:15:13', 0);
INSERT INTO `team_role` VALUES (3, 1, 'MEMBER', '普通成员', '团队普通成员，参与任务协作', '2026-07-12 00:15:13', '2026-07-12 00:15:13', 0);
INSERT INTO `team_role` VALUES (4, 1, 'GUEST', '访客', '团队访客，仅可查看', '2026-07-12 00:15:13', '2026-07-12 00:15:13', 0);
INSERT INTO `team_role` VALUES (21, 6, 'OWNER', '所有者', '团队所有者，拥有全部权限', '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role` VALUES (22, 6, 'ADMIN', '管理员', '团队管理员，管理团队和任务', '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role` VALUES (23, 6, 'MEMBER', '普通成员', '团队普通成员，参与任务协作', '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role` VALUES (24, 6, 'GUEST', '访客', '团队访客，仅可查看', '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);

-- ----------------------------
-- Table structure for team_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `team_role_permission`;
CREATE TABLE `team_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `permission_id` bigint NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_permission`(`role_id` ASC, `permission_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 284 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team_role_permission
-- ----------------------------
INSERT INTO `team_role_permission` VALUES (85, 10, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (86, 9, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (87, 5, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (88, 1, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (89, 10, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (90, 9, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (91, 5, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (92, 1, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (93, 10, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (94, 9, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (95, 5, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (96, 1, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (97, 10, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (98, 9, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (99, 5, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (100, 1, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (101, 10, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (102, 9, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (103, 5, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (104, 1, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (105, 10, 8, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (106, 9, 8, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (107, 5, 8, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (108, 1, 8, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (109, 10, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (110, 9, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (111, 5, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (112, 1, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (113, 10, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (114, 9, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (115, 5, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (116, 1, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (117, 10, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (118, 9, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (119, 5, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (120, 1, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (121, 10, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (122, 9, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (123, 5, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (124, 1, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (125, 10, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (126, 9, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (127, 5, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (128, 1, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (148, 13, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (149, 12, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (150, 6, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (151, 2, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (152, 13, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (153, 12, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (154, 6, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (155, 2, 4, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (156, 13, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (157, 12, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (158, 6, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (159, 2, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (160, 13, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (161, 12, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (162, 6, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (163, 2, 5, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (164, 13, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (165, 12, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (166, 6, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (167, 2, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (168, 13, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (169, 12, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (170, 6, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (171, 2, 7, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (172, 13, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (173, 12, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (174, 6, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (175, 2, 9, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (176, 13, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (177, 12, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (178, 6, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (179, 2, 10, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (180, 13, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (181, 12, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (182, 6, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (183, 2, 11, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (184, 13, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (185, 12, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (186, 6, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (187, 2, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (211, 3, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (212, 3, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (213, 3, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (214, 3, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (215, 7, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (216, 7, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (217, 7, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (218, 7, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (219, 15, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (220, 15, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (221, 15, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (222, 15, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (223, 16, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (224, 16, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (225, 16, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (226, 16, 2, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (242, 4, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (243, 4, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (244, 8, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (245, 8, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (246, 18, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (247, 18, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (248, 19, 6, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (249, 19, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_role_permission` VALUES (257, 21, 1, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (258, 21, 2, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (259, 21, 3, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (260, 21, 4, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (261, 21, 5, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (262, 21, 6, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (263, 21, 7, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (264, 21, 8, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (265, 21, 9, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (266, 21, 10, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (267, 21, 11, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (268, 24, 1, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (269, 24, 6, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (270, 22, 1, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (271, 22, 2, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (272, 22, 3, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (273, 22, 4, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (274, 22, 5, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (275, 22, 6, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (276, 22, 7, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (277, 22, 9, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (278, 22, 10, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (279, 22, 11, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (280, 23, 1, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (281, 23, 2, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (282, 23, 3, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_role_permission` VALUES (283, 23, 6, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);

-- ----------------------------
-- Table structure for team_user_role
-- ----------------------------
DROP TABLE IF EXISTS `team_user_role`;
CREATE TABLE `team_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `team_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_team_user_role`(`team_id` ASC, `user_id` ASC, `role_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team_user_role
-- ----------------------------
INSERT INTO `team_user_role` VALUES (6, 1, 1, 1, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_user_role` VALUES (13, 1, 2, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_user_role` VALUES (14, 1, 3, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_user_role` VALUES (16, 1, 6, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_user_role` VALUES (19, 1, 11, 3, '2026-07-12 14:13:15', '2026-07-12 14:13:15', 0);
INSERT INTO `team_user_role` VALUES (28, 6, 6, 21, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0);
INSERT INTO `team_user_role` VALUES (29, 6, 1, 23, '2026-07-12 14:20:54', '2026-07-12 14:20:54', 0);
INSERT INTO `team_user_role` VALUES (32, 1, 12, 3, '2026-07-12 19:17:55', '2026-07-12 19:17:55', 0);
INSERT INTO `team_user_role` VALUES (33, 6, 12, 23, '2026-07-12 20:49:18', '2026-07-12 20:49:18', 0);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` tinyint NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '$2a$10$xyFoAQTvbf/RAmtQ.tU2COBT0S08gCBzW848/a/lwE7jhofQDQr3O', '管理员', 'admin@qq.com', NULL, '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0);
INSERT INTO `user` VALUES (2, 'user1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '张三', 'zhangsan@example.com', NULL, '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0);
INSERT INTO `user` VALUES (3, 'user2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '李四', 'lisi@example.com', NULL, '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0);
INSERT INTO `user` VALUES (6, 'huang', '$2a$10$B.irTWh9oFhQvG/57Mc9uufNtOm4T8NvUxCWTsPwN3H8trJKFg1YO', '黄', 'huang@qq.com', NULL, '2026-05-23 20:34:36', '2026-05-23 20:34:36', 0);
INSERT INTO `user` VALUES (11, 'xiaofang', '$2a$10$17vSjSZrPJ.3qPUwVCtG/OzPfsiNoujaF.upOMB3uDEi9QhUAnMsO', '小芳', 'xiaofang@163.com', NULL, '2026-06-06 21:52:01', '2026-06-06 21:52:01', 0);
INSERT INTO `user` VALUES (12, 'wanwan', '$2a$10$EJszlGdVFssQThsxEwyvVu1SL9A8UIlLpHleQP7Tb0hjaViT3B8PO', '晚晚', NULL, NULL, '2026-06-06 22:16:47', '2026-06-06 22:16:47', 0);
INSERT INTO `user` VALUES (13, 'xiaotiantian', '$2a$10$7TfnjY7/amVRfTVnmjuAyetYmFEJG6Kj.Ra/6tSNu9TzrObxEt6yW', '小甜甜', '', NULL, '2026-07-12 17:34:25', '2026-07-12 17:34:25', 0);

SET FOREIGN_KEY_CHECKS = 1;
