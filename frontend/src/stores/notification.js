import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getNotifications, getUnreadCount, markNotificationRead, markAllNotificationsRead, clearAllNotifications } from '@/api'

export const useNotificationStore = defineStore('notification', () => {
  const notifications = ref([])
  const unreadCount = ref(0)
  const loading = ref(false)

  const fetchUnreadCount = async () => {
    try {
      const res = await getUnreadCount()
      unreadCount.value = res.data || 0
    } catch (error) {
      console.error('获取未读消息数失败:', error)
    }
  }

  const fetchNotifications = async (params = {}) => {
    loading.value = true
    try {
      const res = await getNotifications(params)
      notifications.value = res.data?.records || res.data?.list || res.data || []
      return res.data
    } catch (error) {
      console.error('获取通知列表失败:', error)
      return null
    } finally {
      loading.value = false
    }
  }

  const markAsRead = async (id) => {
    try {
      await markNotificationRead(id)
      const idx = notifications.value.findIndex(n => n.id === id)
      if (idx !== -1) {
        notifications.value[idx].isRead = 1
      }
      if (unreadCount.value > 0) {
        unreadCount.value--
      }
    } catch (error) {
      console.error('标记已读失败:', error)
    }
  }

  const markAllAsRead = async () => {
    try {
      await markAllNotificationsRead()
      notifications.value.forEach(n => { n.isRead = 1 })
      unreadCount.value = 0
    } catch (error) {
      console.error('全部已读失败:', error)
    }
  }

  const clearAll = async () => {
    try {
      await clearAllNotifications()
      notifications.value = []
      unreadCount.value = 0
    } catch (error) {
      console.error('清除所有消息失败:', error)
    }
  }

  return {
    notifications,
    unreadCount,
    loading,
    fetchUnreadCount,
    fetchNotifications,
    markAsRead,
    markAllAsRead,
    clearAll
  }
})
