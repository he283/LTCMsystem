# -*- coding: utf-8 -*-
"""
聊天历史记录服务
====================================
- 轻量级内存缓存（LRU + TTL），无需额外 DB
- 按 (chat_id, user_id) 维度隔离
- 提供：追加消息、取最近N条、清空、获取所有历史
- 与前端 localStorage 可以双写：服务端作为刷新页面后拉取历史的来源
"""
import time
import threading
import logging
from collections import OrderedDict

from config import (
    CHAT_HISTORY_ENABLED,
    CHAT_HISTORY_MAX_MSGS,
    CHAT_HISTORY_TTL_SECS,
)

logger = logging.getLogger(__name__)


class _ChatHistoryStore:
    """线程安全的 TTL + LRU 缓存（key -> (last_access_ts, deque[messages])）"""

    def __init__(self, max_per_chat=100, ttl_secs=4 * 3600, capacity_chats=500):
        self.max_per_chat = max(1, int(max_per_chat))
        self.ttl_secs = max(60, int(ttl_secs))
        self.capacity_chats = max(10, int(capacity_chats))
        self._lock = threading.RLock()
        # OrderedDict：key = (chat_id, user_id)，value = (last_ts, messages_deque)
        self._cache = OrderedDict()
        # 启动惰性清理：每次写入时清理少量过期项 + 超出容量时弹掉LRU

    def _key(self, chat_id, user_id):
        return (str(chat_id).strip() or 'default', int(user_id))

    def _expired(self, last_ts):
        return (time.time() - last_ts) > self.ttl_secs

    def _cleanup_some(self, limit=5):
        """清理少量过期项（避免一次性全量扫描）"""
        removed = 0
        for k in list(self._cache.keys()):
            if removed >= limit:
                break
            ts, _ = self._cache[k]
            if self._expired(ts):
                del self._cache[k]
                removed += 1
        # 超过总 chat 数量，按 LRU 弹最旧的
        while len(self._cache) > self.capacity_chats:
            oldest_k, _ = self._cache.popitem(last=False)
            logger.info(f'[HISTORY] LRU 淘汰缓存: chat={oldest_k}')

    def append(self, chat_id, user_id, role, content, **extra):
        """追加一条消息到历史
        role: 'user' | 'assistant' | 'system'
        extra: type, meta, timestamp 等可自由放入
        """
        if not CHAT_HISTORY_ENABLED:
            return
        try:
            with self._lock:
                self._cleanup_some()
                k = self._key(chat_id, user_id)
                now = time.time()
                if k in self._cache:
                    self._cache.move_to_end(k)
                    _, msgs = self._cache[k]
                else:
                    msgs = []
                msg = {
                    'role': role,
                    'content': content,
                    'timestamp_ms': int(now * 1000),
                }
                msg.update(extra or {})
                msgs.append(msg)
                # 限制单会话最大消息数
                if len(msgs) > self.max_per_chat:
                    del msgs[:len(msgs) - self.max_per_chat]
                self._cache[k] = (now, msgs)
        except Exception:
            logger.exception('[HISTORY] append 失败')

    def get_recent(self, chat_id, user_id, limit=None, only_role_in=None):
        """取最近 limit 条（含用户和助手），按时间升序"""
        if not CHAT_HISTORY_ENABLED:
            return []
        msgs_ref = None
        try:
            with self._lock:
                k = self._key(chat_id, user_id)
                item = self._cache.get(k)
                if not item:
                    return []
                last_ts, msgs = item
                if self._expired(last_ts):
                    # 已过期，清掉
                    self._cache.pop(k, None)
                    return []
                # 移到末尾（LRU 续命）
                self._cache.move_to_end(k)
                self._cache[k] = (time.time(), msgs)
                msgs_ref = list(msgs)  # 在锁内 copy 出来，避免后续修改冲突
        except Exception:
            logger.exception('[HISTORY] get_recent 出错')
            return []

        msgs = msgs_ref or []
        if only_role_in:
            msgs = [m for m in msgs if m.get('role') in only_role_in]
        if limit:
            msgs = msgs[-int(limit):]
        return msgs

    def get_all(self, chat_id, user_id):
        return self.get_recent(chat_id, user_id, limit=None)

    def clear(self, chat_id, user_id):
        """清空某个会话的历史"""
        try:
            with self._lock:
                k = self._key(chat_id, user_id)
                removed = self._cache.pop(k, None) is not None
                return removed
        except Exception:
            logger.exception('[HISTORY] clear 失败')
            return False

    def get_stats(self):
        with self._lock:
            return {
                'enabled': CHAT_HISTORY_ENABLED,
                'total_sessions': len(self._cache),
                'max_per_chat': self.max_per_chat,
                'ttl_secs': self.ttl_secs,
                'capacity_chats': self.capacity_chats,
            }


# 全局单例
_store = _ChatHistoryStore(
    max_per_chat=CHAT_HISTORY_MAX_MSGS,
    ttl_secs=CHAT_HISTORY_TTL_SECS,
)


def append_user_message(chat_id, user_id, content, **extra):
    _store.append(chat_id, user_id, 'user', content, **extra)


def append_assistant_message(chat_id, user_id, content, **extra):
    _store.append(chat_id, user_id, 'assistant', content, **extra)


def get_llm_context_messages(chat_id, user_id, context_window_size):
    """返回适合 LLM 对话上下文的最近消息（去掉系统/调试字段，只保留 role/content）
    context_window_size: 保留多少轮（每轮=1 user + 1 assistant，共2条）。0 表示不保留
    返回 list[{role, content}]，按时间升序，可直接拼到 llm_polish 的 messages 里
    """
    if not context_window_size or context_window_size <= 0:
        return []
    limit_messages = context_window_size * 2  # 每轮两条
    recent = _store.get_recent(chat_id, user_id, limit=limit_messages,
                               only_role_in=('user', 'assistant'))
    return [
        {'role': m.get('role', 'user'), 'content': str(m.get('content', ''))}
        for m in recent
        if str(m.get('content', '')).strip()
    ]


def get_all_messages(chat_id, user_id):
    return _store.get_all(chat_id, user_id)


def clear_history(chat_id, user_id):
    return _store.clear(chat_id, user_id)


def stats():
    return _store.get_stats()
