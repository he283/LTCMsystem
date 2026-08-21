import request from '@/utils/request'

export const login = (data) => request.post('/auth/login', data)
export const register = (data) => request.post('/auth/register', data)
export const getUserInfo = () => request.get('/user/info')
export const updateUserInfo = (data) => request.put('/user/info', data)
export const changePassword = (data) => request.put('/user/password', data)
// 头像上传：FormData，后端返回新的头像 URL（相对路径 /uploads/avatar/xxx）
export const uploadAvatar = (file) => {
  const formData = new FormData()
  formData.append('file', file)
  return request.post('/user/avatar', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
    timeout: 30000
  })
}
export const getMyTasks = () => request.get('/tasks/my')
export const getTeamTasks = (teamId) => request.get(`/tasks/team/${teamId}`)
export const getTeamMemberStats = (teamId) => request.get(`/tasks/team/${teamId}/stats`)
export const createTask = (data) => request.post('/tasks', data)
export const updateTask = (id, data) => request.put(`/tasks/${id}`, data)
export const deleteTask = (id) => request.delete(`/tasks/${id}`)
export const toggleTaskPublic = (id, data) => request.put(`/tasks/${id}/public`, data)
export const getMyTeams = () => request.get('/teams/my')
export const createTeam = (data) => request.post('/teams', data)
export const joinTeam = (teamId) => request.post(`/teams/${teamId}/join`)
export const deleteTeam = (teamId) => request.delete(`/teams/${teamId}`)
export const inviteMember = (teamId, data) => request.post(`/teams/${teamId}/invite`, data)
export const getTeamMembers = (teamId) => request.get(`/teams/${teamId}/members`)
export const removeMember = (teamId, memberId) => request.delete(`/teams/${teamId}/members/${memberId}`)

export const getPublicTasks = (params) => request.get('/public/tasks', { params })
export const getPublicTaskDetail = (id) => request.get(`/public/tasks/${id}`)

export const getOperationLogs = (params) => request.get('/operation-logs', { params })
export const getTaskChangeLogs = (id) => request.get(`/tasks/${id}/change-logs`)

export const getTaskComments = (taskId, params) => request.get(`/tasks/${taskId}/comments`, { params })
export const addTaskComment = (taskId, data) => request.post(`/tasks/${taskId}/comments`, data)
export const deleteTaskComment = (taskId, commentId) => request.delete(`/tasks/${taskId}/comments/${commentId}`)

export const getPublicTaskComments = (taskId, params) => request.get(`/public/tasks/${taskId}/comments`, { params })

export const applyJoinTeam = (data) => request.post('/teams/apply', data)
export const applyLeaveTeam = (data) => request.post('/teams/leave-apply', data)
export const getTeamApplications = (params) => request.get('/teams/applications', { params })
export const handleTeamApplication = (id, data) => request.put(`/teams/applications/${id}/handle`, data)
// 转让团队管理员（仅创建者可调用）
export const transferTeamAdmin = (teamId, newAdminId) => request.put(`/teams/${teamId}/transfer-admin`, { newAdminId })

export const getNotifications = (params) => request.get('/notifications', { params })
export const getUnreadCount = () => request.get('/notifications/unread-count')
export const markNotificationRead = (id) => request.put(`/notifications/${id}/read`)
export const markAllNotificationsRead = () => request.put('/notifications/read-all')
export const clearAllNotifications = () => request.delete('/notifications/clear-all')

// ============ Agent 助手相关 ============
// Agent 接口会调用大模型（deepseek-v4-flash），耗时通常 5~20s，单独设置较长超时 60s
export const agentChat = (data) => request.post('/agent/chat', data, { timeout: 60000 })
// 流式接口 /agent/chat/stream 由前端直接用 fetch 调用（要取 ReadableStream，axios 不方便）
// health 接口会附带一次 LLM 连通性 ping(最长等 2.5s),给 10s 超时兜底
export const agentHealth = () => request.get('/agent/health', { timeout: 10000 })
export const getTaskAnalysis = (userId) => request.get(`/agent/task-analysis/${userId}`, { timeout: 30000 })
export const getTeamAnalysis = (userId) => request.get(`/agent/team-analysis/${userId}`, { timeout: 30000 })
// 聊天历史：从服务端拉取（刷新页面后localStorage丢失也能找回） / 清空
export const getAgentHistory = (chatId, userId) =>
  request.get(`/agent/history/${encodeURIComponent(chatId)}`, { params: { user_id: userId }, timeout: 5000 })
export const deleteAgentHistory = (chatId, userId) =>
  request.delete(`/agent/history/${encodeURIComponent(chatId)}`, { params: { user_id: userId }, timeout: 5000 })
