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
                <el-select v-model="filterForm.type" placeholder="全部" clearable>
                  <el-option label="登录" value="LOGIN" />
                  <el-option label="登出" value="LOGOUT" />
                  <el-option label="创建" value="CREATE" />
                  <el-option label="更新" value="UPDATE" />
                  <el-option label="删除" value="DELETE" />
                </el-select>
              </el-form-item>
              <el-form-item label="模块">
                <el-select v-model="filterForm.module" placeholder="全部" clearable>
                  <el-option label="用户" value="USER" />
                  <el-option label="团队" value="TEAM" />
                  <el-option label="任务" value="TASK" />
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
              <el-table-column prop="operationTime" label="操作时间" width="180">
                <template #default="{ row }">
                  {{ formatDate(row.operationTime) }}
                </template>
              </el-table-column>
              <el-table-column prop="operatorName" label="操作人" width="120" />
              <el-table-column prop="type" label="操作类型" width="100">
                <template #default="{ row }">
                  <el-tag :type="getTypeTag(row.type)" size="small">
                    {{ getTypeText(row.type) }}
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
              <el-table-column prop="description" label="操作描述" min-width="300" show-overflow-tooltip />
              <el-table-column prop="ip" label="IP地址" width="140" />
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
    CREATE: '创建',
    UPDATE: '更新',
    DELETE: '删除'
  }
  return map[type] || type
}

const getTypeTag = (type) => {
  const map = {
    LOGIN: 'success',
    LOGOUT: 'info',
    CREATE: 'primary',
    UPDATE: 'warning',
    DELETE: 'danger'
  }
  return map[type] || 'info'
}

const getModuleText = (module) => {
  const map = {
    USER: '用户',
    TEAM: '团队',
    TASK: '任务'
  }
  return map[module] || module
}

const getModuleTag = (module) => {
  const map = {
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
      params.operator = filterForm.value.operator
    }
    if (filterForm.value.type) {
      params.type = filterForm.value.type
    }
    if (filterForm.value.module) {
      params.module = filterForm.value.module
    }
    if (filterForm.value.dateRange && filterForm.value.dateRange.length === 2) {
      params.startDate = filterForm.value.dateRange[0]
      params.endDate = filterForm.value.dateRange[1]
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
