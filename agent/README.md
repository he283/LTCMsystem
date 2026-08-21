# 🤖 LTCM Agent 助手

基于 Flask 开发的智能助手服务，为轻量任务协作管理系统提供：

- ✅ **任务分析报告**：统计、逾期提醒、优先级分析、个性化建议（**强制列出每个任务的标题/编号/完成时间**，不再只给统计数字）
- ✅ **今日任务规划**：根据优先级和截止时间智能推荐今日任务
- ✅ **团队信息查询**：所在团队、角色、未读通知
- ✅ **自然语言对话**：直接用中文提问，如"我今天做什么"、"有没有逾期任务"
- ✅ **大模型增强（多供应商）**：数据驱动查询由大模型生成自然语言、有洞察的回复（默认 `agnes-2.5-flash`，可切 `hy3` / `deepseek`，见 MODEL_PROVIDER）
- ✅ **LangChain + LangGraph 状态机**：工作流可视化编排，节点路由清晰可追溯
- ✅ **流式输出（仿 DeepSeek 网页版「在线思考」）**：`POST /agent/chat/stream`，Flask stream_with_context + 前端 `fetch + ReadableStream`；提问后立即反馈阶段状态（分析中/查询中/思考中），思考链（reasoning_content）实时渲染「🧠 深度思考」面板，正文 LLM 原生 token 级流式逐字输出（`LLM_NATIVE_STREAM` 可切回旧版打字机）；**长回复自动拆小片（40字/片）平滑输出**，等待期实时显示「已等待 Ns」计时、正文静默期显示「正在继续生成…」
- ✅ **聊天历史记录（刷新不丢）**：LRU+TTL 内存缓存，按 `chat_id + user_id` 隔离，接口 `GET/DELETE /agent/history/<chat_id>`，默认支持 6 轮上下文带给 LLM
- ✅ **配置来源诊断面板**：`_resolve()` 追踪 API Key / 模型等配置到底来自「环境变量」还是「config.py 默认值」，解决"我填的 key 不生效"困惑；`/agent/health` 同时做大模型 PING 连通性检测（**后台异步检测 + 缓存，health 毫秒级返回，前端永不超时**）

---

## 🏗️ 技术架构

### 核心框架栈

| 层次 | 技术 | 说明 |
|------|------|------|
| Web 服务 | Flask 3.0 | API 接口层，端口 5001；支持流式（stream_with_context + text/plain + no-cache） |
| 数据库 | PyMySQL | 直连 MySQL LTCMsystem 数据库查询结构化数据 |
| 大模型接入 | LangChain ChatOpenAI | 对接 OpenAI 兼容端点（默认 agnes-ai：apihub.agnes-ai.com） |
| 对话工作流 | LangGraph StateGraph | 状态机编排：意图识别（含上下文记忆）→ 查DB → LLM润色 → 返回；含流式版本 |
| 模型 | agnes-2.5-flash（默认） | 可在 MODEL_PROVIDER 切换：hy3（腾讯混元）/ deepseek 官方 |
| 聊天历史 | LRU + TTL 内存缓存 | services/chat_history.py，按 chat_id + user_id 隔离，默认 100 条 / 4 小时 |
| 配置诊断 | _resolve() 来源追踪 | 每个关键配置都能告知「来自环境变量」还是「config.py 默认值」，并附解决 tip |
| 降级机制 | 本地规则 + requests 直连 | LLM/LangGraph 不可用时自动降级，保证可用性；本地草稿**强制列出任务标题+编号** |

### LangGraph 工作流（状态机）

```
START → classify_intent（意图识别，关键词匹配）
           │
    ┌──────┴───────────────────────────────┐
    │ 条件路由                              │
    ▼                                       ▼
static_reply（静态意图）             data_query（数据驱动意图）
│  • greeting / help / thanks       │  • task_analysis / today_tasks
│  • who_are_you                    │  • overdue / high_priority
│  • unknown（无模糊命中）          │  • team_analysis / notifications
│  本地模板直接返回，不调LLM        │  • unknown（模糊命中"任务/团队"等）
│                                    │  查 MySQL + 生成本地草稿
└───────────┬────────────────────────┘
            │
     finalize（封装统一返回格式）
            │
            ▼
          END
     
注意：data_query 节点完成后会进入条件路由：
  • LLM_ENABLED=True 且 context_data 非空 → llm_polish（LangChain 调用当前 MODEL_PROVIDER 的模型润色）
  • 否则 → 直接跳过润色，使用本地草稿
  • llm_polish 失败 → 自动 fallback 到本地草稿（不报错、不影响使用）
```

### 混合架构设计原则

1. **静态意图不浪费 Token**：问候、帮助等模板回复直接用本地内容
2. **数据驱动先查库再润色**：所有任务/团队查询先取结构化数据，LLM只负责"把数据说得更自然"
3. **失败自动降级**：LLM 不可用时仍然能给出基础数据查询结果
4. **输出格式稳定**：无论走哪条路径，返回给前端的 JSON 结构完全一致

---

## ⚙️ 配置说明（config.py）

```python
# ============================================================
# 配置优先级硬规则（很重要！解决"我换了模型/Key却不生效"困惑）
# ============================================================
#  第 0 步：通过 MODEL_PROVIDER 选择供应商预设（可选 agnes-2.5-flash / hy3 / deepseek）
#  第 1 步：LLM_API_KEY / LLM_BASE_URL / LLM_MODEL 环境变量（最高优先级）
#  第 2 步：DEEPSEEK_API_KEY / DEEPSEEK_BASE_URL / DEEPSEEK_MODEL 环境变量（兼容历史写法）
#  第 3 步：当前 MODEL_PROVIDER 预设的 default_xxx 值
#  config.py 用 _resolve() / _resolve_llm_config() 统一追踪真实来源：
#       返回 (实际值, 来源描述字符串)，每个关键配置对应 XXX_SRC 变量记录来源

# ===== 服务 =====
AGENT_HOST = '0.0.0.0'
AGENT_PORT = 5001

# ===== 数据库 =====
DB_HOST / DB_PORT / DB_USER / DB_PASSWORD / DB_NAME (LTCMsystem)

# ===== ★★★ 大模型供应商选择（MODEL_PROVIDER）★★★ =====
#   agnes-2.5-flash → agnes-ai 端点（默认；apihub.agnes-ai.com，模型 agnes-2.5-flash）
#   hy3            → 腾讯混元 huanyuan3（tokenhub.tencentmaas.com）
#   deepseek       → DeepSeek 官方端点（api.deepseek.com，deepseek-v4-flash）
MODEL_PROVIDER, MODEL_PROVIDER_SRC = _resolve('MODEL_PROVIDER', 'agnes-2.5-flash')
MODEL_PROVIDER = MODEL_PROVIDER.lower().strip() or 'agnes-2.5-flash'

_PROVIDER_PRESETS = {
    'deepseek':   {'default_base_url':'https://api.deepseek.com/v1',
                   'default_api_key': 'your-deepseek-key-here',
                   'default_model':   'deepseek-v4-flash',
                   'display_name':    'DeepSeek 官方'},
    'agnes-2.5-flash': {'default_base_url':'https://apihub.agnes-ai.com/v1/chat/completions',
                        'default_api_key': 'sk-xxx（已预设）',
                        'default_model':   'agnes-2.5-flash',
                        'display_name':    'agnes'},
    'hy3':       {'default_base_url':'https://tokenhub.tencentmaas.com/v1',
                  'default_api_key': 'sk-xxx（已预设）',
                  'default_model':   'hy3',
                  'display_name':    'huanyuan3'},
}
_preset = _PROVIDER_PRESETS.get(MODEL_PROVIDER, _PROVIDER_PRESETS['agnes-2.5-flash'])
MODEL_PROVIDER_DISPLAY = _preset.get('display_name', MODEL_PROVIDER)

# ===== 通用 LLM 三件套（新代码 import LLM_*，老代码仍读 DEEPSEEK_*，二者是 alias） =====
def _resolve_llm_config(env_key_primary, env_key_fallback, provider_default):
    env_p = os.getenv(env_key_primary)
    if env_p is not None and env_p != '': return env_p, f'环境变量 {env_key_primary}'
    env_f = os.getenv(env_key_fallback)
    if env_f is not None and env_f != '': return env_f, f'环境变量 {env_key_fallback}（兼容旧版）'
    return provider_default, f'{MODEL_PROVIDER_DISPLAY} 预设（MODEL_PROVIDER="{MODEL_PROVIDER}"）'

LLM_BASE_URL, LLM_BASE_URL_SRC = _resolve_llm_config('LLM_BASE_URL', 'DEEPSEEK_BASE_URL', _preset['default_base_url'])
LLM_API_KEY,  LLM_API_KEY_SRC  = _resolve_llm_config('LLM_API_KEY',  'DEEPSEEK_API_KEY',  _preset['default_api_key'])
LLM_MODEL,    LLM_MODEL_SRC    = _resolve_llm_config('LLM_MODEL',    'DEEPSEEK_MODEL',    _preset['default_model'])
DEEPSEEK_BASE_URL    = LLM_BASE_URL      # 兼容历史写法
DEEPSEEK_API_KEY     = LLM_API_KEY
DEEPSEEK_MODEL       = LLM_MODEL

# 总开关 / 请求参数
LLM_ENABLED, LLM_ENABLED_SRC   = _resolve('LLM_ENABLED', 'True'); LLM_ENABLED = str(LLM_ENABLED).lower()=='true'
DEEPSEEK_TIMEOUT     = int(_resolve('LLM_TIMEOUT',     '30')[0])
DEEPSEEK_TEMPERATURE = float(_resolve('LLM_TEMPERATURE', '0.7')[0])
DEEPSEEK_MAX_TOKENS  = int(_resolve('LLM_MAX_TOKENS',  '2000')[0])
LLM_FALLBACK_TO_LOCAL = True

# 思维链（Reasoning / reasoning_content）显示
#   部分供应商端点（如 agnes-2.5-flash、DeepSeek-R1 等）会返回推理过程文本；
#   True=用 <details><summary>🧠 思考过程</summary>...</details> 折叠块和答案一起渲染；
#   False=只输出最终回答，不显示推理过程（更简洁，token消耗一样）
SHOW_REASONING, SHOW_REASONING_SRC = _resolve('SHOW_REASONING', 'True')
SHOW_REASONING = (str(SHOW_REASONING).lower() == 'true')

# ===== LangChain + LangGraph =====
USE_LANGGRAPH         = True             # True=走LangGraph，False=走纯函数
LANGSMITH_TRACING     = False            # 可选：LangSmith追踪
LANGSMITH_API_KEY     = 'ls_xxx'
LANGSMITH_PROJECT     = 'LTCM-Agent'

# ===== 对话记忆 / 聊天历史 =====
CONTEXT_WINDOW_SIZE   = int(_resolve('CONTEXT_WINDOW_SIZE', '6')[0])
CHAT_HISTORY_ENABLED  = _resolve('CHAT_HISTORY_ENABLED', 'True')[0].lower() == 'true'
CHAT_HISTORY_MAX_MSGS = int(_resolve('CHAT_HISTORY_MAX_MSGS', '100')[0])
CHAT_HISTORY_TTL_SECS = int(_resolve('CHAT_HISTORY_TTL_SECS', str(60*60*4))[0])

# ===== 流式输出 =====
STREAM_ENABLED        = _resolve('STREAM_ENABLED', 'True')[0].lower() == 'true'

# ===== Python解释器路径（本项目指定）=====
VENV_PYTHON = r'D:\Code\python\AI\.venv\Scripts\python.exe'
```

### 一键切换供应商（不用改 config.py 代码，用环境变量更方便）

```bash
# 1️⃣ 切换到 agnes（默认推荐 —— 已在 config.py 预设好 base_url、api_key、model）
set MODEL_PROVIDER=agnes-2.5-flash
# 如要自定义 Key（覆盖预设的 sk-xxx）：
set LLM_API_KEY=sk-your-own-agnes-key

# 2️⃣ 切换到腾讯混元 huanyuan3（tokenhub.tencentmaas.com）
set MODEL_PROVIDER=hy3

# 3️⃣ 切换到 DeepSeek 官方
set MODEL_PROVIDER=deepseek
set LLM_API_KEY=sk-your-own-deepseek-key

# 4️⃣ 任意 OpenAI 兼容端点（SiliconFlow / OneAPI / 本地 vLLM 等），自己填三件套
set LLM_BASE_URL=https://api.siliconflow.cn/v1
set LLM_API_KEY=sk-your-siliconflow-key
set LLM_MODEL=deepseek-ai/DeepSeek-V4-Flash-0731

# 其他常用：
set LLM_ENABLED=True
set USE_LANGGRAPH=True
set CONTEXT_WINDOW_SIZE=6
set STREAM_ENABLED=True
set SHOW_REASONING=True          # True=显示思维链，False=只看最终回答

# 想确认到底哪个生效？
#   方式一：启动 agent 后命令行第一块 → 每行都带 "(来源: ...)"
#   方式二：GET /agent/health → config_sources.api_key + model + base_url
#   方式三：前端 AI 助手聊天窗口顶部「供应商·模型名」一键展开「🔧 配置信息」面板
```

### 想让 config.py 预设的 key 生效？先清掉环境变量再重启

```powershell
# 1. PowerShell 清除当前会话的环境变量
Remove-Item Env:MODEL_PROVIDER, Env:LLM_API_KEY, Env:LLM_BASE_URL, Env:LLM_MODEL, Env:DEEPSEEK_API_KEY -ErrorAction SilentlyContinue
# 2. 如果是「系统属性 → 高级 → 环境变量」窗口里手动加的，去那里删除对应变量；
# 3. 关掉所有 CMD / PowerShell 窗口，重新开一个；
# 4. 重启 agent，再看启动日志 "(来源: agnes 预设 ...)" → 就是 config 的预设生效了。
```

---

## 🚀 快速启动

### 前置条件

- **Python 虚拟环境**：`D:\Code\python\AI\.venv`（已预装 langchain、langgraph、langchain-openai、flask、pymysql、requests）
- **MySQL 数据库**：LTCMsystem 运行中，`root / 123456`（默认）
- **大模型 API Key**：已在 `config.py` 预设（agnes-2.5-flash 默认）或通过环境变量覆盖

### 方式一：使用指定 .venv 直接启动（推荐）

```powershell
# Windows PowerShell
cd D:\Code\LTCMsystem\agent
& "D:\Code\python\AI\.venv\Scripts\python.exe" app.py
```

服务启动后：
- Agent 服务：http://localhost:5001
- 健康检查：http://localhost:5001/agent/health
- 前端访问：启动 Spring Boot(8081) + Vite(3000) 后，侧边栏「AI助手」

### 方式二：使用启动脚本（Windows）

检查 `start.bat` 中的解释器路径是否指向 `.venv`，然后双击运行。

### 方式三：手动新建虚拟环境

若不想使用 `D:\Code\python\AI\.venv`，可自行创建：

```bash
cd agent
python -m venv venv
venv\Scripts\activate      # Windows
pip install -r requirements.txt
python app.py
```

---

## 🧪 运行测试

```powershell
# 1. LangChain + LangGraph 集成测试（推荐，覆盖所有节点和路径）
& "D:\Code\python\AI\.venv\Scripts\python.exe" D:\Code\LTCMsystem\agent\test_langgraph.py

# 2. 纯 requests 版 LLM 测试（旧路径回归）
& "D:\Code\python\AI\.venv\Scripts\python.exe" D:\Code\LTCMsystem\agent\test_llm.py
```

test_langgraph.py 会输出：
- 环境版本检查（.venv 匹配、langchain/langgraph 版本）
- ChatModel 连通性（PING→PONG）
- LangGraph 静态/数据驱动/模糊匹配 各节点链路
- chat_service 集成（自动路径选择）
- 完整对话示例展示

---

## 🔌 API 接口

### 1. 健康检查（含配置来源诊断 + LLM 连通性 PING，毫秒级返回）
```
GET /agent/health
```
响应示例（重点：`config_sources` 告诉你 Key 来自哪里，`llm_connectivity` 验证能不能真连上大模型）：
```json
{
  "status": "ok",
  "agent_name": "LTCM小助手",
  "version": "1.2.0",
  "features": {
    "llm_enabled": true,
    "use_langgraph": true,
    "stream_enabled": true,
    "chat_history_enabled": true,
    "context_window_size": 6
  },
  "config_sources": {
    "api_key":       {"value": "sk-Iu****rkQJ", "source": "config.py 预设（MODEL_PROVIDER=\"agnes-2.5-flash\"）", "provider": "agnes"},
    "model":         {"value": "agnes-2.5-flash", "source": "config.py 预设（MODEL_PROVIDER=\"agnes-2.5-flash\"）", "provider": "agnes"},
    "base_url":      {"value": "https://apihub.agnes-ai.com/v1/chat/completions", "source": "config.py 预设（MODEL_PROVIDER=\"agnes-2.5-flash\"）"},
    "llm_use_env":   {"value": false, "label": "禁用（强制用 config.py）", "source": "config.py 默认值"},
    "deepseek_api_key":  {"value": "sk-Iu****rkQJ", "source": "config.py 预设（MODEL_PROVIDER=\"agnes-2.5-flash\"）"},
    "deepseek_base_url": {"value": "https://apihub.agnes-ai.com/v1/chat/completions", "source": "config.py 预设（MODEL_PROVIDER=\"agnes-2.5-flash\"）"},
    "deepseek_model":    {"value": "agnes-2.5-flash", "source": "config.py 预设（MODEL_PROVIDER=\"agnes-2.5-flash\"）"},
    "llm_enabled":   {"value": true}
  },
  "llm_connectivity": {
    "ping_ok": true,
    "message": "连接成功（12 tokens / 345ms）"
  }
}
```
> **连通性 ping 为后台异步检测**：`ping_ok` 首次请求可能为 `null`（检测中），缓存 30s 自动刷新；health 接口本身永远毫秒级返回，前端不会因 ping 慢而超时。`ping_ok=false` 时的 message 会区分：限流(429)/超时/真实鉴权错误。

### 2. 发送消息（对话·非流式 一次性返回）
```
POST /agent/chat
Content-Type: application/json

{
  "user_id": 1,
  "message": "我今天做什么",
  "chat_id": "chat_202608081730_9fa2"
}
```
> `chat_id` 可选但强烈建议传——用于**持久化聊天历史**（`GET /agent/history/<chat_id>` 恢复）和**带入 LLM 多轮上下文**（CONTEXT_WINDOW_SIZE 默认 6 轮）

响应示例：
```json
{
  "code": 200,
  "data": {
    "reply": {
      "type": "markdown",
      "content": "下午好，管理员！☕ 今天推荐你先处理这些：\n 1. 「UI登录页改版」 T-1024  (截止 2026-08-08 18:00) [产品研发组] ⚠️即将逾期 🔴高优...",
      "data": { /* 结构化上下文，可用于前端渲染卡片 */ },
      "meta": {
        "intent": "today_tasks",
        "used_llm": true,
        "used_langgraph": true,
        "steps": ["classify_intent", "data_query", "llm_polish", "finalize"],
        "llm_latency_ms": 4216.3,
        "llm_usage": {
          "prompt_tokens": 1820,
          "completion_tokens": 312,
          "total_tokens": 2132
        }
      }
    },
    "agent_name": "LTCM小助手",
    "timestamp": "2026-08-08 17:30:24"
  }
}
```

### 2a. 发送消息（对话·**流式输出** ✨ 默认推荐，仿 DeepSeek 网页版「在线思考」）
```
POST /agent/chat/stream
Content-Type: application/json

{
  "user_id": 1,
  "message": "我今天做什么",
  "chat_id": "chat_202608081730_9fa2"
}
```
响应头：
```
Content-Type: text/plain; charset=utf-8
Cache-Control: no-cache, no-transform
X-Accel-Buffering: no
Connection: keep-alive
```

传输格式（三类内容混在一起，前端按 `\0` 前缀区分）：
```
\0__EVENT__:{"type":"status","phase":"analyze","label":"正在分析你的问题…"}
\0__EVENT__:{"type":"status","phase":"query","label":"正在查询你的任务数据…"}
\0__EVENT__:{"type":"status","phase":"llm","label":"🧠 大模型正在思考…"}
\0__EVENT__:{"type":"reasoning","text":"用户"}
\0__EVENT__:{"type":"reasoning","text":"查看"}
下午好
，管理员！
☕ 今天推荐你先处
理这些...
\0__DONE__:{"type":"markdown","used_llm":true,"used_langgraph":true,"intent":"today_tasks","llm_latency_ms":4216.3,"llm_usage":{"prompt_tokens":1820,"completion_tokens":312,"total_tokens":2132}}
```

协议约定（v2 原生流式，`LLM_NATIVE_STREAM=True` 时生效）：
- **正文增量**：普通文本 chunk（LLM 原生 token 级流式，边生成边吐出；静态意图/本地草稿为 2~6 字符打字机；**巨型 chunk 自动拆成 40 字/片平滑转发**，避免"卡住后一波全出"）
- **控制事件**：`\0__EVENT__:{json}\n`，单行完整 JSON，前端按 `\0` 前缀识别、不拼入正文
  - `{"type":"status","phase":"analyze|query|llm|reply|fallback","label":"展示文案"}` —— 阶段状态，前端显示"思考中"状态条（LLM 阶段等待期实时显示「已等待 Ns」计时）
  - `{"type":"reasoning","text":"思考链增量"}` —— 大模型思考过程（部分端点会返回），前端实时渲染到「🧠 深度思考」面板
- **结束标记**：`\0__DONE__:{json}` —— 前面拼的字符串是正文 content，后面 JSON 作为 meta 落地（与旧版一致）
- 前端解析约定：
  - 不要用 axios，直接 `fetch(url).then(r => r.body.getReader())` 拿 `ReadableStream`；
  - 缓冲区内找 `\0` 定位控制消息：`\0__EVENT__:` 解析事件（等 `\n` 收尾），`\0__DONE__:` 解析 meta 结束；
  - 参考实现：`frontend/src/components/AgentChat.vue#handleSend()`；
- 旧版行为（`LLM_NATIVE_STREAM=False`）：不吐事件，正文为完整生成后的 2~6 字符打字机，前端完全兼容。

### 3. 聊天历史（按 chat_id 拉取 / 清空）
```
# 拉取会话记录（刷新页面后恢复）
GET    /agent/history/<chat_id>?user_id=1

# 清空会话记录（点"清空聊天"时调用，前端接着会重新生成新的 chat_id 开始新对话）
DELETE /agent/history/<chat_id>?user_id=1
```
`GET` 响应示例：
```json
{
  "chat_id": "chat_202608081730_9fa2",
  "total": 8,
  "messages": [
    { "role": "user",   "content": "我的任务", "timestamp": "2026-08-08T17:28:01.221Z" },
    { "role": "agent",  "content": "好的，你的任务分析如下...", "type": "markdown",
      "timestamp": "2026-08-08T17:28:05.891Z", "meta": { "intent": "task_analysis", "used_llm": true } },
    ...
  ]
}
```

### 4. 获取任务分析报告
```
GET /agent/task-analysis/{user_id}
```
返回新增：
- `tasks_by_status`: 按状态（PENDING_ASSIGN / IN_PROGRESS / PENDING_REVIEW / DONE / CANCELLED）分组的**任务数组**，每条含 `title / task_code / done_time / due_date / team_name / priority / is_overdue`
- `done_tasks`: 所有已完成任务按完成时间倒序
- `done_tasks_recent`: 近 7 天已完成任务

### 5. 获取团队分析
```
GET /agent/team-analysis/{user_id}
```

---

## 💬 支持的对话示例

| 你可以问 | 匹配意图 | 调用路径 | 会用LLM吗 |
|---------|---------|---------|----------|
| `我的任务` / `任务分析` / `统计任务` | task_analysis | data_query → llm_polish | ✅ 是 |
| `今天做什么` / `今日任务` / `今天安排` | today_tasks | data_query → llm_polish | ✅ 是 |
| `逾期任务` / `过期了的` | overdue_tasks | data_query → llm_polish | ✅ 是 |
| `高优先级` / `紧急任务` | high_priority | data_query → llm_polish | ✅ 是 |
| `我的团队` / `团队情况` | team_analysis | data_query → llm_polish | ✅ 是 |
| `通知` / `未读消息` / `提醒` | notifications | data_query → llm_polish | ✅ 是 |
| `帮助` / `功能` / `怎么用` | help | static_reply → finalize | ❌ 否（省Token）|
| `你好` / `hi` / `哈喽` | greeting | static_reply → finalize | ❌ 否 |
| `谢谢` / `thx` | thanks | static_reply → finalize | ❌ 否 |
| `你是谁` / `自我介绍` | who_are_you | static_reply → finalize | ❌ 否 |
| `我最近要做什么`（模糊） | unknown → fuzzy | data_query → llm_polish | ✅ 是 |
| `今天天气怎么样`（未命中） | unknown | static_reply（引导语）| ❌ 否 |

---

## 📁 目录结构

```
agent/
├── app.py                      # Flask入口，注册/agent/*路由（health 含异步 ping 缓存）
├── config.py                   # 全部配置（服务、DB、LLM 多供应商、LangGraph）
├── requirements.txt            # Python依赖（flask、pymysql、requests、langchain、langgraph、langchain-openai）
├── start.bat                   # Windows启动脚本（检查.venv路径）
├── test_llm.py                 # 旧版 requests 直连大模型测试
├── test_langgraph.py           # LangChain + LangGraph 综合集成测试
├── test_agent.py               # Agent 端到端对话测试
├── test_modelscope_standalone.py # 单一供应商连通性独立测试
├── README.md                   # 本文件
└── services/
    ├── __init__.py
    ├── db_service.py           # MySQL 查询 + 下划线→驼峰转换
    ├── task_analyzer.py        # 任务统计、今日计划、建议生成算法（已含DONE任务逐条清单）
    ├── llm_service.py          # 旧版 requests 直连 + 重试/脱敏（降级用）
    ├── langchain_llm.py        # LangChain ChatOpenAI + LangGraph StateGraph 5节点（含流式/大块拆小）
    ├── chat_history.py         # 聊天历史存储（LRU+TTL 内存缓存，按 chat_id+user_id 隔离）
    └── chat_service.py         # 对话入口：流式/非流式；优先LangGraph，失败回退纯函数
```

---

## 🔧 常见问题

### Q1：想临时关闭 LangGraph，用纯函数模式？
改 `config.py` 中 `USE_LANGGRAPH = False`，功能完全可用，只是工作流不经过 LangGraph 节点。

### Q2：想完全不用大模型（省 API 费用）？
改 `config.py` 中 `LLM_ENABLED = False`，所有回复都会用本地规则生成的草稿版本返回。

### Q3：LangGraph 或 LangChain 导入失败？
确认使用的解释器是 `D:\Code\python\AI\.venv\Scripts\python.exe`，运行：
```
& "D:\Code\python\AI\.venv\Scripts\pip.exe" install -r requirements.txt --upgrade
```

### Q4：返回结果总是使用本地草稿（used_llm=False）？
- 检查 `LLM_ENABLED` 为 True
- 检查 `DEEPSEEK_API_KEY` 是否正确（长度>=10且非占位符）
- 运行 `test_langgraph.py` 查看 连通性测试 是否通过
- 查看 Flask 日志中的 `[LLM]` 或 `[LangGraph]` 报错信息（会自动降级但不抛错到前端）

### Q5：API Key 日志会不会泄露？
不会。`llm_service.py` 和 `langchain_llm.py` 日志中 Key 会脱敏显示为 `sk-db****ee6a` 格式。

### Q6：我在 config.py 里填的 API Key 没生效？实际调用的是另一个 Key！
这是**最常见的问题**——因为系统/用户环境变量的优先级高于 config.py。
1. 先打开 `GET /agent/health` 或前端聊天窗口「🔧 配置信息」面板，看 `config_sources.api_key.source`：
   - 显示 `(来源: 环境变量 LLM_API_KEY / DEEPSEEK_API_KEY)` → 你电脑里设了环境变量，把 config.py 的值覆盖了；
   - 显示 `(来源: config.py 预设 ...)` → 走的是 config.py 里写的。
2. 想让 config.py 的值生效：
   ```powershell
   # 1. 清掉当前 PowerShell 会话的环境变量
   Remove-Item Env:MODEL_PROVIDER, Env:LLM_API_KEY, Env:LLM_BASE_URL, Env:LLM_MODEL, Env:DEEPSEEK_API_KEY -ErrorAction SilentlyContinue
   # 2. 如果是「系统属性 → 高级 → 环境变量」里加的，去那里删除对应变量；
   # 3. 关掉所有 CMD / PowerShell 窗口，重新开一个；
   # 4. 重启 agent，再看 /agent/health 的 source，应该已经变成 config.py 预设了。
   ```
3. 注：`LLM_USE_ENV=0`（config.py 默认）会**禁用环境变量覆盖**，强制用 config.py 预设；设为 `1` 才启用「LLM_* env > DEEPSEEK_* env > config 默认」三层优先级。

### Q7：流式输出怎么用？跟 /agent/chat 有什么区别？
- `/agent/chat`：一次性返回完整 JSON，请求可能要等 5~20s；
- `/agent/chat/stream`：**默认启用「原生流式」（`LLM_NATIVE_STREAM=True`，仿 DeepSeek 网页版）**：
  - 提问后**立即**收到阶段状态事件（分析中 → 查询数据中 → 大模型思考中），等待期不再空白；
  - 模型思考链（`reasoning_content`）通过 reasoning 事件**实时**渲染到「🧠 深度思考」面板；
  - 正文为 LLM **token 级流式**，边生成边逐字显示；
  - 若 `LLM_NATIVE_STREAM=False`，退化为旧版行为：完整生成后再按 2~6 字符打字机吐出；
  - 前端必须用 `fetch + ReadableStream`（axios 不方便拿原始流）；
  - 最后一个 chunk 以 `\0__DONE__:` 开头，后面是 meta JSON；前端要识别并停止拼正文；
  - 完整实现可直接看 `frontend/src/components/AgentChat.vue` 中的 `handleSend()`。

### Q8：刷新页面后聊天记录不见了？
- 正常流程下不会丢：前端 `chat_id` 存在 `localStorage['agent_chat_id']`；
  打开组件时 `onMounted` 会调用 `GET /agent/history/<chat_id>?user_id=uid`，拿到记录就直接渲染；
  没拿到（服务端已过期/重启/没带 user_id）才显示欢迎消息。
- 如果真的没回来，排查：
  1. `config.py` 中 `CHAT_HISTORY_ENABLED` 是不是 `True`；
  2. 请求是否带了 `user_id`（必须登录态，agent 才能定位到哪个用户的哪个会话）；
  3. 服务端重启后，内存缓存会清空（chat_history 是进程内的 OrderedDict），如果你部署了 agent 多副本/频繁重启，可考虑后续把后端换成 Redis 持久化。

### Q9："我有4个已完成任务"只给了统计数字？
已经在**双链路**修复：
1. **LangGraph/LLM 链路**：System Prompt 第 2 条硬规则"上下文中有 done_tasks 等数组必须逐条列标题+编号，禁止只报统计数"；
2. **本地草稿链路**（LLM 失败时回退）：`chat_service.py` 中 `_reply_task_analysis` / `_reply_today_tasks` / `_reply_overdue_tasks` / `_reply_high_priority` 都改成逐条输出，格式固定为：
   ```
   ✅ 已完成：4 个
     1. 「UI登录页改版」 T-1024  （完成于 2026-08-06 15:22）  [产品研发组]
     2. 「团队权限重构」 T-1018  （完成于 2026-08-05 09:10）  [产品研发组]
   ```
3. 结构化数据源 `task_analyzer.analyze_user_tasks` 已经返回 `tasks_by_status / done_tasks / done_tasks_recent`，每条都带 `title / task_code / done_time / team_name`，上面 1 和 2 都是从这里取的。

### Q10：我换了模型来源（agnes / 混元 / DeepSeek / 自建），LLM 用不了怎么办？
现在系统内置了 **MODEL_PROVIDER 多供应商切换机制**，三步走：
1. **先选供应商**：在当前 cmd/PowerShell 里 `set MODEL_PROVIDER=agnes-2.5-flash | hy3 | deepseek`；
   - `agnes-2.5-flash`：默认，base_url=https://apihub.agnes-ai.com/v1/chat/completions、model=agnes-2.5-flash、api_key 已预设
   - `hy3`：腾讯混元（tokenhub.tencentmaas.com/v1、model=hy3、api_key 已预设）
   - `deepseek`：DeepSeek 官方（api.deepseek.com/v1、model=deepseek-v4-flash、自己填 key）
2. **覆盖具体参数**（可选，不写就用对应供应商的预设值）：
   ```
   set LLM_API_KEY=sk-your-own
   set LLM_BASE_URL=https://your-openai-compatible/v1
   set LLM_MODEL=your-model
   ```
3. **重启 agent** → 启动命令行第一块就会打印 `PROVIDER=agnes（标识：agnes-2.5-flash，来源：...）` + `Key来源=...` + `BASE_URL=...`，肉眼就能确认生效 → 然后访问 `/agent/health` 看 `llm_connectivity.ping_ok` 做 PING-PONG 连通性验证。
   - 连不通时 `llm_connectivity.message` 会打印简短报错（401 鉴权 / 404 模型不存在 / 429 限流 / TIMEOUT 超时），直接定位哪一项错了。

### Q11：模型返回的 reasoning_content（思维链）会被吃掉吗？能关掉思维链只看回答吗？
**不会被吃掉，完整兼容。** 两条调用路径都处理了：
- LangChain（`langchain_llm.py`）：`_extract_ai_message_body()` 同时拿 `resp.content` 和 `resp.additional_kwargs.reasoning_content` / `resp.response_metadata.choices[0].message.reasoning_content` 三个位置，保证不同转发端的思维链都能拿到。
- Requests 直连（`llm_service.py`）：`_call_deepseek_api` 200 成功段直接读 `choices[0].message.reasoning_content | reasoning`。

渲染方式（全局开关 `SHOW_REASONING`）：
- `True`（默认）：思维链用 `<details open><summary>🧠 思考过程（Reasoning）</summary>...推理原文...</details>` Markdown 折叠块渲染，然后是 `---` 分隔线 + 最终回答；在 Markdown 渲染器里可以一键点开/收起。
- `False`：完全不输出思维链，只显示最终回答，界面更简洁（Token 用量一样，只是前端不展示）。
切换方式：`set SHOW_REASONING=False` 后重启 agent。
