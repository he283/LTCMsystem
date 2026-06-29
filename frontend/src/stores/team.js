import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getMyTeams, createTeam, joinTeam } from '@/api'

export const useTeamStore = defineStore('team', () => {
  const teams = ref([])
  const loading = ref(false)

  const fetchTeams = async () => {
    loading.value = true
    try {
      const res = await getMyTeams()
      console.log('获取团队响应:', res)
      teams.value = res.data || []
    } catch (error) {
      console.error('获取团队失败:', error)
      teams.value = []
    } finally {
      loading.value = false
    }
  }

  const addTeam = async (teamData) => {
    const res = await createTeam(teamData)
    console.log('创建团队响应:', res)
    const newTeam = res.data
    teams.value.push(newTeam)
    return newTeam
  }

  const joinTeamById = async (teamId) => {
    await joinTeam(teamId)
    await fetchTeams()
  }

  return {
    teams,
    loading,
    fetchTeams,
    addTeam,
    joinTeamById
  }
})
