# -*- coding: utf-8 -*-
"""
Flask主应用入口
"""
from flask import Flask, request, jsonify, session, stream_with_context, Response
from flask_cors import CORS
from datetime import datetime, timedelta

import logging
import threading
import time
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

from config import (
    HOST, PORT, DEBUG, ALLOWED_ORIGINS, AGENT_NAME,
    # LLM + 来源追踪
    LLM_ENABLED, LLM_ENABLED_SRC,
    DEEPSEEK_API_KEY, LLM_API_KEY_SRC,
    DEEPSEEK_BASE_URL, LLM_BASE_URL_SRC,
    DEEPSEEK_MODEL, LLM_MODEL_SRC,
    USE_LANGGRAPH, USE_LANGGRAPH_SRC,
    STREAM_ENABLED,
    CHAT_HISTORY_ENABLED,
    # 多供应商切换
    MODEL_PROVIDER, MODEL_PROVIDER_DISPLAY, MODEL_PROVIDER_SRC,
    SHOW_REASONING, SHOW_REASONING_SRC,
    # 🔥 环境变量覆盖总开关
    LLM_USE_ENV, LLM_USE_ENV_SRC,
    # 三层候选优先级诊断（解决"我改了config.py为什么不生效"）
    _get_llm_config_layers_diag,
)
from services.chat_service import get_reply, get_reply_stream, _match_intent, INTENT_PATTERNS
from services.task_analyzer import analyze_user_tasks, analyze_user_teams


def _mask_key(key: str) -> str:
    if not key or len(key) <= 8:
        return '****'
    return f'{key[:4]}****{key[-4:]}'


def _client_ip(req) -> str:
    """从 Flask request 提取客户端 IP（兼容反向代理 X-Forwarded-For）"""
    xff = req.headers.get('X-Forwarded-For', '')
    if xff:
        return xff.split(',')[0].strip()
    return req.remote_addr or ''


# —— 🧹 精简辅助：把冗长的 source / message 压成一行短标签（前端弹窗不显示一大坨）
def _short_source(src: str) -> str:
    """把 config 里的来源字符串压缩成 1-3 个词的短标签"""
    if not src: return ''
    s = str(src).strip()
    # ✅ 先判断开头：只有 "真正的来源是环境变量" 才会以「环境变量」开头（防止把「已忽略环境变量 xxx」那句话误判成来源是 env）
    if s.startswith('环境变量'):
        if   'LLM_API_KEY'      in s: return '环境变量 LLM_API_KEY'
        elif 'LLM_BASE_URL'     in s: return '环境变量 LLM_BASE_URL'
        elif 'LLM_MODEL'        in s: return '环境变量 LLM_MODEL'
        elif 'DEEPSEEK_API_KEY' in s: return '环境变量 DEEPSEEK_API_KEY'
        elif 'DEEPSEEK_BASE_URL'in s: return '环境变量 DEEPSEEK_BASE_URL'
        elif 'DEEPSEEK_MODEL'   in s: return '环境变量 DEEPSEEK_MODEL'
        elif 'LLM_USE_ENV'      in s: return '环境变量 LLM_USE_ENV'
        else: return s[:20] + ('…' if len(s)>20 else '')
    # 非 env 开头 → 判断是否 provider 预设
    if ('预设' in s) or ('MODEL_PROVIDER' in s):
        return 'config.py 预设' + ('(禁用env)' if 'LLM_USE_ENV=0' in s else '')
    if 'config.py 默认值' in s: return 'config.py 默认'
    # 兜底：截前 40 字
    return s if len(s) <= 40 else s[:37] + '...'


def _short_ping_msg(msg: str, ok) -> str:
    """把冗长的 LLM 连通性 message 剪成一行简略版（80字以内）"""
    if not msg: return ''
    s = str(msg).replace('\n', ' ').strip()
    import re
    if ok:
        tok = re.search(r'消耗[=:：]\s*(\d+)\s*tokens?', s) or re.search(r'total[=:：]\s*(\d+)', s)
        lat = re.search(r'耗时[=:：]\s*([\d.]+)\s*ms', s)
        parts = []
        if tok: parts.append(f'{tok.group(1)} tokens')
        if lat: parts.append(f'{round(float(lat.group(1)))}ms')
        return '连接成功' + (f'（{" / ".join(parts)}）' if parts else '')
    # 失败：先抓错误码标签 + 错误正文（从第一个冒号后取正文，跳过"Error code:"尾部，删除 request_id）
    m = re.search(
        r'(AUTH_FAILED_401|HTTP_401|HTTP_404|HTTP_429|HTTP_5\d{2}|TIMEOUT|CONNECTION_ERROR|EMPTY_CHOICES|INVALID_API_KEY)'
        r'[^A-Za-z_]*([^\n]*)', s,
    )
    if not m:
        short = s
    else:
        code = m.group(1)
        body = m.group(2) or ''
        # body 里如果还有「Error code: xxx request_id=yyy」之类的尾部垃圾，只取其前面的有意义正文
        # 按分号 / 句号切
        body = re.split(r'[。；;\n]', body, maxsplit=1)[0]
        # 去掉 request_id 尾巴
        body = re.sub(r'[，,]\s*(request|trace)_id[=:：]\s*\S+', '', body).strip()
        body = re.sub(r'[（(].*(request|trace)_id.*?[)）]', '', body).strip()
        # 如果正文太短（比如只剩 '401'），就回退到从原始字符串中抓 "Authentication failed" / "Not Found" 这种人类可读句
        if len(body) < 6:
            m2 = re.search(r'(Authentication failed[^。；;\n]{0,40}|Not Found|invalid (api_key|token)[^。；;\n]{0,30}|(rate limit|quota) exceeded[^。；;\n]{0,30}|connection refused|timeout|服务异常|接口 404|模型不存在|鉴权失败)', s, re.IGNORECASE)
            if m2: body = m2.group(0)
        body = body[:55] + ('…' if len(body) > 55 else '')
        return f'{code}：{body}' if body else code
    # 兜底 fallback
    short = re.sub(r'[（(].*(request|trace)_id.*?[)）]', '', s).strip()
    return short[:70] + ('…' if len(short) > 70 else '')


app = Flask(__name__)
app.secret_key = 'ltcm-agent-secret-key'
app.logger.setLevel(logging.INFO)

# 启动时预检查（Flask 3.0+ 不再支持 before_first_request，在第一次请求时检查即可）
_startup_checked = False

# CORS配置
CORS(app, resources={
    r"/agent/*": {
        "origins": ALLOWED_ORIGINS,
        "methods": ["GET", "POST", "OPTIONS", "DELETE"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})


def _error(msg, code=400):
    return jsonify({
        'code': code,
        'message': msg,
        'data': None
    }), code


def _success(data=None, message='success'):
    return jsonify({
        'code': 200,
        'message': message,
        'data': data
    })


# ============================================================
# 启动日志：打印当前生效的配置（特别是 API Key / Model 来源）
# ============================================================
def _log_startup_config():
    """在第一次请求到达时打印生效配置来源（避免循环导入）"""
    global _startup_checked
    if _startup_checked:
        return
    _startup_checked = True
    app.logger.info('=' * 60)
    app.logger.info(f'🤖 {AGENT_NAME} 配置已加载')
    app.logger.info(f'• PROVIDER        = {MODEL_PROVIDER_DISPLAY}  (内部标识: {MODEL_PROVIDER}, 来源: {MODEL_PROVIDER_SRC})')
    app.logger.info(f'• LLM_ENABLED     = {LLM_ENABLED}  (来源: {LLM_ENABLED_SRC})')
    app.logger.info(f'• API Key         = {_mask_key(DEEPSEEK_API_KEY)}  (来源: {LLM_API_KEY_SRC})')
    app.logger.info(f'• BASE_URL        = {DEEPSEEK_BASE_URL}  (来源: {LLM_BASE_URL_SRC})')
    app.logger.info(f'• MODEL           = {DEEPSEEK_MODEL}  (来源: {LLM_MODEL_SRC})')
    app.logger.info(f'• SHOW_REASONING  = {SHOW_REASONING}  (思维链显示, 来源: {SHOW_REASONING_SRC})')
    app.logger.info(f'• USE_LANGGRAPH   = {USE_LANGGRAPH}  (来源: {USE_LANGGRAPH_SRC})')
    app.logger.info(f'• STREAM_ENABLED  = {STREAM_ENABLED}')
    app.logger.info(f'• CHAT_HISTORY    = {CHAT_HISTORY_ENABLED}')
    try:
        from services.chat_history import stats as history_stats
        app.logger.info(f'• 历史存储统计     = {history_stats()}')
    except Exception:
        pass
    app.logger.info(f'启动时意图关键词数量: {len(INTENT_PATTERNS)}')
    for p in INTENT_PATTERNS:
        app.logger.info(f'  意图 {p["intent"]} 关键词数={len(p["keywords"])} -> 样例: {p["keywords"][:3]}')
    app.logger.info(f'意图匹配测试: _match_intent("我的任务")={_match_intent("我的任务")}')

    # —— 🔥 环境变量总开关状态速查（用户"一键禁用/启用环境变量"）
    if LLM_USE_ENV:
        app.logger.info(
            '🧭 LLM_USE_ENV=ON  (环境变量可覆盖 config.py 预设，来源: %s)',
            LLM_USE_ENV_SRC,
        )
    else:
        app.logger.warning(
            '🚫 LLM_USE_ENV=OFF （已强制禁用所有 LLM_*/DEEPSEEK_* 环境变量！来源: %s）',
            LLM_USE_ENV_SRC,
        )
    app.logger.info('   ┌─ 一键切换命令（改完重启 agent 生效）：')
    app.logger.info('   │   [禁用环境变量] set LLM_USE_ENV=0      → 改 config.py 的 default_api_key 立刻生效，不用清其他 6 个变量')
    app.logger.info('   │   [启用环境变量] set LLM_USE_ENV=1      → 恢复三层优先级（LLM_* env > DEEPSEEK_* env > config 预设）')
    app.logger.info('   │   [启用环境变量] set "LLM_USE_ENV="     → 直接删掉变量也行，未设置默认为启用')
    app.logger.info('   └─ （PowerShell 写法：$env:LLM_USE_ENV = "0" / $env:LLM_USE_ENV = "1" / Remove-Item Env:LLM_USE_ENV）')

    # —— 新增：检查环境变量是否把 config.py 里的预设盖掉了（用户最常见的踩坑点）
    try:
        diag = _get_llm_config_layers_diag()
        overridden = [(name, info) for name, info in diag.items() if info['used_layer'] != 2]
        if overridden:
            app.logger.warning('')
            app.logger.warning('⚠️ ╔════════════════════════════════════════════════════════════════╗')
            app.logger.warning('⚠️ ║   配置覆盖警告：你在 config.py 里填的预设并没有真正生效！      ║')
            app.logger.warning('⚠️ ╚════════════════════════════════════════════════════════════════╝')
            for name, info in overridden:
                app.logger.warning(
                    '⚠️   ▶ [%s] 胜出层=Layer%d (%s) | 值=%s',
                    name.upper(), info['used_layer'], info['used_source'], info['used_value'],
                )
                app.logger.warning('⚠️      三层候选明细（从上往下优先级递减，第一个有值的会获胜）：')
                for layer in info['layers']:
                    tag = '<<< 胜 出 <<<' if layer['used'] else ''
                    app.logger.warning(
                        '⚠️        · Layer %d %s | %s  → %s %s',
                        layer['layer'], ('[高优先级]' if layer['layer']==0 else ('[兼容旧写法]' if layer['layer']==1 else '[config.py预设]')),
                        layer['title'], layer['value'], tag,
                    )
            app.logger.warning('⚠️   ┌───────────────────────────────────────────────────────────────┐')
            app.logger.warning('⚠️   │  修复方式 ①【推荐】：不要改 config.py，直接覆盖最高优先级的环境变量  │')
            app.logger.warning('⚠️   │              set LLM_API_KEY=ms-你的新Token                     │')
            app.logger.warning('⚠️   │              （再配其他: LLM_BASE_URL / LLM_MODEL）            │')
            app.logger.warning('⚠️   │  修复方式 ②：非要用 config.py 预设？就先删掉对应的环境变量       │')
            app.logger.warning('⚠️   │    (PowerShell) Remove-Item Env:LLM_API_KEY,Env:DEEPSEEK_API_KEY,Env:LLM_BASE_URL,Env:DEEPSEEK_BASE_URL,Env:LLM_MODEL,Env:DEEPSEEK_MODEL -ErrorAction SilentlyContinue')
            app.logger.warning('⚠️   │    (CMD)       set LLM_API_KEY=& set DEEPSEEK_API_KEY=& set LLM_BASE_URL=& set DEEPSEEK_BASE_URL=& set LLM_MODEL=& set DEEPSEEK_MODEL=')
            app.logger.warning('⚠️   │  → 两种方式改完都要：重启 agent 服务（同一个 cmd/PowerShell 窗口）│')
            app.logger.warning('⚠️   └───────────────────────────────────────────────────────────────┘')
            app.logger.warning('')
        else:
            app.logger.info('✅ 三层候选检查通过：当前三件套全部来自 config.py 的 MODEL_PROVIDER 预设，你改的配置已生效。')
    except Exception as _e:
        app.logger.warning(f'⚠️  配置覆盖检查失败（不影响使用）: {type(_e).__name__}: {_e}')
    app.logger.info('=' * 60)


@app.route('/')
def index():
    _log_startup_config()
    return f'''
    <h1>🤖 {AGENT_NAME} 服务已启动</h1>
    <p>运行在端口 {PORT}</p>
    <p>时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    <ul>
      <li><code>GET  /agent/health</code> — 健康检查 + 配置来源</li>
      <li><code>POST /agent/chat</code> — 发送消息（非流式）</li>
      <li><code>POST /agent/chat/stream</code> — 发送消息（SSE 流式）</li>
      <li><code>GET  /agent/history/&lt;chat_id&gt;?user_id=&lt;uid&gt;</code> — 获取聊天历史</li>
      <li><code>DELETE /agent/history/&lt;chat_id&gt;?user_id=&lt;uid&gt;</code> — 清空聊天历史</li>
      <li><code>GET  /agent/task-analysis/{user_id}</code> — 获取任务分析</li>
      <li><code>GET  /agent/today-tasks/{user_id}</code> — 获取今日任务</li>
    </ul>
    '''


# —— LLM 连通性 ping：后台线程 + 全局缓存 ——
# 之前的实现是 health 每次同步等 ping(最多6s)，导致前端偶发 timeout；
# 现在 health 立即返回缓存结果，ping 由后台线程持续刷新，health 永远秒回。
_llm_ping_cache = {'ok': None, 'msg': None, 'ts': 0.0}
_ping_lock = threading.Lock()


def _background_ping():
    """后台执行一次 LLM ping，结果写入全局缓存（带时间戳）"""
    try:
        from services.langchain_llm import ping_llm_langchain
        ok, msg = ping_llm_langchain()
    except Exception as e:
        ok, msg = False, f'PING 异常: {type(e).__name__}: {e}'
    with _ping_lock:
        _llm_ping_cache['ok'] = ok
        _llm_ping_cache['msg'] = msg
        _llm_ping_cache['ts'] = time.time()


def _get_cached_ping(max_age_secs=30):
    """返回缓存的 ping 结果；缓存过期时启动后台刷新并返回旧值（可能为 None=检测中）"""
    with _ping_lock:
        ok, msg, ts = _llm_ping_cache['ok'], _llm_ping_cache['msg'], _llm_ping_cache['ts']
    if time.time() - ts > max_age_secs:
        threading.Thread(target=_background_ping, daemon=True).start()
    return ok, msg


@app.route('/agent/health', methods=['GET'])
def health():
    """健康检查：显示服务状态 + 配置来源（特别是 API Key 到底来自哪里，便于调试）
    注意：LLM 连通性通过后台线程异步检测，本接口不等待，保证毫秒级响应。"""
    _log_startup_config()
    from config import (
        LLM_ENABLED, LLM_ENABLED_SRC,
        DEEPSEEK_API_KEY_SRC, DEEPSEEK_BASE_URL_SRC, DEEPSEEK_MODEL_SRC,
        USE_LANGGRAPH, USE_LANGGRAPH_SRC,
        DEEPSEEK_TIMEOUT, DEEPSEEK_TEMPERATURE, DEEPSEEK_MAX_TOKENS,
        STREAM_ENABLED, CHAT_HISTORY_ENABLED,
        CONTEXT_WINDOW_SIZE, CHAT_HISTORY_MAX_MSGS, CHAT_HISTORY_TTL_SECS,
        LLM_USE_ENV, LLM_USE_ENV_SRC,
    )
    # 立即返回缓存的 ping 结果（None=首次检测中；后台线程刷新，不阻塞本请求）
    llm_ping_ok = None
    llm_ping_msg = None
    if LLM_ENABLED:
        try:
            llm_ping_ok, llm_ping_msg = _get_cached_ping()
        except Exception as e:
            llm_ping_ok = False
            llm_ping_msg = f'PING 异常: {type(e).__name__}: {e}'

    # 历史统计
    history_stats = None
    try:
        from services.chat_history import stats as history_stats_fn
        history_stats = history_stats_fn()
    except Exception:
        history_stats = {'enabled': CHAT_HISTORY_ENABLED}

    # —— 🧹 精简 config_sources 和 llm_connectivity：只留弹窗真正用到的字段，减轻前后端压力
    import re as _re
    _src_key   = _short_source(LLM_API_KEY_SRC)
    _src_url   = _short_source(LLM_BASE_URL_SRC)
    _src_model = _short_source(LLM_MODEL_SRC)
    slim_config_sources = {
        # 新版精简字段（新前端读这里）
        'api_key':  {'value': _mask_key(DEEPSEEK_API_KEY), 'source': _src_key,   'provider': MODEL_PROVIDER_DISPLAY},
        'model':    {'value': DEEPSEEK_MODEL,               'source': _src_model, 'provider': MODEL_PROVIDER_DISPLAY},
        'base_url': {'value': DEEPSEEK_BASE_URL,            'source': _src_url},
        'llm_use_env': {
            'value': LLM_USE_ENV,
            'label': ('禁用env：强制用config' if not LLM_USE_ENV else '启用env：环境变量优先'),
            'source': _short_source(LLM_USE_ENV_SRC),
        },
        # 旧版兼容字段（老代码还在读 deepseek_*）
        'deepseek_api_key':   {'value': _mask_key(DEEPSEEK_API_KEY), 'source': _src_key},
        'deepseek_base_url':  {'value': DEEPSEEK_BASE_URL,            'source': _src_url},
        'deepseek_model':     {'value': DEEPSEEK_MODEL,               'source': _src_model},
        'llm_enabled':        {'value': LLM_ENABLED},
    }
    _ping_str = str(llm_ping_msg or '')
    _tok_m = _re.search(r'消耗[=:：]\s*(\d+)\s*tokens?', _ping_str) or _re.search(r'total[=:：]\s*(\d+)', _ping_str)
    _lat_m = _re.search(r'耗时[=:：]\s*([\d.]+)\s*ms', _ping_str)
    slim_llm_connectivity = {
        'ping_ok': llm_ping_ok,
        'message': _short_ping_msg(llm_ping_msg, bool(llm_ping_ok)),
        'total_tokens': int(_tok_m.group(1)) if _tok_m else None,
        'latency_ms':   round(float(_lat_m.group(1)), 1) if _lat_m else None,
    }
    del _re

    data = {
        'status': 'ok',
        'agent_name': AGENT_NAME,
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'version': '1.2.0',
        # 功能开关
        'features': {
            'llm_enabled': LLM_ENABLED,
            'use_langgraph': USE_LANGGRAPH,
            'stream_enabled': STREAM_ENABLED,
            'chat_history_enabled': CHAT_HISTORY_ENABLED,
            'context_window_size': CONTEXT_WINDOW_SIZE,
        },
        # 关键配置 + 来源追踪（用户最关心：为什么填的API Key没生效？看这里就知道了！）
        'config_sources': {
            # 多供应商（选哪个大模型服务）
            'model_provider': {
                'value': MODEL_PROVIDER,
                'display_name': MODEL_PROVIDER_DISPLAY,
                'source': MODEL_PROVIDER_SRC,
                'tip': '可选值: modelscope（魔搭推理端点，默认）/ deepseek（DeepSeek官方）/ custom（自定义兼容端点）；通过环境变量 MODEL_PROVIDER=xxx 切换，重启服务生效',
                'supported': ['modelscope', 'deepseek', 'custom'],
            },
            # 思维链（Reasoning）开关
            'show_reasoning': {
                'value': SHOW_REASONING,
                'source': SHOW_REASONING_SRC,
                'tip': 'True=将 reasoning_content 渲染为可折叠的"🧠 思考过程"Markdown块（ModelScope/R1系列模型会返回）；False=只显示最终回答，省屏幕空间',
            },
            # 功能开关
            'llm_enabled': {'value': LLM_ENABLED, 'source': LLM_ENABLED_SRC},
            # API 三件套（新版通用命名，推荐前端看这里；deepseek_xxx 字段保留兼容历史前端）
            'llm_api_key': {
                'value': _mask_key(DEEPSEEK_API_KEY),  # 脱敏显示，避免泄露
                'source': LLM_API_KEY_SRC,             # ←⭐ 到底来自【环境变量】还是【provider预设 / config默认】看这里
                'tip': '优先级: LLM_API_KEY env > DEEPSEEK_API_KEY env > 当前 MODEL_PROVIDER 预设；如要切回 config/provider 预设，请删除系统/用户环境变量 LLM_API_KEY 和 DEEPSEEK_API_KEY 后重启服务',
            },
            'llm_base_url': {'value': DEEPSEEK_BASE_URL, 'source': LLM_BASE_URL_SRC,
                             'tip': '优先级: LLM_BASE_URL env > DEEPSEEK_BASE_URL env > provider 预设'},
            'llm_model':    {'value': DEEPSEEK_MODEL,    'source': LLM_MODEL_SRC,
                             'tip': '优先级: LLM_MODEL env > DEEPSEEK_MODEL env > provider 预设'},
            # 兼容历史（旧前端可能仍读 deepseek_*）
            'deepseek_api_key': {
                'value': _mask_key(DEEPSEEK_API_KEY),
                'source': LLM_API_KEY_SRC,
                'tip': '该字段是旧版兼容名，建议新代码读取 llm_api_key',
            },
            'deepseek_base_url': {'value': DEEPSEEK_BASE_URL, 'source': DEEPSEEK_BASE_URL_SRC},
            'deepseek_model':    {'value': DEEPSEEK_MODEL,    'source': DEEPSEEK_MODEL_SRC},
            'use_langgraph':     {'value': USE_LANGGRAPH, 'source': USE_LANGGRAPH_SRC},
            # 🔥 一键禁用/启用环境变量覆盖的总开关（解决用户痛点：改 config 不生效 / 想清 6 个 env 很麻烦）
            'llm_use_env': {
                'value': LLM_USE_ENV,
                'value_text': '启用（环境变量可覆盖 config.py 预设）' if LLM_USE_ENV
                             else '禁用（强制只用 config.py 预设，忽略所有 LLM_*/DEEPSEEK_* 环境变量）',
                'source': LLM_USE_ENV_SRC,
                'tip_off': '禁用环境变量覆盖：set LLM_USE_ENV=0  （改 config.py 的 default_api_key 立刻生效，不用清其它 6 个变量）',
                'tip_on':  '启用环境变量覆盖：set LLM_USE_ENV=1  （或直接删此变量，未设置默认启用）',
                'tip_ps':  'PowerShell：$env:LLM_USE_ENV="0" / $env:LLM_USE_ENV="1" / Remove-Item Env:LLM_USE_ENV；改完必须重启 agent 服务',
            },
        },
        'llm_params': {
            'timeout_secs': DEEPSEEK_TIMEOUT,
            'temperature': DEEPSEEK_TEMPERATURE,
            'max_tokens': DEEPSEEK_MAX_TOKENS,
            'provider': MODEL_PROVIDER,
            'provider_display': MODEL_PROVIDER_DISPLAY,
            'show_reasoning': SHOW_REASONING,
        },
        'llm_connectivity': {
            'ping_ok': llm_ping_ok,
            'message': llm_ping_msg,
            # message 文本里可能包含 tokens/latency，这里同步拆出结构化字段方便前端展示
            # （实际值会通过 ping_llm_langchain 返回；如果超时这里是 None）
        },
        'chat_history': history_stats,
    }
    # 🧹 最后强制覆盖为精简版（删掉所有冗余字段，减轻前后端解析/渲染压力）
    data['config_sources'] = slim_config_sources
    data['llm_connectivity'] = slim_llm_connectivity
    # 移除完全不再需要的顶级键
    for _k in ('llm_params',):
        data.pop(_k, None)
    return _success(data)


@app.route('/agent/chat', methods=['POST'])
def chat():
    """
    对话接口（非流式）
    请求体：
    {
      "user_id": 1,                    // 用户ID（必填）
      "message": "我的任务",            // 用户消息（必填）
      "chat_id": "chat_xxx_xxx"        // 可选，会话ID（用于历史记录 + 上下文）
    }
    """
    _log_startup_config()
    data = request.get_json(silent=True) or {}
    user_id = data.get('user_id')
    message = (data.get('message') or '').strip()
    chat_id = data.get('chat_id')

    if not user_id:
        return _error('缺少 user_id 参数')
    if not message:
        return _error('消息内容不能为空')

    try:
        app.logger.info(f'[CHAT] user_id={user_id}, chat_id={chat_id}, message="{message[:80]}"')
        app.logger.info(f'[CHAT] 直接匹配: _match_intent(message)={_match_intent(message)}')
        # 记录 AI 使用日志到 operation_log（失败不影响对话）
        try:
            from services.db_service import log_ai_chat
            log_ai_chat(user_id, _client_ip(request), request.headers.get('User-Agent', ''))
        except Exception:
            pass
        reply = get_reply(user_id, message, chat_id=chat_id)
        app.logger.info(
            f'[CHAT] reply type={reply.get("type")}, content_length={len(reply.get("content", ""))} '
            f'used_llm={reply.get("meta", {}).get("used_llm")} '
            f'used_langgraph={reply.get("meta", {}).get("used_langgraph")}'
        )
        return _success({
            'reply': reply,
            'agent_name': AGENT_NAME,
            'chat_id': chat_id,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        })
    except Exception as e:
        app.logger.exception('chat error')
        return _error(f'处理消息出错：{str(e)}', 500)


@app.route('/agent/chat/stream', methods=['POST'])
def chat_stream():
    """
    对话接口（流式输出 SSE / 纯文本 chunk）
    请求体：同 /agent/chat，增加 chat_id 用于历史
    返回内容类型：text/event-stream 或 text/plain（逐 chunk 返回文本）
    约定：最后一个 chunk 以 '\\0__DONE__:' 开头，后面跟 JSON 格式 meta 数据。
    """
    _log_startup_config()
    data = request.get_json(silent=True) or {}
    user_id = data.get('user_id')
    message = (data.get('message') or '').strip()
    chat_id = data.get('chat_id')

    if not user_id:
        return _error('缺少 user_id 参数')
    if not message:
        return _error('消息内容不能为空')

    app.logger.info(f'[CHAT][STREAM] user_id={user_id}, chat_id={chat_id}, message="{message[:80]}"')

    # 记录 AI 使用日志到 operation_log（失败不影响对话）
    try:
        from services.db_service import log_ai_chat
        log_ai_chat(user_id, _client_ip(request), request.headers.get('User-Agent', ''))
    except Exception:
        pass

    def _generate():
        try:
            for chunk in get_reply_stream(user_id, message, chat_id=chat_id):
                # 以 text/plain 直接吐出（chunk 是字符串）
                if isinstance(chunk, str):
                    yield chunk
        except Exception as e:
            app.logger.exception('[CHAT][STREAM] generator error')
            import json as _json
            err_meta = {
                'type': 'text',
                'error': f'{type(e).__name__}: {e}',
                'used_llm': False,
                'used_langgraph': False,
            }
            yield f'\n\0__DONE__:' + _json.dumps(err_meta, ensure_ascii=False)

    # stream_with_context 保证 Flask 正常管理请求上下文（logging/request等）
    resp = Response(
        stream_with_context(_generate()),
        mimetype='text/plain; charset=utf-8',
    )
    # 禁用缓冲（让代理/浏览器边收边渲染）
    resp.headers['Cache-Control'] = 'no-cache, no-transform'
    resp.headers['X-Accel-Buffering'] = 'no'
    resp.headers['Connection'] = 'keep-alive'
    return resp


# ============================================================
# 聊天历史接口：前端 localStorage 丢失时可以从服务端拉取
# ============================================================
@app.route('/agent/history/<chat_id>', methods=['GET'])
def get_history(chat_id):
    """获取某个会话的完整聊天历史（GET /agent/history/<chat_id>?user_id=1）"""
    _log_startup_config()
    try:
        user_id = request.args.get('user_id', type=int)
        if not user_id:
            return _error('缺少 user_id 参数')
        if not CHAT_HISTORY_ENABLED:
            return _success({'enabled': False, 'messages': []}, '服务端聊天历史未启用')
        from services.chat_history import get_all_messages
        msgs = get_all_messages(chat_id, user_id)
        return _success({
            'enabled': True,
            'chat_id': chat_id,
            'user_id': user_id,
            'count': len(msgs),
            'messages': msgs,
        })
    except Exception as e:
        app.logger.exception('get_history error')
        return _error(f'获取历史出错：{str(e)}', 500)


@app.route('/agent/history/<chat_id>', methods=['DELETE'])
def delete_history(chat_id):
    """清空某个会话的历史（DELETE /agent/history/<chat_id>?user_id=1）"""
    _log_startup_config()
    try:
        user_id = request.args.get('user_id', type=int)
        if not user_id:
            return _error('缺少 user_id 参数')
        from services.chat_history import clear_history
        removed = clear_history(chat_id, user_id)
        return _success({
            'chat_id': chat_id,
            'user_id': user_id,
            'cleared': bool(removed),
        })
    except Exception as e:
        app.logger.exception('delete_history error')
        return _error(f'清空历史出错：{str(e)}', 500)


# ============================================================
# 其他分析接口（直接拿结构化数据，不用聊天）
# ============================================================
@app.route('/agent/task-analysis/<int:user_id>', methods=['GET'])
def task_analysis(user_id):
    """直接获取用户任务分析报告"""
    _log_startup_config()
    try:
        result = analyze_user_tasks(user_id)
        return _success(result)
    except Exception as e:
        app.logger.exception('task_analysis error')
        return _error(f'分析失败：{str(e)}', 500)


@app.route('/agent/team-analysis/<int:user_id>', methods=['GET'])
def team_analysis(user_id):
    """直接获取用户团队分析"""
    _log_startup_config()
    try:
        result = analyze_user_teams(user_id)
        return _success(result)
    except Exception as e:
        app.logger.exception('team_analysis error')
        return _error(f'分析失败：{str(e)}', 500)


if __name__ == '__main__':
    print(f'🤖 {AGENT_NAME} 启动中...')
    print(f'📍 地址：http://{HOST}:{PORT}')
    print(f'🐛 调试模式：{DEBUG}')
    # 启动日志：不等到第一次请求，直接在命令行打一次（便于排查 API Key 来源）
    try:
        print('=' * 60)
        print(f'🤖 {AGENT_NAME} 配置')
        print(f'• PROVIDER        = {MODEL_PROVIDER_DISPLAY}  (标识: {MODEL_PROVIDER}, {MODEL_PROVIDER_SRC})')
        print(f'• LLM_ENABLED     = {LLM_ENABLED}  ({LLM_ENABLED_SRC})')
        print(f'• API Key         = {_mask_key(DEEPSEEK_API_KEY)}  ({LLM_API_KEY_SRC})')
        print(f'• BASE_URL        = {DEEPSEEK_BASE_URL}  ({LLM_BASE_URL_SRC})')
        print(f'• MODEL           = {DEEPSEEK_MODEL}  ({LLM_MODEL_SRC})')
        print(f'• SHOW_REASONING  = {SHOW_REASONING}  (思维链, {SHOW_REASONING_SRC})')
        print(f'• USE_LANGGRAPH   = {USE_LANGGRAPH}  ({USE_LANGGRAPH_SRC})')
        print(f'• STREAM_ENABLED  = {STREAM_ENABLED}')
        print(f'• CHAT_HISTORY    = {CHAT_HISTORY_ENABLED}')
        print(f'💡 切换供应商: set MODEL_PROVIDER=modelscope|deepseek|custom 然后重启agent')
        print('=' * 60)
    except Exception:
        pass
    # threaded=True:多线程处理请求,避免大模型流式生成期间阻塞 /agent/health 等短请求(前端会5s超时)
    app.run(host=HOST, port=PORT, debug=DEBUG, threaded=True)
