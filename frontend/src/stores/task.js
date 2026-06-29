import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getMyTasks, getTeamTasks, createTask, updateTask, deleteTask } from '@/api'

export const useTaskStore = defineStore('task', () => {
  const tasks = ref([])
  const loading = ref(false)

  const fetchTasks = async () => {
    loading.value = true
    try {
      const res = await getMyTasks()
      console.log('获取任务响应:', res)
      tasks.value = res.data || []
    } catch (error) {
      console.error('获取任务失败:', error)
      tasks.value = []
    } finally {
      loading.value = false
    }
  }

  const addTask = async (taskData) => {
    const res = await createTask(taskData)
    console.log('创建任务响应:', res)
    const newTask = res.data
    tasks.value.push(newTask)
    return newTask
  }

  const editTask = async (id, taskData) => {
    const res = await updateTask(id, taskData)
    console.log('编辑任务响应:', res)
    const updatedTask = res.data
    const index = tasks.value.findIndex(t => t.id === id)
    if (index !== -1) {
      tasks.value[index] = updatedTask
    }
    return updatedTask
  }

  const removeTask = async (id) => {
    await deleteTask(id)
    tasks.value = tasks.value.filter(t => t.id !== id)
  }

  return {
    tasks,
    loading,
    fetchTasks,
    addTask,
    editTask,
    removeTask
  }
})
