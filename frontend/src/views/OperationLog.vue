<template>
  <div class="operation-log-container">
    <el-container>
      <el-header class="header">
        <div class="logo" @click="goHome">
          <el-icon><Document /></el-icon>
          轻量任务协作管理系统
        </div>
        <div class="user-info">
          <el-dropdown @command="handleCommand">
            <span class="user-dropdown">
              <el-avatar :size="32" style="margin-right: 10px" />
              <span>{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</span>
              <el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="home">返回首页</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-container>
        <el-aside width="220px" class="aside">
          <el-menu
            :default-active="activeMenu"
            class="el-menu-vertical"
            @select="handleSelect"
            active-text-color="#409eff"
          >
            <el-menu-item index="home" @click="goHome">
              <el-icon><DataLine /></el-icon>
              <span>工作台</span>
            </el-menu-item>
            <el-menu-item index="operation-log">
              <el-icon><Tickets /></el-icon>
              <span>操作日志</span>
            </el-menu-item>
          </el-menu>
        </el-aside>
        <el-main class="main">
          <div class="page-header">
            <h3 class="page-title">操作日志</h3>
          </div>

          <el-card>
            <el-form :inline="true" :model="filterForm" class="filter-form">
              <el-form-item label="操作人">
                <el-input v-model="filterForm.operator" placeholder="请输入操作人" clearable />
              </el-form-item>
              <el-form-item label="操作类型">
                <el-select v-model="filterForm.type" placeholder="全部" clearable style="width: 140px">
                  <el-option label="登录" value="LOGIN" />
                  <el-option label="登出" value="LOGOUT" />
                  <el-option label="任务新增" value="TASK_CREATE" />
                  <el-option label="任务修改" value="TASK_UPDATE" />
                  <el-option label="任务删除" value="TASK_DELETE" />
                  <el-option label="团队新增" value="TEAM_CREATE" />
                  <el-option label="团队修改" value="TEAM_UPDATE" />
                  <el-option label="团队删除" value="TEAM_DELETE" />
                  <el-option label="加入团队" value="TEAM_JOIN" />
                  <el-option label="退出团队" value="TEAM_LEAVE" />
                  <el-option label="邀请成员" value="TEAM_INVITE" />
                  <el-option label="移除成员" value="TEAM_REMOVE_MEMBER" />
                  <el-option label="AI对话" value="AI_CHAT" />
                </el-select>
              </el-form-item>
              <el-form-item label="模块">
                <el-select v-model="filterForm.module" placeholder="全部" clearable style="width: 140px">
                  <el-option label="认证" value="auth" />
                  <el-option label="用户" value="user" />
                  <el-option label="团队" value="team" />
                  <el-option label="任务" value="task" />
                  <el-option label="AI助手" value="agent" />
                </el-select>
              </el-form-item>
              <el-form-item label="时间范围">
                <el-date-picker
                  v-model="filterForm.dateRange"
                  type="daterange"
                  range-separator="至"
                  start-placeholder="开始日期"
                  end-placeholder="结束日期"
                  value-format="YYYY-MM-DD"
                />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="loadLogs">
                  <el-icon><Search /></el-icon>
                  查询
                </el-button>
                <el-button @click="resetFilter">重置</el-button>
              </el-form-item>
            </el-form>
          </el-card>

          <el-card style="margin-top: 20px">
            <el-table
              v-loading="loading"
              :data="logList"
              style="width: 100%"
              stripe
            >
              <el-table-column prop="createTime" label="操作时间" width="180">
                <template #default="{ row }">
                  {{ formatDate(row.createTime) }}
                </template>
              </el-table-column>
              <el-table-column prop="nickname" label="操作人" width="120" />
              <el-table-column prop="operationType" label="操作类型" width="100">
                <template #default="{ row }">
                  <el-tag :type="getTypeTag(row.operationType)" size="small">
                    {{ getTypeText(row.operationType) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="module" label="模块" width="100">
                <template #default="{ row }">
                  <el-tag :type="getModuleTag(row.module)" size="small">
                    {{ getModuleText(row.module) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="operationDesc" label="操作描述" min-width="300" show-overflow-tooltip />
              <el-table-column prop="ipAddress" label="IP地址" width="140" />
            </el-table>

            <div class="pagination">
              <el-pagination
                v-model:current-page="pageNum"
                v-model:page-size="pageSize"
                :total="total"
                :page-sizes="[10, 20, 50, 100]"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
              />
            </div>
          </el-card>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import dayjs from 'dayjs'
import {
  Document, ArrowDown, DataLine, Tickets, Search
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getOperationLogs } from '@/api'

const router = useRouter()
const userStore = useUserStore()

const activeMenu = ref('operation-log')
const loading = ref(false)
const logList = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(20)

const filterForm = ref({
  operator: '',
  type: '',
  module: '',
  dateRange: []
})

const getTypeText = (type) => {
  const map = {
    LOGIN: '登录',
    LOGOUT: '登出',
    TASK_CREATE: '任务新增',
    TASK_UPDATE: '任务修改',
    TASK_DELETE: '任务删除',
    TEAM_CREATE: '团队新增',
    TEAM_UPDATE: '团队修改',
    TEAM_DELETE: '团队删除',
    TEAM_JOIN: '加入团队',
    TEAM_LEAVE: '退出团队',
    TEAM_INVITE: '邀请成员',
    TEAM_REMOVE_MEMBER: '移除成员',
    AI_CHAT: 'AI对话'
  }
  return map[type] || type
}

const getTypeTag = (type) => {
  const map = {
    LOGIN: 'success',
    LOGOUT: 'info',
    TASK_CREATE: 'primary',
    TASK_UPDATE: 'warning',
    TASK_DELETE: 'danger',
    TEAM_CREATE: 'primary',
    TEAM_UPDATE: 'warning',
    TEAM_DELETE: 'danger',
    TEAM_JOIN: 'success',
    TEAM_LEAVE: 'info',
    TEAM_INVITE: 'primary',
    TEAM_REMOVE_MEMBER: 'danger',
    AI_CHAT: 'warning'
  }
  return map[type] || 'info'
}

const getModuleText = (module) => {
  const map = {
    auth: '认证',
    user: '用户',
    team: '团队',
    task: '任务',
    agent: 'AI助手',
    USER: '用户',
    TEAM: '团队',
    TASK: '任务'
  }
  return map[module] || module
}

const getModuleTag = (module) => {
  const map = {
    auth: 'success',
    user: 'success',
    team: 'primary',
    task: 'warning',
    agent: 'danger',
    USER: 'success',
    TEAM: 'primary',
    TASK: 'warning'
  }
  return map[module] || 'info'
}

const formatDate = (date) => {
  if (!date) return '-'
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss')
}

const loadLogs = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pageNum.value,
      pageSize: pageSize.value
    }
    if (filterForm.value.operator) {
      params.username = filterForm.value.operator
    }
    if (filterForm.value.type) {
      params.operationType = filterForm.value.type
    }
    if (filterForm.value.module) {
      params.module = filterForm.value.module
    }
    if (filterForm.value.dateRange && filterForm.value.dateRange.length === 2) {
      // 后端 LocalDateTime 参数走 Spring 标准 ISO 格式解析
      params.startTime = filterForm.value.dateRange[0] + 'T00:00:00'
      params.endTime = filterForm.value.dateRange[1] + 'T23:59:59'
    }
    const res = await getOperationLogs(params)
    if (res.data) {
      logList.value = res.data.records || res.data.list || []
      total.value = res.data.total || 0
    }
  } catch (error) {
    ElMessage.error('加载操作日志失败')
    console.error('加载操作日志失败:', error)
  } finally {
    loading.value = false
  }
}

const resetFilter = () => {
  filterForm.value = {
    operator: '',
    type: '',
    module: '',
    dateRange: []
  }
  pageNum.value = 1
  loadLogs()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  pageNum.value = 1
  loadLogs()
}

const handleCurrentChange = (page) => {
  pageNum.value = page
  loadLogs()
}

const goHome = () => {
  router.push('/home')
}

const handleSelect = (index) => {
  if (index === 'home') {
    goHome()
  }
}

const handleCommand = (command) => {
  if (command === 'home') {
    goHome()
  } else if (command === 'logout') {
    userStore.logout()
    ElMessage.success('退出成功')
    router.push('/login')
  }
}

onMounted(() => {
  loadLogs()
})
</script>

<style scoped>
.operation-log-container {
  width: 100%;
  height: 100vh;
}

.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.logo {
  font-size: 20px;
  font-weight: bold;
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.user-dropdown {
  cursor: pointer;
  display: flex;
  align-items: center;
}

.user-dropdown span {
  color: #e7eb10;
}

.aside {
  background-color: #f5f7fa;
  border-right: 1px solid #e6e6e6;
  height: calc(100vh - 60px);
}

.main {
  background-color: #f0f2f5;
  padding: 24px;
  height: calc(100vh - 60px);
  overflow-y: auto;
}

.page-title {
  margin: 0 0 20px 0;
  font-size: 22px;
  color: #303133;
}

.page-header {
  margin-bottom: 20px;
}

.filter-form {
  margin: 0;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
