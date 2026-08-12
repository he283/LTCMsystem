# -*- coding: utf-8 -*-
"""
LLM服务：封装DeepSeek大模型API调用
提供：重试机制、密钥脱敏、错误分类、系统提示词、结构化上下文注入
"""
import json
import time
import logging
import traceback
import requests

from config import (
    LLM_ENABLED,
    DEEPSEEK_API_KEY,
    DEEPSEEK_BASE_URL,
    DEEPSEEK_MODEL,
    DEEPSEEK_TIMEOUT,
    DEEPSEEK_TEMPERATURE,
    DEEPSEEK_MAX_TOKENS,
    LLM_FALLBACK_TO_LOCAL,
    AGENT_NAME,
    # 多供应商
    MODEL_PROVIDER,
    MODEL_PROVIDER_DISPLAY,
    MODEL_PROVIDER_SRC,
    LLM_BASE_URL_SRC,
    LLM_API_KEY_SRC,
    LLM_MODEL_SRC,
    SHOW_REASONING,
    # 三层候选诊断（"我改了config.py为什么没生效"）
    _get_llm_config_layers_diag,
)

logger = logging.getLogger(__name__)

# ============================================================
# 工具函数
# ============================================================

def _mask_key(key):
    """密钥脱敏：只显示前后4位，中间打码"""
    if not key or len(key) <= 8:
        return '****'
    return f'{key[:4]}****{key[-4:]}'


def _json_safe(data, indent=None):
    """安全JSON序列化（处理datetime等非标准类型）"""
    def default(o):
        try:
            return str(o)
        except Exception:
            return repr(o)
    return json.dumps(data, ensure_ascii=False, indent=indent, default=default)


def _render_with_reasoning_simple(content: str, reasoning: str) -> str:
    """requests 直连路径的思维链拼接（与 langchain_llm 对齐，只是这里直接处理字符串）"""
    if not reasoning or not SHOW_REASONING:
        return content or ''
    return (
        f'<details open>\n'
        f'<summary>🧠 思考过程（Reasoning）</summary>\n\n'
        f'{reasoning}\n\n'
        f'</details>\n\n'
        f'---\n\n'
        f'{content or ""}'
    )


# ============================================================
# 核心LLM调用
# ============================================================

def _call_deepseek_api(messages, max_retry=2):
    """
    内部调用DeepSeek Chat Completions接口
    :param messages: [{"role": "system"/"user"/"assistant", "content": str}, ...]
    :param max_retry: 最大重试次数（网络错误时）
    :return: {"success": bool, "content": str, "error": str, "usage": dict}
    """
    if not LLM_ENABLED:
        return {
            'success': False,
            'content': None,
            'error': 'LLM_DISABLED',
            'usage': None
        }

    if not DEEPSEEK_API_KEY or DEEPSEEK_API_KEY.startswith('your-') or len(DEEPSEEK_API_KEY) < 10:
        logger.warning('[LLM] API Key未配置或无效，已跳过LLM调用')
        return {
            'success': False,
            'content': None,
            'error': 'INVALID_API_KEY',
            'usage': None
        }

    url = f'{DEEPSEEK_BASE_URL.rstrip("/")}/chat/completions'
    headers = {
        'Authorization': f'Bearer {DEEPSEEK_API_KEY}',
        'Content-Type': 'application/json'
    }
    payload = {
        'model': DEEPSEEK_MODEL,
        'messages': messages,
        'temperature': DEEPSEEK_TEMPERATURE,
        'max_tokens': DEEPSEEK_MAX_TOKENS,
        'stream': False
    }

    last_error = None
    for attempt in range(max_retry + 1):
        try:
            logger.info(
                f'[LLM] 调用（provider={MODEL_PROVIDER_DISPLAY} 尝试 {attempt + 1}/{max_retry + 1}）| '
                f'model={DEEPSEEK_MODEL} | base_url={DEEPSEEK_BASE_URL} | '
                f'key={_mask_key(DEEPSEEK_API_KEY)} (来源: {LLM_API_KEY_SRC}) | '
                f'messages={len(messages)} 条'
            )
            resp = requests.post(
                url,
                headers=headers,
                json=payload,
                timeout=DEEPSEEK_TIMEOUT
            )
            status = resp.status_code

            # 4xx 客户端错误，不重试（除了429限流）
            if 400 <= status < 500 and status != 429:
                try:
                    err_data = resp.json()
                    err_msg = err_data.get('error', {}).get('message', resp.text)
                except Exception:
                    err_msg = resp.text[:200]
                if status == 401:
                    logger.error(f'[LLM] 鉴权失败(401)，请检查API Key是否正确：{_mask_key(DEEPSEEK_API_KEY)}')
                    diag_prefix = (
                        f'\n┌─── 🔐 LLM 401 认证诊断 ─────────────────────────────────────────────\n'
                        f'│ 供应商:     {MODEL_PROVIDER_DISPLAY}（MODEL_PROVIDER="{MODEL_PROVIDER}"，来源: {MODEL_PROVIDER_SRC}）\n'
                        f'│ 当前Key:    {_mask_key(DEEPSEEK_API_KEY)}（来源: {LLM_API_KEY_SRC}）\n'
                        f'│ BASE_URL:   {DEEPSEEK_BASE_URL}（来源: {LLM_BASE_URL_SRC}）\n'
                        f'│ MODEL:      {DEEPSEEK_MODEL}（来源: {LLM_MODEL_SRC}）\n'
                        f'│ 原始报错:   {err_msg}\n'
                        f'├─ 修复建议：\n'
                    )
                    if MODEL_PROVIDER == 'modelscope':
                        fix = (
                            '│  1) 到 https://www.modelscope.cn/my/myaccesstoken 复制你自己的 ModelScope Token\n'
                            '│  2) 在当前 cmd/PowerShell 临时注入（推荐，不写进仓库）：\n'
                            '│          set LLM_API_KEY=ms-your-own-valid-token\n'
                            '│  3) 重启 agent 服务，再访问 GET /agent/health 看 llm_connectivity.ping_ok 是否为 True\n'
                            '│  ⚠️ 注意：示例代码里的 ms-5b3a... / config 预设里的 ms-your-own-modelscope-token 都只是占位符，不能真实鉴权！\n'
                        )
                    elif MODEL_PROVIDER == 'deepseek':
                        fix = (
                            '│  1) 到 https://platform.deepseek.com/api_keys 申请你自己的 DeepSeek API Key\n'
                            '│  2) 在当前 cmd/PowerShell 临时注入：\n'
                            '│          set LLM_API_KEY=sk-your-own-deepseek-key\n'
                            '│  3) 重启 agent 服务，再访问 GET /agent/health 看 llm_connectivity.ping_ok 是否为 True\n'
                        )
                    else:  # custom
                        fix = (
                            '│  1) 确认你自建/第三方转发端需要的鉴权方式是 Bearer Token 而不是别的（x-api-key / 签名等）\n'
                            '│  2) 注入三件套：\n'
                            '│          set MODEL_PROVIDER=custom\n'
                            '│          set LLM_BASE_URL=https://your-endpoint.example.com/v1\n'
                            '│          set LLM_API_KEY=your-key-here\n'
                            '│          set LLM_MODEL=provider-model-name\n'
                            '│  3) 重启 agent 服务，访问 /agent/health 校验\n'
                        )
                    # —— 新增：三层候选对比表，直击"我改了config.py为什么没生效"灵魂拷问
                    try:
                        diag = _get_llm_config_layers_diag()
                        layer_lines = ['├─ 三层候选对比（🔝从上往下优先级递减，✅标注的才是"实际发出去的那一条"）：']
                        for name, info in diag.items():
                            layer_lines.append(
                                f'│   📌 [{name.upper()}] 生效层=Layer{info["used_layer"]} → {info["used_source"]}  值={info["used_value"]}'
                            )
                            for layer in info['layers']:
                                mark = '✅用' if layer['used'] else '  跳过'
                                layer_lines.append(
                                    f'│        Layer {layer["layer"]} {mark}  {layer["title"]}  →  {layer["value"]}'
                                )
                        # 再追加一行小提示：胜出层不是 config.py 时提醒清除环境变量
                        if any(info['used_layer'] != 2 for info in diag.values()):
                            layer_lines.append('├─  ⚠️  发现环境变量覆盖了 config.py！想让 config.py 的预设生效，请先删除环境变量：')
                            layer_lines.append('│     (PS) Remove-Item Env:LLM_API_KEY,Env:DEEPSEEK_API_KEY,Env:LLM_BASE_URL,Env:DEEPSEEK_BASE_URL,Env:LLM_MODEL,Env:DEEPSEEK_MODEL')
                            layer_lines.append('│     (CMD) set LLM_API_KEY=& set DEEPSEEK_API_KEY=& set LLM_BASE_URL=& set DEEPSEEK_BASE_URL=& set LLM_MODEL=& set DEEPSEEK_MODEL=')
                        diag_layers_block = '\n'.join(layer_lines) + '\n'
                    except Exception as _e:
                        diag_layers_block = f'├─ (三层候选对比生成失败: {type(_e).__name__}: {_e})\n'
                    diag_suffix = '└─────────────────────────────────────────────────────────────────────'
                    last_error = f'AUTH_FAILED_401: {err_msg}{diag_prefix}{fix}{diag_layers_block}{diag_suffix}'
                elif status == 404:
                    logger.error(f'[LLM] 接口404，请检查BASE_URL: {DEEPSEEK_BASE_URL}')
                    last_error = (
                        f'NOT_FOUND_404: {err_msg}\n'
                        f'┌─── 🧭 LLM 404 诊断 ─────────────────────────────────────────────────\n'
                        f'│ BASE_URL = {DEEPSEEK_BASE_URL}（来源: {LLM_BASE_URL_SRC}）\n'
                        f'│ MODEL    = {DEEPSEEK_MODEL}（来源: {LLM_MODEL_SRC}）\n'
                        f'└─ 核对 BASE_URL 是否以 /v1 结尾、MODEL 是否和 provider 要求的格式完全一致（魔搭是 "deepseek-ai/DeepSeek-V4-Flash-0731"，deepseek官方是 "deepseek-v4-flash"）\n'
                    )
                else:
                    logger.error(f'[LLM] 客户端错误 {status}: {err_msg}')
                    last_error = f'CLIENT_ERROR_{status}: {err_msg}'
                if status != 429:
                    break

            # 5xx 或 429，继续重试
            if status != 200:
                logger.warning(f'[LLM] HTTP {status}，尝试重试...')
                last_error = f'HTTP_{status}'
                if attempt < max_retry:
                    time.sleep(1.5 ** attempt)
                    continue
                # 最后一次仍失败
                try:
                    err_data = resp.json()
                    last_error = f'HTTP_{status}: {err_data.get("error", {}).get("message", resp.text[:200])}'
                except Exception:
                    pass
                break

            # 200 成功
            result = resp.json()
            choices = result.get('choices') or []
            if not choices:
                last_error = 'EMPTY_CHOICES'
                logger.error(f'[LLM] 返回内容为空: {result}')
                break

            msg = choices[0].get('message', {}) or {}
            content = (msg.get('content') or '').strip()
            reasoning = (msg.get('reasoning_content') or msg.get('reasoning') or '').strip() or None
            usage = result.get('usage', {})

            # ModelScope / 推理模型可能 reasoning 有内容但 content 为空（先输出思维链），两者都空才算真正空
            if not content and not reasoning:
                last_error = 'EMPTY_CONTENT'
                logger.warning('[LLM] 返回内容为空字符串（content 和 reasoning_content 都为空）')
                break

            content = _render_with_reasoning_simple(content, reasoning)

            logger.info(
                f'[LLM] 调用成功（provider={MODEL_PROVIDER_DISPLAY}）| '
                f'prompt_tokens={usage.get("prompt_tokens", "?")} | '
                f'completion_tokens={usage.get("completion_tokens", "?")} | '
                f'content_len={len(content)} reasoning_len={len(reasoning) if reasoning else 0}'
            )
            return {
                'success': True,
                'content': content,
                'error': None,
                'usage': usage
            }

        except requests.exceptions.Timeout:
            last_error = 'TIMEOUT'
            logger.warning(f'[LLM] 请求超时（尝试 {attempt + 1}/{max_retry + 1}）')
            if attempt < max_retry:
                time.sleep(1.5 ** attempt)
        except requests.exceptions.ConnectionError as e:
            last_error = f'CONNECTION_ERROR: {type(e).__name__}'
            logger.warning(f'[LLM] 连接错误（尝试 {attempt + 1}/{max_retry + 1}）: {last_error}')
            if attempt < max_retry:
                time.sleep(1.5 ** attempt)
        except Exception as e:
            last_error = f'{type(e).__name__}: {str(e)}'
            logger.error(f'[LLM] 未预期异常: {last_error}\n{traceback.format_exc()}')
            break

    return {
        'success': False,
        'content': None,
        'error': last_error,
        'usage': None
    }


# ============================================================
# 面向业务的高层接口
# ============================================================

# 默认系统提示词：明确身份 + 输出规范 + 上下文使用规则
DEFAULT_SYSTEM_PROMPT = f'''你是「{AGENT_NAME}」，一个服务于 LTCM（轻量任务协作管理系统）的智能任务助手。

你的职责：
1. 基于下方【上下文数据】分析用户的任务、团队、通知情况，用亲切自然的中文回复
2. 如果上下文数据足够，给出有数据支撑、有温度、有洞察的分析和建议
3. 输出格式要求：
   - 擅长使用 Markdown 格式（加粗、标题、列表、Emoji增强可读性）
   - 任务卡片信息请条理清晰地展示编号、状态、优先级、截止时间
   - 适度使用Emoji让内容更生动但不要过度
4. 如果上下文数据为空或不足以回答问题，如实告知并给建议，不要编造数据
5. 不要暴露你调用了系统或数据库，直接用第一人称和用户交流
6. 保持回复简洁但信息完整，不要无意义寒暄
7. 逾期任务和高优先级任务要醒目提醒（建议用红色/橙色Emoji标注）

重要：你是任务管理助手，不要回答与任务/团队/工作管理无关的问题（如闲聊、编程、数学题等），遇到这类问题请礼貌地引导用户回到任务管理相关话题。
'''.strip()


def enhance_reply_with_llm(
    user_id,
    user_name,
    user_query,
    context_data,
    context_label,
    local_reply_content,
    system_prompt=None
):
    """
    【混合架构核心函数】用LLM润色/增强本地生成的回复
    - 调用失败时按配置自动降级为本地回复

    :param user_id: 用户ID
    :param user_name: 用户昵称
    :param user_query: 用户原始提问
    :param context_data: 本地查询到的结构化数据（dict/list，会被JSON注入上下文）
    :param context_label: 数据类型标签（如"任务分析报告"/"今日任务清单"等）
    :param local_reply_content: 本地规则生成的默认回复（降级时直接返回）
    :param system_prompt: 自定义系统提示词（可选，覆盖默认）
    :return: (content_str, used_llm: bool)
    """
    # 如果LLM未开启，直接返回本地回复
    if not LLM_ENABLED:
        return local_reply_content, False

    # 系统提示词
    sys_prompt = system_prompt or DEFAULT_SYSTEM_PROMPT

    # 构造用户消息：注入结构化上下文 + 用户原始提问
    context_json = _json_safe(context_data, indent=2)
    user_message_parts = []
    user_message_parts.append(f'【当前用户】{user_name or "用户"} (ID: {user_id})')
    user_message_parts.append(f'【查询类型】{context_label}')
    user_message_parts.append(f'【上下文数据（仅供参考，不要原样输出JSON）】\n```json\n{context_json}\n```')
    user_message_parts.append(f'\n【用户的原始提问】\n{user_query}')
    if local_reply_content and LLM_FALLBACK_TO_LOCAL:
        user_message_parts.append(f'\n【系统默认草稿（可润色改写，但关键数据不要出错）】\n{local_reply_content}')
    user_message = '\n\n'.join(user_message_parts)

    messages = [
        {'role': 'system', 'content': sys_prompt},
        {'role': 'user', 'content': user_message}
    ]

    # 调用LLM
    result = _call_deepseek_api(messages)
    if result.get('success') and result.get('content'):
        return result['content'], True

    # 失败处理
    logger.warning(f'[LLM] 增强失败 ({result.get("error")})，按配置决定是否降级')
    if LLM_FALLBACK_TO_LOCAL:
        logger.info('[LLM] 已降级为本地规则回复')
        return local_reply_content, False
    else:
        # 不降级：返回错误提示
        return f'😢 智能助手暂时无法响应（错误：{result.get("error")}），请稍后再试～', False


# ============================================================
# 简单连通性测试
# ============================================================

def ping_llm():
    """
    测试LLM是否可用（发送最小请求）
    :return: (ok: bool, message: str)
    """
    if not LLM_ENABLED:
        return False, 'LLM未启用（LLM_ENABLED=False）'
    if not DEEPSEEK_API_KEY or len(DEEPSEEK_API_KEY) < 10:
        return False, f'API Key无效: {_mask_key(DEEPSEEK_API_KEY)}'

    messages = [
        {'role': 'system', 'content': '你是一个测试助手，只需要回复"PONG"三个字，不要其他内容。'},
        {'role': 'user', 'content': 'PING'}
    ]
    result = _call_deepseek_api(messages, max_retry=1)
    if result['success']:
        content = result['content'].strip()
        usage = result.get('usage') or {}
        return True, f'连接成功！回复="{content}"，消耗={usage.get("total_tokens", "?")} tokens'
    return False, f'连接失败: {result.get("error")}'
