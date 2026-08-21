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

 Date: 20/08/2026 15:55:32
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
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消息通知表' ROW_FORMAT = Dynamic;

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
INSERT INTO `notification` VALUES (10, 1, 'TEAM_APPLY', '新的退出申请', '有成员申请退出团队「产品研发组」，请及时处理', 'APPLICATION', 6, 1, '2026-08-20 09:57:04', '2026-08-20 09:56:40', '2026-08-20 09:56:40', 0);
INSERT INTO `notification` VALUES (12, 3, 'TEAM_APPLY', '新的退出申请', '有成员申请退出团队「云端数据组」，请及时处理', 'APPLICATION', 7, 1, '2026-08-20 10:38:17', '2026-08-20 10:37:43', '2026-08-20 10:37:43', 0);
INSERT INTO `notification` VALUES (14, 3, 'TEAM_APPLY', '新的退出申请', '有成员申请退出团队「云端数据组」，请及时处理', 'APPLICATION', 8, 1, '2026-08-20 10:48:42', '2026-08-20 10:46:11', '2026-08-20 10:46:11', 0);
INSERT INTO `notification` VALUES (17, 3, 'TEAM_APPLY', '新的退出申请', '有成员申请退出团队「云端数据组」，请及时处理', 'APPLICATION', 9, 1, '2026-08-20 11:07:06', '2026-08-20 11:04:54', '2026-08-20 11:04:54', 0);
INSERT INTO `notification` VALUES (19, 3, 'TEAM_APPLY', '新的退出申请', '有成员申请退出团队「云端数据组」，请及时处理', 'APPLICATION', 11, 1, '2026-08-20 11:09:03', '2026-08-20 11:08:39', '2026-08-20 11:08:39', 0);
INSERT INTO `notification` VALUES (20, 1, 'TEAM_LEAVE_REJECTED', '退出申请被拒绝', '您退出团队「云端数据组」的申请被拒绝，原因：无', 'TEAM', 8, 1, '2026-08-20 11:09:46', '2026-08-20 11:08:56', '2026-08-20 11:08:56', 0);
INSERT INTO `notification` VALUES (21, 3, 'TEAM_APPLY', '新的退出申请', '有成员申请退出团队「云端数据组」，请及时处理', 'APPLICATION', 12, 1, '2026-08-20 11:10:25', '2026-08-20 11:10:16', '2026-08-20 11:10:16', 0);
INSERT INTO `notification` VALUES (22, 1, 'TEAM_LEAVE_REJECTED', '退出申请被拒绝', '您退出团队「云端数据组」的申请被拒绝，原因：无', 'TEAM', 8, 1, '2026-08-20 11:21:38', '2026-08-20 11:10:30', '2026-08-20 11:10:30', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 124 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '全局操作日志表' ROW_FORMAT = Dynamic;

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
INSERT INTO `operation_log` VALUES (22, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-08 16:41:40', '2026-08-08 16:41:40', 0);
INSERT INTO `operation_log` VALUES (23, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-08 18:06:19', '2026-08-08 18:06:19', 0);
INSERT INTO `operation_log` VALUES (24, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-10 10:37:43', '2026-08-10 10:37:43', 0);
INSERT INTO `operation_log` VALUES (25, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-11 15:15:14', '2026-08-11 15:15:14', 0);
INSERT INTO `operation_log` VALUES (26, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.133.0 Chrome/148.0.7778.280 Electron/42.8.0 Safari/537.36', '2026-08-13 17:04:46', '2026-08-13 17:04:46', 0);
INSERT INTO `operation_log` VALUES (27, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-18 17:29:36', '2026-08-18 17:29:36', 0);
INSERT INTO `operation_log` VALUES (28, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-19 10:24:39', '2026-08-19 10:24:39', 0);
INSERT INTO `operation_log` VALUES (29, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-19 10:24:57', '2026-08-19 10:24:57', 0);
INSERT INTO `operation_log` VALUES (30, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-19 10:25:32', '2026-08-19 10:25:32', 0);
INSERT INTO `operation_log` VALUES (31, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.133.0 Chrome/148.0.7778.280 Electron/42.8.0 Safari/537.36', '2026-08-19 10:34:05', '2026-08-19 10:34:05', 0);
INSERT INTO `operation_log` VALUES (32, 1, 'admin', '管理员', 'TASK_CREATE', '任务新增', 'task', 17, '寻求启动资金', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 10:46:52', '2026-08-19 10:46:52', 0);
INSERT INTO `operation_log` VALUES (33, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 10:53:44', '2026-08-19 10:53:44', 0);
INSERT INTO `operation_log` VALUES (34, 1, 'admin', '管理员', 'TASK_CREATE', '任务新增', 'task', 18, '玩', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 10:56:10', '2026-08-19 10:56:10', 0);
INSERT INTO `operation_log` VALUES (35, 1, 'admin', '管理员', 'TASK_CREATE', '任务新增', 'task', 19, '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 10:58:00', '2026-08-19 10:58:00', 0);
INSERT INTO `operation_log` VALUES (36, 1, 'admin', '管理员', 'TASK_DELETE', '任务删除', 'task', 19, '1', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 10:58:10', '2026-08-19 10:58:10', 0);
INSERT INTO `operation_log` VALUES (37, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'curl/8.21.0', '2026-08-19 11:11:35', '2026-08-19 11:11:35', 0);
INSERT INTO `operation_log` VALUES (38, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-19 11:11:51', '2026-08-19 11:11:51', 0);
INSERT INTO `operation_log` VALUES (39, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'curl/8.21.0', '2026-08-19 11:51:05', '2026-08-19 11:51:05', 0);
INSERT INTO `operation_log` VALUES (40, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'curl/8.21.0', '2026-08-19 11:52:27', '2026-08-19 11:52:27', 0);
INSERT INTO `operation_log` VALUES (41, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 11:56:42', '2026-08-19 11:56:42', 0);
INSERT INTO `operation_log` VALUES (42, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:43:08', '2026-08-19 15:43:08', 0);
INSERT INTO `operation_log` VALUES (43, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:44:14', '2026-08-19 15:44:14', 0);
INSERT INTO `operation_log` VALUES (44, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:46:07', '2026-08-19 15:46:07', 0);
INSERT INTO `operation_log` VALUES (45, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:47:57', '2026-08-19 15:47:57', 0);
INSERT INTO `operation_log` VALUES (46, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:51:25', '2026-08-19 15:51:25', 0);
INSERT INTO `operation_log` VALUES (47, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:51:36', '2026-08-19 15:51:36', 0);
INSERT INTO `operation_log` VALUES (48, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:51:52', '2026-08-19 15:51:52', 0);
INSERT INTO `operation_log` VALUES (49, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:52:06', '2026-08-19 15:52:06', 0);
INSERT INTO `operation_log` VALUES (50, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:54:56', '2026-08-19 15:54:56', 0);
INSERT INTO `operation_log` VALUES (51, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:55:34', '2026-08-19 15:55:34', 0);
INSERT INTO `operation_log` VALUES (52, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 15:59:37', '2026-08-19 15:59:37', 0);
INSERT INTO `operation_log` VALUES (53, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 16:01:34', '2026-08-19 16:01:34', 0);
INSERT INTO `operation_log` VALUES (54, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 16:06:45', '2026-08-19 16:06:45', 0);
INSERT INTO `operation_log` VALUES (55, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'curl/8.21.0', '2026-08-19 16:17:29', '2026-08-19 16:17:29', 0);
INSERT INTO `operation_log` VALUES (56, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 16:22:19', '2026-08-19 16:22:19', 0);
INSERT INTO `operation_log` VALUES (57, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 16:23:30', '2026-08-19 16:23:30', 0);
INSERT INTO `operation_log` VALUES (58, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'curl/8.21.0', '2026-08-19 16:26:04', '2026-08-19 16:26:04', 0);
INSERT INTO `operation_log` VALUES (59, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'curl/8.21.0', '2026-08-19 16:28:25', '2026-08-19 16:28:25', 0);
INSERT INTO `operation_log` VALUES (60, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 16:34:41', '2026-08-19 16:34:41', 0);
INSERT INTO `operation_log` VALUES (61, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 16:35:05', '2026-08-19 16:35:05', 0);
INSERT INTO `operation_log` VALUES (62, 2, 'user1', '张三', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 17:03:06', '2026-08-19 17:03:06', 0);
INSERT INTO `operation_log` VALUES (63, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-19 17:20:48', '2026-08-19 17:20:48', 0);
INSERT INTO `operation_log` VALUES (64, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-19 17:20:55', '2026-08-19 17:20:55', 0);
INSERT INTO `operation_log` VALUES (65, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 17:23:12', '2026-08-19 17:23:12', 0);
INSERT INTO `operation_log` VALUES (66, 2, 'user1', '张三', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 17:46:25', '2026-08-19 17:46:25', 0);
INSERT INTO `operation_log` VALUES (67, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-19 17:57:02', '2026-08-19 17:57:02', 0);
INSERT INTO `operation_log` VALUES (68, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:09:14', '2026-08-20 09:09:14', 0);
INSERT INTO `operation_log` VALUES (69, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:09:20', '2026-08-20 09:09:20', 0);
INSERT INTO `operation_log` VALUES (70, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:10:21', '2026-08-20 09:10:21', 0);
INSERT INTO `operation_log` VALUES (71, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:10:37', '2026-08-20 09:10:37', 0);
INSERT INTO `operation_log` VALUES (72, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:10:54', '2026-08-20 09:10:54', 0);
INSERT INTO `operation_log` VALUES (73, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:11:06', '2026-08-20 09:11:06', 0);
INSERT INTO `operation_log` VALUES (74, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:11:19', '2026-08-20 09:11:19', 0);
INSERT INTO `operation_log` VALUES (75, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:11:24', '2026-08-20 09:11:24', 0);
INSERT INTO `operation_log` VALUES (76, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:11:28', '2026-08-20 09:11:28', 0);
INSERT INTO `operation_log` VALUES (77, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:11:38', '2026-08-20 09:11:38', 0);
INSERT INTO `operation_log` VALUES (78, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:12:03', '2026-08-20 09:12:03', 0);
INSERT INTO `operation_log` VALUES (79, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:12:49', '2026-08-20 09:12:49', 0);
INSERT INTO `operation_log` VALUES (80, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:13:06', '2026-08-20 09:13:06', 0);
INSERT INTO `operation_log` VALUES (81, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:13:13', '2026-08-20 09:13:13', 0);
INSERT INTO `operation_log` VALUES (82, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:13:17', '2026-08-20 09:13:17', 0);
INSERT INTO `operation_log` VALUES (83, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:13:57', '2026-08-20 09:13:57', 0);
INSERT INTO `operation_log` VALUES (84, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:14:02', '2026-08-20 09:14:02', 0);
INSERT INTO `operation_log` VALUES (85, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:14:22', '2026-08-20 09:14:22', 0);
INSERT INTO `operation_log` VALUES (86, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:15:13', '2026-08-20 09:15:13', 0);
INSERT INTO `operation_log` VALUES (87, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:15:22', '2026-08-20 09:15:22', 0);
INSERT INTO `operation_log` VALUES (88, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:15:40', '2026-08-20 09:15:40', 0);
INSERT INTO `operation_log` VALUES (89, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:15:47', '2026-08-20 09:15:47', 0);
INSERT INTO `operation_log` VALUES (90, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:17:13', '2026-08-20 09:17:13', 0);
INSERT INTO `operation_log` VALUES (91, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:18:20', '2026-08-20 09:18:20', 0);
INSERT INTO `operation_log` VALUES (92, 2, 'user1', '小棠', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:20:17', '2026-08-20 09:20:17', 0);
INSERT INTO `operation_log` VALUES (93, 2, 'user1', '小棠', 'TASK_UPDATE', '任务修改', 'task', 32, '实时数据管道搭建', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:27:56', '2026-08-20 09:27:56', 0);
INSERT INTO `operation_log` VALUES (94, 3, 'user2', '李四', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:45:31', '2026-08-20 09:45:31', 0);
INSERT INTO `operation_log` VALUES (95, 3, 'user2', '小姚', 'TASK_UPDATE', '任务修改', 'task', 40, '配送路径优化算法', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:48:41', '2026-08-20 09:48:41', 0);
INSERT INTO `operation_log` VALUES (96, 3, 'user2', '小姚', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:50:27', '2026-08-20 09:50:27', 0);
INSERT INTO `operation_log` VALUES (97, 3, 'user2', '小姚', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:56:17', '2026-08-20 09:56:17', 0);
INSERT INTO `operation_log` VALUES (98, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 09:56:56', '2026-08-20 09:56:56', 0);
INSERT INTO `operation_log` VALUES (99, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 10:07:44', '2026-08-20 10:07:44', 0);
INSERT INTO `operation_log` VALUES (100, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 10:12:52', '2026-08-20 10:12:52', 0);
INSERT INTO `operation_log` VALUES (101, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 10:13:47', '2026-08-20 10:13:47', 0);
INSERT INTO `operation_log` VALUES (102, 2, 'user1', '小棠', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 10:18:49', '2026-08-20 10:18:49', 0);
INSERT INTO `operation_log` VALUES (103, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `operation_log` VALUES (107, 3, 'user2', '小姚', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 10:37:55', '2026-08-20 10:37:55', 0);
INSERT INTO `operation_log` VALUES (108, 3, 'user2', '小姚', 'TEAM_UPDATE', '转让管理员给: 管理员(admin)', 'team', 7, '晨曦工作室', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 10:39:10', '2026-08-20 10:39:10', 0);
INSERT INTO `operation_log` VALUES (109, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-08-20 10:40:17', '2026-08-20 10:40:17', 0);
INSERT INTO `operation_log` VALUES (110, 3, 'user2', '小姚', 'TASK_UPDATE', '任务修改', 'task', 40, '配送路径优化算法', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 10:56:10', '2026-08-20 10:56:10', 0);
INSERT INTO `operation_log` VALUES (111, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 11:04:33', '2026-08-20 11:04:33', 0);
INSERT INTO `operation_log` VALUES (112, 1, 'admin', '管理员', 'TASK_CREATE', '任务新增', 'task', 70, '测试分配通知任务', '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 11:04:33', '2026-08-20 11:04:33', 0);
INSERT INTO `operation_log` VALUES (113, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 11:04:53', '2026-08-20 11:04:53', 0);
INSERT INTO `operation_log` VALUES (114, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 11:05:04', '2026-08-20 11:05:04', 0);
INSERT INTO `operation_log` VALUES (115, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 11:05:11', '2026-08-20 11:05:11', 0);
INSERT INTO `operation_log` VALUES (116, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 11:05:28', '2026-08-20 11:05:28', 0);
INSERT INTO `operation_log` VALUES (117, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'python-requests/2.32.5', '2026-08-20 11:19:41', '2026-08-20 11:19:41', 0);
INSERT INTO `operation_log` VALUES (118, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'curl/8.21.0', '2026-08-20 14:57:49', '2026-08-20 14:57:49', 0);
INSERT INTO `operation_log` VALUES (119, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'curl/8.21.0', '2026-08-20 14:57:51', '2026-08-20 14:57:51', 0);
INSERT INTO `operation_log` VALUES (120, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'curl/8.21.0', '2026-08-20 14:58:54', '2026-08-20 14:58:54', 0);
INSERT INTO `operation_log` VALUES (121, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'curl/8.21.0', '2026-08-20 14:58:55', '2026-08-20 14:58:55', 0);
INSERT INTO `operation_log` VALUES (122, 1, 'admin', '管理员', 'LOGIN', '登录', 'auth', NULL, NULL, '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 15:02:29', '2026-08-20 15:02:29', 0);
INSERT INTO `operation_log` VALUES (123, 1, 'admin', '管理员', 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0', '2026-08-20 15:03:41', '2026-08-20 15:03:41', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `task` VALUES (17, '寻求启动资金', '没钱了', 'PENDING_ASSIGN', 'MEDIUM', '2026-09-04 00:00:00', 1, 1, 1, '2026-08-19 10:46:52', '2026-08-19 10:46:52', 0, 1, '求合作', 'TK0000171576');
INSERT INTO `task` VALUES (18, '玩', '挖宝', 'PENDING_ASSIGN', 'MEDIUM', '2026-08-15 00:00:00', 1, 1, 6, '2026-08-19 10:56:10', '2026-08-19 10:56:10', 0, 0, NULL, 'TK0000185A19');
INSERT INTO `task` VALUES (19, '1', '1', 'PENDING_ASSIGN', 'HIGH', '2026-07-29 00:00:00', 1, 2, 1, '2026-08-19 10:58:00', '2026-08-19 10:58:10', 1, 0, NULL, 'TK000019468F');
INSERT INTO `task` VALUES (20, '品牌视觉系统设计', '【晨曦工作室】品牌视觉系统设计的详细描述与执行计划。', 'PENDING_ASSIGN', 'HIGH', '2026-09-01 11:29:49', 3, 12, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「品牌视觉系统设计」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK000020RXB1');
INSERT INTO `task` VALUES (21, '官网首页视觉改版', '【晨曦工作室】官网首页视觉改版的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-09-15 11:29:49', 3, 3, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「官网首页视觉改版」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK000021BV01');
INSERT INTO `task` VALUES (22, '产品包装设计', '【晨曦工作室】产品包装设计的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-09-01 11:29:49', 3, 13, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「产品包装设计」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK000022EJ98');
INSERT INTO `task` VALUES (23, '企业宣传册排版', '【晨曦工作室】企业宣传册排版的详细描述与执行计划。', 'IN_PROGRESS', 'LOW', '2026-08-09 11:29:49', 3, 6, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「企业宣传册排版」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK00002328YN');
INSERT INTO `task` VALUES (24, '插画IP形象绘制', '【晨曦工作室】插画IP形象绘制的详细描述与执行计划。', 'IN_PROGRESS', 'HIGH', '2026-08-24 11:29:49', 3, 13, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「插画IP形象绘制」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK000024PQKO');
INSERT INTO `task` VALUES (25, '社交媒体海报系列', '【晨曦工作室】社交媒体海报系列的详细描述与执行计划。', 'IN_PROGRESS', 'MEDIUM', '2026-08-26 11:29:49', 3, 11, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「社交媒体海报系列」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK00002530VW');
INSERT INTO `task` VALUES (26, '视觉规范手册编写', '【晨曦工作室】视觉规范手册编写的详细描述与执行计划。', 'PENDING_REVIEW', 'MEDIUM', '2026-08-20 21:29:49', 3, 13, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「视觉规范手册编写」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK000026EFAN');
INSERT INTO `task` VALUES (27, '展会物料设计', '【晨曦工作室】展会物料设计的详细描述与执行计划。', 'PENDING_REVIEW', 'LOW', '2026-08-21 23:29:49', 3, 13, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「展会物料设计」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK000027AMVS');
INSERT INTO `task` VALUES (28, '视频封面设计', '【晨曦工作室】视频封面设计的详细描述与执行计划。', 'DONE', 'HIGH', '2026-08-11 01:29:49', 3, 1, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「视频封面设计」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK000028JV76');
INSERT INTO `task` VALUES (29, '品牌色板梳理', '【晨曦工作室】品牌色板梳理的详细描述与执行计划。', 'DONE', 'MEDIUM', '2026-08-14 07:29:49', 3, 13, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「品牌色板梳理」— 来自团队 晨曦工作室 的公开任务,欢迎围观与协作。', 'TK0000294BF5');
INSERT INTO `task` VALUES (30, '数据仓库建模', '【云端数据组】数据仓库建模的详细描述与执行计划。', 'PENDING_ASSIGN', 'HIGH', '2026-09-05 11:29:49', 3, 3, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「数据仓库建模」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK0000307BKU');
INSERT INTO `task` VALUES (31, 'ETL调度任务优化', '【云端数据组】ETL调度任务优化的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-09-17 11:29:49', 3, 11, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「ETL调度任务优化」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK0000314EL1');
INSERT INTO `task` VALUES (32, '实时数据管道搭建', '【云端数据组】实时数据管道搭建的详细描述与执行计划。', 'IN_PROGRESS', 'MEDIUM', '2026-09-04 11:29:49', 3, 2, 8, '2026-08-19 11:29:49', '2026-08-20 09:27:56', 0, 1, '「实时数据管道搭建」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK000032RKE7');
INSERT INTO `task` VALUES (33, '用户行为分析报表', '【云端数据组】用户行为分析报表的详细描述与执行计划。', 'IN_PROGRESS', 'LOW', '2026-08-13 11:29:49', 3, 2, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「用户行为分析报表」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK000033KAKV');
INSERT INTO `task` VALUES (34, '数据质量监控体系', '【云端数据组】数据质量监控体系的详细描述与执行计划。', 'IN_PROGRESS', 'HIGH', '2026-08-25 11:29:49', 3, 12, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「数据质量监控体系」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK000034PA8M');
INSERT INTO `task` VALUES (35, '埋点方案设计', '【云端数据组】埋点方案设计的详细描述与执行计划。', 'IN_PROGRESS', 'MEDIUM', '2026-08-21 11:29:49', 3, 13, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「埋点方案设计」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK000035TYDO');
INSERT INTO `task` VALUES (36, 'BI看板搭建', '【云端数据组】BI看板搭建的详细描述与执行计划。', 'PENDING_REVIEW', 'MEDIUM', '2026-08-20 00:29:49', 3, 11, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「BI看板搭建」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK000036AGAE');
INSERT INTO `task` VALUES (37, '离线计算任务迁移', '【云端数据组】离线计算任务迁移的详细描述与执行计划。', 'PENDING_REVIEW', 'LOW', '2026-08-21 23:29:49', 3, 1, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「离线计算任务迁移」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK000037M34N');
INSERT INTO `task` VALUES (38, '数据权限管控', '【云端数据组】数据权限管控的详细描述与执行计划。', 'DONE', 'HIGH', '2026-07-31 03:29:49', 3, 1, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「数据权限管控」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK0000385GMR');
INSERT INTO `task` VALUES (39, '数据字典维护', '【云端数据组】数据字典维护的详细描述与执行计划。', 'DONE', 'MEDIUM', '2026-08-02 07:29:49', 3, 12, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「数据字典维护」— 来自团队 云端数据组 的公开任务,欢迎围观与协作。', 'TK000039W1AX');
INSERT INTO `task` VALUES (40, '配送路径优化算法', '【智慧物流组】配送路径优化算法的详细描述与执行计划。', 'CANCELLED', 'HIGH', '2026-09-15 11:29:49', 3, 1, 9, '2026-08-19 11:29:49', '2026-08-20 10:56:10', 0, 1, '「配送路径优化算法」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK000040F8K2');
INSERT INTO `task` VALUES (41, '车辆调度系统开发', '【智慧物流组】车辆调度系统开发的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-09-15 11:29:49', 3, 1, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「车辆调度系统开发」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK0000419PYV');
INSERT INTO `task` VALUES (42, '仓储分拣流程设计', '【智慧物流组】仓储分拣流程设计的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-08-25 11:29:49', 3, 13, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「仓储分拣流程设计」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK0000422HT1');
INSERT INTO `task` VALUES (43, '物流轨迹实时追踪', '【智慧物流组】物流轨迹实时追踪的详细描述与执行计划。', 'IN_PROGRESS', 'LOW', '2026-08-08 11:29:49', 3, 6, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「物流轨迹实时追踪」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK000043XMB7');
INSERT INTO `task` VALUES (44, '运力资源管理平台', '【智慧物流组】运力资源管理平台的详细描述与执行计划。', 'IN_PROGRESS', 'HIGH', '2026-08-25 11:29:49', 3, 13, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「运力资源管理平台」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK000044CIN9');
INSERT INTO `task` VALUES (45, '异常件处理流程', '【智慧物流组】异常件处理流程的详细描述与执行计划。', 'IN_PROGRESS', 'MEDIUM', '2026-08-27 11:29:49', 3, 12, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「异常件处理流程」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK00004536PB');
INSERT INTO `task` VALUES (46, '末端配送体验优化', '【智慧物流组】末端配送体验优化的详细描述与执行计划。', 'PENDING_REVIEW', 'MEDIUM', '2026-08-19 20:29:49', 3, 2, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「末端配送体验优化」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK000046UML7');
INSERT INTO `task` VALUES (47, '运输成本核算模型', '【智慧物流组】运输成本核算模型的详细描述与执行计划。', 'PENDING_REVIEW', 'LOW', '2026-08-21 17:29:49', 3, 2, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「运输成本核算模型」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK000047TKZD');
INSERT INTO `task` VALUES (48, '司机端App改版', '【智慧物流组】司机端App改版的详细描述与执行计划。', 'DONE', 'HIGH', '2026-08-02 06:29:49', 3, 12, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「司机端App改版」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK000048BY9S');
INSERT INTO `task` VALUES (49, '智能客服机器人', '【智慧物流组】智能客服机器人的详细描述与执行计划。', 'DONE', 'MEDIUM', '2026-08-07 00:29:49', 3, 3, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「智能客服机器人」— 来自团队 智慧物流组 的公开任务,欢迎围观与协作。', 'TK0000494PMQ');
INSERT INTO `task` VALUES (50, '文创IP形象设计', '【文创设计坊】文创IP形象设计的详细描述与执行计划。', 'PENDING_ASSIGN', 'HIGH', '2026-08-28 11:29:49', 13, 11, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「文创IP形象设计」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000050IFNN');
INSERT INTO `task` VALUES (51, '非遗文创产品开发', '【文创设计坊】非遗文创产品开发的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-08-28 11:29:49', 13, 1, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「非遗文创产品开发」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000051EMX3');
INSERT INTO `task` VALUES (52, '文创礼盒包装设计', '【文创设计坊】文创礼盒包装设计的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-09-18 11:29:49', 13, 1, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「文创礼盒包装设计」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000052TZPD');
INSERT INTO `task` VALUES (53, '博物馆联名系列', '【文创设计坊】博物馆联名系列的详细描述与执行计划。', 'IN_PROGRESS', 'LOW', '2026-08-09 11:29:50', 13, 12, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「博物馆联名系列」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000053TGJ9');
INSERT INTO `task` VALUES (54, '文创周边众筹方案', '【文创设计坊】文创周边众筹方案的详细描述与执行计划。', 'IN_PROGRESS', 'HIGH', '2026-08-29 11:29:50', 13, 6, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「文创周边众筹方案」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000054C9BE');
INSERT INTO `task` VALUES (55, '品牌故事短片脚本', '【文创设计坊】品牌故事短片脚本的详细描述与执行计划。', 'IN_PROGRESS', 'MEDIUM', '2026-08-28 11:29:50', 13, 2, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「品牌故事短片脚本」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000055YQ5P');
INSERT INTO `task` VALUES (56, '文创市集展位设计', '【文创设计坊】文创市集展位设计的详细描述与执行计划。', 'PENDING_REVIEW', 'MEDIUM', '2026-08-20 15:29:50', 13, 2, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「文创市集展位设计」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK00005690JD');
INSERT INTO `task` VALUES (57, '用户共创活动策划', '【文创设计坊】用户共创活动策划的详细描述与执行计划。', 'PENDING_REVIEW', 'LOW', '2026-08-19 19:29:50', 13, 2, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「用户共创活动策划」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000057MKBS');
INSERT INTO `task` VALUES (58, '文创衍生品定价', '【文创设计坊】文创衍生品定价的详细描述与执行计划。', 'DONE', 'HIGH', '2026-08-16 06:29:50', 13, 1, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「文创衍生品定价」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK000058UQPH');
INSERT INTO `task` VALUES (59, '年度新品发布策划', '【文创设计坊】年度新品发布策划的详细描述与执行计划。', 'DONE', 'MEDIUM', '2026-08-12 00:29:50', 13, 13, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「年度新品发布策划」— 来自团队 文创设计坊 的公开任务,欢迎围观与协作。', 'TK0000590DPB');
INSERT INTO `task` VALUES (60, '光伏组件效率测试', '【绿能科技组】光伏组件效率测试的详细描述与执行计划。', 'PENDING_ASSIGN', 'HIGH', '2026-09-11 11:29:50', 2, 3, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「光伏组件效率测试」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK000060I43E');
INSERT INTO `task` VALUES (61, '储能系统方案设计', '【绿能科技组】储能系统方案设计的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-08-27 11:29:50', 2, 1, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「储能系统方案设计」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK000061IE5M');
INSERT INTO `task` VALUES (62, '节能改造可行性报告', '【绿能科技组】节能改造可行性报告的详细描述与执行计划。', 'PENDING_ASSIGN', 'MEDIUM', '2026-09-10 11:29:50', 2, 12, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「节能改造可行性报告」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK00006258M5');
INSERT INTO `task` VALUES (63, '新能源充电桩布局', '【绿能科技组】新能源充电桩布局的详细描述与执行计划。', 'IN_PROGRESS', 'LOW', '2026-08-05 11:29:50', 2, 11, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「新能源充电桩布局」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK000063TAD6');
INSERT INTO `task` VALUES (64, '能耗数据监测平台', '【绿能科技组】能耗数据监测平台的详细描述与执行计划。', 'IN_PROGRESS', 'HIGH', '2026-08-22 11:29:50', 2, 11, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「能耗数据监测平台」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK000064C866');
INSERT INTO `task` VALUES (65, '绿色工厂认证材料', '【绿能科技组】绿色工厂认证材料的详细描述与执行计划。', 'IN_PROGRESS', 'MEDIUM', '2026-08-28 11:29:50', 2, 6, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「绿色工厂认证材料」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK000065FCFH');
INSERT INTO `task` VALUES (66, '碳足迹核算模型', '【绿能科技组】碳足迹核算模型的详细描述与执行计划。', 'PENDING_REVIEW', 'MEDIUM', '2026-08-21 17:29:50', 2, 2, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「碳足迹核算模型」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK000066HAPI');
INSERT INTO `task` VALUES (67, '可再生能源政策调研', '【绿能科技组】可再生能源政策调研的详细描述与执行计划。', 'PENDING_REVIEW', 'LOW', '2026-08-21 16:29:50', 2, 2, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「可再生能源政策调研」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK000067R4XL');
INSERT INTO `task` VALUES (68, '节能产品宣传片', '【绿能科技组】节能产品宣传片的详细描述与执行计划。', 'DONE', 'HIGH', '2026-08-02 08:29:50', 2, 3, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「节能产品宣传片」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK0000689CCB');
INSERT INTO `task` VALUES (69, '分布式能源试点', '【绿能科技组】分布式能源试点的详细描述与执行计划。', 'DONE', 'MEDIUM', '2026-08-11 09:29:50', 2, 2, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 1, '「分布式能源试点」— 来自团队 绿能科技组 的公开任务,欢迎围观与协作。', 'TK0000697DOZ');

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
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务变更历史表' ROW_FORMAT = Dynamic;

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
INSERT INTO `task_change_log` VALUES (13, 17, 'CREATE', '创建任务', NULL, '创建任务', 1, '管理员', '2026-08-19 10:46:52', '2026-08-19 10:46:52', 0);
INSERT INTO `task_change_log` VALUES (14, 18, 'CREATE', '创建任务', NULL, '创建任务', 1, '管理员', '2026-08-19 10:56:10', '2026-08-19 10:56:10', 0);
INSERT INTO `task_change_log` VALUES (15, 19, 'CREATE', '创建任务', NULL, '创建任务', 1, '管理员', '2026-08-19 10:58:00', '2026-08-19 10:58:00', 0);
INSERT INTO `task_change_log` VALUES (16, 32, 'status', '状态', 'PENDING_ASSIGN', 'IN_PROGRESS', 2, '小棠', '2026-08-20 09:27:56', '2026-08-20 09:27:56', 0);
INSERT INTO `task_change_log` VALUES (17, 40, 'status', '状态', 'PENDING_ASSIGN', 'CANCELLED', 3, '小姚', '2026-08-20 09:48:41', '2026-08-20 09:48:41', 0);
INSERT INTO `task_change_log` VALUES (18, 40, 'assigneeId', '负责人', '黄', '管理员', 3, '小姚', '2026-08-20 10:56:10', '2026-08-20 10:56:10', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task_comment
-- ----------------------------
INSERT INTO `task_comment` VALUES (1, 15, 1, '这是我能看的吗', '2026-07-12 20:30:41', '2026-07-12 20:30:41', 0);
INSERT INTO `task_comment` VALUES (2, 2, 1, '来个尼格', '2026-07-12 20:33:17', '2026-07-12 20:33:17', 0);
INSERT INTO `task_comment` VALUES (3, 15, 6, '管理员来给我炒两个菜', '2026-07-12 20:47:08', '2026-07-12 20:47:08', 0);
INSERT INTO `task_comment` VALUES (4, 16, 1, '给我来两斤米酒', '2026-07-12 20:52:17', '2026-07-12 20:52:17', 0);
INSERT INTO `task_comment` VALUES (5, 16, 6, '没钱咋办', '2026-07-12 20:54:49', '2026-07-12 20:54:49', 0);
INSERT INTO `task_comment` VALUES (6, 63, 2, '你好', '2026-08-20 09:26:15', '2026-08-20 09:26:15', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team
-- ----------------------------
INSERT INTO `team` VALUES (1, '产品研发组', '负责产品研发工作', 1, '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0, 'T0000016949');
INSERT INTO `team` VALUES (6, '制作国宴', '这是一支制作国宴的团队', 6, '2026-07-12 14:20:36', '2026-07-12 14:20:36', 0, 'T000006C6A2');
INSERT INTO `team` VALUES (7, '晨曦工作室', '专注创意设计与品牌视觉，让每一个作品都闪闪发光', 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 'T000007P0TT');
INSERT INTO `team` VALUES (8, '云端数据组', '大数据采集、清洗与分析，用数据驱动业务决策', 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 'T000008Z0LH');
INSERT INTO `team` VALUES (9, '智慧物流组', '物流调度与路径优化，打造高效智能配送体系', 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 'T000009SB48');
INSERT INTO `team` VALUES (10, '文创设计坊', '文化创意产品设计与IP孵化，连接传统与潮流', 13, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 'T000010L0HG');
INSERT INTO `team` VALUES (11, '绿能科技组', '新能源技术研究与节能方案落地，助力绿色低碳', 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0, 'T000011U02N');

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
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '团队加入退出申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of team_application
-- ----------------------------
INSERT INTO `team_application` VALUES (1, 1, 12, 'JOIN', 'REJECTED', NULL, 1, NULL, '2026-07-12 17:32:33', NULL, '2026-07-12 17:14:11', '2026-07-12 17:14:11', 0);
INSERT INTO `team_application` VALUES (2, 1, 12, 'JOIN', 'APPROVED', NULL, 1, NULL, '2026-07-12 19:14:15', NULL, '2026-07-12 17:33:36', '2026-07-12 17:33:36', 0);
INSERT INTO `team_application` VALUES (3, 1, 13, 'JOIN', 'APPROVED', NULL, 1, NULL, '2026-07-12 17:35:14', NULL, '2026-07-12 17:34:44', '2026-07-12 17:34:44', 0);
INSERT INTO `team_application` VALUES (4, 1, 13, 'LEAVE', 'APPROVED', '不想干了', 1, NULL, '2026-07-12 19:15:34', NULL, '2026-07-12 19:15:13', '2026-07-12 19:15:13', 0);
INSERT INTO `team_application` VALUES (5, 1, 12, 'JOIN', 'APPROVED', NULL, 1, NULL, '2026-07-12 19:17:54', NULL, '2026-07-12 19:17:31', '2026-07-12 19:17:31', 0);
INSERT INTO `team_application` VALUES (6, 1, 3, 'LEAVE', 'REJECTED', '666', 1, NULL, '2026-08-20 09:58:04', NULL, '2026-08-20 09:56:40', '2026-08-20 09:56:40', 0);
INSERT INTO `team_application` VALUES (7, 8, 2, 'LEAVE', 'REJECTED', '1', 3, NULL, '2026-08-20 10:38:37', NULL, '2026-08-20 10:37:43', '2026-08-20 10:37:43', 0);
INSERT INTO `team_application` VALUES (8, 8, 1, 'LEAVE', 'REJECTED', '不想干了', 3, NULL, '2026-08-20 10:52:19', NULL, '2026-08-20 10:46:11', '2026-08-20 10:46:11', 0);
INSERT INTO `team_application` VALUES (11, 8, 1, 'LEAVE', 'REJECTED', '考研', 3, '小姚', '2026-08-20 11:08:56', NULL, '2026-08-20 11:08:39', '2026-08-20 11:08:39', 0);
INSERT INTO `team_application` VALUES (12, 8, 1, 'LEAVE', 'REJECTED', '结婚', 3, '小姚', '2026-08-20 11:10:30', NULL, '2026-08-20 11:10:16', '2026-08-20 11:10:16', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 70 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `team_member` VALUES (35, 7, 3, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (36, 7, 13, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (37, 7, 12, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (38, 7, 6, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (39, 7, 11, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (40, 7, 1, 'ADMIN', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (41, 8, 3, 'ADMIN', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (42, 8, 6, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (43, 8, 11, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (44, 8, 2, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (45, 8, 12, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (46, 8, 13, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (47, 8, 1, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (48, 9, 3, 'ADMIN', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (49, 9, 1, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (50, 9, 11, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (51, 9, 12, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (52, 9, 6, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (53, 9, 13, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (54, 9, 2, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (55, 10, 13, 'ADMIN', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (56, 10, 1, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (57, 10, 3, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (58, 10, 6, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (59, 10, 11, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (60, 10, 12, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (61, 10, 2, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (62, 11, 2, 'ADMIN', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (63, 11, 1, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (64, 11, 6, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (65, 11, 12, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (66, 11, 3, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');
INSERT INTO `team_member` VALUES (67, 11, 11, 'MEMBER', '2026-08-19 11:29:49', 0, '2026-08-19 11:29:49', '2026-08-19 11:29:49');

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
) ENGINE = InnoDB AUTO_INCREMENT = 49 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `team_role` VALUES (25, 7, 'OWNER', '所有者', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (26, 7, 'ADMIN', '管理员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (27, 7, 'MEMBER', '普通成员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (28, 7, 'GUEST', '访客', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (29, 8, 'OWNER', '所有者', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (30, 8, 'ADMIN', '管理员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (31, 8, 'MEMBER', '普通成员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (32, 8, 'GUEST', '访客', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (33, 9, 'OWNER', '所有者', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (34, 9, 'ADMIN', '管理员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (35, 9, 'MEMBER', '普通成员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (36, 9, 'GUEST', '访客', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (37, 10, 'OWNER', '所有者', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (38, 10, 'ADMIN', '管理员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (39, 10, 'MEMBER', '普通成员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (40, 10, 'GUEST', '访客', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (41, 11, 'OWNER', '所有者', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (42, 11, 'ADMIN', '管理员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (43, 11, 'MEMBER', '普通成员', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role` VALUES (44, 11, 'GUEST', '访客', '', '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 446 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `team_role_permission` VALUES (284, 25, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (285, 25, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (286, 25, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (287, 25, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (288, 25, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (289, 25, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (290, 25, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (291, 25, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (292, 25, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (293, 25, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (294, 25, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (295, 26, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (296, 26, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (297, 26, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (298, 26, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (299, 26, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (300, 26, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (301, 26, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (302, 26, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (303, 26, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (304, 26, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (305, 27, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (306, 27, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (307, 27, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (308, 27, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (309, 28, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (310, 28, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (311, 29, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (312, 29, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (313, 29, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (314, 29, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (315, 29, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (316, 29, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (317, 29, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (318, 29, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (319, 29, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (320, 29, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (321, 29, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (322, 30, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (323, 30, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (324, 30, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (325, 30, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (326, 30, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (327, 30, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (328, 30, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (329, 30, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (330, 30, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (331, 30, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (332, 31, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (333, 31, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (334, 31, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (335, 31, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (336, 32, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (337, 32, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (338, 33, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (339, 33, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (340, 33, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (341, 33, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (342, 33, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (343, 33, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (344, 33, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (345, 33, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (346, 33, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (347, 33, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (348, 33, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (349, 34, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (350, 34, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (351, 34, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (352, 34, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (353, 34, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (354, 34, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (355, 34, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (356, 34, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (357, 34, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (358, 34, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (359, 35, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (360, 35, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (361, 35, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (362, 35, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (363, 36, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (364, 36, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (365, 37, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (366, 37, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (367, 37, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (368, 37, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (369, 37, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (370, 37, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (371, 37, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (372, 37, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (373, 37, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (374, 37, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (375, 37, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (376, 38, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (377, 38, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (378, 38, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (379, 38, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (380, 38, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (381, 38, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (382, 38, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (383, 38, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (384, 38, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (385, 38, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (386, 39, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (387, 39, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (388, 39, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (389, 39, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (390, 40, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (391, 40, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (392, 41, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (393, 41, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (394, 41, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (395, 41, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (396, 41, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (397, 41, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (398, 41, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (399, 41, 8, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (400, 41, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (401, 41, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (402, 41, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (403, 42, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (404, 42, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (405, 42, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (406, 42, 4, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (407, 42, 5, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (408, 42, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (409, 42, 7, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (410, 42, 9, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (411, 42, 10, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (412, 42, 11, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (413, 43, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (414, 43, 2, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (415, 43, 3, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (416, 43, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (417, 44, 1, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (418, 44, 6, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_role_permission` VALUES (419, 45, 1, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (420, 45, 2, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (421, 45, 3, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (422, 45, 4, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (423, 45, 5, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (424, 45, 6, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (425, 45, 7, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (426, 45, 8, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (427, 45, 9, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (428, 45, 10, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (429, 45, 11, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (430, 48, 1, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (431, 48, 6, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (432, 46, 1, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (433, 46, 2, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (434, 46, 3, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (435, 46, 4, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (436, 46, 5, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (437, 46, 6, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (438, 46, 7, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (439, 46, 9, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (440, 46, 10, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (441, 46, 11, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (442, 47, 1, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (443, 47, 2, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (444, 47, 3, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);
INSERT INTO `team_role_permission` VALUES (445, 47, 6, '2026-08-20 10:29:26', '2026-08-20 10:29:26', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 69 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `team_user_role` VALUES (34, 7, 3, 27, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (35, 7, 13, 27, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (36, 7, 12, 27, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (37, 7, 6, 27, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (38, 7, 11, 27, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (39, 7, 1, 26, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (40, 8, 3, 29, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (41, 8, 6, 31, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (42, 8, 11, 31, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (43, 8, 2, 31, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (44, 8, 12, 31, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (45, 8, 13, 31, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (46, 8, 1, 31, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (47, 9, 3, 33, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (48, 9, 1, 35, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (49, 9, 11, 35, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (50, 9, 12, 35, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (51, 9, 6, 35, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (52, 9, 13, 35, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (53, 9, 2, 35, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (54, 10, 13, 37, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (55, 10, 1, 39, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (56, 10, 3, 39, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (57, 10, 6, 39, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (58, 10, 11, 39, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (59, 10, 12, 39, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (60, 10, 2, 39, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (61, 11, 2, 41, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (62, 11, 1, 43, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (63, 11, 6, 43, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (64, 11, 12, 43, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (65, 11, 3, 43, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);
INSERT INTO `team_user_role` VALUES (66, 11, 11, 43, '2026-08-19 11:29:49', '2026-08-19 11:29:49', 0);

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
INSERT INTO `user` VALUES (1, 'admin', '$2a$10$xyFoAQTvbf/RAmtQ.tU2COBT0S08gCBzW848/a/lwE7jhofQDQr3O', '管理员', 'admin@qq.com', '/uploads/avatar/user1.png', '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0);
INSERT INTO `user` VALUES (2, 'user1', '$2a$10$ejgt7m1cce8N6agZgxJY8e9ez7Mr6rPLxRL12RZ1O5dTur1fdTXtm', '小棠', 'xiaotang@example.com', '/uploads/avatar/user2.png', '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0);
INSERT INTO `user` VALUES (3, 'user2', '$2a$10$m3jNv6w2l0QT8rpi43SflOu3HYqH6xNSG1q6B1bGs4IaxuCAoHR.S', '小姚', 'lisi@example.com', '/uploads/avatar/user3.png', '2026-05-22 19:55:51', '2026-05-22 19:55:51', 0);
INSERT INTO `user` VALUES (6, 'huang', '$2a$10$B.irTWh9oFhQvG/57Mc9uufNtOm4T8NvUxCWTsPwN3H8trJKFg1YO', '黄', 'huang@qq.com', NULL, '2026-05-23 20:34:36', '2026-05-23 20:34:36', 0);
INSERT INTO `user` VALUES (11, 'xiaofang', '$2a$10$17vSjSZrPJ.3qPUwVCtG/OzPfsiNoujaF.upOMB3uDEi9QhUAnMsO', '小芳', 'xiaofang@163.com', NULL, '2026-06-06 21:52:01', '2026-06-06 21:52:01', 0);
INSERT INTO `user` VALUES (12, 'wanwan', '$2a$10$EJszlGdVFssQThsxEwyvVu1SL9A8UIlLpHleQP7Tb0hjaViT3B8PO', '晚晚', NULL, NULL, '2026-06-06 22:16:47', '2026-06-06 22:16:47', 0);
INSERT INTO `user` VALUES (13, 'xiaotiantian', '$2a$10$7TfnjY7/amVRfTVnmjuAyetYmFEJG6Kj.Ra/6tSNu9TzrObxEt6yW', '小甜甜', '', NULL, '2026-07-12 17:34:25', '2026-07-12 17:34:25', 0);

SET FOREIGN_KEY_CHECKS = 1;
