# -*- coding: utf-8 -*-
r"""
独立最小化验证脚本：不经过 Flask / LangChain / LangGraph，直接用 openai SDK 验证
ModelScope / DeepSeek / 自定义 OpenAI 兼容端点的三件套是否有效。

用法（Windows cmd / PowerShell）：
    :: 先注入你自己的真实 Token（不要改代码里的默认值，那都是占位符！）
    set MODEL_PROVIDER=modelscope
    set LLM_API_KEY=ms-your-own-valid-modelscope-token
    :: 可选：不设就用 provider 预设
    :: set LLM_BASE_URL=https://api-inference.modelscope.cn/v1
    :: set LLM_MODEL=deepseek-ai/DeepSeek-V4-Flash-0731
    :: 运行
    & "D:\Code\python\AI\.venv\Scripts\python.exe" D:\Code\LTCMsystem\agent\test_modelscope_standalone.py

脚本会依次做：
  1) 打印当前三件套（Key 脱敏）和来源；
  2) 非流式请求一次"你好"并打印完整响应；
  3) 流式请求一次"1+1=？请先思考再给答案"，演示 reasoning_content（思维链）和 content（最终回答）的分离；
  4) 遇到 401/404/TIMEOUT 时，直接打印可复制的修复命令。
"""

from __future__ import annotations

import os
import sys
from typing import Tuple


# ---------------------------------------------------------------------------
# 小工具：解析配置（和 agent/config.py 的规则保持一致，但不 import 任何项目模块，保持纯独立）
# ---------------------------------------------------------------------------

PROVIDER_PRESETS = {
    'modelscope': {
        'default_base_url': 'https://api-inference.modelscope.cn/v1',
        'default_api_key':  'ms-your-own-modelscope-token',   # 占位符，必须换你自己的！
        'default_model':    'deepseek-ai/DeepSeek-V4-Flash-0731',
        'display_name':     'ModelScope 魔搭',
    },
    'deepseek': {
        'default_base_url': 'https://api.deepseek.com/v1',
        'default_api_key':  'your-deepseek-key-here',
        'default_model':    'deepseek-v4-flash',
        'display_name':     'DeepSeek 官方',
    },
    'custom': {
        'default_base_url': 'https://api.deepseek.com/v1',
        'default_api_key':  'sk-xxx',
        'default_model':    'deepseek-v4-flash',
        'display_name':     '自定义 OpenAI 兼容端点',
    },
}


def _resolve(env_key: str, default: str) -> Tuple[str, str]:
    v = os.getenv(env_key)
    if v is not None and v != '':
        return v, f'环境变量 {env_key}'
    return default, f'脚本默认值（未设置 {env_key}）'


def _resolve_llm(provider_preset_default: str,
                 env_key_primary: str, env_key_fallback: str) -> Tuple[str, str]:
    env_p = os.getenv(env_key_primary)
    if env_p is not None and env_p != '':
        return env_p, f'环境变量 {env_key_primary}'
    env_f = os.getenv(env_key_fallback)
    if env_f is not None and env_f != '':
        return env_f, f'环境变量 {env_key_fallback}（兼容旧写法）'
    return provider_preset_default, 'MODEL_PROVIDER 预设值（占位符，需要你换成自己的）'


def _mask(key: str) -> str:
    if not key:
        return '(空)'
    if len(key) <= 8:
        return '*' * len(key)
    return f'{key[:4]}****{key[-4:]}'


# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------

def main() -> int:
    # 1) 解析配置
    model_provider, provider_src = _resolve('MODEL_PROVIDER', 'modelscope')
    model_provider = model_provider.lower().strip() or 'modelscope'
    preset = PROVIDER_PRESETS.get(model_provider, PROVIDER_PRESETS['modelscope'])
    provider_display = preset['display_name']

    base_url, base_src  = _resolve_llm(preset['default_base_url'],  'LLM_BASE_URL', 'DEEPSEEK_BASE_URL')
    api_key,  key_src   = _resolve_llm(preset['default_api_key'],   'LLM_API_KEY',  'DEEPSEEK_API_KEY')
    model,    model_src = _resolve_llm(preset['default_model'],     'LLM_MODEL',    'DEEPSEEK_MODEL')

    print('=' * 72)
    print(f'[1/4] 当前生效配置')
    print(f'  PROVIDER  = {provider_display}（MODEL_PROVIDER="{model_provider}"，来源: {provider_src}）')
    print(f'  BASE_URL  = {base_url}          (来源: {base_src})')
    print(f'  MODEL     = {model}                          (来源: {model_src})')
    print(f'  API_KEY   = {_mask(api_key)}                (来源: {key_src})')
    if api_key.startswith(('ms-your-', 'your-', 'sk-xxx')):
        print('  ⚠️  你还在用脚本里写死的占位符 Token！**一定会 401 鉴权失败**')
        print(f'     请先执行：{"set LLM_API_KEY=ms-your-own-token" if model_provider=="modelscope" else "set LLM_API_KEY=sk-your-own-deepseek-key"}')
        print('=' * 72)
    print()

    # 2) 尝试 import openai SDK
    try:
        from openai import OpenAI
    except Exception as e:
        print(f'[FATAL] 缺少 openai 依赖：{type(e).__name__}: {e}')
        print('  安装命令：')
        print('    & "D:\\Code\\python\\AI\\.venv\\Scripts\\python.exe" -m pip install -U openai')
        return 2

    client = OpenAI(base_url=base_url.rstrip('/'), api_key=api_key)

    # 3) 非流式调用
    print('[2/4] 非流式请求：模型=你好（快速验证鉴权/接口是否通）')
    print('-' * 72)
    try:
        resp = client.chat.completions.create(
            model=model,
            messages=[{'role': 'user', 'content': '你好'}],
            max_tokens=200,
            stream=False,
        )
        choices = getattr(resp, 'choices', []) or []
        if not choices:
            print('  ❌ choices 为空，原始响应：', resp)
            return 3
        msg = choices[0].message
        content = (getattr(msg, 'content', '') or '').strip()
        reasoning = (getattr(msg, 'reasoning_content', None) or getattr(msg, 'reasoning', None) or '').strip()
        usage = getattr(resp, 'usage', None)
        print('  ✅ 200 成功')
        if reasoning:
            print(f'  思维链 reasoning_content ({len(reasoning)} 字)：\n{reasoning}\n')
        print(f'  回答 content：{content or "(空)"}')
        if usage:
            print(f'  token 用量：prompt={usage.prompt_tokens}, completion={usage.completion_tokens}, total={usage.total_tokens}')
    except Exception as e:
        status_code = getattr(e, 'status_code', None)
        body = getattr(e, 'body', None) or {}
        try:
            sub_msg = body.get('error', {}).get('message', '') if isinstance(body, dict) else ''
        except Exception:
            sub_msg = ''
        raw_msg = sub_msg or str(e)
        print(f'  ❌ {type(e).__name__}  status={status_code or "?"}')
        print(f'     {raw_msg}')
        print()
        # 诊断
        if status_code == 401:
            print('🔐 401 鉴权失败 — 怎么修：')
            print('  1. 去以下地址拿到你自己的真实 Token：')
            if model_provider == 'modelscope':
                print('        https://www.modelscope.cn/my/myaccesstoken')
            elif model_provider == 'deepseek':
                print('        https://platform.deepseek.com/api_keys')
            else:
                print('        <你的自定义平台的密钥管理页面>')
            print('  2. 在当前窗口执行（临时生效，新窗口失效）：')
            if model_provider == 'modelscope':
                print('        set LLM_API_KEY=ms-你复制的token')
            else:
                print('        set LLM_API_KEY=sk-你复制的key')
            print('     （想永久生效：计算机→属性→高级系统设置→环境变量→用户变量 里添加同名项）')
            print('  3. 重跑本脚本，看到 ✅ 200 成功 就可以回去用 agent 服务了')
            print()
            print(f'  附当前诊断：BASE_URL={base_url} MODEL={model} KEY={_mask(api_key)} 来源={key_src}')
            return 10
        if status_code == 404:
            print('🧭 404 不存在 — 核对 BASE_URL 是否以 /v1 结尾、MODEL 是否符合 provider 要求：')
            print(f'     BASE_URL = {base_url}')
            print(f'     MODEL    = {model}')
            print('   ModelScope 必须是 "组织/模型名" 格式，例如 deepseek-ai/DeepSeek-V4-Flash-0731')
            print('   DeepSeek 官方必须是 "deepseek-v4-flash" / "deepseek-chat" 等')
            return 11
        if 'timeout' in str(type(e).__name__).lower() or 'timed out' in raw_msg.lower():
            print('⏰ 超时 — 解决：')
            print('  - 检查能否直接浏览器打开：', base_url)
            print('  - 公司/校园网是否需要代理？是否要设置 NO_PROXY=localhost,127.0.0.1')
            return 12
        return 13

    print()
    # 4) 流式调用 + reasoning_content（跟你问题里贴的那段脚本逻辑一致）
    print('[3/4] 流式请求：1+1=？请先思考再给答案（演示 reasoning_content 和 content 的分离）')
    print('-' * 72)
    try:
        stream = client.chat.completions.create(
            model=model,
            messages=[{'role': 'user', 'content': '1+1=？先写一步推理，再给出答案'}],
            max_tokens=500,
            stream=True,
        )
        done_reasoning = False
        for chunk in stream:
            if not chunk.choices:
                continue
            delta = chunk.choices[0].delta
            reasoning_chunk = (getattr(delta, 'reasoning_content', None)
                               or getattr(delta, 'reasoning', None) or '')
            answer_chunk = (getattr(delta, 'content', None) or '')
            if reasoning_chunk:
                print(reasoning_chunk, end='', flush=True)
            elif answer_chunk:
                if not done_reasoning:
                    print('\n\n === Final Answer ===\n')
                    done_reasoning = True
                print(answer_chunk, end='', flush=True)
        print()
        print('  ✅ 流式输出结束')
    except Exception as e:
        status_code = getattr(e, 'status_code', None)
        body = getattr(e, 'body', None) or {}
        try:
            sub_msg = body.get('error', {}).get('message', '') if isinstance(body, dict) else ''
        except Exception:
            sub_msg = ''
        print(f'  ❌ 流式失败 {type(e).__name__} status={status_code or "?"}')
        print(f'     {sub_msg or str(e)}')
        return 20

    print()
    print('[4/4] 总结：如果前几步都 ✅ 200 成功，你的三件套就完全可用了。')
    print(f'     现在重启 agent 服务，保证它的 LLM_API_KEY / MODEL_PROVIDER 和本脚本一致。')
    return 0


if __name__ == '__main__':
    sys.exit(main())
