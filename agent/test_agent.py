# -*- coding: utf-8 -*-
"""
快速测试脚本：验证数据库连接和核心功能
"""
import sys
sys.path.insert(0, '.')

from services.db_service import get_user_tasks, get_task_statistics, get_user_teams
from services.task_analyzer import analyze_user_tasks

print("=" * 60)
print("1. 测试数据库连接")
print("=" * 60)
try:
    stats = get_task_statistics(1)  # 测试用户ID=1
    print(f"✅ 数据库连接成功")
    print(f"   用户ID=1 的任务统计：{stats}")
except Exception as e:
    print(f"❌ 数据库连接失败：{e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print()
print("=" * 60)
print("2. 测试任务分析")
print("=" * 60)
try:
    result = analyze_user_tasks(1)
    print(f"✅ 任务分析成功")
    print(f"   用户：{result['user_name']}")
    print(f"   待办任务数：{result['todo_count']}")
    print(f"   今日推荐任务：{len(result['today_plan']['priority_list'])} 个")
    print(f"   建议数：{len(result['suggestions'])} 条")
except Exception as e:
    print(f"❌ 任务分析失败：{e}")
    import traceback
    traceback.print_exc()

print()
print("=" * 60)
print("3. 测试chat_service对话功能")
print("=" * 60)
try:
    from services.chat_service import get_reply

    test_msgs = [
        "你好",
        "我今天做什么",
        "我的任务",
        "逾期任务",
        "帮助"
    ]
    for msg in test_msgs:
        reply = get_reply(1, msg)
        content_preview = reply['content'][:80].replace('\n', ' ')
        print(f"   Q: {msg:20s} -> A: {content_preview}...")
    print(f"✅ 对话功能测试通过")
except Exception as e:
    print(f"❌ 对话功能测试失败：{e}")
    import traceback
    traceback.print_exc()

print()
print("🎉 所有测试完成！")
