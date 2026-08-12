# -*- coding: utf-8 -*-
"""
任务分析服务：分析用户任务，生成建议和报告
"""
from datetime import datetime, timedelta
from services.db_service import (
    get_user_tasks, get_task_statistics, get_user_teams, get_user_notifications, get_user_by_id
)

# 状态映射
STATUS_MAP = {
    'PENDING_ASSIGN': ('待分配', 'info'),
    'IN_PROGRESS': ('进行中', 'warning'),
    'PENDING_REVIEW': ('待评审', 'primary'),
    'DONE': ('已完成', 'success'),
    'CANCELLED': ('已取消', 'danger')
}

PRIORITY_MAP = {
    'LOW': ('低', 'info'),
    'MEDIUM': ('中', 'warning'),
    'HIGH': ('高', 'danger')
}


def _status_text(s):
    return STATUS_MAP.get(s, (s, 'info'))[0]


def _priority_text(p):
    return PRIORITY_MAP.get(p, (p, 'info'))[0]


def analyze_user_tasks(user_id):
    """
    全面分析用户的任务情况
    返回：统计数据、待办列表、建议列表、已完成任务清单（带标题/编号/完成时间）
    """
    user = get_user_by_id(user_id)
    stats = get_task_statistics(user_id)
    all_tasks = get_user_tasks(user_id)

    # 未完成任务
    active_tasks = [t for t in all_tasks if t.get('status') not in ('DONE', 'CANCELLED')]
    active_tasks.sort(key=lambda t: (
        t.get('dueDate') is None or t.get('dueDate', datetime.max) <= datetime.now(),
        t.get('dueDate') if t.get('dueDate') else datetime.max,
        0 if t.get('priority') == 'HIGH' else 1
    ))

    # 已完成任务（取最近所有已完成的，按完成时间倒序，最多列出20个供LLM选）
    all_done = [t for t in all_tasks if t.get('status') == 'DONE']
    # 尝试用 update_time 近似完成时间（任务状态改为 DONE 时一般会更新 update_time）
    # 如果有明确的完成时间字段（如 finish_time/complete_time）也兼容
    def _done_time(t):
        for f in ('finishTime', 'completeTime', 'updateTime', 'createTime'):
            v = t.get(f)
            if isinstance(v, datetime):
                return v
        return datetime.min
    all_done.sort(key=_done_time, reverse=True)
    # 区分"近7天已完成"和"全部已完成"
    seven_days_ago = datetime.now() - timedelta(days=7)
    done_recent = [t for t in all_done if _done_time(t) >= seven_days_ago]

    # 逾期任务
    now = datetime.now()
    overdue = [t for t in active_tasks
               if t.get('dueDate') and t['dueDate'] < now]

    # 高优先级任务
    high_priority = [t for t in active_tasks if t.get('priority') == 'HIGH']

    # 生成建议
    suggestions = _generate_suggestions(user, stats, active_tasks, overdue, high_priority)

    # 生成今天应该做什么
    today_tasks = _plan_today_tasks(user, active_tasks, high_priority, overdue)

    # 任务状态详情：按状态分组列出每个状态下的任务标题/编号
    by_status_details = {}
    for t in all_tasks:
        s = t.get('status') or 'UNKNOWN'
        by_status_details.setdefault(s, []).append(_format_task(t, done_time=_done_time(t)))
    for s, arr in by_status_details.items():
        arr.sort(key=lambda x: (x.get('is_overdue') is False, x.get('priority') != 'HIGH'))

    return {
        'user_name': (user.get('nickname') or user.get('username')) if user else '用户',
        'statistics': stats,
        'todo_count': len(active_tasks),
        'done_recent_count': len(done_recent),
        'overdue_tasks': [_format_task(t) for t in overdue],
        'high_priority_tasks': [_format_task(t) for t in high_priority],
        'suggestions': suggestions,
        'today_plan': today_tasks,
        'active_tasks_top': [_format_task(t) for t in active_tasks[:5]],
        # ↓↓↓ 新增：明确列出每个状态下的任务详情，尤其是 DONE，让LLM能说出具体是哪4个
        'tasks_by_status': by_status_details,          # 键=PENDING_ASSIGN/IN_PROGRESS/... 值=[{title, task_code, status_text,...}]
        'done_tasks': [_format_task(t, done_time=_done_time(t)) for t in all_done],           # 所有已完成（按完成时间倒序）
        'done_tasks_recent': [_format_task(t, done_time=_done_time(t)) for t in done_recent], # 近7天已完成
        'cancelled_tasks': [_format_task(t, done_time=_done_time(t)) for t in all_tasks if t.get('status') == 'CANCELLED'],
    }


def _format_task(t, done_time=None):
    """格式化任务用于展示"""
    due = t['dueDate'].strftime('%Y-%m-%d') if t.get('dueDate') else '未设置'
    is_overdue = False
    days_left = None
    if t.get('dueDate') and t.get('status') not in ('DONE', 'CANCELLED'):
        delta = t['dueDate'] - datetime.now()
        days_left = delta.days
        is_overdue = days_left < 0

    out = {
        'id': t.get('id'),
        'task_code': t.get('taskCode', ''),
        'title': t.get('title', ''),
        'status': t.get('status', ''),
        'status_text': _status_text(t.get('status')),
        'priority': t.get('priority', ''),
        'priority_text': _priority_text(t.get('priority')),
        'due_date': due,
        'is_overdue': is_overdue,
        'days_left': days_left,
        'team_name': t.get('teamName', '个人任务'),
        'assignee_name': t.get('assigneeName', '未分配'),
    }
    if isinstance(done_time, datetime):
        out['done_time'] = done_time.strftime('%Y-%m-%d %H:%M')
    return out


def _generate_suggestions(user, stats, active_tasks, overdue, high_priority):
    """生成个性化建议"""
    suggestions = []
    name = (user.get('nickname') or user.get('username')) if user else '你'

    # 1. 逾期提醒
    if overdue:
        suggestions.append({
            'type': 'danger',
            'icon': '⚠️',
            'title': f'{name}，你有 {len(overdue)} 个任务已经逾期！',
            'content': f'建议优先处理逾期任务，特别是 {len([t for t in overdue if t.get("priority") == "HIGH"])} 个高优先级的。'
        })

    # 2. 高优先级提醒
    if high_priority and len(high_priority) > len(active_tasks) * 0.6 and len(active_tasks) > 3:
        suggestions.append({
            'type': 'warning',
            'icon': '🔥',
            'title': '高优先级任务较多',
            'content': f'{len(high_priority)}/{len(active_tasks)} 个任务是高优先级，建议合理分配精力，避免同时处理过多紧急任务。'
        })

    # 3. 任务完成表扬
    done = stats.get('by_status', {}).get('DONE', 0)
    if done >= 3:
        suggestions.append({
            'type': 'success',
            'icon': '🎉',
            'title': '近期表现不错！',
            'content': f'你已经完成了 {done} 个任务，继续保持！'
        })

    # 4. 工作量评估
    if len(active_tasks) == 0:
        suggestions.append({
            'type': 'info',
            'icon': '😌',
            'title': '当前暂无待办任务',
            'content': '可以考虑接手一些新任务，或者整理一下已完成的工作。'
        })
    elif len(active_tasks) > 8:
        suggestions.append({
            'type': 'warning',
            'icon': '💪',
            'title': '待办任务偏多',
            'content': f'当前有 {len(active_tasks)} 个待办任务，建议先聚焦在高优先级和逾期任务上。'
        })

    # 5. 截止日期提醒
    due_soon = stats.get('due_soon', 0)
    if due_soon > 0 and not overdue:
        suggestions.append({
            'type': 'warning',
            'icon': '⏰',
            'title': '即将到期提醒',
            'content': f'有 {due_soon} 个任务将在3天内到期，请留意进度。'
        })

    # 6. 默认建议
    if not suggestions:
        suggestions.append({
            'type': 'info',
            'icon': '📋',
            'title': '任务情况良好',
            'content': '目前任务进度正常，继续保持！可以考虑合理规划后续工作。'
        })

    return suggestions


def _plan_today_tasks(user, active_tasks, high_priority, overdue):
    """规划今天应该做的任务"""
    name = (user.get('nickname') or user.get('username')) if user else '你'
    plan = {
        'greeting': _get_greeting(name),
        'priority_list': [],
        'tips': []
    }

    # 今日推荐顺序：逾期 > 高优先级 > 进行中 > 其他
    today_list = []
    seen_ids = set()

    # 先加逾期
    for t in overdue:
        if t.get('id') not in seen_ids:
            today_list.append(t)
            seen_ids.add(t['id'])

    # 再加高优先级
    for t in high_priority:
        if t.get('id') not in seen_ids:
            today_list.append(t)
            seen_ids.add(t['id'])

    # 再加进行中的
    for t in active_tasks:
        if t.get('status') == 'IN_PROGRESS' and t.get('id') not in seen_ids:
            today_list.append(t)
            seen_ids.add(t['id'])

    # 补充其他
    for t in active_tasks:
        if t.get('id') not in seen_ids:
            today_list.append(t)
            seen_ids.add(t['id'])

    # 取前5个作为今日推荐
    top5 = today_list[:5]
    for idx, t in enumerate(top5, 1):
        plan['priority_list'].append({
            'rank': idx,
            'task': _format_task(t)
        })

    # 今日小贴士
    if overdue:
        plan['tips'].append('优先处理逾期任务，减少积压')
    if high_priority:
        plan['tips'].append('高优先级任务需要更专注的时间')
    if len(active_tasks) > 5:
        plan['tips'].append('今日推荐先处理前5个，其他任务可安排到后续日期')
    if not plan['tips']:
        plan['tips'].append('保持专注，逐个完成任务！')

    return plan


def _get_greeting(name):
    """根据时间生成问候语"""
    hour = datetime.now().hour
    if hour < 6:
        return f'{name}，夜深了，注意休息哦 🌙'
    elif hour < 12:
        return f'早上好，{name}！☀️ 今天也要加油'
    elif hour < 14:
        return f'中午好，{name}！🍱 记得吃午饭'
    elif hour < 18:
        return f'下午好，{name}！☕ 下午茶时间'
    elif hour < 22:
        return f'晚上好，{name}！🌆 辛苦一天了'
    else:
        return f'{name}，早点休息，明天继续加油 🌙'


# ============== 团队分析 ==============

def analyze_user_teams(user_id):
    """分析用户的团队情况"""
    teams = get_user_teams(user_id)
    notifications = get_user_notifications(user_id, unread_only=True, limit=5)

    role_map = {
        'OWNER': '所有者',
        'ADMIN': '管理员',
        'MEMBER': '成员',
        'GUEST': '访客'
    }

    team_list = []
    for tm in teams:
        team_list.append({
            'id': tm.get('id'),
            'name': tm.get('name', ''),
            'team_code': tm.get('teamCode', ''),
            'my_role': role_map.get(tm.get('myRole'), '成员'),
            'creator_name': tm.get('creatorName', '')
        })

    return {
        'team_count': len(team_list),
        'teams': team_list,
        'unread_notifications': notifications
    }
