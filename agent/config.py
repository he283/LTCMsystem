# -*- coding: utf-8 -*-
"""
Agent配置文件
"""
import os

# 服务配置
HOST = os.getenv('AGENT_HOST', '0.0.0.0')
PORT = int(os.getenv('AGENT_PORT', 5001))
DEBUG = os.getenv('AGENT_DEBUG', 'False') == 'True'

# 数据库配置
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', '123456'),
    'database': os.getenv('DB_NAME', 'LTCMsystem'),
    'charset': 'utf8mb4'
}

# 允许的前端来源
ALLOWED_ORIGINS = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:5173',
    'http://127.0.0.1:5173',
    '*'
]

# Agent名称
AGENT_NAME = 'LTCM小助手'


# ============================================================
# 配置辅助：追踪配置值到底来自 环境变量 还是 config默认值
# ============================================================
def _resolve(key, default):
    """返回 (实际值, 来源说明: 'env' / 'config_default')"""
    env_val = os.getenv(key)
    if env_val is not None and env_val != '':
        return env_val, f'环境变量 {key}'
    return default, f'config.py 默认值'


# ============ 大模型配置（MODEL_PROVIDER 多供应商可切换）============
# 是否启用LLM增强（设为False则完全使用本地规则回复，不产生API费用）
LLM_ENABLED, LLM_ENABLED_SRC = _resolve('LLM_ENABLED', 'True')
LLM_ENABLED = (str(LLM_ENABLED).lower() == 'true')

# ------------------------------------------------------------
# 🔥 总开关：要不要允许「环境变量」覆盖 config.py 里的 MODEL_PROVIDER 预设？
#   LLM_USE_ENV = "1"（默认，没设也当 1）→ 启用三层优先级：LLM_* env > DEEPSEEK_* env > config.py 预设
#   LLM_USE_ENV = "0"                  → 禁用环境变量覆盖，强制只用 config.py 的预设
#                                           （你改 config.py 里的 default_api_key 立刻生效，不用清环境变量）
# 典型用法：
#   禁用：set LLM_USE_ENV=0   （之后改 config.py 立竿见影，不用关心系统里残留了什么 key）
#   启用：set LLM_USE_ENV=1   （或直接删掉这个变量，未设置默认就是启用）
# ------------------------------------------------------------
LLM_USE_ENV, LLM_USE_ENV_SRC = _resolve('LLM_USE_ENV', '0')
LLM_USE_ENV = not (str(LLM_USE_ENV).strip() in ('0', 'false', 'False', 'no', 'off'))


# ------------------------------------------------------------
# MODEL_PROVIDER 选择（支持多供应商预设）：
#   agnes-2.5-flash → agnes-ai 端点（默认；apihub.agnes-ai.com，模型 agnes-2.5-flash）
#   hy3            → 腾讯混元 huanyuan3（tokenhub.tencentmaas.com，模型 hy3）
#   deepseek       → DeepSeek 官方端点（api.deepseek.com，模型 deepseek-v4-flash）
# 也可以不选预设，直接用环境变量 LLM_BASE_URL/LLM_API_KEY/LLM_MODEL 填任意 OpenAI 兼容端点
# 优先级：环境变量 MODEL_PROVIDER > config.py 默认值
# ------------------------------------------------------------
MODEL_PROVIDER, MODEL_PROVIDER_SRC = _resolve('MODEL_PROVIDER', 'agnes-2.5-flash')
MODEL_PROVIDER = str(MODEL_PROVIDER).lower().strip() or 'agnes-2.5-flash'

# 各供应商的预设值（如果环境变量没单独覆盖 LLM_BASE_URL/LLM_API_KEY/LLM_MODEL，就用下面这个预设）
_PROVIDER_PRESETS = {
    'deepseek': {
        'default_base_url': 'https://api.deepseek.com/v1',
        # ⚠️ 占位符：请到 https://platform.deepseek.com/api_keys 申请自己的 DeepSeek API Key，
        #    然后通过 set LLM_API_KEY=sk-xxx 环境变量注入，不要把真实 key 写进仓库
        'default_api_key':  'your-deepseek-key-here',
        'default_model':    'deepseek-v4-flash',
        'display_name':     'DeepSeek 官方',
    },
    'agnes-2.5-flash': {
        'default_base_url': 'https://apihub.agnes-ai.com/v1/chat/completions',
        # ⚠️ 安全提示：请通过环境变量注入 Key（推荐，不会把真实密钥写进代码/仓库）：
        #         set LLM_API_KEY=sk-your-own-valid-key
        #    或直接改这里（仅本地临时调试用，仓库提交前改回占位符）
        'default_api_key':  'your-deepseek-key-here',
        'default_model':    'agnes-2.5-flash',
        'display_name':     'agnes',
    },
    'hy3': {
        'default_base_url': 'https://tokenhub.tencentmaas.com/v1',
        'default_api_key':  'your-deepseek-key-here',
        'default_model':    'hy3',
        'display_name':     'huanyuan3',
    },
}
# 取当前供应商的预设模板
_preset = _PROVIDER_PRESETS.get(MODEL_PROVIDER, _PROVIDER_PRESETS['agnes-2.5-flash'])
MODEL_PROVIDER_DISPLAY = _preset.get('display_name', MODEL_PROVIDER)


# —— 🔧 工具函数（必须放在 _resolve_llm_config 前面定义，否则 NameError）
def _mask_key(k: str) -> str:
    if not k: return '(空/未设置)'
    if len(k) <= 8: return '*' * len(k)
    return f'{k[:4]}****{k[-4:]}'


def _mask_nonkey(v: str) -> str:
    """对非密钥字段（base_url/model）也做长度保护，避免打印超长"""
    if not v: return '(空/未设置)'
    if len(v) <= 60: return v
    return v[:57] + '...'


# ------------------------------------------------------------
# 通用 LLM 配置三件套（所有新代码一律 import LLM_BASE_URL / LLM_API_KEY / LLM_MODEL）
# 优先级：
#   1) 环境变量 LLM_BASE_URL / LLM_API_KEY / LLM_MODEL
#   2) 环境变量 DEEPSEEK_BASE_URL / DEEPSEEK_API_KEY / DEEPSEEK_MODEL（兼容历史）
#   3) 当前 MODEL_PROVIDER 预设的 default_xxx
#   来源追踪字段分别是 LLM_*_SRC，健康检查和启动日志会打印
# ------------------------------------------------------------
def _resolve_llm_config(env_key_primary: str, env_key_fallback: str, provider_default: str):
    """
    带双环境变量兼容的解析：先查 env_key_primary，再查 env_key_fallback，最后用 provider_default
    🔥 总开关 LLM_USE_ENV=False 时，直接忽略前两层环境变量，强制用 provider_default
       （即使 env 里有值也不会被用，来源字段会明确标注"总开关禁用"）
    """
    if not LLM_USE_ENV:
        # 忽略环境变量，强制用 provider 预设（哪怕环境变量里确实填了也不用）
        override_note = ''
        env_p = os.getenv(env_key_primary)
        env_f = os.getenv(env_key_fallback)
        ignored = []
        if env_p is not None and env_p != '':
            ignored.append(f'{env_key_primary}={_mask_key(env_p)}')
        if env_f is not None and env_f != '':
            ignored.append(f'{env_key_fallback}={_mask_key(env_f)}')
        if ignored:
            override_note = f'（总开关 LLM_USE_ENV=0 已忽略环境变量 {", ".join(ignored)}，强制使用预设）'
        else:
            override_note = f'（总开关 LLM_USE_ENV=0，强制使用预设）'
        return provider_default, f'{MODEL_PROVIDER_DISPLAY} 预设（MODEL_PROVIDER="{MODEL_PROVIDER}"）{override_note}'

    env_p = os.getenv(env_key_primary)
    if env_p is not None and env_p != '':
        return env_p, f'环境变量 {env_key_primary}'
    env_f = os.getenv(env_key_fallback)
    if env_f is not None and env_f != '':
        return env_f, f'环境变量 {env_key_fallback}（兼容旧版）'
    return provider_default, f'{MODEL_PROVIDER_DISPLAY} 预设（MODEL_PROVIDER="{MODEL_PROVIDER}"）'

LLM_BASE_URL, LLM_BASE_URL_SRC   = _resolve_llm_config('LLM_BASE_URL', 'DEEPSEEK_BASE_URL', _preset['default_base_url'])
LLM_API_KEY,  LLM_API_KEY_SRC    = _resolve_llm_config('LLM_API_KEY',  'DEEPSEEK_API_KEY',  _preset['default_api_key'])
LLM_MODEL,    LLM_MODEL_SRC      = _resolve_llm_config('LLM_MODEL',    'DEEPSEEK_MODEL',    _preset['default_model'])


def _get_llm_config_layers_diag() -> dict:
    """
    诊断三件套（base_url / api_key / model）的三层候选值：
      Layer 0: LLM_*        环境变量（最高优先级）
      Layer 1: DEEPSEEK_*   环境变量（兼容旧写法，第二优先级）
      Layer 2: 当前 MODEL_PROVIDER 预设的 default_*（config.py 里填的那一条，第三优先级）
    返回：
      { 'base_url': {'used_layer':0/1/2, 'used_source':..., 'used_value':'...', 'layers':[...]},
        'api_key':  {...},
        'model':    {...} }
    每个 layers 元素：{'layer':0..2, 'title':'LLM_API_KEY 环境变量', 'present':True/False,
                       'value':'ms-x****-token 或 url字符串', 'used':True/False}
    """
    def _one_item(env_primary, env_fallback, provider_default, final_value, *, is_key: bool):
        layer_val = [
            (0, f'环境变量 {env_primary}',                os.getenv(env_primary)),
            (1, f'环境变量 {env_fallback}（兼容旧写法）', os.getenv(env_fallback)),
            (2, f'{MODEL_PROVIDER_DISPLAY} 预设（config.py里的 default_*）', provider_default),
        ]
        layers = []
        used_layer = 2  # 默认落在 provider 预设
        mask = _mask_key if is_key else _mask_nonkey
        for layer, title, val in layer_val:
            present = (val is not None and val != '')
            used = present and (str(val) == str(final_value))
            if used:
                used_layer = layer
                break
            # 注意：如果高层为空，继续往下走；上面逻辑先找 present 并且值匹配的那一层
        # 再完整遍历一遍生成 layers 列表（不能在上面 break 的循环里做，因为要展示全部三层）
        layers = []
        hit_used = False
        for layer, title, val in layer_val:
            present = (val is not None and val != '')
            if not hit_used:
                used = present  # 从高层往下，第一个 present 的就是"胜出"的层
                if used: hit_used = True
            else:
                used = False
            layers.append({
                'layer': layer,
                'title': title,
                'present': present,
                'value': mask(str(val)) if present else '(此层未设置)',
                'used': used,
            })
        used_layer = next((l['layer'] for l in layers if l['used']), 2)
        used_source = next((l['title'] for l in layers if l['used']),
                           f'{MODEL_PROVIDER_DISPLAY} 预设（MODEL_PROVIDER="{MODEL_PROVIDER}"）')
        return {
            'used_layer': used_layer,
            'used_source': used_source,
            'used_value': mask(str(final_value)),
            'layers': layers,
        }

    diag = {
        'base_url': _one_item('LLM_BASE_URL',  'DEEPSEEK_BASE_URL',  _preset['default_base_url'],  LLM_BASE_URL,  is_key=False),
        'api_key':  _one_item('LLM_API_KEY',   'DEEPSEEK_API_KEY',   _preset['default_api_key'],   LLM_API_KEY,   is_key=True),
        'model':    _one_item('LLM_MODEL',     'DEEPSEEK_MODEL',     _preset['default_model'],     LLM_MODEL,     is_key=False),
    }
    # 🔥 总开关 LLM_USE_ENV 诊断：如果用户把总开关关了（禁用环境变量），三层对比里标清楚 Layer0/1 被"总开关跳过"
    if not LLM_USE_ENV:
        for _name, _info in diag.items():
            for _layer in _info['layers']:
                if _layer['layer'] in (0, 1):
                    _layer['env_value_present'] = _layer['present']  # 真实 env 是否有值
                    _layer['value'] = _layer['value'] + ('   [总开关LLM_USE_ENV=0 已忽略]' if _layer['present'] else '   [总开关LLM_USE_ENV=0 忽略]')
                    _layer['present'] = False  # 逻辑上视为未设置，强制让 Layer2 成为唯一的 used
            # 修正 used 标记：LLM_USE_ENV=False 时，used 一定是 Layer 2
            for _layer in _info['layers']:
                _layer['used'] = (_layer['layer'] == 2)
            _info['used_layer'] = 2
            _info['used_source'] = f'{MODEL_PROVIDER_DISPLAY} 预设（MODEL_PROVIDER="{MODEL_PROVIDER}"，LLM_USE_ENV=0 强制忽略环境变量）'
    diag['llm_use_env'] = {
        'value': LLM_USE_ENV,
        'value_text': '启用（环境变量可覆盖 config.py）' if LLM_USE_ENV else '禁用（强制只用 config.py 预设，忽略所有 LLM_*/DEEPSEEK_* 环境变量）',
        'source': LLM_USE_ENV_SRC,
        'tip_off': '禁用环境变量覆盖：set LLM_USE_ENV=0  （改 config.py 立刻生效，不用清其它变量）',
        'tip_on':  '启用环境变量覆盖：set LLM_USE_ENV=1  （或删除此变量，默认启用）',
    }
    return diag


# 兼容历史写法：langchain_llm.py / llm_service.py 原来 import 的是 DEEPSEEK_*，这里做 alias，不用改 import
DEEPSEEK_API_KEY     = LLM_API_KEY
DEEPSEEK_API_KEY_SRC = LLM_API_KEY_SRC
DEEPSEEK_BASE_URL    = LLM_BASE_URL
DEEPSEEK_BASE_URL_SRC= LLM_BASE_URL_SRC
DEEPSEEK_MODEL       = LLM_MODEL
DEEPSEEK_MODEL_SRC   = LLM_MODEL_SRC

# 请求超时（秒）
DEEPSEEK_TIMEOUT = int(_resolve('LLM_TIMEOUT', '30')[0])
# 温度参数（0=更确定性，1=更创造性）
DEEPSEEK_TEMPERATURE = float(_resolve('LLM_TEMPERATURE', '0.7')[0])
# 最大输出token数
DEEPSEEK_MAX_TOKENS = int(_resolve('LLM_MAX_TOKENS', '2000')[0])

# LLM调用失败时是否降级为本地规则（推荐True）
LLM_FALLBACK_TO_LOCAL = True

# 是否显示思维链 reasoning_content（ModelScope/DeepSeek-R1 等模型会返回思维链文本）
# True=思维链 + "=== Final Answer ===" + 最终答案；False=只保留最终答案
SHOW_REASONING, SHOW_REASONING_SRC = _resolve('SHOW_REASONING', 'True')
SHOW_REASONING = (str(SHOW_REASONING).lower() == 'true')

# ============ LangChain + LangGraph 配置 ============
# 是否启用 LangGraph 工作流（True=用LangGraph状态机，False=用原来的纯函数调用）
USE_LANGGRAPH, USE_LANGGRAPH_SRC = _resolve('USE_LANGGRAPH', 'True')
USE_LANGGRAPH = (str(USE_LANGGRAPH).lower() == 'true')

# LangSmith 追踪（可选）：设置环境变量 LANGSMITH_API_KEY 即开启
# export LANGSMITH_TRACING=true
# export LANGSMITH_API_KEY=ls_xxx
LANGSMITH_TRACING = _resolve('LANGSMITH_TRACING', 'False')[0].lower() == 'true'
LANGSMITH_API_KEY = _resolve('LANGSMITH_API_KEY', '')[0]
LANGSMITH_PROJECT = _resolve('LANGSMITH_PROJECT', 'LTCM-Agent')[0]

# 对话记忆/历史记录相关
# 历史消息带入LLM的轮数（每轮=1条用户+1条助手，0=不保留历史，节省Token）
CONTEXT_WINDOW_SIZE = int(_resolve('CONTEXT_WINDOW_SIZE', '6')[0])

# 是否启用服务端聊天历史（True=按chat_id缓存，刷新页面也能看到）
CHAT_HISTORY_ENABLED = _resolve('CHAT_HISTORY_ENABLED', 'True')[0].lower() == 'true'

# 每个 chat_id 最多缓存多少条消息（含用户和助手）
CHAT_HISTORY_MAX_MSGS = int(_resolve('CHAT_HISTORY_MAX_MSGS', '100')[0])

# 历史消息过期时间（秒），超过这个时间不使用则清除
CHAT_HISTORY_TTL_SECS = int(_resolve('CHAT_HISTORY_TTL_SECS', str(60 * 60 * 4))[0])  # 默认4小时

# 是否启用流式输出（SSE，True=默认走流式 /stream 接口）
STREAM_ENABLED = _resolve('STREAM_ENABLED', 'True')[0].lower() == 'true'

# 是否启用「大模型原生流式」（仿 DeepSeek 网页版在线思考）
# True=提问后立即反馈阶段状态（分析中/查询中/思考中），LLM 边生成边逐字输出，等待感大幅降低
# False=等大模型完整生成后再模拟打字机（旧行为，等待期间只有 loading 动画）
LLM_NATIVE_STREAM = _resolve('LLM_NATIVE_STREAM', 'True')[0].lower() == 'true'

# Python解释器路径（用于启动脚本）
VENV_PYTHON = r'D:\Code\python\AI\.venv\Scripts\python.exe'
