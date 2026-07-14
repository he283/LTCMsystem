<template>
  <div class="plaza-container">
    <el-header class="plaza-header">
      <div class="logo" @click="goHome">
        <el-icon><Document /></el-icon>
        轻量任务协作管理系统
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="goLogin" v-if="!isLoggedIn">登录</el-button>
        <el-button @click="goHome" v-if="isLoggedIn">进入系统</el-button>
      </div>
    </el-header>

    <el-main class="plaza-main">
      <div class="plaza-title">
        <h2>任务广场</h2>
        <p>探索公开任务，发现优秀团队的工作成果</p>
      </div>

      <el-card class="filter-card">
        <div class="filter-bar">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索任务标题或简介"
            style="width: 300px; margin-right: 16px"
            clearable
            @keyup.enter="loadTasks"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
          <el-select v-model="priorityFilter" placeholder="优先级" clearable style="width: 120px; margin-right: 16px" @change="loadTasks">
            <el-option label="低" value="LOW" />
            <el-option label="中" value="MEDIUM" />
            <el-option label="高" value="HIGH" />
          </el-select>
          <el-select v-model="statusFilter" placeholder="状态" clearable style="width: 120px; margin-right: 16px" @change="loadTasks">
            <el-option label="待分配" value="PENDING_ASSIGN" />
            <el-option label="进行中" value="IN_PROGRESS" />
            <el-option label="待评审" value="PENDING_REVIEW" />
            <el-option label="已完成" value="DONE" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
          <el-button type="primary" @click="loadTasks">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
        </div>
      </el-card>

      <el-row :gutter="20" class="task-grid" v-loading="loading">
        <el-col :span="8" v-for="task in taskList" :key="task.id">
          <el-card shadow="hover" class="task-card" @click="viewDetail(task.id)">
            <template #header>
              <div class="card-header">
                <span class="task-title">{{ task.title }}</span>
                <el-tag :type="getStatusType(task.status)" size="small">{{ getStatusText(task.status) }}</el-tag>
              </div>
            </template>
            <div class="task-code-tag">
              <el-tag type="info" size="small">编号: {{ task.taskCode || '-' }}</el-tag>
            </div>
            <div class="task-desc">{{ task.publicDesc || '暂无公开简介' }}</div>
            <div class="task-meta">
              <div class="meta-item">
                <el-icon><User /></el-icon>
                <span>{{ task.teamName || '未知团队' }}</span>
              </div>
              <div class="meta-item">
                <el-tag :type="getPriorityType(task.priority)" size="small">{{ getPriorityText(task.priority) }}</el-tag>
              </div>
            </div>
            <div class="task-footer">
              <span class="create-time">发布于 {{ formatDate(task.createTime) }}</span>
              <el-button type="primary" size="small" link>查看详情 →</el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>
      <el-empty v-if="taskList.length === 0 && !loading" description="暂无公开任务" />

      <div class="pagination">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[9, 18, 36]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Document, User } from '@element-plus/icons-vue'
import { getPublicTasks } from '@/api'
import dayjs from 'dayjs'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const taskList = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(9)
const searchKeyword = ref('')
const priorityFilter = ref('')
const statusFilter = ref('')

const isLoggedIn = computed(() => !!userStore.token)

const loadTasks = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pageNum.value,
      pageSize: pageSize.value
    }
    if (searchKeyword.value) {
      params.keyword = searchKeyword.value
    }
    if (priorityFilter.value) {
      params.priority = priorityFilter.value
    }
    if (statusFilter.value) {
      params.status = statusFilter.value
    }
    const res = await getPublicTasks(params)
    taskList.value = res.data.records || []
    total.value = res.data.total || 0
  } catch (error) {
    console.error('加载公开任务失败:', error)
  } finally {
    loading.value = false
  }
}

const viewDetail = (id) => {
  router.push(`/plaza/${id}`)
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
  return dayjs(date).format('YYYY-MM-DD')
}

const handleSizeChange = (size) => {
  pageSize.value = size
  loadTasks()
}

const handleCurrentChange = (page) => {
  pageNum.value = page
  loadTasks()
}

onMounted(() => {
  loadTasks()
})
</script>

<style scoped>
.plaza-container {
  min-height: 100vh;
  background-color: #f0f2f5;
}

.plaza-header {
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

.plaza-main {
  max-width: 1200px;
  margin: 0 auto;
  padding: 30px 20px;
}

.plaza-title {
  text-align: center;
  margin-bottom: 30px;
}

.plaza-title h2 {
  font-size: 28px;
  color: #303133;
  margin: 0 0 10px 0;
}

.plaza-title p {
  color: #909399;
  margin: 0;
}

.filter-card {
  margin-bottom: 24px;
}

.filter-bar {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.task-grid {
  margin-bottom: 20px;
}

.task-grid .task-card {
  margin-bottom: 20px;
}

.task-card {
  cursor: pointer;
  transition: all 0.3s;
  border-radius: 8px;
}

.task-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.task-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  margin-right: 10px;
}

.task-desc {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  min-height: 60px;
  margin-bottom: 16px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.task-code-tag {
  margin-bottom: 10px;
}

.task-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #909399;
  font-size: 13px;
}

.task-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #ebeef5;
}

.create-time {
  color: #c0c4cc;
  font-size: 12px;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}
</style>
