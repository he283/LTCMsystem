<template>
  <div class="home-container">
    <el-container>
      <el-header class="header">
        <div class="logo">
          <el-icon><Document /></el-icon>
          轻量任务协作管理系统
        </div>
        <div class="user-info">
          <el-popover
            placement="bottom-end"
            :width="380"
            trigger="click"
            v-model:visible="showNotificationPanel"
            popper-class="notification-popover"
            @show="openNotificationPanel"
          >
            <template #reference>
              <el-badge :value="notificationStore.unreadCount" :hidden="notificationStore.unreadCount === 0" class="notification-bell" :max="99">
                <el-icon size="22" class="bell-icon"><Bell /></el-icon>
              </el-badge>
            </template>
            <div class="notification-panel">
              <div class="notification-header">
                <span class="notification-title">通知消息</span>
                <div class="notification-actions">
                  <el-button type="primary" link size="small" @click="handleMarkAllNotificationsRead" :disabled="notificationStore.unreadCount === 0">
                    全部已读
                  </el-button>
                  <el-button type="danger" link size="small" @click="handleClearAllNotifications" :disabled="notificationStore.notifications.length === 0">
                    清除所有
                  </el-button>
                </div>
              </div>
              <div class="notification-list" v-loading="notificationStore.loading">
                <el-empty v-if="notificationStore.notifications.length === 0" description="暂无通知" :image-size="60" />
                <div
                  v-for="item in notificationStore.notifications"
                  :key="item.id"
                  class="notification-item"
                  :class="{ unread: !item.isRead }"
                  @click="handleMarkNotificationRead(item)"
                >
                  <div class="notification-item-header">
                    <el-tag :type="getNotificationTypeTag(item.type)" size="small">
                      {{ getNotificationTypeText(item.type) }}
                    </el-tag>
                    <span class="notification-time">{{ formatDate(item.createTime) }}</span>
                  </div>
                  <div class="notification-content">{{ item.content }}</div>
                </div>
              </div>
            </div>
          </el-popover>
          <el-dropdown @command="handleCommand">
            <span class="user-dropdown">
              <el-avatar :size="32" style="margin-right: 10px" />
              <span>{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</span>
              <el-icon class="el-icon--right"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item command="operationLog" v-if="userStore.userInfo?.role === 'ADMIN'">操作日志</el-dropdown-item>
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
            <el-menu-item index="plaza" @click="goPlaza">
              <el-icon><Reading /></el-icon>
              <span>任务广场</span>
            </el-menu-item>
            <el-menu-item index="dashboard">
              <el-icon><DataLine /></el-icon>
              <span>工作台</span>
            </el-menu-item>
            <el-menu-item index="task">
              <el-icon><List /></el-icon>
              <span>任务管理</span>
            </el-menu-item>
            <el-menu-item index="team">
              <el-icon><UserFilled /></el-icon>
              <span>团队管理</span>
            </el-menu-item>
          </el-menu>
        </el-aside>
        <el-main class="main">
          <div v-if="activeMenu === 'dashboard'">
            <h3 class="page-title">工作台</h3>
            <el-row :gutter="20" style="margin-top: 20px">
              <el-col :span="5">
                <el-card shadow="hover" class="stat-card" :body-style="{ padding: '20px' }">
                  <div class="stat-content">
                    <div class="stat-icon todo">
                      <el-icon size="30"><Clock /></el-icon>
                    </div>
                    <div class="stat-info">
                      <div class="stat-number">{{ stats.pending }}</div>
                      <div class="stat-label">待分配</div>
                    </div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="5">
                <el-card shadow="hover" class="stat-card" :body-style="{ padding: '20px' }">
                  <div class="stat-content">
                    <div class="stat-icon in-progress">
                      <el-icon size="30"><Loading /></el-icon>
                    </div>
                    <div class="stat-info">
                      <div class="stat-number">{{ stats.inProgress }}</div>
                      <div class="stat-label">进行中</div>
                    </div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="5">
                <el-card shadow="hover" class="stat-card" :body-style="{ padding: '20px' }">
                  <div class="stat-content">
                    <div class="stat-icon review">
                      <el-icon size="30"><Reading /></el-icon>
                    </div>
                    <div class="stat-info">
                      <div class="stat-number">{{ stats.review }}</div>
                      <div class="stat-label">待评审</div>
                    </div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="5">
                <el-card shadow="hover" class="stat-card" :body-style="{ padding: '20px' }">
                  <div class="stat-content">
                    <div class="stat-icon done">
                      <el-icon size="30"><CircleCheck /></el-icon>
                    </div>
                    <div class="stat-info">
                      <div class="stat-number">{{ stats.done }}</div>
                      <div class="stat-label">已完成</div>
                    </div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="4">
                <el-card shadow="hover" class="stat-card" :body-style="{ padding: '20px' }">
                  <div class="stat-content">
                    <div class="stat-icon cancelled">
                      <el-icon size="30"><Delete /></el-icon>
                    </div>
                    <div class="stat-info">
                      <div class="stat-number">{{ stats.cancelled }}</div>
                      <div class="stat-label">已取消</div>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>

            <el-card style="margin-top: 30px">
              <template #header>
                <div class="card-header">
                  <span>最近任务</span>
                  <el-button type="primary" size="small" @click="activeMenu = 'task'">查看全部</el-button>
                </div>
              </template>
              <el-empty v-if="recentTasks.length === 0" description="暂无任务" />
              <div v-else class="recent-tasks">
                <div class="task-item" v-for="task in recentTasks" :key="task.id">
                  <el-tag :type="getStatusType(task.status)" size="small" style="margin-right: 10px">
                    {{ getStatusText(task.status) }}
                  </el-tag>
                  <span class="task-title">{{ task.title }}</span>
                </div>
              </div>
            </el-card>
          </div>

          <div v-if="activeMenu === 'task'">
            <div class="page-header">
              <h3 class="page-title">任务管理</h3>
              <div class="page-actions">
                <el-select v-model="statusFilter" placeholder="状态筛选" clearable style="margin-right: 10px">
                  <el-option label="全部" value="" />
                  <el-option label="待分配" value="PENDING_ASSIGN" />
                  <el-option label="进行中" value="IN_PROGRESS" />
                  <el-option label="待评审" value="PENDING_REVIEW" />
                  <el-option label="已完成" value="DONE" />
                  <el-option label="已取消" value="CANCELLED" />
                </el-select>
                <el-select v-model="teamFilter" placeholder="团队筛选" clearable style="margin-right: 10px">
                  <el-option label="全部" :value="null" />
                  <el-option v-for="team in teamStore.teams" :key="team.id" :label="team.name" :value="team.id" />
                </el-select>
                <el-button type="primary" @click="showTaskDialog = true">
                  <el-icon><Plus /></el-icon>
                  新建任务
                </el-button>
              </div>
            </div>

            <el-card>
              <el-table
                v-loading="taskStore.loading"
                :data="filteredTasks"
                style="width: 100%"
                stripe
              >
                <el-table-column prop="taskCode" label="任务编号" width="130">
                  <template #default="{ row }">
                    <span class="task-code">{{ row.taskCode || '-' }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="title" label="标题" min-width="200" />
                <el-table-column prop="description" label="描述" min-width="250" show-overflow-tooltip />
                <el-table-column prop="status" label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag :type="getStatusType(row.status)">
                      {{ getStatusText(row.status) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="priority" label="优先级" width="100">
                  <template #default="{ row }">
                    <el-tag :type="getPriorityType(row.priority)">
                      {{ getPriorityText(row.priority) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="dueDate" label="截止日期" width="120">
                  <template #default="{ row }">
                    {{ row.dueDate ? formatDate(row.dueDate) : '-' }}
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="260" fixed="right">
                  <template #default="{ row }">
                    <el-button size="small" type="primary" link @click="viewChangeLogs(row)">
                      <el-icon><Tickets /></el-icon>
                      变更
                    </el-button>
                    <el-button size="small" @click="editTask(row)">
                      <el-icon><Edit /></el-icon>
                      编辑
                    </el-button>
                    <el-button size="small" type="danger" @click="removeTaskItem(row.id)">
                      <el-icon><Delete /></el-icon>
                      删除
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="filteredTasks.length === 0 && !taskStore.loading" description="暂无任务" />
            </el-card>
          </div>

          <div v-if="activeMenu === 'team' && !selectedTeam">
            <div class="page-header">
              <h3 class="page-title">团队管理</h3>
              <div class="page-actions">
                <el-button type="primary" @click="showJoinTeamDialog = true" style="margin-right: 10px">
                  <el-icon><Connection /></el-icon>
                  加入团队
                </el-button>
                <el-button type="primary" @click="showTeamDialog = true">
                  <el-icon><Plus /></el-icon>
                  新建团队
                </el-button>
              </div>
            </div>

            <el-row :gutter="20" class="team-grid">
              <el-col :span="8" v-for="team in teamStore.teams" :key="team.id">
                <el-card shadow="hover" class="team-card" @click="selectTeam(team)">
                  <template #header>
                    <div class="team-header">
                      <span class="team-name">{{ team.name }}</span>
                      <el-tag type="success" size="small">我的团队</el-tag>
                    </div>
                  </template>
                  <div class="team-code-row">
                    <el-tag type="info" size="small">编号: {{ team.teamCode || '-' }}</el-tag>
                  </div>
                  <p class="team-desc">{{ team.description || '暂无描述' }}</p>
                  <div class="team-footer">
                    <span class="team-members">
                      <el-icon><User /></el-icon>
                      创建人: {{ team.creatorNickname || team.creatorName || team.creatorId }}
                    </span>
                  </div>
                </el-card>
              </el-col>
              <el-empty v-if="teamStore.teams.length === 0 && !teamStore.loading" description="暂无团队" style="width: 100%" />
            </el-row>
          </div>

          <div v-if="activeMenu === 'team' && selectedTeam">
            <div class="page-header">
              <el-breadcrumb separator="/" style="margin-bottom: 15px">
                <el-breadcrumb-item @click="backToTeamList">团队管理</el-breadcrumb-item>
                <el-breadcrumb-item>{{ selectedTeam.name }}</el-breadcrumb-item>
              </el-breadcrumb>
              <div class="team-detail-header">
                <div>
                  <h3 class="page-title" style="display: inline; margin-right: 10px">{{ selectedTeam.name }}</h3>
                  <el-tag type="info" size="small">编号: {{ selectedTeam.teamCode || '-' }}</el-tag>
                </div>
                <div class="page-actions">
                  <el-button @click="showLeaveTeamDialog = true" v-if="!isTeamCreator">
                    <el-icon><SwitchButton /></el-icon>
                    退出团队
                  </el-button>
                  <el-button type="danger" @click="confirmDeleteTeam" v-if="isTeamCreator">
                    <el-icon><Delete /></el-icon>
                    解散团队
                  </el-button>
                </div>
              </div>
            </div>

            <el-tabs v-model="teamTab" @tab-change="handleTeamTabChange">
              <el-tab-pane label="成员任务进度" name="stats">
                <el-row :gutter="20">
                  <el-col :span="24">
                    <el-card>
                      <el-table :data="teamMemberStats" v-loading="loadingStats" stripe>
                        <el-table-column prop="nickname" label="成员" width="120">
                          <template #default="{ row }">
                            {{ row.nickname || row.username }}
                          </template>
                        </el-table-column>
                        <el-table-column prop="totalTasks" label="总任务" width="80" />
                        <el-table-column label="任务分布" width="250">
                          <template #default="{ row }">
                            <div class="task-progress">
                              <span class="progress-tag todo">{{ row.todoTasks }} 待办</span>
                              <span class="progress-tag in-progress">{{ row.inProgressTasks }} 进行中</span>
                              <span class="progress-tag done">{{ row.doneTasks }} 完成</span>
                            </div>
                          </template>
                        </el-table-column>
                        <el-table-column prop="completionRate" label="完成率" width="150">
                          <template #default="{ row }">
                            <el-progress :percentage="Math.round(row.completionRate)" :color="getProgressColor(row.completionRate)" />
                          </template>
                        </el-table-column>
                      </el-table>
                    </el-card>
                  </el-col>
                </el-row>
              </el-tab-pane>

              <el-tab-pane label="团队成员" name="members">
                <el-row :gutter="20" style="margin-top: 0">
                  <el-col :span="24">
                    <el-card>
                      <template #header>
                        <div class="card-header">
                          <span>团队成员</span>
                          <el-button type="primary" size="small" @click="showInviteDialog = true" v-if="isTeamAdmin">
                            <el-icon><UserFilled /></el-icon>
                            邀请成员
                          </el-button>
                        </div>
                      </template>
                      <el-table :data="teamMembers" stripe>
                        <el-table-column prop="username" label="用户名" width="120" />
                        <el-table-column prop="nickname" label="昵称" width="120" />
                        <el-table-column prop="role" label="角色" width="100">
                          <template #default="{ row }">
                            <el-tag :type="row.role === 'ADMIN' ? 'danger' : 'info'">
                              {{ row.role === 'ADMIN' ? '管理员' : '成员' }}
                            </el-tag>
                          </template>
                        </el-table-column>
                        <el-table-column prop="joinTime" label="加入时间" width="180">
                          <template #default="{ row }">
                            {{ formatDate(row.joinTime) }}
                          </template>
                        </el-table-column>
                        <el-table-column label="操作" width="120" v-if="isTeamAdmin">
                          <template #default="{ row }">
                            <el-button 
                              size="small" 
                              type="danger" 
                              @click="confirmRemoveMember(row.userId)"
                              :disabled="row.userId === userStore.userInfo?.id"
                            >
                              移除
                            </el-button>
                          </template>
                        </el-table-column>
                      </el-table>
                    </el-card>
                  </el-col>
                </el-row>
              </el-tab-pane>

              <el-tab-pane label="审批管理" name="applications" v-if="isTeamAdmin">
                <el-row :gutter="20" style="margin-top: 0">
                  <el-col :span="24">
                    <el-card>
                      <template #header>
                        <div class="card-header">
                          <span>待审批申请</span>
                        </div>
                      </template>
                      <el-table :data="teamApplications" v-loading="loadingApplications" stripe>
                        <el-table-column prop="type" label="类型" width="100">
                          <template #default="{ row }">
                            <el-tag :type="getApplicationTypeTag(row.type)" size="small">
                              {{ getApplicationTypeText(row.type) }}
                            </el-tag>
                          </template>
                        </el-table-column>
                        <el-table-column prop="applicantName" label="申请人" width="120" />
                        <el-table-column prop="reason" label="申请原因" min-width="200" show-overflow-tooltip />
                        <el-table-column prop="status" label="状态" width="100">
                          <template #default="{ row }">
                            <el-tag :type="getApplicationStatusTag(row.status)" size="small">
                              {{ getApplicationStatusText(row.status) }}
                            </el-tag>
                          </template>
                        </el-table-column>
                        <el-table-column prop="createTime" label="申请时间" width="180">
                          <template #default="{ row }">
                            {{ formatDate(row.createTime) }}
                          </template>
                        </el-table-column>
                        <el-table-column label="操作" width="160" fixed="right">
                          <template #default="{ row }">
                            <el-button 
                              size="small" 
                              type="success" 
                              @click="handleApplication(row, 'approve')"
                              :disabled="row.status !== 'PENDING'"
                            >
                              <el-icon><Check /></el-icon>
                              通过
                            </el-button>
                            <el-button 
                              size="small" 
                              type="danger" 
                              @click="handleApplication(row, 'reject')"
                              :disabled="row.status !== 'PENDING'"
                            >
                              <el-icon><Close /></el-icon>
                              拒绝
                            </el-button>
                          </template>
                        </el-table-column>
                      </el-table>
                      <el-empty v-if="teamApplications.length === 0 && !loadingApplications" description="暂无待审批申请" />
                    </el-card>
                  </el-col>
                </el-row>
              </el-tab-pane>

              <el-tab-pane label="团队任务" name="tasks">
                <el-row :gutter="20" style="margin-top: 0">
                  <el-col :span="24">
                    <el-card>
                      <template #header>
                        <div class="card-header">
                          <span>团队任务</span>
                          <el-button type="primary" size="small" @click="showTaskDialog = true; taskForm.teamId = selectedTeam.id">
                            <el-icon><Plus /></el-icon>
                            新建任务
                          </el-button>
                        </div>
                      </template>
                      <el-table :data="teamTasks" stripe>
                        <el-table-column prop="taskCode" label="任务编号" width="120">
                          <template #default="{ row }">
                            <span class="task-code">{{ row.taskCode || '-' }}</span>
                          </template>
                        </el-table-column>
                        <el-table-column prop="title" label="标题" min-width="200" />
                        <el-table-column prop="status" label="状态" width="100">
                          <template #default="{ row }">
                            <el-tag :type="getStatusType(row.status)">
                              {{ getStatusText(row.status) }}
                            </el-tag>
                          </template>
                        </el-table-column>
                        <el-table-column prop="priority" label="优先级" width="100">
                          <template #default="{ row }">
                            <el-tag :type="getPriorityType(row.priority)">
                              {{ getPriorityText(row.priority) }}
                            </el-tag>
                          </template>
                        </el-table-column>
                        <el-table-column prop="dueDate" label="截止日期" width="120">
                          <template #default="{ row }">
                            {{ row.dueDate ? formatDate(row.dueDate) : '-' }}
                          </template>
                        </el-table-column>
                        <el-table-column label="操作" width="240">
                          <template #default="{ row }">
                            <el-button size="small" type="primary" link @click="viewChangeLogs(row)">
                              <el-icon><Tickets /></el-icon>
                              变更
                            </el-button>
                            <el-button size="small" @click="editTask(row)">编辑</el-button>
                            <el-button size="small" type="danger" @click="removeTaskItem(row.id)">删除</el-button>
                          </template>
                        </el-table-column>
                      </el-table>
                    </el-card>
                  </el-col>
                </el-row>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-main>
      </el-container>
    </el-container>

    <!-- 任务对话框 -->
    <el-dialog
      v-model="showTaskDialog"
      :title="editingTask ? '编辑任务' : '新建任务'"
      width="500px"
      destroy-on-close
    >
      <el-form :model="taskForm" :rules="taskRules" ref="taskFormRef" label-width="80px">
        <el-form-item label="任务编号" v-if="editingTask">
          <span class="task-code">{{ editingTask.taskCode || '-' }}</span>
        </el-form-item>
        <el-form-item label="标题" prop="title">
          <el-input v-model="taskForm.title" placeholder="请输入任务标题" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="taskForm.description" type="textarea" :rows="3" placeholder="请输入任务描述" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="taskForm.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="待分配" value="PENDING_ASSIGN" />
            <el-option label="进行中" value="IN_PROGRESS" />
            <el-option label="待评审" value="PENDING_REVIEW" />
            <el-option label="已完成" value="DONE" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="taskForm.priority" placeholder="请选择优先级" style="width: 100%">
            <el-option label="低" value="LOW" />
            <el-option label="中" value="MEDIUM" />
            <el-option label="高" value="HIGH" />
          </el-select>
        </el-form-item>
        <el-form-item label="截止日期" prop="dueDate">
          <el-date-picker
            v-model="taskForm.dueDate"
            type="date"
            placeholder="选择日期"
            style="width: 100%"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="分配给" prop="assigneeId" v-if="taskForm.teamId">
          <el-select v-model="taskForm.assigneeId" placeholder="请选择成员" clearable style="width: 100%">
            <el-option 
              v-for="member in teamMembers" 
              :key="member.userId" 
              :label="member.nickname || member.username" 
              :value="member.userId" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="公开到广场" v-if="canTogglePublic && taskForm.teamId">
          <el-switch v-model="taskForm.isPublic" :active-value="1" :inactive-value="0" />
          <div style="font-size: 12px; color: #909399; margin-top: 4px">公开后，所有人可在任务广场看到此任务</div>
        </el-form-item>
        <el-form-item label="公开简介" v-if="canTogglePublic && taskForm.teamId && taskForm.isPublic === 1" prop="publicDesc">
          <el-input v-model="taskForm.publicDesc" type="textarea" :rows="2" placeholder="请输入对外展示的公开简介" maxlength="200" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button v-if="editingTask" type="primary" link @click="viewChangeLogs(editingTask)">
          <el-icon><History /></el-icon>
          变更历史
        </el-button>
        <span style="flex: 1"></span>
        <el-button @click="showTaskDialog = false">取消</el-button>
        <el-button type="primary" @click="saveTask" :loading="saving">保存</el-button>
      </template>
    </el-dialog>

    <!-- 团队对话框 -->
    <el-dialog
      v-model="showTeamDialog"
      title="新建团队"
      width="500px"
      destroy-on-close
    >
      <el-form :model="teamForm" :rules="teamRules" ref="teamFormRef" label-width="80px">
        <el-form-item label="团队名称" prop="name">
          <el-input v-model="teamForm.name" placeholder="请输入团队名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="teamForm.description" type="textarea" :rows="3" placeholder="请输入团队描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showTeamDialog = false">取消</el-button>
        <el-button type="primary" @click="saveTeam" :loading="saving">保存</el-button>
      </template>
    </el-dialog>

    <!-- 加入团队对话框 -->
    <el-dialog
      v-model="showJoinTeamDialog"
      title="加入团队"
      width="500px"
      destroy-on-close
    >
      <el-form :model="joinTeamForm" :rules="joinTeamRules" ref="joinTeamFormRef" label-width="80px">
        <el-form-item label="团队编号" prop="teamCode">
          <el-input v-model="joinTeamForm.teamCode" placeholder="请输入团队编号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showJoinTeamDialog = false">取消</el-button>
        <el-button type="primary" @click="handleJoinTeam" :loading="saving">申请加入</el-button>
      </template>
    </el-dialog>

    <!-- 退出团队对话框 -->
    <el-dialog
      v-model="showLeaveTeamDialog"
      title="退出团队"
      width="500px"
      destroy-on-close
    >
      <el-form :model="leaveTeamForm" :rules="leaveTeamRules" ref="leaveTeamFormRef" label-width="80px">
        <el-form-item label="退出原因" prop="reason">
          <el-input v-model="leaveTeamForm.reason" type="textarea" :rows="3" placeholder="请输入退出原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showLeaveTeamDialog = false">取消</el-button>
        <el-button type="danger" @click="handleLeaveTeam" :loading="saving">确认退出</el-button>
      </template>
    </el-dialog>

    <!-- 变更历史弹窗 -->
    <el-dialog
      v-model="showChangeLogDialog"
      title="任务变更历史"
      width="700px"
      destroy-on-close
    >
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
      <template #footer>
        <el-button @click="showChangeLogDialog = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 邀请成员对话框 -->
    <el-dialog
      v-model="showInviteDialog"
      title="邀请成员"
      width="500px"
      destroy-on-close
    >
      <el-form :model="inviteForm" :rules="inviteRules" ref="inviteFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="inviteForm.username" placeholder="请输入要邀请的用户用户名" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showInviteDialog = false">取消</el-button>
        <el-button type="primary" @click="handleInviteMember" :loading="saving">邀请</el-button>
      </template>
    </el-dialog>

    <!-- 个人中心对话框 -->
    <el-dialog
      v-model="showProfileDialog"
      title="个人中心"
      width="600px"
      destroy-on-close
    >
      <el-tabs v-model="activeProfileTab">
        <el-tab-pane label="个人信息" name="info">
          <el-descriptions :column="1" border style="margin-bottom: 20px">
            <el-descriptions-item label="用户名">
              {{ userStore.userInfo?.username }}
            </el-descriptions-item>
            <el-descriptions-item label="注册时间">
              {{ userStore.userInfo?.createTime ? formatDate(userStore.userInfo.createTime) : '-' }}
            </el-descriptions-item>
          </el-descriptions>
          <el-form :model="profileForm" :rules="profileRules" ref="profileFormRef" label-width="80px">
            <el-form-item label="昵称" prop="nickname">
              <el-input v-model="profileForm.nickname" placeholder="请输入昵称" />
            </el-form-item>
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="profileForm.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="修改密码" name="password">
          <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="80px">
            <el-form-item label="旧密码" prop="oldPassword">
              <el-input v-model="passwordForm.oldPassword" type="password" placeholder="请输入旧密码" show-password />
            </el-form-item>
            <el-form-item label="新密码" prop="newPassword">
              <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码（至少6位）" show-password />
            </el-form-item>
            <el-form-item label="确认密码" prop="confirmPassword">
              <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请再次输入新密码" show-password />
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
      <template #footer>
        <div style="display: flex; justify-content: flex-end; gap: 10px">
          <el-button @click="showProfileDialog = false">取消</el-button>
          <el-button 
            v-if="activeProfileTab === 'info'" 
            type="primary" 
            @click="saveProfile" 
            :loading="savingProfile"
          >
            保存
          </el-button>
          <el-button 
            v-if="activeProfileTab === 'password'" 
            type="primary" 
            @click="savePassword" 
            :loading="savingPassword"
          >
            修改密码
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'
import {
  Document, ArrowDown, DataLine, List, UserFilled,
  Clock, Loading, CircleCheck, Plus, Edit, Delete,
  User, Connection, Reading, Bell, Tickets,
  SwitchButton, Check, Close
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { useTaskStore } from '@/stores/task'
import { useTeamStore } from '@/stores/team'
import { useNotificationStore } from '@/stores/notification'
import {
  getTeamMembers, getTeamTasks, getTeamMemberStats, deleteTeam, inviteMember, removeMember, toggleTaskPublic,
  applyJoinTeam, applyLeaveTeam, getTeamApplications, handleTeamApplication,
  getTaskChangeLogs
} from '@/api'

const router = useRouter()
const userStore = useUserStore()
const taskStore = useTaskStore()
const teamStore = useTeamStore()
const notificationStore = useNotificationStore()

const activeMenu = ref('dashboard')
const statusFilter = ref('')
const teamFilter = ref(null)
const showTaskDialog = ref(false)
const showTeamDialog = ref(false)
const showJoinTeamDialog = ref(false)
const showInviteDialog = ref(false)
const showChangeLogDialog = ref(false)
const showNotificationPanel = ref(false)
const showLeaveTeamDialog = ref(false)
const editingTask = ref(null)
const saving = ref(false)
const selectedTeam = ref(null)
const teamTab = ref('members')
const teamMembers = ref([])
const teamMemberStats = ref([])
const teamTasks = ref([])
const loadingStats = ref(false)
const changeLogs = ref([])
const loadingChangeLogs = ref(false)
const teamApplications = ref([])
const loadingApplications = ref(false)

const taskFormRef = ref(null)
const teamFormRef = ref(null)
const joinTeamFormRef = ref(null)
const leaveTeamFormRef = ref(null)
const inviteFormRef = ref(null)

const taskForm = ref({
  title: '',
  description: '',
  status: 'PENDING_ASSIGN',
  priority: 'MEDIUM',
  dueDate: '',
  assigneeId: null,
  teamId: null,
  isPublic: 0,
  publicDesc: ''
})

const teamForm = ref({
  name: '',
  description: ''
})

const joinTeamForm = ref({
  teamCode: ''
})

const leaveTeamForm = ref({
  reason: ''
})

const inviteForm = ref({
  username: ''
})

const taskRules = {
  title: [{ required: true, message: '请输入任务标题', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
  priority: [{ required: true, message: '请选择优先级', trigger: 'change' }]
}

const teamRules = {
  name: [{ required: true, message: '请输入团队名称', trigger: 'blur' }]
}

const joinTeamRules = {
  teamCode: [{ required: true, message: '请输入团队编号', trigger: 'blur' }]
}

const leaveTeamRules = {
  reason: [{ required: true, message: '请输入退出原因', trigger: 'blur' }]
}

const inviteRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }]
}

const stats = computed(() => {
  const pending = taskStore.tasks.filter(t => t.status === 'PENDING_ASSIGN').length
  const inProgress = taskStore.tasks.filter(t => t.status === 'IN_PROGRESS').length
  const review = taskStore.tasks.filter(t => t.status === 'PENDING_REVIEW').length
  const done = taskStore.tasks.filter(t => t.status === 'DONE').length
  const cancelled = taskStore.tasks.filter(t => t.status === 'CANCELLED').length
  return { pending, inProgress, review, done, cancelled }
})

const recentTasks = computed(() => {
  return [...taskStore.tasks].slice(0, 5)
})

const filteredTasks = computed(() => {
  let tasks = taskStore.tasks
  if (statusFilter.value) {
    tasks = tasks.filter(t => t.status === statusFilter.value)
  }
  if (teamFilter.value) {
    tasks = tasks.filter(t => t.teamId === teamFilter.value)
  }
  return tasks
})

const isTeamAdmin = computed(() => {
  if (!selectedTeam.value || !userStore.userInfo) return false
  return selectedTeam.value.creatorId === userStore.userInfo.id ||
    teamMembers.value.some(m => m.userId === userStore.userInfo.id && m.role === 'ADMIN')
})

const canTogglePublic = computed(() => {
  if (!selectedTeam.value || !userStore.userInfo) return false
  return selectedTeam.value.creatorId === userStore.userInfo.id ||
    teamMembers.value.some(m => m.userId === userStore.userInfo.id && m.role === 'ADMIN')
})

const getStatusType = (status) => {
  const map = {
    PENDING_ASSIGN: 'info',
    IN_PROGRESS: 'warning',
    PENDING_REVIEW: 'primary',
    DONE: 'success',
    CANCELLED: 'danger'
  }
  return map[status] || 'info'
}

const getStatusText = (status) => {
  const map = {
    PENDING_ASSIGN: '待分配',
    IN_PROGRESS: '进行中',
    PENDING_REVIEW: '待评审',
    DONE: '已完成',
    CANCELLED: '已取消'
  }
  return map[status] || status
}

const getPriorityType = (priority) => {
  const map = {
    LOW: 'info',
    MEDIUM: 'warning',
    HIGH: 'danger'
  }
  return map[priority] || 'info'
}

const getPriorityText = (priority) => {
  const map = {
    LOW: '低',
    MEDIUM: '中',
    HIGH: '高'
  }
  return map[priority] || priority
}

const getProgressColor = (percentage) => {
  if (percentage >= 80) return '#67c23a'
  if (percentage >= 50) return '#e6a23c'
  return '#409eff'
}

const formatDate = (date) => {
  if (!date) return '-'
  return dayjs(date).format('YYYY-MM-DD HH:mm')
}

const getNotificationTypeText = (type) => {
  const map = {
    SYSTEM: '系统通知',
    TASK: '任务通知',
    TEAM_APPLY: '团队申请',
    APPROVAL: '审批结果'
  }
  return map[type] || type
}

const getNotificationTypeTag = (type) => {
  const map = {
    SYSTEM: 'primary',
    TASK: 'success',
    TEAM_APPLY: 'warning',
    APPROVAL: 'info'
  }
  return map[type] || 'info'
}

const getApplicationTypeText = (type) => {
  const map = {
    JOIN: '加入申请',
    LEAVE: '退出申请'
  }
  return map[type] || type
}

const getApplicationTypeTag = (type) => {
  const map = {
    JOIN: 'primary',
    LEAVE: 'warning'
  }
  return map[type] || 'info'
}

const getApplicationStatusText = (status) => {
  const map = {
    PENDING: '待审批',
    APPROVED: '已通过',
    REJECTED: '已拒绝'
  }
  return map[status] || status
}

const getApplicationStatusTag = (status) => {
  const map = {
    PENDING: 'warning',
    APPROVED: 'success',
    REJECTED: 'danger'
  }
  return map[status] || 'info'
}

const loadData = async () => {
  try {
    await Promise.all([
      userStore.fetchUserInfo(),
      taskStore.fetchTasks(),
      teamStore.fetchTeams(),
      notificationStore.fetchUnreadCount()
    ])
  } catch (error) {
    console.error('加载数据失败:', error)
  }
}

const handleSelect = (index) => {
  if (index === 'plaza') {
    goPlaza()
    return
  }
  activeMenu.value = index
  if (index === 'team') {
    selectedTeam.value = null
  }
}

const goPlaza = () => {
  router.push('/plaza')
}

const showProfileDialog = ref(false)
const activeProfileTab = ref('info')
const profileFormRef = ref(null)
const passwordFormRef = ref(null)
const savingProfile = ref(false)
const savingPassword = ref(false)

const profileForm = ref({
  nickname: '',
  email: ''
})

const passwordForm = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== passwordForm.value.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const profileRules = {
  nickname: [{ required: true, message: '请输入昵称', trigger: 'blur' }]
}

const passwordRules = {
  oldPassword: [{ required: true, message: '请输入旧密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少 6 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      userStore.logout()
      ElMessage.success('退出成功')
      router.push('/login')
    } catch {
      // 用户取消
    }
  } else if (command === 'profile') {
    openProfileDialog()
  } else if (command === 'operationLog') {
    router.push('/operation-log')
  }
}

const openProfileDialog = () => {
  if (userStore.userInfo) {
    profileForm.value.nickname = userStore.userInfo.nickname || ''
    profileForm.value.email = userStore.userInfo.email || ''
  }
  passwordForm.value = {
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
  }
  activeProfileTab.value = 'info'
  showProfileDialog.value = true
}

const saveProfile = async () => {
  if (!profileFormRef.value) return
  await profileFormRef.value.validate(async (valid) => {
    if (valid) {
      savingProfile.value = true
      try {
        await userStore.updateUserProfile(profileForm.value)
        ElMessage.success('保存成功')
        showProfileDialog.value = false
      } catch (error) {
        console.error('保存失败:', error)
      } finally {
        savingProfile.value = false
      }
    }
  })
}

const savePassword = async () => {
  if (!passwordFormRef.value) return
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      savingPassword.value = true
      try {
        await userStore.updateUserPassword({
          oldPassword: passwordForm.value.oldPassword,
          newPassword: passwordForm.value.newPassword
        })
        ElMessage.success('密码修改成功，请重新登录')
        showProfileDialog.value = false
        userStore.logout()
        router.push('/login')
      } catch (error) {
        console.error('修改密码失败:', error)
      } finally {
        savingPassword.value = false
      }
    }
  })
}

const selectTeam = async (team) => {
  selectedTeam.value = team
  teamTab.value = 'members'
  await loadTeamData(team.id)
}

const backToTeamList = () => {
  selectedTeam.value = null
  teamTab.value = 'members'
  teamMembers.value = []
  teamMemberStats.value = []
  teamTasks.value = []
  teamApplications.value = []
}

const handleTeamTabChange = async (tab) => {
  if (tab === 'applications' && isTeamAdmin.value) {
    await loadTeamApplications()
  }
}

const loadTeamData = async (teamId) => {
  try {
    const [membersRes, tasksRes, statsRes] = await Promise.all([
      getTeamMembers(teamId),
      getTeamTasks(teamId),
      getTeamMemberStats(teamId)
    ])
    teamMembers.value = membersRes.data || []
    teamTasks.value = tasksRes.data || []
    teamMemberStats.value = statsRes.data || []
  } catch (error) {
    console.error('加载团队数据失败:', error)
  }
}

const editTask = (task) => {
  editingTask.value = task
  taskForm.value = {
    title: task.title,
    description: task.description || '',
    status: task.status,
    priority: task.priority,
    dueDate: task.dueDate || '',
    assigneeId: task.assigneeId || null,
    teamId: task.teamId || null,
    isPublic: task.isPublic || 0,
    publicDesc: task.publicDesc || ''
  }
  showTaskDialog.value = true
}

const saveTask = async () => {
  if (!taskFormRef.value) return
  await taskFormRef.value.validate(async (valid) => {
    if (valid) {
      saving.value = true
      try {
        let taskId
        if (editingTask.value) {
          await taskStore.editTask(editingTask.value.id, taskForm.value)
          taskId = editingTask.value.id
          ElMessage.success('更新成功')
        } else {
          const newTask = await taskStore.addTask(taskForm.value)
          taskId = newTask.id
          ElMessage.success('创建成功')
        }
        
        if (taskForm.value.teamId && canTogglePublic.value) {
          await toggleTaskPublic(taskId, {
            isPublic: taskForm.value.isPublic,
            publicDesc: taskForm.value.publicDesc
          })
        }
        
        showTaskDialog.value = false
        resetTaskForm()
        if (selectedTeam.value) {
          await loadTeamData(selectedTeam.value.id)
        }
      } catch (error) {
        ElMessage.error(error.response?.data?.message || '操作失败')
      } finally {
        saving.value = false
      }
    }
  })
}

const resetTaskForm = () => {
  editingTask.value = null
  taskForm.value = {
    title: '',
    description: '',
    status: 'PENDING_ASSIGN',
    priority: 'MEDIUM',
    dueDate: '',
    assigneeId: null,
    teamId: null,
    isPublic: 0,
    publicDesc: ''
  }
  if (taskFormRef.value) {
    taskFormRef.value.resetFields()
  }
}

const removeTaskItem = async (id) => {
  try {
    await ElMessageBox.confirm('确定要删除这个任务吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await taskStore.removeTask(id)
    ElMessage.success('删除成功')
    if (selectedTeam.value) {
      await loadTeamData(selectedTeam.value.id)
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.response?.data?.message || '删除失败')
    }
  }
}

const saveTeam = async () => {
  if (!teamFormRef.value) return
  await teamFormRef.value.validate(async (valid) => {
    if (valid) {
      saving.value = true
      try {
        await teamStore.addTeam(teamForm.value)
        ElMessage.success('创建成功')
        showTeamDialog.value = false
        resetTeamForm()
      } catch (error) {
        ElMessage.error(error.response?.data?.message || '创建失败')
      } finally {
        saving.value = false
      }
    }
  })
}

const resetTeamForm = () => {
  teamForm.value = { name: '', description: '' }
  if (teamFormRef.value) {
    teamFormRef.value.resetFields()
  }
}

const handleJoinTeam = async () => {
  if (!joinTeamFormRef.value) return
  await joinTeamFormRef.value.validate(async (valid) => {
    if (valid) {
      saving.value = true
      try {
        await applyJoinTeam({ teamCode: joinTeamForm.value.teamCode, applyType: 'JOIN' })
        ElMessage.success('申请已提交，等待管理员审批')
        showJoinTeamDialog.value = false
        joinTeamForm.value = { teamCode: '' }
        if (joinTeamFormRef.value) {
          joinTeamFormRef.value.resetFields()
        }
      } catch (error) {
        ElMessage.error(error.response?.data?.message || '申请失败')
      } finally {
        saving.value = false
      }
    }
  })
}

const handleLeaveTeam = async () => {
  if (!leaveTeamFormRef.value) return
  await leaveTeamFormRef.value.validate(async (valid) => {
    if (valid) {
      saving.value = true
      try {
        await applyLeaveTeam({
          teamId: selectedTeam.value.id,
          applyType: 'LEAVE',
          applyReason: leaveTeamForm.value.reason
        })
        ElMessage.success('退出申请已提交，等待审批')
        showLeaveTeamDialog.value = false
        leaveTeamForm.value = { reason: '' }
        if (leaveTeamFormRef.value) {
          leaveTeamFormRef.value.resetFields()
        }
        backToTeamList()
        await teamStore.fetchTeams()
      } catch (error) {
        ElMessage.error(error.response?.data?.message || '申请失败')
      } finally {
        saving.value = false
      }
    }
  })
}

const isTeamCreator = computed(() => {
  if (!selectedTeam.value || !userStore.userInfo) return false
  return selectedTeam.value.creatorId === userStore.userInfo.id
})

const loadTeamApplications = async () => {
  if (!selectedTeam.value || !isTeamAdmin.value) return
  loadingApplications.value = true
  try {
    const res = await getTeamApplications({
      teamId: selectedTeam.value.id,
      status: 'PENDING'
    })
    teamApplications.value = res.data?.records || res.data?.list || res.data || []
  } catch (error) {
    console.error('加载团队申请失败:', error)
  } finally {
    loadingApplications.value = false
  }
}

const handleApplication = async (application, action) => {
  try {
    await handleTeamApplication(application.id, {
      status: action === 'approve' ? 'APPROVED' : 'REJECTED'
    })
    ElMessage.success(action === 'approve' ? '已通过' : '已拒绝')
    await loadTeamApplications()
  } catch (error) {
    ElMessage.error(error.response?.data?.message || '操作失败')
  }
}

const viewChangeLogs = async (task) => {
  showChangeLogDialog.value = true
  loadingChangeLogs.value = true
  changeLogs.value = []
  try {
    const res = await getTaskChangeLogs(task.id)
    changeLogs.value = res.data?.records || res.data?.list || res.data || []
  } catch (error) {
    console.error('加载变更历史失败:', error)
    ElMessage.error('加载变更历史失败')
  } finally {
    loadingChangeLogs.value = false
  }
}

const openNotificationPanel = async () => {
  showNotificationPanel.value = true
  await notificationStore.fetchNotifications({ pageSize: 20 })
}

const handleMarkNotificationRead = async (notification) => {
  if (notification.isRead) return
  await notificationStore.markAsRead(notification.id)
}

const handleMarkAllNotificationsRead = async () => {
  await notificationStore.markAllAsRead()
  ElMessage.success('已全部标记为已读')
}

const handleClearAllNotifications = async () => {
  try {
    await ElMessageBox.confirm('确定要清除所有通知消息吗？此操作不可恢复！', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await notificationStore.clearAll()
    ElMessage.success('已清除所有消息')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('清除所有消息失败:', error)
    }
  }
}

const confirmDeleteTeam = async () => {
  try {
    await ElMessageBox.confirm('确定要解散这个团队吗？此操作不可恢复！', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteTeam(selectedTeam.value.id)
    ElMessage.success('团队已解散')
    await teamStore.fetchTeams()
    backToTeamList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.response?.data?.message || '操作失败')
    }
  }
}

const handleInviteMember = async () => {
  if (!inviteFormRef.value) return
  await inviteFormRef.value.validate(async (valid) => {
    if (valid) {
      saving.value = true
      try {
        await inviteMember(selectedTeam.value.id, inviteForm.value)
        ElMessage.success('邀请成功')
        showInviteDialog.value = false
        inviteForm.value = { username: '' }
        if (inviteFormRef.value) {
          inviteFormRef.value.resetFields()
        }
        await loadTeamData(selectedTeam.value.id)
      } catch (error) {
        ElMessage.error(error.response?.data?.message || '邀请失败')
      } finally {
        saving.value = false
      }
    }
  })
}

const confirmRemoveMember = async (memberId) => {
  try {
    await ElMessageBox.confirm('确定要移除这个成员吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await removeMember(selectedTeam.value.id, memberId)
    ElMessage.success('移除成功')
    await loadTeamData(selectedTeam.value.id)
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.response?.data?.message || '操作失败')
    }
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.home-container {
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
}

.user-dropdown {
  cursor: pointer;
  display: flex;
  align-items: center;
}
/* 新增：修改用户昵称文字颜色 */
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

.team-detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.page-actions {
  display: flex;
  align-items: center;
}

.stat-card {
  border-radius: 8px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon.todo {
  background-color: #ecf5ff;
  color: #409eff;
}

.stat-icon.in-progress {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.stat-icon.done {
  background-color: #f0f9eb;
  color: #67c23a;
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
  line-height: 1.2;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 4px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.recent-tasks {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item {
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 6px;
  display: flex;
  align-items: center;
}

.task-title {
  flex: 1;
  color: #303133;
}

.team-grid {
  margin-top: 0;
}

.team-card {
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.team-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.team-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.team-name {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.team-desc {
  color: #606266;
  margin: 0 0 16px 0;
  min-height: 44px;
}

.team-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #ebeef5;
  color: #909399;
  font-size: 13px;
}

.team-members {
  display: flex;
  align-items: center;
  gap: 4px;
}

.task-progress {
  display: flex;
  gap: 8px;
}

.progress-tag {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.progress-tag.todo {
  background-color: #ecf5ff;
  color: #409eff;
}

.progress-tag.in-progress {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.progress-tag.done {
  background-color: #f0f9eb;
  color: #67c23a;
}

.stat-icon.review {
  background-color: #ecf5ff;
  color: #409eff;
}

.stat-icon.cancelled {
  background-color: #fef0f0;
  color: #f56c6c;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.notification-bell {
  cursor: pointer;
  color: white;
}

.bell-icon {
  vertical-align: middle;
}

.task-code {
  color: #909399;
  font-family: monospace;
  font-size: 13px;
}

.team-code-row {
  margin-bottom: 10px;
}
</style>

<style>
.notification-popover {
  padding: 0 !important;
}

.notification-panel {
  max-height: 450px;
  display: flex;
  flex-direction: column;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #ebeef5;
}

.notification-actions {
  display: flex;
  gap: 8px;
}

.notification-title {
  font-weight: 600;
  font-size: 14px;
  color: #303133;
}

.notification-list {
  flex: 1;
  overflow-y: auto;
  max-height: 380px;
}

.notification-item {
  padding: 12px 16px;
  border-bottom: 1px solid #f5f7fa;
  cursor: pointer;
  transition: background-color 0.2s;
}

.notification-item:hover {
  background-color: #f5f7fa;
}

.notification-item.unread {
  background-color: #ecf5ff;
}

.notification-item.unread:hover {
  background-color: #d9ecff;
}

.notification-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.notification-time {
  font-size: 12px;
  color: #909399;
}

.notification-content {
  font-size: 13px;
  color: #606266;
  line-height: 1.5;
}
</style>

