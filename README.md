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
- 任务状态管理（待办/进行中/已完成）
- 任务优先级（低/中/高）
- 个人任务列表

### 团队管理
- 创建团队
- 加入团队
- 团队任务协作

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

### 团队接口
- `GET /api/teams/my` - 获取我的团队
- `POST /api/teams` - 创建团队
- `POST /api/teams/{teamId}/join` - 加入团队

## 开发说明

### 后端开发
- 使用 MyBatis Plus 简化数据访问
- JWT 进行无状态认证
- 全局异常处理统一响应格式

### 前端开发
- 使用 Vue 3 Composition API
- Element Plus UI 组件库
- Axios 拦截器处理请求/响应
