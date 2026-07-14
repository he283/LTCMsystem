import request from '@/utils/request'

export const login = (data) => request.post('/auth/login', data)
export const register = (data) => request.post('/auth/register', data)
export const getUserInfo = () => request.get('/user/info')
export const updateUserInfo = (data) => request.put('/user/info', data)
export const changePassword = (data) => request.put('/user/password', data)
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

export const getNotifications = (params) => request.get('/notifications', { params })
export const getUnreadCount = () => request.get('/notifications/unread-count')
export const markNotificationRead = (id) => request.put(`/notifications/${id}/read`)
export const markAllNotificationsRead = () => request.put('/notifications/read-all')
export const clearAllNotifications = () => request.delete('/notifications/clear-all')
