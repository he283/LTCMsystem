# 轻量任务协作管理系统

一个简洁高效的任务协作管理系统，支持个人任务管理和团队协作。

## 技术栈

### 后端
- Spring Boot 3.2.0
- MyBatis Plus 3.5.5
- MySQL 8.0
- Spring Security + JWT
- Lombok

### 前端
- Vue 3.4
- Vite 5.0
- Element Plus
- Vue Router 4
- Pinia
- Axios

## 项目结构

```
LTCMsystem/
├── backend/                 # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/ltcmsystem/
│   │   │   │   ├── common/     # 通用类
│   │   │   │   ├── config/     # 配置类
│   │   │   │   ├── controller/ # 控制器
│   │   │   │   ├── dto/        # 数据传输对象
│   │   │   │   ├── entity/     # 实体类
│   │   │   │   ├── mapper/     # 数据访问层
│   │   │   │   ├── service/    # 服务层
│   │   │   │   └── util/       # 工具类
│   │   │   └── resources/
│   │   │       ├── application.yml
│   │   │       └── schema.sql
│   └── pom.xml
├── frontend/                # 前端项目
│   ├── src/
│   │   ├── api/             # API接口
│   │   ├── components/      # 组件
│   │   ├── router/          # 路由
│   │   ├── utils/           # 工具类
│   │   ├── views/           # 页面
│   │   ├── App.vue
│   │   └── main.js
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
└── README.md
```

## 快速开始

### 前置要求

- JDK 17+
- Node.js 16+
- MySQL 8.0+

### 1. 数据库配置

创建数据库并执行初始化脚本：

```sql
-- 创建数据库
CREATE DATABASE ltcmsystem DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE ltcmsystem;

-- 执行 backend/src/main/resources/schema.sql 中的内容
```

修改 `backend/src/main/resources/application.yml` 中的数据库配置：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ltcmsystem?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai
    username: your_username
    password: your_password
```

### 2. 运行后端

```bash
cd backend
mvn spring-boot:run
```

后端将在 http://localhost:8080 启动

### 3. 运行前端

```bash
cd frontend
npm install
npm run dev
```

前端将在 http://localhost:3000 启动

## 默认账号

系统预置了三个测试账号，密码均为 `123456`：

- admin / 123456 (管理员)
- user1 / 123456 (张三)
- user2 / 123456 (李四)

## 功能特性

### 用户功能
- 用户注册/登录
- JWT令牌认证
- 用户信息管理

### 任务管理
- 任务创建/编辑/删除
- 任务状态管理（待分配/进行中/待评审/已完成/已取消）
- 任务状态机流转校验（禁止非法跳转）
- 任务优先级（低/中/高）
- 任务变更历史记录
- 任务唯一编号（task_code）
- 个人任务列表
- 任务公开/私有设置
- 任务广场（公开任务浏览）

### 团队管理
- 创建团队（自动生成团队编号）
- 团队唯一编号（team_code）
- 通过团队编号申请加入（需管理员审批）
- 退出团队申请（需管理员审批）
- 团队审批管理（通过/拒绝）
- 团队任务协作
- 团队创建人显示昵称
- 团队RBAC权限体系
  - 所有者：拥有全部权限
  - 管理员：管理团队和任务（不可解散团队）
  - 普通成员：创建和编辑任务、查看团队
  - 访客：仅可查看

### 任务广场
- 公开任务列表浏览
- 关键词搜索
- 优先级/状态筛选
- 分页展示（一行3个卡片）
- 公开任务详情页
- 显示任务编号和团队编号
- 任务变更历史查看
- 无需登录即可浏览

### 消息通知
- 系统通知、任务通知、团队申请通知、审批结果通知
- 顶部导航栏通知铃铛
- 未读数量角标提醒
- 标记已读/全部已读
- 通知列表弹窗

### 操作日志
- 全局操作日志记录（登录/登出、任务增删改、团队增删改/加入/退出/邀请/移除）
- 操作日志查询页面
- 支持按操作人、操作类型、模块、时间范围筛选
- 记录IP地址和User-Agent
- 管理员可见

## API接口

### 认证接口
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册

### 用户接口
- `GET /api/user/info` - 获取当前用户信息

### 任务接口
- `GET /api/tasks/my` - 获取我的任务
- `GET /api/tasks/team/{teamId}` - 获取团队任务
- `POST /api/tasks` - 创建任务
- `PUT /api/tasks/{id}` - 更新任务
- `DELETE /api/tasks/{id}` - 删除任务
- `PUT /api/tasks/{id}/public` - 切换任务公开状态
- `GET /api/tasks/{id}/change-logs` - 获取任务变更历史

### 团队接口
- `GET /api/teams/my` - 获取我的团队
- `POST /api/teams` - 创建团队
- `POST /teams/apply` - 申请加入团队（通过团队编号）
- `POST /teams/leave-apply` - 申请退出团队
- `GET /teams/applications` - 获取团队申请列表（管理员）
- `PUT /teams/applications/{id}/handle` - 审批申请（管理员）

### 通知接口
- `GET /api/notifications` - 获取我的通知列表
- `GET /api/notifications/unread-count` - 获取未读通知数量
- `PUT /api/notifications/{id}/read` - 标记通知已读
- `PUT /api/notifications/read-all` - 全部标记已读

### 操作日志接口
- `GET /api/operation-logs` - 分页查询操作日志（管理员）

### 公开接口（免登录）
- `GET /api/public/tasks` - 分页查询公开任务列表
- `GET /api/public/tasks/{id}` - 查询单条公开任务详情

## 开发说明

### 后端开发
- 使用 MyBatis Plus 简化数据访问
- JWT 进行无状态认证
- 全局异常处理统一响应格式
- 团队级 RBAC 权限控制（所有者/管理员/普通成员/访客）
- 任务状态机流转校验（5种状态，禁止非法跳转）
- 任务变更历史自动记录
- 全局操作日志记录
- 消息通知服务

### 前端开发
- 使用 Vue 3 Composition API
- Element Plus UI 组件库
- Axios 拦截器处理请求/响应
- 路由守卫实现权限控制

# LTCMsystem
轻量任务协作管理系统，面向个人学习规划、学生团队课程项目、小型团队办公协作，用于任务统筹、分工分配、 进度追踪与数据复盘，解决任务管理混乱、分工不清晰、进度难跟踪的问题。
