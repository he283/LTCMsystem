<template>
  <div class="login-log-container">
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
                <el-dropdown-item command="operationLog">操作日志</el-dropdown-item>
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
            <el-menu-item index="login-log">
              <el-icon><Key /></el-icon>
              <span>登录日志</span>
            </el-menu-item>
          </el-menu>
        </el-aside>
        <el-main class="main">
          <div class="page-header">
            <h3 class="page-title">登录日志</h3>
            <span class="page-sub">记录所有用户的登录行为（含 IP 与 User-Agent），仅管理员可见</span>
          </div>

          <el-card>
            <el-form :inline="true" :model="filterForm" class="filter-form">
              <el-form-item label="用户名">
                <el-input v-model="filterForm.username" placeholder="请输入用户名" clearable style="width: 200px" />
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
              <el-table-column prop="createTime" label="登录时间" width="180">
                <template #default="{ row }">
                  {{ formatDate(row.createTime) }}
                </template>
              </el-table-column>
              <el-table-column prop="username" label="用户名" width="130">
                <template #default="{ row }">
                  <span class="username-cell">{{ row.username || '-' }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="nickname" label="昵称" width="130" />
              <el-table-column prop="ipAddress" label="IP 地址" width="150">
                <template #default="{ row }">
                  <span class="ip-cell">{{ row.ipAddress || '-' }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="userAgent" label="User-Agent" min-width="260" show-overflow-tooltip>
                <template #default="{ row }">
                  <span class="ua-cell">{{ row.userAgent || '-' }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="operationDesc" label="说明" width="100">
                <template #default="{ row }">
                  <el-tag type="success" size="small">{{ row.operationDesc || '登录' }}</el-tag>
                </template>
              </el-table-column>
            </el-table>

            <el-empty v-if="!loading && logList.length === 0" description="暂无登录记录" />

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
  Document, ArrowDown, DataLine, Tickets, Key, Search
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getOperationLogs } from '@/api'

const router = useRouter()
const userStore = useUserStore()

const activeMenu = ref('login-log')
const loading = ref(false)
const logList = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(20)

const filterForm = ref({
  username: '',
  dateRange: []
})

const formatDate = (date) => {
  if (!date) return '-'
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss')
}

const loadLogs = async () => {
  loading.value = true
  try {
    // 复用操作日志接口，按 operationType=LOGIN 过滤出登录记录
    const params = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      operationType: 'LOGIN'
    }
    if (filterForm.value.username) {
      params.username = filterForm.value.username
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
    ElMessage.error('加载登录日志失败')
    console.error('加载登录日志失败:', error)
  } finally {
    loading.value = false
  }
}

const resetFilter = () => {
  filterForm.value = {
    username: '',
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

const goOperationLog = () => {
  router.push('/operation-log')
}

const handleSelect = (index) => {
  if (index === 'home') {
    goHome()
  } else if (index === 'operation-log') {
    goOperationLog()
  }
}

const handleCommand = (command) => {
  if (command === 'home') {
    goHome()
  } else if (command === 'operationLog') {
    goOperationLog()
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
.login-log-container {
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
  margin: 0 0 6px 0;
  font-size: 22px;
  color: #303133;
}

.page-sub {
  font-size: 13px;
  color: #909399;
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

.username-cell {
  font-weight: 600;
  color: #303133;
}

.ip-cell {
  font-family: monospace;
  font-size: 13px;
}

.ua-cell {
  font-size: 12px;
  color: #606266;
}
</style>
