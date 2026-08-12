<template>
  <div class="agent-chat-container">
    <!-- 聊天头部 -->
    <div class="chat-header">
      <div class="header-left">
        <div class="agent-avatar">
          <el-icon :size="24"><ChatDotRound /></el-icon>
        </div>
        <div class="header-info">
          <div class="agent-name">LTCM小助手</div>
          <div class="agent-status" :class="{ online: agentOnline }">
            <span class="status-dot"></span>
            {{ agentOnline ? '在线' : '离线' }}
            <span v-if="cfgProviderLabel" class="config-src-tip" @click="showConfigDebug = !showConfigDebug">
              · {{ cfgProviderLabel }}
              <el-tooltip v-if="cfgKey.value" :content="tooltipText" placement="bottom">
                <el-icon class="debug-icon"><Warning /></el-icon>
              </el-tooltip>
            </span>
          </div>
        </div>
      </div>
      <div class="header-actions">
        <el-button type="primary" link size="small" @click="showQuickCommands = !showQuickCommands">
          <el-icon><MagicStick /></el-icon> 快捷指令
        </el-button>
        <el-button type="danger" link size="small" @click="clearChat" :disabled="sending">
          <el-icon><Delete /></el-icon> 清空
        </el-button>
      </div>
    </div>

    <!-- 配置信息面板（极简版：只显示 4 行脱敏值 — API Key / Model / Base URL / LLM 连通性） -->
    <div v-if="showConfigDebug && healthInfo" class="config-debug-panel">
      <div class="config-title">🔧 配置信息</div>
      <el-descriptions :column="1" size="small" border>
        <el-descriptions-item label="API Key（脱敏）">
          <code>{{ cfgKey }}</code>
        </el-descriptions-item>
        <el-descriptions-item label="Model">
          {{ cfgModel }}
        </el-descriptions-item>
        <el-descriptions-item label="Base URL">
          {{ cfgBase }}
        </el-descriptions-item>
        <el-descriptions-item label="LLM 连通性">
          <el-tag :type="connTagType" size="small">{{ connLabel }}</el-tag>
          <span v-if="connMsg" class="src-muted" style="margin-left:8px">{{ connMsg }}</span>
        </el-descriptions-item>
      </el-descriptions>
    </div>

    <!-- 快捷指令面板 -->
    <div class="quick-commands" v-if="showQuickCommands">
      <div class="quick-title">🚀 试试这些：</div>
      <div class="quick-btns">
        <el-button size="small" @click="sendQuick('我今天做什么')">📅 今日任务</el-button>
        <el-button size="small" @click="sendQuick('我的任务')">📊 任务分析</el-button>
        <el-button size="small" @click="sendQuick('逾期任务')">🔴 逾期任务</el-button>
        <el-button size="small" @click="sendQuick('高优先级')">🔥 高优任务</el-button>
        <el-button size="small" @click="sendQuick('我的团队')">👥 团队信息</el-button>
        <el-button size="small" @click="sendQuick('通知')">🔔 未读通知</el-button>
        <el-button size="small" @click="sendQuick('帮助')">💡 帮助说明</el-button>
      </div>
    </div>

    <!-- 聊天消息列表 -->
    <div class="chat-messages" ref="messagesRef" v-loading="loadingHistory">
      <el-empty v-if="messages.length === 0" description="开始和LTCM小助手聊天吧~" :image-size="80" />

      <div
        v-for="(msg, index) in messages"
        :key="index"
        class="message-item"
        :class="msg.role === 'user' ? 'user-msg' : 'agent-msg'"
      >
        <!-- 用户消息 -->
        <template v-if="msg.role === 'user'">
          <div class="msg-bubble user-bubble">
            <div class="msg-content">{{ msg.content }}</div>
            <div class="msg-time">{{ formatTime(msg.timestamp) }}</div>
          </div>
          <el-avatar class="msg-avatar" :size="36">
            {{ userInitial }}
          </el-avatar>
        </template>

        <!-- Agent消息 -->
        <template v-else>
          <div class="msg-avatar agent-avatar-inline">
            <el-icon :size="20"><ChatDotRound /></el-icon>
          </div>
          <div class="msg-bubble agent-bubble" :class="{ loading: msg.loading }">
            <template v-if="msg.loading">
              <div class="typing-indicator">
                <span></span><span></span><span></span>
              </div>
            </template>
            <template v-else>
              <div class="msg-content markdown-body" v-if="msg.type === 'markdown'">
                <div v-html="renderMarkdown(msg.content)"></div>
              </div>
              <div class="msg-content" v-else>{{ msg.content }}</div>
              <div class="msg-footer">
                <span class="msg-time">{{ formatTime(msg.timestamp) }}</span>
                <span v-if="msg.meta?.used_llm" class="meta-tag llm-tag" title="已调用大模型润色">✨ LLM</span>
                <span v-if="msg.meta?.used_langgraph" class="meta-tag lg-tag" title="使用LangGraph工作流">🧩 LangGraph</span>
                <span v-if="msg.meta?.intent" class="meta-tag intent-tag">🎯 {{ intentLabel(msg.meta.intent) }}</span>
                <span v-if="msg.meta?.llm_latency_ms" class="meta-tag latency-tag">⏱ {{ Math.round(msg.meta.llm_latency_ms) }}ms</span>
              </div>
            </template>
          </div>
        </template>
      </div>

      <!-- 自动滚动锚点 -->
      <div ref="scrollAnchor"></div>
    </div>

    <!-- 输入区域 -->
    <div class="chat-input-area">
      <el-input
        v-model="inputMessage"
        type="textarea"
        :rows="2"
        placeholder="输入你的问题，如：我今天做什么？（Enter发送，Shift+Enter换行）"
        maxlength="500"
        show-word-limit
        resize="none"
        @keydown.enter.exact.prevent="handleSend"
        :disabled="sending"
      />
      <div class="input-actions">
        <span v-if="sending" class="streaming-tip">🔄 生成中（流式输出）...</span>
        <el-button
          type="primary"
          :loading="sending"
          @click="handleSend"
          :disabled="!inputMessage.trim()"
        >
          <el-icon><Promotion /></el-icon> 发送
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ChatDotRound, MagicStick, Delete, Promotion, Warning
} from '@element-plus/icons-vue'
import { agentChat, agentHealth, getAgentHistory, deleteAgentHistory } from '@/api'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// ===== 状态 =====
const messages = ref([])
const inputMessage = ref('')
const sending = ref(false)
const loadingHistory = ref(false)
const agentOnline = ref(false)
const healthInfo = ref(null)
const showQuickCommands = ref(true)
const showConfigDebug = ref(false)
const messagesRef = ref(null)
const scrollAnchor = ref(null)

// 会话ID：localStorage 持久化（每次用户独立一个 chat_id，后续可扩展新建会话列表）
const chatId = ref('')
const ensureChatId = () => {
  let cid = localStorage.getItem('agent_chat_id')
  if (!cid) {
    cid = 'chat_' + Date.now() + '_' + Math.random().toString(36).slice(2, 11)
    localStorage.setItem('agent_chat_id', cid)
  }
  chatId.value = cid
  return cid
}

// ===== 计算属性 =====
const userInitial = computed(() => {
  const name = userStore.userInfo?.nickname || userStore.userInfo?.username || 'U'
  return name.charAt(0).toUpperCase()
})

// ===== 配置信息弹窗（精简版）的计算属性：统一降级兼容，模板里清爽不写大段三元 =====
const cfg = computed(() => healthInfo.value?.config_sources || {})
const cfgApiObj = computed(() => cfg.value.api_key || cfg.value.deepseek_api_key || {})   // 新版优先，旧版兜底
const cfgModelObj = computed(() => cfg.value.model || cfg.value.deepseek_model || {})
const cfgBaseObj = computed(() => cfg.value.base_url || cfg.value.deepseek_base_url || {})
const cfgConn = computed(() => healthInfo.value?.llm_connectivity || {})

// ===== 从「{ value, source } 对象」或「直接字符串」或「undefined」中安全取值（必须放在 cfgProviderLabel/tooltipText 前面定义！） =====
const _extractValue = (x) => {
  if (x == null) return ''
  if (typeof x === 'string') return x
  if (typeof x === 'object') {
    const v = x.value
    if (v == null) return ''
    return typeof v === 'string' ? v : String(v)
  }
  return ''
}

// 顶栏显示的「供应商·模型名」：比如 huanyuan3·hy3
const cfgProviderLabel = computed(() => {
  const modelVal = _extractValue(cfgModelObj.value)
  const provider = (cfgModelObj.value && cfgModelObj.value.provider) || (cfgApiObj.value && cfgApiObj.value.provider) || ''
  if (provider && modelVal) return `${provider}·${modelVal}`
  return modelVal || provider || ''
})
// 鼠标悬停 tooltip：一行最短版
const tooltipText = computed(() => {
  const key = _extractValue(cfgApiObj.value)
  const src = (cfgApiObj.value && cfgApiObj.value.source) || ''
  if (!key && !src) return ''
  return `Key: ${key || '(未获取)'} ｜ 来源: ${src || '未知'}`
})

// 弹窗 4 行用的字段（统一 value/source 拆开，模板不再写重复三元）
const cfgKey = computed(() => _extractValue(cfgApiObj.value))
const cfgKeySource = computed(() => (typeof cfgApiObj.value === 'object' && cfgApiObj.value ? cfgApiObj.value.source || '' : ''))
const cfgModel = computed(() => _extractValue(cfgModelObj.value))
const cfgModelSource = computed(() => (typeof cfgModelObj.value === 'object' && cfgModelObj.value ? cfgModelObj.value.source || '' : ''))
const cfgBase = computed(() => _extractValue(cfgBaseObj.value))
const cfgBaseSource = computed(() => (typeof cfgBaseObj.value === 'object' && cfgBaseObj.value ? cfgBaseObj.value.source || '' : ''))

// 连通性 tag + message（message 已由后端 short_ping_msg 精简，直接显示即可）
const connLabel = computed(() => {
  const ok = cfgConn.value.ping_ok
  if (ok === true) return '连接成功'
  if (ok === false) return '连接失败'
  return '未检测'
})
const connTagType = computed(() => {
  const ok = cfgConn.value.ping_ok
  if (ok === true) return 'success'
  if (ok === false) return 'danger'
  return 'info'
})
const connMsg = computed(() => {
  const msg = cfgConn.value.message || ''
  const tok = cfgConn.value.total_tokens
  const lat = cfgConn.value.latency_ms
  // 如果后端没拆结构化字段就直接显示 message；如果都有，就拼"成功（N tokens / Nms）"，避免重复
  if (!msg && !tok && !lat) return ''
  if (msg && tok) return msg
  const parts = []
  if (tok) parts.push(`${tok} tokens`)
  if (lat) parts.push(`${Math.round(lat)}ms`)
  if (parts.length) return parts.join(' / ')
  return msg || ''
})

const INTENT_LABEL = {
  task_analysis: '任务分析',
  today_tasks: '今日任务',
  overdue_tasks: '逾期任务',
  high_priority: '高优任务',
  team_analysis: '团队概览',
  notifications: '通知查询',
  help: '帮助',
  greeting: '问候',
  thanks: '感谢',
  who_are_you: '身份',
  unknown: '未知意图'
}
const intentLabel = (i) => INTENT_LABEL[i] || i

// ===== 工具函数 =====
const formatTime = (ts) => {
  if (!ts) return ''
  let d
  if (typeof ts === 'number') {
    d = new Date(ts >= 1e12 ? ts : ts * 1000)
  } else {
    d = new Date(ts)
  }
  if (isNaN(d.getTime())) return ''
  const now = new Date()
  const sameDay = d.toDateString() === now.toDateString()
  if (sameDay) {
    return d.toTimeString().slice(0, 5)
  }
  return `${d.getMonth() + 1}/${d.getDate()} ${d.toTimeString().slice(0, 5)}`
}

// 简易Markdown渲染（只处理加粗、列表、换行，避免引入额外依赖）
const renderMarkdown = (text) => {
  if (!text) return ''
  let html = text
    // 转义
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    // 标题
    .replace(/^### (.+)$/gm, '<h4 style="margin:12px 0 8px;color:#303133;font-weight:600">$1</h4>')
    .replace(/^---$/gm, '<hr style="margin:12px 0;border:none;border-top:1px solid #ebeef5"/>')
    // 粗体
    .replace(/\*\*(.+?)\*\*/g, '<strong style="color:#303133">$1</strong>')
    // 代码
    .replace(/`(.+?)`/g, '<code style="background:#f5f7fa;padding:2px 6px;border-radius:4px;font-size:12px;color:#409eff">$1</code>')
    // 无序列表项（支持 Unicode 项目符号 ·•）
    .replace(/^[•·] (.+)$/gm, '<li style="margin:4px 0;list-style:none;padding-left:16px;position:relative">· $1</li>')
    // 有序列表
    .replace(/^(\d+)\. (.+)$/gm, '<li style="margin:4px 0;list-style:none;padding-left:20px;position:relative"><span style="position:absolute;left:0;color:#909399">$1.</span>$2</li>')
    // 缩进式列表（任务细节中 "  1. xxx" 这种带前导空格的）→ 处理成缩进显示
    .replace(/^( {2,})(\d+)\. (.+)$/gm, (_m, pad, num, content) => {
      const indent = pad.length * 12
      return `<li style="margin:4px 0 4px ${indent}px;list-style:none;padding-left:20px;position:relative"><span style="position:absolute;left:0;color:#909399">${num}.</span>${content}</li>`
    })
    // 换行
    .replace(/\n/g, '<br/>')
  return html
}

// 滚动到底部
const scrollToBottom = async () => {
  await nextTick()
  scrollAnchor.value?.scrollIntoView({ behavior: 'smooth', block: 'end' })
}

// ===== 健康检查（顺便拿配置来源，解决用户「填的 API Key 为啥没生效」的痛点） =====
const checkAgentHealth = async () => {
  try {
    const res = await agentHealth()
    const st = res.data?.status
    agentOnline.value = st === 'ok'
    if (res.data) {
      healthInfo.value = res.data
    }
  } catch (e) {
    agentOnline.value = false
  }
}

// ===== 加载服务端历史（刷新页面后继续上次对话） =====
const loadServerHistory = async () => {
  if (!userStore.userInfo?.id) return
  ensureChatId()
  loadingHistory.value = true
  try {
    const res = await getAgentHistory(chatId.value, userStore.userInfo.id)
    const list = res.data?.messages || []
    if (list && list.length > 0) {
      // 把服务端消息渲染出来（role: 'user'/'assistant'，timestamp_ms / timestamp）
      const rendered = list.map(m => ({
        role: m.role === 'user' ? 'user' : 'agent',
        content: m.content || '',
        type: m.type === 'markdown' ? 'markdown' : 'text',
        meta: m.meta || null,
        timestamp: (m.timestamp_ms ? new Date(m.timestamp_ms).toISOString() : (m.timestamp || new Date().toISOString()))
      }))
      messages.value = rendered
    } else {
      // 服务端没历史 → 加一个欢迎消息
      addWelcomeMessage()
    }
  } catch (e) {
    // 拉不到就用本地欢迎消息
    addWelcomeMessage()
  } finally {
    loadingHistory.value = false
    scrollToBottom()
  }
}

// ===== 发送消息（流式） =====
const handleSend = async () => {
  const content = inputMessage.value.trim()
  if (!content) return
  if (!userStore.userInfo?.id) {
    ElMessage.warning('请先登录')
    return
  }
  if (!agentOnline.value) {
    ElMessage.warning('Agent服务暂不可用，请稍后再试（或查看「健康检查」配置来源面板排查）')
    return
  }
  const cid = ensureChatId()

  // 添加用户消息
  messages.value.push({
    role: 'user',
    content,
    timestamp: new Date().toISOString()
  })
  inputMessage.value = ''
  scrollToBottom()

  // Agent loading 占位
  const loadingMsg = {
    role: 'agent',
    content: '',
    type: 'text',
    loading: true,
    timestamp: new Date().toISOString(),
    meta: null
  }
  const loadingIndex = messages.value.length
  messages.value.push(loadingMsg)
  sending.value = true
  scrollToBottom()

  try {
    // fetch 调用流式接口（注意：baseURL /api 前缀由全局代理拼接）
    const token = localStorage.getItem('token') || ''
    const resp = await fetch('/api/agent/chat/stream', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {})
      },
      body: JSON.stringify({
        user_id: userStore.userInfo.id,
        message: content,
        chat_id: cid
      })
    })

    if (!resp.ok) {
      throw new Error(`HTTP ${resp.status}`)
    }

    const reader = resp.body.getReader()
    const decoder = new TextDecoder('utf-8')
    let buf = ''           // 残留缓冲区（chunk 可能在中间切分）
    let fullText = ''      // 已确认的完整正文（不含 DONE 标记）
    let receivedMeta = null
    const DONE_PREFIX = '\0__DONE__:'

    while (true) {
      const { value, done } = await reader.read()
      if (done) break
      if (value) {
        buf += decoder.decode(value, { stream: true })
        // 检查是否包含 DONE 标记（最后一个 chunk 会带）
        const doneIdx = buf.indexOf(DONE_PREFIX)
        if (doneIdx >= 0) {
          // DONE 之前的部分当正文
          const before = buf.slice(0, doneIdx)
          fullText += before
          // DONE 之后当 meta JSON
          const after = buf.slice(doneIdx + DONE_PREFIX.length)
          if (after) {
            try { receivedMeta = JSON.parse(after) } catch (e) { receivedMeta = { raw: after } }
          }
          buf = ''
          break
        } else {
          // 没有 DONE，全部当正文追加
          fullText += buf
          buf = ''
        }
        // 实时更新 UI（打字机效果）
        messages.value[loadingIndex] = {
          role: 'agent',
          type: 'markdown',
          loading: false,
          content: fullText,
          meta: receivedMeta,
          timestamp: messages.value[loadingIndex].timestamp || new Date().toISOString()
        }
        scrollToBottom()
      }
    }
    // 如果还有 buf 残留（DONE 标记在最后一个 read 之后才完整）
    if (buf) {
      const doneIdx = buf.indexOf(DONE_PREFIX)
      if (doneIdx >= 0) {
        fullText += buf.slice(0, doneIdx)
        const after = buf.slice(doneIdx + DONE_PREFIX.length)
        if (after) {
          try { receivedMeta = JSON.parse(after) } catch (e) {}
        }
      } else {
        fullText += buf
      }
    }

    // 最终落地
    const finalType = (receivedMeta && receivedMeta.type) ? receivedMeta.type : 'markdown'
    messages.value[loadingIndex] = {
      role: 'agent',
      type: finalType,
      loading: false,
      content: fullText,
      meta: receivedMeta || null,
      timestamp: new Date().toISOString()
    }
  } catch (e) {
    messages.value[loadingIndex] = {
      role: 'agent',
      content: `😢 出错了：${e.message}，请稍后再试。`,
      type: 'text',
      loading: false,
      timestamp: new Date().toISOString()
    }
  } finally {
    sending.value = false
    scrollToBottom()
  }
}

// 快捷指令发送
const sendQuick = (cmd) => {
  inputMessage.value = cmd
  handleSend()
}

// 清空聊天（同时清服务端和本地）
const clearChat = async () => {
  try {
    await ElMessageBox.confirm('确定要清空当前聊天记录吗？（服务端和本地都会清除）', '提示', {
      confirmButtonText: '确定清空',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch (e) {
    return // 取消
  }
  const cid = chatId.value
  if (cid && userStore.userInfo?.id) {
    try {
      await deleteAgentHistory(cid, userStore.userInfo.id)
    } catch (e) {}
  }
  messages.value = []
  addWelcomeMessage()
  // 重新生成 chat_id，避免和之前记录混淆
  const newChatId = 'chat_' + Date.now() + '_' + Math.random().toString(36).slice(2, 11)
  localStorage.setItem('agent_chat_id', newChatId)
  chatId.value = newChatId
}

// 欢迎消息
const addWelcomeMessage = () => {
  const name = userStore.userInfo?.nickname || userStore.userInfo?.username || '你好'
  messages.value.push({
    role: 'agent',
    type: 'markdown',
    content: `👋 欢迎使用 **LTCM小助手**！

我可以帮你：
• 📅 查询今日任务安排
• 📊 分析任务进度和统计（**会列出每个任务的标题+编号**）
• 🔔 查看逾期和高优任务
• 👥 了解团队信息和通知

试试点击上方的快捷指令，或者直接输入"帮助"查看完整功能～`,
    timestamp: new Date().toISOString()
  })
}

onMounted(() => {
  ensureChatId()
  checkAgentHealth()
  // 已登录：尝试拉服务端历史；未登录：只放欢迎消息
  if (userStore.userInfo?.id) {
    loadServerHistory()
  } else {
    addWelcomeMessage()
  }
  // 定期检查Agent状态（每分钟）
  setInterval(checkAgentHealth, 60000)
})

// 登录状态变化：用户登录后再拉一次历史
watch(
  () => userStore.userInfo?.id,
  (newId, oldId) => {
    if (newId && !oldId) {
      loadServerHistory()
    }
  }
)

// 监听消息变化自动滚动
watch(messages, () => {
  scrollToBottom()
}, { deep: true })
</script>

<style scoped lang="scss">
.agent-chat-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 600px;
  background: #fafbfc;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid #ebeef5;
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
  color: white;

  .header-left {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .agent-avatar {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: rgba(255,255,255,0.25);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .header-info {
    .agent-name {
      font-size: 16px;
      font-weight: 600;
    }
    .agent-status {
      font-size: 12px;
      opacity: 0.95;
      display: flex;
      align-items: center;
      gap: 4px;
      margin-top: 2px;

      .status-dot {
        display: inline-block;
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: #f56c6c;
      }
      &.online .status-dot {
        background: #67c23a;
      }
      .config-src-tip {
        cursor: help;
        margin-left: 6px;
        padding: 0 6px;
        background: rgba(255,255,255,0.2);
        border-radius: 8px;
        display: inline-flex;
        align-items: center;
        .debug-icon { margin-left: 2px; }
      }
    }
  }

  .header-actions :deep(.el-button) {
    color: white !important;
    opacity: 0.9;
    &:hover { opacity: 1; }
  }
}

.config-debug-panel {
  background: #fffbe6;
  border-bottom: 1px solid #faecd8;
  padding: 12px 20px;
  .config-title {
    font-size: 13px;
    font-weight: 600;
    color: #b88230;
    margin-bottom: 8px;
  }
  .src-muted { color: #909399; font-size: 12px; }
}

.quick-commands {
  padding: 12px 20px;
  background: #ecf5ff;
  border-bottom: 1px solid #d9ecff;

  .quick-title {
    font-size: 13px;
    color: #409eff;
    margin-bottom: 8px;
    font-weight: 500;
  }
  .quick-btns {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    :deep(.el-button) {
      border-radius: 16px;
    }
  }
}

.chat-messages {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: #fafbfc;
}

.message-item {
  display: flex;
  margin-bottom: 20px;
  align-items: flex-start;
  gap: 10px;

  &.user-msg {
    flex-direction: row-reverse;

    .msg-bubble {
      background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
      color: white;
      border-top-right-radius: 4px;

      .msg-time {
        color: rgba(255,255,255,0.7);
      }
    }
  }

  &.agent-msg {
    .msg-bubble {
      background: white;
      border: 1px solid #ebeef5;
      border-top-left-radius: 4px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }
  }
}

.msg-avatar {
  flex-shrink: 0;
  background: linear-gradient(135deg, #909399 0%, #a6a9ad 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
}

.agent-avatar-inline {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
  color: white;
}

.msg-bubble {
  max-width: 75%;
  padding: 12px 16px;
  border-radius: 12px;

  .msg-content {
    line-height: 1.7;
    font-size: 14px;
    word-break: break-word;
  }

  .msg-footer {
    margin-top: 8px;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    flex-wrap: wrap;
    gap: 4px 6px;
  }

  .msg-time {
    font-size: 11px;
    opacity: 0.65;
  }

  .meta-tag {
    font-size: 11px;
    padding: 1px 6px;
    border-radius: 8px;
    line-height: 1.6;
    &.llm-tag       { background: #fef0f0; color: #f56c6c; }
    &.lg-tag        { background: #ecf5ff; color: #409eff; }
    &.intent-tag    { background: #f0f9eb; color: #67c23a; }
    &.latency-tag   { background: #fdf6ec; color: #e6a23c; }
  }

  &.loading {
    padding: 16px 20px;
    .typing-indicator {
      display: flex;
      gap: 4px;
      align-items: center;
      span {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: #c0c4cc;
        animation: typing 1.4s infinite;
        &:nth-child(2) { animation-delay: 0.2s; }
        &:nth-child(3) { animation-delay: 0.4s; }
      }
    }
  }
}

@keyframes typing {
  0%, 60%, 100% { transform: translateY(0); opacity: 0.5; }
  30% { transform: translateY(-4px); opacity: 1; }
}

.markdown-body {
  :deep(h4) { margin: 12px 0 8px; }
  :deep(hr) { margin: 12px 0; border: none; border-top: 1px solid #ebeef5; }
  :deep(li) { margin: 4px 0; }
  :deep(code) { word-break: break-all; }
}

.chat-input-area {
  padding: 16px 20px;
  background: white;
  border-top: 1px solid #ebeef5;

  .input-actions {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 12px;
    margin-top: 10px;

    .streaming-tip {
      font-size: 12px;
      color: #909399;
    }
  }
}
</style>
