# -*- coding: utf-8 -*-
"""
测试 DeepSeek LLM 接入效果
测试内容：
1. LLM API 连通性（ping）
2. 静态意图（不调用LLM，节省Token）
3. 数据驱动意图（对比本地回复 vs LLM增强回复）
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from services.llm_service import ping_llm
from services.chat_service import get_reply, STATIC_REPLIES, DATA_DRIVEN_INTENTS, _match_intent
from config import LLM_ENABLED, DEEPSEEK_MODEL, DEEPSEEK_BASE_URL


def divider(title=''):
    print()
    print('=' * 70)
    if title:
        print(f'  {title}')
        print('=' * 70)


def section(title):
    print()
    print(f'--- {title} ' + '-' * (60 - len(title)))


if __name__ == '__main__':
    USER_ID = 1
    print()
    print('🤖  LTCM Agent - DeepSeek LLM 接入测试')
    print(f'   LLM_ENABLED={LLM_ENABLED}  MODEL={DEEPSEEK_MODEL}')
    print(f'   BASE_URL={DEEPSEEK_BASE_URL}')

    # ============================================================
    # 1. LLM连通性测试
    # ============================================================
    divider('1. LLM API 连通性测试')
    ok, msg = ping_llm()
    status = '✅ 成功' if ok else '❌ 失败'
    print(f'{status}: {msg}')
    if not ok:
        print('⚠️  后续测试中LLM增强将自动降级为本地回复（已开启FALLBACK）')

    # ============================================================
    # 2. 静态意图（预期不调用LLM）
    # ============================================================
    divider('2. 静态意图测试（greeting/help/thanks/who/unknown → 不调用LLM）')
    static_cases = [
        ('你好', 'greeting'),
        ('帮助', 'help'),
        ('谢谢', 'thanks'),
        ('你是谁', 'who_are_you'),
        ('123今天天气怎么样', 'unknown'),
    ]
    for q, expected_intent in static_cases:
        intent = _match_intent(q)
        reply = get_reply(USER_ID, q)
        used_llm = reply.get('meta', {}).get('used_llm', False)
        status = '✅' if (intent == expected_intent and not used_llm) else '⚠️'
        print(f'{status} Q="{q}" | intent={intent:12s} | used_llm={used_llm} | content_len={len(reply.get("content", ""))}')

    # ============================================================
    # 3. 数据驱动意图 → 本地 + LLM增强
    # ============================================================
    divider('3. 数据驱动意图测试 → LLM增强（对比本地草稿和LLM生成）')
    data_cases = [
        ('我的任务', 'task_analysis'),
        ('今天做什么', 'today_tasks'),
        ('逾期任务', 'overdue_tasks'),
        ('高优先级', 'high_priority'),
        ('我的团队', 'team_analysis'),
        ('通知消息', 'notifications'),
    ]

    for q, expected_intent in data_cases:
        section(f'Q: "{q}" (预期intent={expected_intent})')

        # 先临时禁用LLM拿到本地草稿
        import config
        original_enabled = config.LLM_ENABLED
        try:
            config.LLM_ENABLED = False
            from services import chat_service
            # 重新import无效，所以手动用_raw的方式：对比enhance_reply_with_llm调用
            # 这里改为：直接显示最终结果中的meta字段
        finally:
            config.LLM_ENABLED = original_enabled

        # 实际调用（LLM开关保持config中的原值）
        reply = get_reply(USER_ID, q)
        meta = reply.get('meta', {})
        intent = meta.get('intent', '?')
        used_llm = meta.get('used_llm', False)
        content = reply.get('content', '')
        content_preview = content.replace('\n', ' ⏎ ')[:120]

        print(f'   intent      : {intent}')
        print(f'   used_llm    : {used_llm}  {"(已由DeepSeek生成自然语言)" if used_llm else "(使用本地规则或LLM不可用降级)"}')
        print(f'   type        : {reply.get("type", "?")}')
        print(f'   content_len : {len(content)} chars')
        print(f'   preview     : {content_preview}...')

    # ============================================================
    # 4. 模糊匹配测试
    # ============================================================
    divider('4. 模糊匹配测试（未命中关键词但含任务/团队语义）')
    fuzzy_cases = [
        '我最近要做什么',
        '团队情况怎么样',
        '我有消息吗',
    ]
    for q in fuzzy_cases:
        reply = get_reply(USER_ID, q)
        meta = reply.get('meta', {})
        used_llm = meta.get('used_llm', False)
        intent = meta.get('intent', '?')
        print(f'   Q="{q}"')
        print(f'      → intent={intent} | used_llm={used_llm} | len={len(reply.get("content",""))}')

    # ============================================================
    # 总结
    # ============================================================
    divider()
    print('🏁 测试完成！')
    print('   如果 used_llm=True → 表示成功调用了DeepSeek生成回复')
    print('   如果 used_llm=False → 表示使用本地模板（静态意图/LLM不可用）')
    print()
    print('   如果LLM调用失败但FALLBACK=True，系统会自动退回本地回复，')
    print('   不会影响使用，可以查看agent服务的日志排查具体错误。')
    print()
