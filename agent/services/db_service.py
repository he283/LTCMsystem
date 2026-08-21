# -*- coding: utf-8 -*-
"""
数据库服务：封装与LTCM系统数据库的交互
"""
import pymysql
import threading
import re
import logging
from datetime import datetime, timedelta
from config import DB_CONFIG

logger = logging.getLogger(__name__)

_local = threading.local()


def _to_camel(name):
    """下划线转驼峰"""
    return re.sub(r'_([a-z])', lambda m: m.group(1).upper(), name)


def _convert_keys(row):
    """字典key转换为驼峰（单条）"""
    if not row:
        return row
    return {_to_camel(k): v for k, v in row.items()}


def _convert_list(rows):
    """列表key统一转驼峰"""
    if not rows:
        return rows
    return [_convert_keys(r) for r in rows]


def get_db():
    """获取数据库连接（线程安全）"""
    conn = getattr(_local, 'conn', None)
    if conn is None:
        conn = pymysql.connect(**DB_CONFIG)
        _local.conn = conn
    try:
        conn.ping(reconnect=True)
    except:
        conn = pymysql.connect(**DB_CONFIG)
        _local.conn = conn
    return conn


def close_db():
    conn = getattr(_local, 'conn', None)
    if conn is not None:
        conn.close()
        _local.conn = None


def query(sql, args=None, fetch_all=True):
    """通用查询方法（返回驼峰key）"""
    conn = get_db()
    with conn.cursor(pymysql.cursors.DictCursor) as cursor:
        cursor.execute(sql, args or ())
        if fetch_all:
            return _convert_list(cursor.fetchall())
        return _convert_keys(cursor.fetchone())


# ============== 用户相关查询 ==============

def get_user_by_id(user_id):
    """根据ID获取用户信息"""
    return query(
        "SELECT id, username, nickname, email, avatar FROM user WHERE id = %s AND deleted = 0",
        (user_id,), fetch_all=False
    )


def log_ai_chat(user_id, ip_address='', user_agent=''):
    """记录一次 AI 助手对话到操作日志表（operationType=AI_CHAT, module=agent）
    失败不影响主流程（静默降级）
    """
    try:
        user = get_user_by_id(user_id) or {}
        username = user.get('username') or ''
        nickname = user.get('nickname') or username or ''
        conn = get_db()
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO operation_log
                  (user_id, username, nickname, operation_type, operation_desc, module,
                   target_id, target_name, ip_address, user_agent, create_time, update_time, deleted)
                VALUES (%s, %s, %s, 'AI_CHAT', 'AI助手对话', 'agent', NULL, NULL, %s, %s, NOW(), NOW(), 0)
                """,
                (user_id, username, nickname, ip_address or '', user_agent or '')
            )
        conn.commit()
        return True
    except Exception as e:
        logger.warning(f'[DB] 记录AI对话日志失败(不影响对话): {e}')
        return False


# ============== 任务相关查询 ==============

def get_user_tasks(user_id, status=None, team_id=None, limit=None):
    """
    获取用户的任务
    - 作为创建者或负责人的任务
    """
    sql = """
    SELECT t.id, t.task_code, t.title, t.description, t.status, t.priority,
           t.due_date, t.creator_id, t.assignee_id, t.team_id, t.is_public, t.public_desc,
           t.create_time, t.update_time,
           tm.name AS team_name,
           creator.nickname AS creator_name, creator.username AS creator_username,
           assignee.nickname AS assignee_name, assignee.username AS assignee_username
    FROM task t
    LEFT JOIN team tm ON t.team_id = tm.id AND tm.deleted = 0
    LEFT JOIN user creator ON t.creator_id = creator.id AND creator.deleted = 0
    LEFT JOIN user assignee ON t.assignee_id = assignee.id AND assignee.deleted = 0
    WHERE t.deleted = 0
      AND (t.creator_id = %s OR t.assignee_id = %s)
    """
    args = [user_id, user_id]
    if status:
        sql += " AND t.status = %s"
        args.append(status)
    if team_id:
        sql += " AND t.team_id = %s"
        args.append(team_id)
    sql += " ORDER BY t.due_date IS NULL, t.due_date ASC, t.priority = 'HIGH' DESC, t.create_time DESC"
    if limit:
        sql += " LIMIT %s"
        args.append(limit)
    return query(sql, tuple(args))


def get_task_statistics(user_id):
    """
    获取用户任务统计数据
    """
    conn = get_db()
    with conn.cursor() as cursor:
        # 总数
        cursor.execute("""
            SELECT COUNT(*) FROM task 
            WHERE deleted = 0 AND (creator_id = %s OR assignee_id = %s)
        """, (user_id, user_id))
        total = cursor.fetchone()[0]

        # 按状态统计
        cursor.execute("""
            SELECT status, COUNT(*) 
            FROM task 
            WHERE deleted = 0 AND (creator_id = %s OR assignee_id = %s)
            GROUP BY status
        """, (user_id, user_id))
        by_status = dict(cursor.fetchall())

        # 按优先级统计
        cursor.execute("""
            SELECT priority, COUNT(*) 
            FROM task 
            WHERE deleted = 0 AND (creator_id = %s OR assignee_id = %s)
            GROUP BY priority
        """, (user_id, user_id))
        by_priority = dict(cursor.fetchall())

        # 即将到期（3天内）
        today_end = (datetime.now() + timedelta(days=3)).strftime('%Y-%m-%d 23:59:59')
        cursor.execute("""
            SELECT COUNT(*) FROM task
            WHERE deleted = 0 AND (creator_id = %s OR assignee_id = %s)
              AND status NOT IN ('DONE', 'CANCELLED')
              AND due_date IS NOT NULL AND due_date <= %s
        """, (user_id, user_id, today_end))
        due_soon = cursor.fetchone()[0]

        # 已逾期
        cursor.execute("""
            SELECT COUNT(*) FROM task
            WHERE deleted = 0 AND (creator_id = %s OR assignee_id = %s)
              AND status NOT IN ('DONE', 'CANCELLED')
              AND due_date IS NOT NULL AND due_date < NOW()
        """, (user_id, user_id))
        overdue = cursor.fetchone()[0]

    return {
        'total': total,
        'by_status': by_status,
        'by_priority': by_priority,
        'due_soon': due_soon,
        'overdue': overdue
    }


# ============== 团队相关查询 ==============

def get_user_teams(user_id):
    """获取用户所在的团队"""
    return query("""
        SELECT tm.id, tm.name, tm.team_code, tm.description, tm.creator_id,
               u.nickname AS creator_name,
               tm2.role AS my_role
        FROM team_member tm2
        INNER JOIN team tm ON tm2.team_id = tm.id AND tm.deleted = 0
        LEFT JOIN user u ON tm.creator_id = u.id AND u.deleted = 0
        WHERE tm2.user_id = %s AND tm2.deleted = 0
        ORDER BY tm.create_time DESC
    """, (user_id,))


def get_team_members(team_id):
    """获取团队成员"""
    return query("""
        SELECT u.id, u.username, u.nickname, u.avatar, tm.role, tm.join_time
        FROM team_member tm
        INNER JOIN user u ON tm.user_id = u.id AND u.deleted = 0
        WHERE tm.team_id = %s AND tm.deleted = 0
        ORDER BY tm.join_time ASC
    """, (team_id,))


# ============== 通知相关查询 ==============

def get_user_notifications(user_id, unread_only=True, limit=10):
    """获取用户通知"""
    sql = """
        SELECT n.id, n.user_id, n.type, n.title, n.content,
               n.related_type, n.related_id, n.is_read, n.read_time,
               n.create_time, n.update_time
        FROM notification n
        WHERE n.user_id = %s AND n.deleted = 0
    """
    args = [user_id]
    if unread_only:
        sql += " AND n.is_read = 0"
    sql += " ORDER BY n.create_time DESC LIMIT %s"
    args.append(limit)
    return query(sql, tuple(args))
