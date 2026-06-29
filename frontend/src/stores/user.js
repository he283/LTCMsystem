import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login, register, getUserInfo, updateUserInfo, changePassword } from '@/api'

export const useUserStore = defineStore('user', () => {
  const userInfo = ref(null)
  const token = ref(localStorage.getItem('token') || '')

  const setToken = (newToken) => {
    token.value = newToken
    if (newToken) {
      localStorage.setItem('token', newToken)
    } else {
      localStorage.removeItem('token')
    }
  }

  const fetchUserInfo = async () => {
    try {
      const res = await getUserInfo()
      console.log('获取用户信息响应:', res)
      userInfo.value = res.data
    } catch (error) {
      console.error('获取用户信息失败:', error)
      // 如果没有用户信息，设置一个临时用户（适配临时后端）
      if (!userInfo.value) {
        userInfo.value = {
          id: 1,
          username: 'admin',
          nickname: '管理员',
          email: 'admin@example.com'
        }
      }
    }
  }

  const updateUserProfile = async (profileData) => {
    const res = await updateUserInfo(profileData)
    userInfo.value = res.data
    return res.data
  }

  const updateUserPassword = async (passwordData) => {
    await changePassword(passwordData)
  }

  const loginUser = async (loginData) => {
    const res = await login(loginData)
    console.log('loginUser响应:', res)
    if (res.data && res.data.token) {
      setToken(res.data.token)
    } else {
      // 临时方案，如果没有token也设置
      setToken('temp-token')
    }
    await fetchUserInfo()
  }

  const registerUser = async (registerData) => {
    await register(registerData)
  }

  const logout = () => {
    userInfo.value = null
    setToken('')
  }

  return {
    userInfo,
    token,
    setToken,
    fetchUserInfo,
    updateUserProfile,
    updateUserPassword,
    loginUser,
    registerUser,
    logout
  }
})
