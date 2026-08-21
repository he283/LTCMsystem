# 轻量任务协作管理系统

一个简洁高效的任务协作管理系统，支持个人任务管理和团队协作。

## 技术栈

### 后端
- Spring Boot 3.1.5
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

### Python Agent 助手（可选，需单独启动）
- Flask 3.0（API 服务，端口 5001）
- LangChain 1.3+（统一大模型抽象）
- LangGraph 1.2+（对话状态机工作流编排）
- LangChain-OpenAI（通过 OpenAI 兼容端点对接大模型）
- agnes-ai API（多供应商预设，默认模型：agnes-2.5-flash，可在 config.py 的 MODEL_PROVIDER 切换）
- PyMySQL（直连 MySQL 查询结构化数据）
- 指定虚拟环境：`D:\Code\python\AI\.venv`

## 项目结构

```
LTCMsystem/
├── backend/                 # 后端项目（Spring Boot，端口 8081）
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
├── frontend/                # 前端项目（Vue3 + Vite，端口 3000）
│   ├── src/
│   │   ├── api/             # API接口
│   │   ├── components/      # 组件（含 AgentChat.vue AI助手聊天窗口）
│   │   ├── router/          # 路由
│   │   ├── utils/           # 工具类
│   │   ├── views/           # 页面（含 Home.vue 侧边栏 AI助手入口）
│   │   ├── App.vue
│   │   └── main.js
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
├── agent/                   # Python Agent 助手（Flask + LangChain + LangGraph，端口 5001）
│   ├── app.py               # Flask 入口（/agent/chat, /agent/chat/stream, /agent/history, /agent/health）
│   ├── config.py            # 配置：DB、大模型 API Key（MODEL_PROVIDER 多供应商，带_env/默认值来源追踪）、LangChain、流式/历史/.venv路径
│   ├── requirements.txt     # Python 依赖
│   ├── start.bat            # Windows 启动脚本
│   ├── test_langgraph.py    # LangChain/LangGraph 集成测试
│   ├── test_llm.py          # 旧版 requests 直连 LLM 测试
│   ├── README.md            # Agent 模块详细文档
│   └── services/
│       ├── db_service.py        # MySQL 查询 + 字段名转换
│       ├── task_analyzer.py     # 任务统计/今日计划/建议算法（已含DONE任务逐条清单）
│       ├── llm_service.py       # 旧版 requests 直连 DeepSeek（降级用）
│       ├── langchain_llm.py     # LangChain ChatOpenAI + LangGraph StateGraph 5节点工作流（含流式版本）
│       ├── chat_history.py      # 聊天历史存储（LRU+TTL 内存缓存，按 chat_id+user_id 隔离）
│       └── chat_service.py      # 对话入口（流式/非流式；优先 LangGraph，失败自动回退纯函数）
└── README.md
```

## 快速开始

### 前置要求

- JDK 17+
- Node.js 16+
- MySQL 8.0+
- Python 3.10+（可选，使用 AI 助手时需要，推荐使用虚拟环境 `D:\Code\python\AI\.venv`）

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

后端将在 http://localhost:8081 启动

### 3. 运行前端

```bash
cd frontend
npm install
npm run dev
```

前端将在 http://localhost:3000 启动

### 4. 运行 AI 助手（可选，推荐）

使用指定的 Python 虚拟环境 `D:\Code\python\AI\.venv`（已预装 LangChain / LangGraph / langchain-openai / flask / pymysql / requests）：

```powershell
# Windows PowerShell
cd agent
& "D:\Code\python\AI\.venv\Scripts\python.exe" app.py
```

Agent 服务将在 http://localhost:5001 启动

验证：
- 健康检查：http://localhost:5001/agent/health
- 前端入口：登录系统后点击侧边栏「AI助手」
- 集成测试：`& "D:\Code\python\AI\.venv\Scripts\python.exe" test_langgraph.py`

> 想关闭大模型/关闭 LangGraph？修改 `agent/config.py` 中 `LLM_ENABLED = False` 或 `USE_LANGGRAPH = False`，服务会自动降级为本地规则回复。

完整启动顺序：**MySQL → Spring Boot(8081) → Agent(5001) → Vite(3000)**

## 默认账号

系统预置的测试账号，密码均为 `123456`：

- admin / 123456 (管理员，全局管理权限)
- user1 / 123456 (张三)
- user2 / 123456 (李四)
- huang / 123456
- xiaofang / 123456
- wanwan / 123456
- xiaotiantian / 123456

## 功能特性

### 用户功能
- 用户注册/登录
- JWT令牌认证
- 用户信息管理（昵称/邮箱修改）
- **头像上传**（个人中心上传，支持 jpg/png/gif/webp ≤2MB，右上角/聊天窗口即时生效）

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
- 团队审批管理（待审批 / **审批记录**两个页签，展示处理人、处理时间、处理备注）
- **转让团队管理员**（仅创建者可转让，创建者降为普通成员，RBAC 角色同步）
- **团队卡片区分「我管理的团队 / 我加入的团队」**（不同颜色标签）
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
- 系统通知、任务通知、**任务分配通知（TASK_ASSIGN，分配/转派任务时提醒新负责人）**、团队申请通知、审批结果通知
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

### AI 智能助手（Python Agent + LangChain + LangGraph + 大模型）
- **自然语言对话**：直接用中文提问，侧边栏「AI助手」聊天窗口交互
- **任务分析报告**：任务总数、状态统计、逾期提醒、高优先级清单、个性化建议
  - ✅ **强制列出任务细节**（修复"只给4个没标题"痛点）：每个状态下的任务都逐条显示「标题 + 编号 T-xxx + 完成/截止时间 + 所属团队」，不会再只说"已完成4个"这种统计数字
- **今日任务规划**：根据逾期程度、优先级、截止时间智能排序推荐前5个任务，配小贴士
- **逾期任务清单**：列出所有逾期任务、逾期天数、所属团队
- **高优先级任务**：汇总高优先级+逾期任务，建议精力充沛时段处理
- **团队信息概览**：所在团队、团队编号、我的角色、创建人、最新未读通知
- **未读通知查询**：最新未读通知列表（前10条）
- **流式输出（仿 DeepSeek 网页版「在线思考」）**：默认走 `/agent/chat/stream`，Flask `stream_with_context` + 前端 `fetch + ReadableStream` 实时渲染；提问后**立即**反馈阶段状态（分析中→查询中→大模型思考中），思考链（reasoning_content）实时渲染「🧠 深度思考」面板，正文为 LLM 原生 token 级流式逐字输出（`LLM_NATIVE_STREAM=False` 可切回旧版"完整生成后打字机"）；最后以 `\0__DONE__:JSON_meta` 携带 token 用量/耗时等元信息
  - **长回复平滑输出**：针对 agnes 等端点会把长正文后半段聚合成巨型 chunk 一次性推送的问题，后端自动把大块拆成小片（40字/片 + 微延迟）转发，保持"逐字输出"观感；思考等待期前端显示「已等待 Ns」实时计时，正文静默期显示「正在继续生成…」提示，杜绝"卡住后一波全出"和误以为卡死
  - **LLM 连通性检测不阻塞**：`/agent/health` 的连通性 ping 改为后台线程 + 30s 缓存，health 接口毫秒级返回（前端永不超时）；连通性标签三态区分：限流(429)→黄色「限流中」、超时→黄色「检查超时」、真实错误→红色「连接失败」
- **聊天历史记录（刷新页面不丢）**：
  - 按 `chat_id + user_id` 隔离，前端 `chat_id` 存在 localStorage；
  - 服务端 LRU+TTL 内存缓存（默认保留 100 条消息 / 4 小时，可配置）；
  - 接口：`GET / DELETE /agent/history/<chat_id>?user_id=uid`；
  - 多轮上下文：LangGraph `classify_intent` 节点会把最近 `CONTEXT_WINDOW_SIZE`（默认 6 轮）带入大模型，让 AI 记得之前聊过什么
- **混合架构**：本地关键词匹配 → MySQL 结构化查询 → 大模型(默认 agnes-2.5-flash，可在 `MODEL_PROVIDER` 切换) 自然语言润色
- **LangGraph 工作流**：意图分类 → 静态回复/数据查询 → LLM润色 → 结果封装，节点链路可追溯；流式版本在 agent 内部实现 2~6 字符打字机增量
- **自动降级**：LangGraph 不可用 → 回退纯函数；LLM 不可用 → 回退本地草稿；始终保证可用
- **Token 节省**：静态意图（问候/帮助/感谢/身份）不调用LLM，仅数据驱动意图调用润色
- **API Key 来源诊断**（根治"填的key不生效"痛点）：
  - `config.py` 的 `_resolve()` 追踪每个关键配置的实际来源（环境变量 DEEPSEEK_API_KEY / config.py 默认值 / MODEL_PROVIDER 预设）；
  - 新增「环境变量总开关」`LLM_USE_ENV`：`0` 表示禁用 env 覆盖、强制用 config.py 预设；`1`（默认）表示启用「LLM_* env > DEEPSEEK_* env > config 默认」三层优先级；
  - `/agent/health` 返回 `config_sources`（精简 8 键：脱敏 Key / Model / Base URL / LLM_USE_ENV，外加旧版 `deepseek_*` 兼容字段 + `llm_enabled`）和 `llm_connectivity`（真实 PING 连通性，附带结构化 `total_tokens / latency_ms` + 简短一行 message，不再打印 request_id）；
  - 启动日志和 /health 都明明白白告诉你"Key 来自环境变量还是 config 默认"，不再猜；
  - 前端 AI 助手聊天窗口顶部点击「供应商·模型名」展开「🔧 配置信息」面板，极简显示 4 行：脱敏 API Key、Model、Base URL、LLM 连通性（来源信息改为鼠标悬停 ⚠️ 图标时才显示，不占版面）。

## API接口

### 认证接口
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册

### 用户接口
- `GET /api/user/info` - 获取当前用户信息
- `PUT /api/user/info` - 修改昵称/邮箱
- `PUT /api/user/password` - 修改密码
- `POST /api/user/avatar` - 上传头像（multipart，字段名 file，返回头像URL）

### 任务接口
- `GET /api/tasks/my` - 获取我的任务
- `GET /api/tasks/team/{teamId}` - 获取团队任务
- `POST /api/tasks` - 创建任务（有负责人时自动发任务分配通知）
- `PUT /api/tasks/{id}` - 更新任务（负责人变更时通知新负责人）
- `DELETE /api/tasks/{id}` - 删除任务
- `PUT /api/tasks/{id}/public` - 切换任务公开状态
- `GET /api/tasks/{id}/change-logs` - 获取任务变更历史

### 团队接口
- `GET /api/teams/my` - 获取我的团队（含当前用户角色 role，用于区分管理/加入）
- `POST /api/teams` - 创建团队
- `POST /api/teams/apply` - 申请加入团队（通过团队编号）
- `POST /api/teams/leave-apply` - 申请退出团队
- `GET /api/teams/applications` - 获取团队申请列表（管理员，支持按 status 过滤）
- `PUT /api/teams/applications/{id}/handle` - 审批申请（管理员，记录处理人与备注）
- `GET /api/teams/{teamId}/members` - 获取团队成员列表
- `POST /api/teams/{teamId}/invite` - 邀请成员
- `DELETE /api/teams/{teamId}/members/{memberId}` - 移除成员
- `PUT /api/teams/{teamId}/transfer-admin` - 转让团队管理员（仅创建者）

### 文件访问
- `GET /uploads/avatar/**` - 头像等上传文件的静态访问（后端本地 uploads 目录，前端经 /uploads 代理）

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

### AI 助手接口（Python Agent，端口 5001，前端通过 /api/agent 代理转发）
- `GET /agent/health` - Agent 服务健康检查（**含配置来源诊断 + LLM 连通性**）
  - 返回结构（已精简，减少 JSON 体积和前端渲染压力）：
    - `ok / version / uptime_ms`：基础健康信息
    - `config_sources`：8 键极简版
      - `api_key / model / base_url`（新版字段，各含 `value` 脱敏值、`source` 来源短标签、可选 `provider` 供应商简称）
      - `deepseek_api_key / deepseek_model / deepseek_base_url`（旧版兼容字段，同样 `value+source` 短版）
      - `llm_use_env`（含 `value` 布尔、`label` 显示文字、`source`）
      - `llm_enabled`（含 `value` 布尔）
      - *注*：原 model_provider / supported / tip / show_reasoning / use_langgraph / llm_* 大段 tip 等冗余字段已全部删除，顶级 `llm_params` 整块也不再返回
    - `llm_connectivity`：`ping_ok / message（一行简略版，无 request_id 尾巴）/ total_tokens / latency_ms / model_provider / model_name / base_url`
  - **连通性 ping 为后台异步检测**（结果缓存 30s）：health 接口毫秒级返回，首次调用 `ping_ok` 可能为 `null`（检测中），稍后刷新即可看到结果；前端不会因 ping 慢而超时
  - 前端「供应商·模型名」一键展开的「🔧 配置信息」面板只显示 4 行：API Key（脱敏）/ Model / Base URL / LLM 连通性；来源信息改在 ⚠️ 图标悬停 tooltip 查看
- `POST /agent/chat` - 对话接口（非流式，一次性返回）
  - 请求：`{ "user_id": 1, "message": "我的任务", "chat_id": "chat_xxx"  // 可选，用于历史+上下文 }`
  - 响应：`{ "reply": { "type":"markdown", "content":"...", "data":{...}, "meta":{ "intent":"task_analysis", "used_llm":true, "used_langgraph":true, "steps":[...], "llm_latency_ms":4216, "llm_usage":{...} } } }`
- `POST /agent/chat/stream` - **对话接口（流式输出 SSE / text/plain）**——默认使用
  - 请求：`{ "user_id": 1, "message": "我的任务", "chat_id": "chat_xxx" }`
  - 响应头：`Content-Type: text/plain; charset=utf-8; Cache-Control: no-cache; X-Accel-Buffering: no`
  - 传输格式（默认「原生流式」，`LLM_NATIVE_STREAM=True`）：三类内容混排——正文增量（LLM token 级流式/静态模板打字机）、控制事件 `\0__EVENT__:{json}\n`（status=阶段状态"分析中/查询中/思考中"、reasoning=思考链增量）、结束标记 `\0__DONE__:` + JSON meta：`{ "type":"markdown", "used_llm":true, "used_langgraph":true, "intent":"task_analysis", "llm_latency_ms":4216, "llm_usage":{...}, "data":{...} }`
  - 前端识别规则：缓冲区内找 `\0` 定位——`\0__EVENT__:` 解析控制事件（不拼正文）、遇到 `\0__DONE__:` 停止拼正文、取后半 JSON 解析为 meta 落地
  - `LLM_NATIVE_STREAM=False` 时退化为旧版：完整生成后按 2~6 字符打字机，无事件，前端完全兼容
- `GET /agent/history/<chat_id>?user_id=uid` - 获取指定会话的聊天历史（按时间升序，刷新页面后用它恢复记录）
  - 返回：`{ "chat_id": "...", "total": 12, "messages": [ { "role":"user"/"agent", "content":"...", "type":"markdown"/"text", "timestamp":"ISO", "meta":{...} }, ... ] }`
- `DELETE /agent/history/<chat_id>?user_id=uid` - 清空指定会话的聊天历史
- `GET /agent/task-analysis/{user_id}` - 获取任务分析报告（JSON结构化数据，已新增 `tasks_by_status` 按状态分组清单、`done_tasks` 全部已完成按完成时间倒序、`done_tasks_recent` 近7天已完成，每条都带 `title/task_code/done_time/team_name`）
- `GET /agent/team-analysis/{user_id}` - 获取团队信息概览（JSON结构化数据）

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

### Agent 开发（Python + LangChain + LangGraph）
- **双路径架构 + 流式/非流式双入口**：
  - `services/chat_service.py` 中 `get_reply()`（非流式）/ `get_reply_stream()`（流式 generator）优先走 LangGraph，失败自动回退纯函数；
  - 流式由 `langchain_llm.invoke_agent_via_langgraph_stream()` 先拿到完整 content，再按 2~6 字符随机增量吐出，兼容不支持原生 stream 的模型；最后吐 `\0__DONE__:` + meta JSON；
  - 流式结束时 chat_service 会从 DONE 行拿 meta，把 assistant 回复连同 meta 一起追加到 `chat_history`。
- **LangGraph 状态机 5 节点**：`classify_intent`（带上下文记忆）→ `static_reply`/`data_query` → `llm_polish`(可选) → `finalize`，代码见 `services/langchain_llm.py`
- **上下文记忆（多轮对话）**：`chat_history.get_llm_context_messages(chat_id, user_id, CONTEXT_WINDOW_SIZE)` 取最近 N 轮（默认 6 轮）拼进 `_build_llm_messages` 带给大模型，省 Token 又能记得前文；`CONTEXT_WINDOW_SIZE=0` 可完全关闭
- **聊天历史持久层**：`services/chat_history.py`，线程安全的 `OrderedDict` LRU + TTL（默认 4h，`CHAT_HISTORY_TTL_SECS` 可调），每个 `(chat_id,user_id)` 最多缓存 `CHAT_HISTORY_MAX_MSGS`（默认 100）条，过期自动清理；刷新页面通过 `GET /agent/history/<chat_id>` 恢复
- **任务细节强制列出**（本地草稿 + LLM 双保险）：
  - 本地：`_reply_task_analysis / _reply_today_tasks / _reply_overdue_tasks / _reply_high_priority` 逐条输出「`1. 「标题」 T-xxx  (完成/截止 yyyy-MM-dd HH:mm)  [团队名]`」；
  - LLM：System Prompt 第 2 条强制规则"上下文中有 done_tasks 等数组的必须逐条列出标题+编号，禁止只说统计数"。
- **配置来源追踪 + API Key 生效诊断**：
  - `config.py` 的 `_resolve(key, default)` 返回 `(实际值, 来源说明)`，对 `DEEPSEEK_API_KEY / DEEPSEEK_MODEL / LLM_ENABLED / USE_LANGGRAPH / CONTEXT_WINDOW_SIZE / CHAT_HISTORY_ENABLED / ...` 都有 `XXX_SRC` 记录来源；
  - 优先级硬规则：**系统环境变量 DEEPSEEK_API_KEY > config.py 默认值**；
  - `/agent/health` 返回 `config_sources[*].tip` 会写明"如需切回 config.py 默认值，请删除系统/用户环境变量 DEEPSEEK_API_KEY 后重启服务"；
  - 启动日志 stdout 和 Flask logger 都会打印 `api_key=sk-db****ee6a  (来源: 环境变量 DEEPSEEK_API_KEY)` 等一行信息。
- **模型接入**：`ChatOpenAI(api_key, base_url=<MODEL_PROVIDER 对应端点>, model="agnes-2.5-flash")`，与 OpenAI API 完全兼容；供应商/模型在 `agent/config.py` 的 `MODEL_PROVIDER` 预设中切换（agnes / deepseek 等）
- **数据安全**：API Key 日志脱敏 `sk-****rkQJ`，推荐通过环境变量注入
- **成本控制**：静态意图（greeting/help/thanks/who）100% 本地模板；仅数据驱动意图调用 LLM 润色；`LLM_ENABLED=False` 全局关闭
- **高可用降级链**：LangGraph 导入异常 → 纯函数；LangChain ChatOpenAI 调用失败 → requests 直连；requests 也失败 → 本地草稿
- **虚拟环境**：所有依赖安装到 `D:\Code\python\AI\.venv`，不要使用全局 Python 解释器运行/安装
- **更多细节**：见 [agent/README.md](agent/README.md)

## 生产环境部署检查清单

- [x] 恢复密码验证逻辑 (UserServiceImpl.java)
- [x] 收紧 Spring Security 配置，只放行 `/api/auth/**`、`/api/public/**`、`/uploads/**` (SecurityConfig.java + JwtAuthenticationFilter)
- [x] 启用JWT拦截器 (WebMvcConfig.java)
- [x] 移除默认用户ID逻辑 (UserContext.java)
- [x] 配置安全的JWT密钥（HS256 256位以上，考虑使用环境变量）
- [ ] 配置HTTPS
- [ ] 配置正确的CORS策略，限制允许的源
- [ ] 禁用SQL日志输出
- [ ] 配置生产级别的数据库连接池
- [ ] 添加日志记录和监控
- [ ] 配置数据备份策略
