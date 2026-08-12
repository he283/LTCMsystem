# -*- coding: utf-8 -*-
"""
测试 LangChain + LangGraph 版 Agent
测试内容：
1. 环境检查（.venv解释器、LangChain/LangGraph/DeepSeek依赖版本）
2. LangChain ChatModel 连通性测试（PING-PONG）
3. LangGraph 工作流节点测试（静态意图、数据驱动意图）
4. chat_service 集成测试（USE_LANGGRAPH=True走LangGraph路径）
5. 完整对话示例输出
"""
import sys
import os
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def divider(title=''):
    print()
    print('=' * 72)
    if title:
        print(f'  {title}')
        print('=' * 72)


def section(title):
    print()
    print(f'--- {title} ' + '-' * max(0, 62 - len(title)))


if __name__ == '__main__':
    USER_ID = 1
    print()
    print('🚀 LTCM Agent - LangChain + LangGraph 集成测试')
    print(f'   Python: {sys.executable}')
    print(f'   Version: {sys.version}')

    # ============================================================
    # 1. 环境检查
    # ============================================================
    divider('1. 环境 & 依赖版本检查')

    try:
        import langchain
        print(f'✅ langchain        : {langchain.__version__}')
    except Exception as e:
        print(f'❌ langchain        : 导入失败 - {e}')

    try:
        import langgraph
        # 部分版本可能没有__version__，改用其他方式
        try:
            ver = langgraph.__version__
        except AttributeError:
            ver = '已安装 (无__version__属性)'
        print(f'✅ langgraph        : {ver}')
    except Exception as e:
        print(f'❌ langgraph        : 导入失败 - {e}')

    try:
        from langchain_openai import ChatOpenAI
        print(f'✅ langchain-openai : 可用')
    except Exception as e:
        print(f'❌ langchain-openai : 导入失败 - {e}')

    # 检查指定.venv路径
    import config
    print(f'✅ 目标解释器路径   : {config.VENV_PYTHON}')
    print(f'✅ 当前解释器路径   : {sys.executable}')
    is_target = config.VENV_PYTHON.lower().replace('/', '\\') == sys.executable.lower().replace('/', '\\')
    if not is_target:
        print(f'⚠️  注意：当前解释器与目标.venv不一致（运行时无影响，但安装依赖时需确保装到目标.venv中）')
    else:
        print(f'✅ 解释器匹配：当前正运行在目标.venv中')

    print()
    print(f'   USE_LANGGRAPH = {config.USE_LANGGRAPH}')
    print(f'   LLM_ENABLED   = {config.LLM_ENABLED}')
    print(f'   DEEPSEEK_MODEL= {config.DEEPSEEK_MODEL}')
    print(f'   DEEPSEEK_BASE = {config.DEEPSEEK_BASE_URL}')

    # ============================================================
    # 2. LangChain ChatModel 连通性测试（PING-PONG）
    # ============================================================
    divider('2. LangChain ChatModel 连通性测试 (deepseek-v4-flash)')
    try:
        from services.langchain_llm import ping_llm_langchain
        ok, msg = ping_llm_langchain()
        status = '✅ 成功' if ok else '❌ 失败'
        print(f'{status}: {msg}')
        if not ok:
            print('⚠️  后续LLM润色节点会自动降级为本地草稿（FALLBACK已开启）')
    except Exception as e:
        print(f'❌ 导入失败: {type(e).__name__}: {e}')

    # ============================================================
    # 3. LangGraph 工作流直接测试
    # ============================================================
    divider('3. LangGraph StateGraph 直接调用测试')

    try:
        from services.langchain_llm import invoke_agent_via_langgraph, get_agent_graph

        # 先编译一次图
        t0 = time.perf_counter()
        graph = get_agent_graph()
        t1 = time.perf_counter()
        print(f'✅ 图编译完成: {round((t1-t0)*1000, 0)}ms')

        # 测试1: 静态意图 - greeting (不查DB, 不调LLM)
        section('3.1 静态意图: "你好" (预期走 static_reply → finalize，不调用LLM)')
        reply = invoke_agent_via_langgraph(USER_ID, '你好')
        meta = reply.get('meta', {})
        steps = meta.get('steps', [])
        print(f'   steps           : {" → ".join(steps)}')
        print(f'   intent          : {meta.get("intent")}')
        print(f'   used_langgraph  : {meta.get("used_langgraph")}')
        print(f'   used_llm        : {meta.get("used_llm")} (应为 False)')
        print(f'   type            : {reply.get("type")}')
        print(f'   content_preview : {reply.get("content", "")[:80].replace(chr(10), " ⏎ ")}...')
        if meta.get('used_llm') is False:
            print('   ✅ 静态意图正确：未调用LLM，节省Token')

        # 测试2: 数据驱动意图 - task_analysis (查DB + LLM润色)
        section('3.2 数据驱动: "我的任务" (预期走 data_query → llm_polish → finalize)')
        t0 = time.perf_counter()
        reply = invoke_agent_via_langgraph(USER_ID, '我的任务')
        elapsed = (time.perf_counter() - t0) * 1000
        meta = reply.get('meta', {})
        steps = meta.get('steps', [])
        print(f'   steps           : {" → ".join(steps)}')
        print(f'   intent          : {meta.get("intent")}')
        print(f'   used_langgraph  : {meta.get("used_langgraph")}')
        print(f'   used_llm        : {meta.get("used_llm")}')
        print(f'   latency         : {round(elapsed, 0)}ms')
        if meta.get('llm_latency_ms'):
            print(f'   llm_latency     : {meta.get("llm_latency_ms")}ms')
        if meta.get('llm_usage'):
            u = meta['llm_usage']
            print(f'   token_usage     : prompt={u.get("prompt_tokens")} '
                  f'completion={u.get("completion_tokens")} total={u.get("total_tokens")}')
        if meta.get('llm_error'):
            print(f'   llm_error       : {meta["llm_error"]}')
        print(f'   has_data        : {reply.get("data") is not None}')
        print(f'   content_len     : {len(reply.get("content", ""))}')

        # 测试3: 数据驱动意图 - today_tasks
        section('3.3 数据驱动: "今天做什么"')
        t0 = time.perf_counter()
        reply = invoke_agent_via_langgraph(USER_ID, '今天做什么')
        elapsed = (time.perf_counter() - t0) * 1000
        meta = reply.get('meta', {})
        steps = meta.get('steps', [])
        print(f'   steps           : {" → ".join(steps)}')
        print(f'   intent          : {meta.get("intent")}')
        print(f'   used_llm        : {meta.get("used_llm")} | latency: {round(elapsed,0)}ms')
        print(f'   content_preview : {reply.get("content", "")[:100].replace(chr(10), " ⏎ ")}...')

        # 测试4: unknown模糊匹配
        section('3.4 模糊匹配: "我最近要做什么事" (unknown → 模糊 → data_query)')
        reply = invoke_agent_via_langgraph(USER_ID, '我最近要做什么事')
        meta = reply.get('meta', {})
        steps = meta.get('steps', [])
        print(f'   steps           : {" → ".join(steps)}')
        print(f'   intent          : {meta.get("intent")}')
        print(f'   used_llm        : {meta.get("used_llm")}')

    except Exception as e:
        print(f'❌ LangGraph测试异常: {type(e).__name__}: {e}')
        import traceback
        traceback.print_exc()

    # ============================================================
    # 4. chat_service 集成测试 (自动选择路径)
    # ============================================================
    divider('4. chat_service.get_reply 集成测试（自动选择LangGraph/纯函数路径）')
    try:
        from services.chat_service import get_reply

        test_cases = [
            ('帮助', 'help → 静态意图，不调LLM'),
            ('逾期任务', 'overdue_tasks → 数据驱动 + LLM润色'),
            ('高优先级', 'high_priority → 数据驱动'),
            ('我的团队', 'team_analysis → 数据驱动'),
            ('通知消息', 'notifications → 数据驱动'),
        ]
        for q, desc in test_cases:
            section(f'Q="{q}"  ({desc})')
            t0 = time.perf_counter()
            reply = get_reply(USER_ID, q)
            elapsed = (time.perf_counter() - t0) * 1000
            meta = reply.get('meta', {})
            print(f'   used_langgraph  : {meta.get("used_langgraph")}')
            print(f'   used_llm        : {meta.get("used_llm")}')
            print(f'   intent          : {meta.get("intent")}')
            print(f'   total_time      : {round(elapsed, 0)}ms')
            print(f'   content_len     : {len(reply.get("content", ""))}')
            content = reply.get('content', '')
            preview = content[:120].replace('\n', ' ⏎ ')
            if len(content) > 120:
                preview += '...'
            print(f'   preview         : {preview}')

    except Exception as e:
        print(f'❌ chat_service测试异常: {type(e).__name__}: {e}')
        import traceback
        traceback.print_exc()

    # ============================================================
    # 5. 完整对话示例展示
    # ============================================================
    divider('5. 完整示例输出（展示最终给用户的效果）')

    example_queries = [
        ('你好', '问候'),
        ('分析一下我的任务', '任务分析（LLM润色版）'),
    ]
    try:
        from services.chat_service import get_reply
        for q, label in example_queries:
            section(f'示例：{label}  → 用户问: "{q}"')
            reply = get_reply(USER_ID, q)
            print()
            print('🤖 LTCM小助手回复:')
            print('-' * 72)
            print(reply.get('content', ''))
            print('-' * 72)
            meta = reply.get('meta', {})
            print(f'   (intent={meta.get("intent")} | used_langgraph={meta.get("used_langgraph")} | '
                  f'used_llm={meta.get("used_llm")})')
    except Exception as e:
        print(f'❌ 示例输出异常: {type(e).__name__}: {e}')

    # ============================================================
    # 总结
    # ============================================================
    divider()
    print('🏁 LangChain + LangGraph 集成测试完成！')
    print()
    print('   核心流程（LangGraph状态机）:')
    print('     START → classify_intent')
    print('                ├ 静态意图 → static_reply → finalize → END')
    print('                └ 数据意图 → data_query')
    print('                                ├ 有data + LLM可用 → llm_polish → finalize → END')
    print('                                └ 否则 → finalize → END')
    print()
    print('   使用方式:')
    print('     1. 启动Agent服务: 用指定.venv运行 agent/start.bat 或 app.py')
    print('     2. 前端集成: 通过 /api/agent/chat 调用')
    print('     3. USE_LANGGRAPH=True → 走LangGraph（默认）')
    print('     4. USE_LANGGRAPH=False → 回退到纯函数模式')
    print()
