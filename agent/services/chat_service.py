# -*- coding: utf-8 -*-
"""
对话服务：处理用户输入，识别意图，生成回复
架构：本地关键词匹配 + 结构化数据查询 + LLM自然语言润色（混合模式）
"""
import re
import random
import logging

from services.task_analyzer import analyze_user_tasks, analyze_user_teams
from services.db_service import get_user_tasks, get_user_notifications, get_user_by_id
from services.llm_service import enhance_reply_with_llm

logger = logging.getLogger(__name__)

# ============== 需要LLM增强的意图（数据驱动型查询） ==============
# 这些意图有结构化上下文数据，调用LLM可以让回复更自然有洞察
DATA_DRIVEN_INTENTS = {
    'task_analysis': '任务分析报告',
    'today_tasks': '今日任务规划',
    'overdue_tasks': '逾期任务清单',
    'high_priority': '高优先级任务清单',
    'team_analysis': '团队信息概览',
    'notifications': '未读通知列表',
}

# ============== 意图关键词匹配 ==============

INTENT_PATTERNS = [
    # 任务分析/统计
    {
        'intent': 'task_analysis',
        'keywords': [
            '我的任务', '任务分析', '任务统计', '统计任务', '任务报告',
            '任务情况', '查看任务', '有哪些任务', '待办', '待办事项',
            '任务列表', '多少任务', '任务数'
        ]
    },
    # 今日任务
    {
        'intent': 'today_tasks',
        'keywords': [
            '今天做什么', '今天的任务', '今日任务', '今天干什么',
            '今天安排', '今日计划', '今天推荐', '今天要做'
        ]
    },
    # 逾期任务
    {
        'intent': 'overdue_tasks',
        'keywords': [
            '逾期', '过期', '超时', '没完成', '延期', '超过'
        ]
    },
    # 高优先级
    {
        'intent': 'high_priority',
        'keywords': [
            '高优先级', '紧急', '重要', '优先级高', '要紧'
        ]
    },
    # 团队分析
    {
        'intent': 'team_analysis',
        'keywords': [
            '我的团队', '团队', '所在团队', '加入的团队', '团队情况'
        ]
    },
    # 通知/消息
    {
        'intent': 'notifications',
        'keywords': [
            '通知', '消息', '未读', '提醒'
        ]
    },
    # 帮助
    {
        'intent': 'help',
        'keywords': [
            '帮助', '怎么用', '你能做什么', '功能', '使用说明', 'help'
        ]
    },
    # 问候
    {
        'intent': 'greeting',
        'keywords': [
            '你好', 'hi', 'hello', '在吗', '哈喽', '您好', '嗨'
        ]
    },
    # 感谢
    {
        'intent': 'thanks',
        'keywords': [
            '谢谢', '感谢', 'thanks', 'thx', '多谢'
        ]
    },
    # 身份
    {
        'intent': 'who_are_you',
        'keywords': [
            '你是谁', '自我介绍', '叫什么', '你是'
        ]
    },
]

# ============== 静态回复模板 ==============

STATIC_REPLIES = {
    'greeting': [
        '你好呀！我是 LTCM小助手 🤖，很高兴为你服务！\n\n你可以问我：\n• "我今天做什么" — 获取今日任务安排\n• "分析我的任务" — 任务整体分析\n• "有哪些通知" — 查看未读消息\n• "帮助" — 查看全部功能',
        '嗨～欢迎回来！✨ 我是你的任务管理助手，随时帮你梳理任务和进度～'
    ],
    'help': [
        """
🤖 **LTCM小助手功能说明**

📋 **任务相关**
• `我的任务` / `任务分析` — 全面分析你的任务进度、统计和建议
• `今天做什么` / `今日任务` — 获取今日推荐任务清单和优先级
• `逾期任务` — 查看所有已逾期的任务
• `高优先级` — 查看所有高优先级任务

👥 **团队相关**
• `我的团队` — 查看所在团队和未读通知

🔔 **消息相关**
• `通知` / `未读消息` — 查看最新的未读通知

💡 **其他**
• `帮助` — 查看本说明
• `你是谁` — 认识一下我

你也可以直接用自然语言问我，例如："我有多少个任务没做完？"
        """.strip()
    ],
    'thanks': [
        '不客气～😊 随时为你服务！',
        '小事一桩～有问题随时找我哦！',
        '不用谢！加油，任务完成就在眼前！💪'
    ],
    'who_are_you': [
        """
我是 **LTCM小助手** 🤖，你的专属任务管理AI助手！

我可以帮你：
📊 分析任务情况和统计数据
📅 规划每日任务优先级
⏰ 提醒逾期和即将到期的任务
👥 查看团队信息和通知

用自然语言和我聊天就可以啦～
        """.strip()
    ],
    'unknown': [
        '这个我暂时还不太理解呢 🤔\n试试问我："我今天做什么"、"分析我的任务"，或者输入"帮助"查看全部功能～',
        '嗯，这个问题我需要再学习学习！💡\n你可以试试问我任务相关的问题，比如"我有哪些任务"？',
        '抱歉，我没太明白你的意思 😅\n输入"帮助"可以查看我能做什么哦！'
    ]
}


# ============== 核心对话逻辑 ==============

def _try_langgraph(user_id, user_message, chat_id=None):
    """
    优先尝试LangGraph路径（配置允许时）
    返回: (成功与否, 回复dict_or_None)
    """
    from config import USE_LANGGRAPH
    if not USE_LANGGRAPH:
        return False, None
    try:
        from services.langchain_llm import invoke_agent_via_langgraph
        reply = invoke_agent_via_langgraph(user_id, user_message, chat_id=chat_id)
        return True, reply
    except Exception as e:
        logger.warning(f'[CHAT] LangGraph路径不可用，回退到纯函数路径: {type(e).__name__}: {e}')
        return False, None


def _try_langgraph_stream(user_id, user_message, chat_id=None):
    """优先尝试LangGraph流式路径。返回生成器或None"""
    from config import USE_LANGGRAPH
    if not USE_LANGGRAPH:
        return None
    try:
        from services.langchain_llm import invoke_agent_via_langgraph_stream
        return invoke_agent_via_langgraph_stream(user_id, user_message, chat_id=chat_id)
    except Exception as e:
        logger.warning(f'[CHAT] LangGraph流式路径不可用: {type(e).__name__}: {e}')
        return None


def _legacy_stream(user_id, user_message, chat_id=None):
    """纯函数路径的流式包装（先得到完整内容，再打字机输出）"""
    reply = get_reply(user_id, user_message, chat_id=chat_id, _skip_stream=True)
    content = reply.get('content') or ''
    meta = reply.get('meta') or {}
    meta['type'] = reply.get('type', 'markdown')
    meta['data'] = reply.get('data')

    import time as _time
    import random as _rand
    import json as _json

    idx = 0
    n = len(content)
    while idx < n:
        chunk_sz = _rand.randint(2, 6)
        chunk = content[idx:idx + chunk_sz]
        idx += chunk_sz
        yield chunk
        _time.sleep(0.01 + _rand.random() * 0.015)
    yield '\0__DONE__:' + _json.dumps(meta, ensure_ascii=False, default=str)


def get_reply_stream(user_id, user_message, chat_id=None):
    """
    统一流式入口：
      - 优先 LangGraph 流式（生成器）
      - 否则 legacy 流式
    返回 Generator[str]
    """
    user_message = (user_message or '').strip()
    # 先写用户历史（保证即使出错也有上下文轨迹）
    from config import CHAT_HISTORY_ENABLED
    if chat_id and CHAT_HISTORY_ENABLED:
        from services.chat_history import append_user_message
        append_user_message(chat_id, user_id, user_message)

    gen = _try_langgraph_stream(user_id, user_message, chat_id=chat_id)
    if gen is not None:
        # 流式结束时把 assistant content 追加到历史（从 DONE 行取）
        full = []
        meta_done = None
        for chunk in gen:
            if isinstance(chunk, str) and chunk.startswith('\0__DONE__:'):
                try:
                    import json as _json
                    meta_done = _json.loads(chunk[len('\0__DONE__:'):])
                except Exception:
                    meta_done = {}
                # 不直接吐这个原始标记，改吐一个更干净的标记（便于前端识别，但不污染content）
                yield chunk
            else:
                if isinstance(chunk, str):
                    full.append(chunk)
                yield chunk
        if chat_id and CHAT_HISTORY_ENABLED and meta_done is not None:
            from services.chat_history import append_assistant_message
            full_text = ''.join(full)
            append_assistant_message(
                chat_id, user_id, full_text,
                type=meta_done.get('type', 'markdown'),
                meta={k: v for k, v in meta_done.items() if k != 'data'}
            )
        return

    # 回退 legacy 流式
    for chunk in _legacy_stream(user_id, user_message, chat_id=chat_id):
        yield chunk


def get_reply(user_id, user_message, chat_id=None, _skip_stream=False):
    """
    处理用户消息，返回回复
    架构（自动选择）：
      - 优先级1：LangGraph状态机（USE_LANGGRAPH=True时，LangChain+LangGraph+deepseek-v4-flash）
      - 优先级2：纯函数（意图识别 → 本地数据查询 → requests版LLM润色 → 返回）
    :param chat_id: 可选会话ID，用于关联聊天历史（并把上下文带入LLM）
    :param _skip_stream: 内部用，避免流式函数内递归调用造成历史重复写入
    """
    from config import CHAT_HISTORY_ENABLED

    user_message = user_message.strip()
    if not user_message:
        return {
            'type': 'text',
            'content': '你想说什么呢？😊 试试问我"我今天做什么"吧！'
        }

    # 【优先级1】走LangGraph（如果可用）
    ok, lg_reply = _try_langgraph(user_id, user_message, chat_id=chat_id)
    if ok and lg_reply is not None:
        # 追加到聊天历史
        if chat_id and CHAT_HISTORY_ENABLED and not _skip_stream:
            from services.chat_history import append_user_message, append_assistant_message
            append_user_message(chat_id, user_id, user_message)
            append_assistant_message(chat_id, user_id, lg_reply.get('content', ''),
                                     type=lg_reply.get('type', 'text'),
                                     meta=lg_reply.get('meta', {}))
        return lg_reply

    # 【优先级2】回退到原纯函数逻辑
    # 1. 识别意图
    intent = _match_intent(user_message)
    logger.info(f'[CHAT][LEGACY] 用户ID={user_id} | 识别意图={intent} | 消息="{user_message[:50]}"')

    # 2. 根据意图生成本地回复（含结构化data）
    if intent == 'task_analysis':
        local_reply = _reply_task_analysis(user_id)
    elif intent == 'today_tasks':
        local_reply = _reply_today_tasks(user_id)
    elif intent == 'overdue_tasks':
        local_reply = _reply_overdue_tasks(user_id)
    elif intent == 'high_priority':
        local_reply = _reply_high_priority(user_id)
    elif intent == 'team_analysis':
        local_reply = _reply_team_analysis(user_id)
    elif intent == 'notifications':
        local_reply = _reply_notifications(user_id)
    elif intent in STATIC_REPLIES:
        local_reply = {
            'type': 'markdown',
            'content': random.choice(STATIC_REPLIES[intent])
        }
    else:
        # 模糊处理
        local_reply = _try_fuzzy_match(user_id, user_message)
        # 模糊处理也可能命中数据型意图，这里做个兼容：如果返回了data就增强
        if 'data' not in local_reply:
            if 'meta' not in local_reply:
                local_reply['meta'] = {'intent': intent, 'used_llm': False, 'used_langgraph': False}
            # 写历史（unknown 也要写）
            if chat_id and CHAT_HISTORY_ENABLED and not _skip_stream:
                from services.chat_history import append_user_message, append_assistant_message
                append_user_message(chat_id, user_id, user_message)
                append_assistant_message(chat_id, user_id, local_reply.get('content', ''),
                                         type=local_reply.get('type', 'text'),
                                         meta=local_reply.get('meta', {}))
            return local_reply  # 纯静态（unknown），直接返回，省Token

    # 3. 对于数据驱动的意图，尝试LLM增强（requests版enhance_reply_with_llm）
    used_llm = False
    if intent in DATA_DRIVEN_INTENTS and local_reply.get('data') is not None:
        user = get_user_by_id(user_id) or {}
        user_name = user.get('nickname') or user.get('username') or '用户'
        context_data = local_reply['data']
        context_label = DATA_DRIVEN_INTENTS.get(intent, '任务查询')

        enhanced_content, used_llm = enhance_reply_with_llm(
            user_id=user_id,
            user_name=user_name,
            user_query=user_message,
            context_data=context_data,
            context_label=context_label,
            local_reply_content=local_reply['content']
        )
        if enhanced_content:
            local_reply = dict(local_reply)
            local_reply['content'] = enhanced_content

    # 4. 打元数据标记
    local_reply.setdefault('meta', {})
    local_reply['meta'].update({
        'intent': intent,
        'used_llm': used_llm,
        'used_langgraph': False,
    })

    # 5. 追加到聊天历史
    if chat_id and CHAT_HISTORY_ENABLED and not _skip_stream:
        from services.chat_history import append_user_message, append_assistant_message
        append_user_message(chat_id, user_id, user_message)
        append_assistant_message(chat_id, user_id, local_reply.get('content', ''),
                                 type=local_reply.get('type', 'text'),
                                 meta=local_reply.get('meta', {}))

    return local_reply


def _match_intent(text):
    """基于关键词匹配用户意图"""
    text_lower = text.lower()
    for pattern in INTENT_PATTERNS:
        for kw in pattern['keywords']:
            if kw.lower() in text_lower:
                return pattern['intent']
    return 'unknown'


# ============== 各类意图的回复生成（本地规则 + 结构化数据） ==============

def _reply_task_analysis(user_id):
    """生成任务分析报告（含每个状态下的任务细节：标题+编号+完成时间）"""
    try:
        result = analyze_user_tasks(user_id)
        stats = result['statistics']
        by_status = result.get('tasks_by_status') or {}

        # 格式化状态统计 + 任务细节（标题+编号）
        status_display_order = ['PENDING_ASSIGN', 'IN_PROGRESS', 'PENDING_REVIEW', 'DONE', 'CANCELLED']
        status_map = {
            'PENDING_ASSIGN': ('待分配', 'ℹ️'),
            'IN_PROGRESS': ('进行中', '🔄'),
            'PENDING_REVIEW': ('待评审', '📝'),
            'DONE': ('已完成', '✅'),
            'CANCELLED': ('已取消', '❌'),
        }
        status_sections = []
        for s in status_display_order:
            count = stats.get('by_status', {}).get(s, 0)
            label, icon = status_map.get(s, (s, '•'))
            if count <= 0 and not by_status.get(s):
                status_sections.append(f"{icon} **{label}**：0 个")
                continue
            tasks = by_status.get(s) or []
            # 列出来：标题+编号
            detail_lines = []
            for idx, t in enumerate(tasks, 1):
                code = t.get('task_code') or ''
                code_str = f" `{code}`" if code else ''
                title = t.get('title') or '(无标题)'
                team = t.get('team_name') or '个人任务'
                extras = []
                if s == 'DONE':
                    dt = t.get('done_time')
                    if dt:
                        extras.append(f"完成于 {dt}")
                else:
                    # 未完成的：显示优先级/逾期/截止
                    if t.get('is_overdue'):
                        extras.append('🔴逾期')
                    if t.get('priority') == 'HIGH':
                        extras.append('🔥高优')
                    dd = t.get('due_date')
                    if dd and dd != '未设置':
                        extras.append(f"截止 {dd}")
                extra_str = ' | '.join(extras)
                line = f"  {idx}. 「{title}」{code_str}"
                if extra_str:
                    line += f"  （{extra_str}）"
                line += f"  [{team}]"
                detail_lines.append(line)
            detail_block = '\n'.join(detail_lines) if detail_lines else '  （暂无）'
            status_sections.append(f"{icon} **{label}**：{count} 个\n{detail_block}")
        status_text = '\n\n'.join(status_sections)

        # 建议
        sug_lines = []
        for s in result['suggestions']:
            sug_lines.append(f"{s['icon']} **{s['title']}**\n{s['content']}")
        sug_text = '\n\n'.join(sug_lines)

        content = f"""
📊 **{result['user_name']} 的任务分析报告**

---
### 📋 任务概览
• 任务总数：{stats['total']} 个
• 待办任务：{result['todo_count']} 个
• 近7天完成：{result['done_recent_count']} 个
• 🔴 已逾期：{stats['overdue']} 个
• 🟠 3天内到期：{stats['due_soon']} 个

---
### 📋 任务详情（按状态）
{status_text}

---
### 💡 给你的建议
{sug_text}

> 需要我帮你深入看看某个具体任务吗？
        """.strip()

        return {
            'type': 'markdown',
            'content': content,
            'data': result
        }
    except Exception as e:
        logger.exception('[LOCAL] 任务分析出错')
        return {
            'type': 'text',
            'content': f'分析任务时出了点问题 😢：{str(e)}'
        }


def _reply_today_tasks(user_id):
    """生成今日任务推荐（含任务编号）"""
    try:
        result = analyze_user_tasks(user_id)
        plan = result['today_plan']
        priority_list = plan['priority_list']

        if not priority_list:
            content = f"""{plan['greeting']}

📭 太棒啦！今天没有待办任务，好好休息一下吧～
或者输入"我的团队"看看团队有没有新消息。
            """
        else:
            items = []
            for item in priority_list:
                t = item['task']
                rank_icon = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'][item['rank'] - 1]
                badges = []
                if t['is_overdue']:
                    badges.append('🔴逾期')
                if t['priority'] == 'HIGH':
                    badges.append('🔥高优')
                badge_text = ' '.join(badges)
                code = t.get('task_code') or ''
                code_str = f" `{code}`" if code else ''

                items.append(f"{rank_icon} 「{t['title']}」{code_str}"
                             f"\n　├ 状态：{t['status_text']} | 优先级：{t['priority_text']}"
                             f"\n　├ 截止：{t['due_date']} {badge_text}"
                             f"\n　└ 团队：{t['team_name']}")

            tasks_text = '\n\n'.join(items)
            tips = '\n'.join([f'• {tip}' for tip in plan['tips']])

            content = f"""{plan['greeting']}

📅 **今日推荐任务清单（优先处理前5个）**
---
{tasks_text}

---
💡 **今日小贴士**
{tips}
            """

        return {
            'type': 'markdown',
            'content': content,
            'data': result
        }
    except Exception as e:
        logger.exception('[LOCAL] 今日任务出错')
        return {
            'type': 'text',
            'content': f'生成今日计划时出错 😢：{str(e)}'
        }


def _reply_overdue_tasks(user_id):
    """返回逾期任务列表（含编号）"""
    try:
        result = analyze_user_tasks(user_id)
        tasks = result['overdue_tasks']

        if not tasks:
            content = '🎉 太棒啦！你目前没有逾期任务，继续保持哦～'
        else:
            items = []
            for idx, t in enumerate(tasks, 1):
                days_ago = abs(t['days_left']) if t['days_left'] is not None else '?'
                code = t.get('task_code') or ''
                code_str = f" `{code}`" if code else ''
                items.append(
                    f"{idx}. 「{t['title']}」{code_str}\n"
                    f"　逾期 {days_ago} 天 | 优先级：{t['priority_text']} | {t['team_name']}\n"
                    f"　原截止日期：{t['due_date']}"
                )
            text = '\n\n'.join(items)
            content = f"""
🔴 **逾期任务提醒（共 {len(tasks)} 个）**
---
{text}

⚠️ 建议优先处理上述逾期任务，减少工作积压！
            """.strip()

        return {
            'type': 'markdown',
            'content': content,
            'data': result
        }
    except Exception as e:
        logger.exception('[LOCAL] 逾期任务出错')
        return {
            'type': 'text',
            'content': f'查询逾期任务出错 😢：{str(e)}'
        }


def _reply_high_priority(user_id):
    """返回高优先级任务列表（含编号）"""
    try:
        result = analyze_user_tasks(user_id)
        tasks = result['high_priority_tasks']

        if not tasks:
            content = '😌 目前没有高优先级任务，可以轻松一些了～'
        else:
            items = []
            for idx, t in enumerate(tasks, 1):
                status_badge = '🔴逾期' if t['is_overdue'] else t['status_text']
                code = t.get('task_code') or ''
                code_str = f" `{code}`" if code else ''
                items.append(
                    f"{idx}. 「{t['title']}」{code_str}\n"
                    f"　状态：{status_badge} | 截止：{t['due_date']} | {t['team_name']}"
                )
            text = '\n\n'.join(items)
            content = f"""
🔥 **高优先级任务（共 {len(tasks)} 个）**
---
{text}

💡 高优先级任务建议安排精力最充沛的时间段处理！
            """.strip()

        return {
            'type': 'markdown',
            'content': content,
            'data': result
        }
    except Exception as e:
        logger.exception('[LOCAL] 高优任务出错')
        return {
            'type': 'text',
            'content': f'查询高优任务出错 😢：{str(e)}'
        }


def _reply_team_analysis(user_id):
    """团队分析"""
    try:
        result = analyze_user_teams(user_id)
        teams = result['teams']
        notifications = result['unread_notifications']

        if teams:
            team_lines = []
            for tm in teams:
                info = f"• **{tm['name']}** `{tm['team_code'] or ''}`\n"
                info += f"　身份：{tm['my_role']} | 创建者：{tm['creator_name'] or '-'}"
                team_lines.append(info)
            teams_text = '\n\n'.join(team_lines)
        else:
            teams_text = '• 暂无加入任何团队'

        notif_lines = []
        if notifications:
            for n in notifications[:5]:
                notif_lines.append(f"• 🔔 {n.get('title', '')}：{n.get('content', '')[:50]}")
            notif_text = '\n'.join(notif_lines)
        else:
            notif_text = '• 暂无未读通知 🎉'

        content = f"""
👥 **我的团队概览（共 {result['team_count']} 个）**
---
{teams_text}

---
🔔 **最新未读通知**
{notif_text}
        """.strip()

        return {
            'type': 'markdown',
            'content': content,
            'data': result
        }
    except Exception as e:
        logger.exception('[LOCAL] 团队信息出错')
        return {
            'type': 'text',
            'content': f'查询团队信息出错 😢：{str(e)}'
        }


def _reply_notifications(user_id):
    """通知查询"""
    try:
        notifications = get_user_notifications(user_id, unread_only=True, limit=10)
        if notifications:
            lines = []
            for idx, n in enumerate(notifications, 1):
                title = n.get('title', '')
                content = n.get('content', '')[:80]
                time_str = n.get('create_time', '')
                lines.append(f"{idx}. **{title}**\n　{content}\n　{time_str}")
            text = '\n\n'.join(lines)
            content = f"""
🔔 **未读通知（共 {len(notifications)} 条）**
---
{text}
            """.strip()
        else:
            content = '🎉 太棒啦！目前没有未读通知，一切尽在掌握！'

        return {
            'type': 'markdown',
            'content': content,
            'data': {
                'notification_count': len(notifications),
                'notifications': notifications
            }
        }
    except Exception as e:
        logger.exception('[LOCAL] 通知查询出错')
        return {
            'type': 'text',
            'content': f'查询通知出错 😢：{str(e)}'
        }


def _try_fuzzy_match(user_id, text):
    """模糊匹配未命中的情况"""
    # 简单规则：包含"任务"就给个任务分析
    if '任务' in text or '做' in text or '事' in text:
        return _reply_today_tasks(user_id)
    # 包含"团队"或者"通知"相关关键词
    if '团队' in text:
        return _reply_team_analysis(user_id)
    if '消息' in text:
        return _reply_notifications(user_id)

    # 否则返回默认未知回复
    return {
        'type': 'markdown',
        'content': random.choice(STATIC_REPLIES['unknown'])
    }
