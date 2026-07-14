<template>
  <div class="detail-container">
    <el-header class="detail-header">
      <div class="logo" @click="goPlaza">
        <el-icon><Document /></el-icon>
        轻量任务协作管理系统
      </div>
      <div class="header-actions">
        <el-button @click="goPlaza">
          <el-icon><Back /></el-icon>
          返回广场
        </el-button>
        <el-button type="primary" @click="goLogin" v-if="!isLoggedIn">登录</el-button>
        <el-button @click="goHome" v-if="isLoggedIn">进入系统</el-button>
      </div>
    </el-header>

    <el-main class="detail-main">
      <div class="detail-content" v-loading="loading">
        <template v-if="taskDetail">
          <div class="task-header">
            <h1 class="task-title">{{ taskDetail.title }}</h1>
            <div class="task-tags">
              <el-tag :type="getStatusType(taskDetail.status)" size="large">{{ getStatusText(taskDetail.status) }}</el-tag>
              <el-tag :type="getPriorityType(taskDetail.priority)" size="large">{{ getPriorityText(taskDetail.priority) }}优先级</el-tag>
            </div>
          </div>

          <el-card class="info-card">
            <template #header>
              <span class="card-title">任务信息</span>
            </template>
            <el-descriptions :column="2" border>
              <el-descriptions-item label="任务编号">
                <span class="task-code">{{ taskDetail.taskCode || '-' }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="团队编号">
                <span class="task-code">{{ taskDetail.teamCode || '-' }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="所属团队">
                <span class="team-name">{{ taskDetail.teamName || '未知团队' }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="发布时间">
                {{ formatDate(taskDetail.createTime) }}
              </el-descriptions-item>
              <el-descriptions-item label="截止时间" :span="2">
                {{ taskDetail.dueDate ? formatDate(taskDetail.dueDate) : '-' }}
              </el-descriptions-item>
            </el-descriptions>
          </el-card>

          <el-card class="desc-card">
            <template #header>
              <span class="card-title">公开简介</span>
            </template>
            <div class="public-desc">
              {{ taskDetail.publicDesc || '暂无公开简介' }}
            </div>
          </el-card>

          <el-card class="changelog-card" v-if="isLoggedIn">
            <template #header>
              <div class="card-header">
                <span class="card-title">变更历史</span>
              </div>
            </template>
            <el-table :data="changeLogs" v-loading="loadingChangeLogs" stripe>
              <el-table-column prop="createTime" label="变更时间" width="170">
                <template #default="{ row }">
                  {{ formatDate(row.createTime) }}
                </template>
              </el-table-column>
              <el-table-column prop="operatorName" label="操作人" width="100" />
              <el-table-column prop="fieldName" label="变更字段" width="120" />
              <el-table-column prop="oldValue" label="变更前" min-width="140" show-overflow-tooltip />
              <el-table-column prop="newValue" label="变更后" min-width="140" show-overflow-tooltip />
            </el-table>
            <el-empty v-if="changeLogs.length === 0 && !loadingChangeLogs" description="暂无变更记录" />
          </el-card>

          <el-card class="comment-card">
            <template #header>
              <div class="card-header">
                <span class="card-title">评论区</span>
                <span class="comment-count">共 {{ commentTotal }} 条评论</span>
              </div>
            </template>

            <div class="comment-input-area" v-if="isLoggedIn">
              <el-input
                v-model="newComment"
                type="textarea"
                :rows="3"
                placeholder="发表评论..."
                maxlength="2000"
                show-word-limit
              />
              <div class="comment-actions">
                <el-button type="primary" :loading="submittingComment" @click="handleSubmitComment" :disabled="!newComment.trim()">
                  发表评论
                </el-button>
              </div>
            </div>
            <div class="comment-login-tip" v-else>
              <el-alert
                title="登录后可发表评论"
                type="info"
                :closable="false"
                show-icon
              >
                <template #default>
                  <el-button type="primary" size="small" @click="goLogin">立即登录</el-button>
                </template>
              </el-alert>
            </div>

            <div class="comment-list" v-loading="loadingComments">
              <el-empty v-if="comments.length === 0 && !loadingComments" description="暂无评论，快来抢沙发吧~" :image-size="60" />
              <div
                v-for="comment in comments"
                :key="comment.id"
                class="comment-item"
              >
                <div class="comment-header">
                  <el-avatar :size="36" :src="comment.avatar">
                    {{ (comment.nickname || comment.username || 'U').charAt(0).toUpperCase() }}
                  </el-avatar>
                  <div class="comment-user-info">
                    <span class="comment-username">{{ comment.nickname || comment.username }}</span>
                    <span class="comment-time">{{ formatDate(comment.createTime) }}</span>
                  </div>
                  <el-dropdown v-if="canDeleteComment(comment)" @command="(cmd) => handleCommentCommand(cmd, comment)">
                    <el-button type="primary" link size="small">
                      <el-icon><MoreFilled /></el-icon>
                    </el-button>
                    <template #dropdown>
                      <el-dropdown-menu>
                        <el-dropdown-item command="delete">删除</el-dropdown-item>
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                </div>
                <div class="comment-content">{{ comment.content }}</div>
              </div>
            </div>

            <div class="comment-pagination" v-if="commentTotal > pageSize">
              <el-pagination
                v-model:current-page="commentPage"
                :page-size="pageSize"
                :total="commentTotal"
                layout="prev, pager, next"
                @current-change="loadComments"
              />
            </div>
          </el-card>

          <el-card class="tip-card" v-if="!isLoggedIn">
            <el-alert
              title="登录后可查看完整任务详情和参与协作"
              type="info"
              show-icon
              :closable="false"
            >
              <template #default>
                <p>此任务来自 {{ taskDetail.teamName || '公开团队' }}，登录后可以：</p>
                <ul style="margin: 10px 0 0 20px">
                  <li>查看任务完整描述和详细信息</li>
                  <li>加入团队参与任务协作</li>
                  <li>创建和管理自己的任务</li>
                </ul>
                <el-button type="primary" size="small" style="margin-top: 16px" @click="goLogin">立即登录</el-button>
              </template>
            </el-alert>
          </el-card>
        </template>

        <el-empty v-else-if="!loading" description="任务不存在或未公开">
          <template #description>
            <p>该任务可能已被删除，或者未设置为公开状态</p>
            <el-button type="primary" @click="goPlaza">返回广场</el-button>
          </template>
        </el-empty>
      </div>
    </el-main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Document, Back, MoreFilled } from '@element-plus/icons-vue'
import { getPublicTaskDetail, getTaskChangeLogs, getPublicTaskComments, addTaskComment, deleteTaskComment } from '@/api'
import dayjs from 'dayjs'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const loadingChangeLogs = ref(false)
const loadingComments = ref(false)
const submittingComment = ref(false)
const taskDetail = ref(null)
const changeLogs = ref([])
const comments = ref([])
const commentTotal = ref(0)
const commentPage = ref(1)
const pageSize = ref(20)
const newComment = ref('')

const isLoggedIn = computed(() => !!userStore.token)

const canDeleteComment = (comment) => {
  if (!isLoggedIn.value) return false
  const currentUserId = userStore.userInfo?.id
  if (!currentUserId) return false
  return comment.userId === currentUserId
}

const loadDetail = async () => {
  loading.value = true
  try {
    const taskId = route.params.id
    const res = await getPublicTaskDetail(taskId)
    taskDetail.value = res.data
    loadComments()
    if (isLoggedIn.value) {
      loadChangeLogs(taskId)
    }
  } catch (error) {
    console.error('加载任务详情失败:', error)
    taskDetail.value = null
  } finally {
    loading.value = false
  }
}

const loadChangeLogs = async (taskId) => {
  loadingChangeLogs.value = true
  try {
    const res = await getTaskChangeLogs(taskId)
    changeLogs.value = res.data?.records || res.data?.list || res.data || []
  } catch (error) {
    console.error('加载变更历史失败:', error)
  } finally {
    loadingChangeLogs.value = false
  }
}

const loadComments = async (page = 1) => {
  const taskId = route.params.id
  if (!taskId) return
  loadingComments.value = true
  commentPage.value = page
  try {
    const res = await getPublicTaskComments(taskId, { pageNum: page, pageSize: pageSize.value })
    comments.value = res.data?.records || res.data?.list || res.data || []
    commentTotal.value = res.data?.total || 0
  } catch (error) {
    console.error('加载评论失败:', error)
  } finally {
    loadingComments.value = false
  }
}

const handleSubmitComment = async () => {
  if (!newComment.value.trim()) return
  const taskId = route.params.id
  submittingComment.value = true
  try {
    await addTaskComment(taskId, { content: newComment.value.trim() })
    ElMessage.success('评论发表成功')
    newComment.value = ''
    commentPage.value = 1
    loadComments(1)
  } catch (error) {
    console.error('发表评论失败:', error)
    ElMessage.error(error?.response?.data?.message || '发表评论失败')
  } finally {
    submittingComment.value = false
  }
}

const handleCommentCommand = async (cmd, comment) => {
  if (cmd === 'delete') {
    try {
      await ElMessageBox.confirm('确定要删除这条评论吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      const taskId = route.params.id
      await deleteTaskComment(taskId, comment.id)
      ElMessage.success('删除成功')
      loadComments(commentPage.value)
    } catch (error) {
      if (error !== 'cancel') {
        console.error('删除评论失败:', error)
        ElMessage.error(error?.response?.data?.message || '删除评论失败')
      }
    }
  }
}

const goPlaza = () => {
  router.push('/plaza')
}

const goLogin = () => {
  router.push('/login')
}

const goHome = () => {
  router.push('/home')
}

const getStatusType = (status) => {
  const map = { PENDING_ASSIGN: 'info', IN_PROGRESS: 'warning', PENDING_REVIEW: 'primary', DONE: 'success', CANCELLED: 'danger' }
  return map[status] || 'info'
}

const getStatusText = (status) => {
  const map = { PENDING_ASSIGN: '待分配', IN_PROGRESS: '进行中', PENDING_REVIEW: '待评审', DONE: '已完成', CANCELLED: '已取消' }
  return map[status] || status
}

const getPriorityType = (priority) => {
  const map = { LOW: 'info', MEDIUM: 'warning', HIGH: 'danger' }
  return map[priority] || 'info'
}

const getPriorityText = (priority) => {
  const map = { LOW: '低', MEDIUM: '中', HIGH: '高' }
  return map[priority] || priority
}

const formatDate = (date) => {
  if (!date) return '-'
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

onMounted(() => {
  loadDetail()
})
</script>

<style scoped>
.detail-container {
  min-height: 100vh;
  background-color: #f0f2f5;
}

.detail-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30px;
  height: 60px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.logo {
  font-size: 18px;
  font-weight: bold;
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.detail-main {
  max-width: 900px;
  margin: 0 auto;
  padding: 30px 20px;
}

.detail-content {
  background-color: white;
  border-radius: 8px;
  padding: 30px;
}

.task-header {
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 1px solid #ebeef5;
}

.task-title {
  font-size: 24px;
  color: #303133;
  margin: 0 0 16px 0;
}

.task-tags {
  display: flex;
  gap: 10px;
}

.info-card {
  margin-bottom: 20px;
  border-radius: 8px;
}

.card-title {
  font-weight: 500;
  font-size: 16px;
  color: #303133;
}

.team-name {
  color: #409eff;
  font-weight: 500;
}

.desc-card {
  margin-bottom: 20px;
  border-radius: 8px;
}

.changelog-card {
  margin-bottom: 20px;
  border-radius: 8px;
}

.comment-card {
  margin-bottom: 20px;
  border-radius: 8px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.comment-count {
  color: #909399;
  font-size: 14px;
  font-weight: normal;
}

.comment-input-area {
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #ebeef5;
}

.comment-actions {
  margin-top: 10px;
  display: flex;
  justify-content: flex-end;
}

.comment-login-tip {
  margin-bottom: 20px;
}

.comment-list {
  min-height: 100px;
}

.comment-item {
  padding: 16px 0;
  border-bottom: 1px solid #f5f7fa;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.comment-user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.comment-username {
  font-weight: 500;
  color: #303133;
  font-size: 14px;
}

.comment-time {
  font-size: 12px;
  color: #909399;
}

.comment-content {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
  padding-left: 48px;
}

.comment-pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.task-code {
  color: #909399;
  font-family: monospace;
  font-size: 13px;
}

.public-desc {
  color: #606266;
  font-size: 14px;
  line-height: 1.8;
  white-space: pre-wrap;
}

.tip-card {
  border-radius: 8px;
}
</style>
