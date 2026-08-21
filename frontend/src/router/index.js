import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/',
    redirect: '/plaza'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/plaza',
    name: 'TaskPlaza',
    component: () => import('@/views/TaskPlaza.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/plaza/:id',
    name: 'TaskDetail',
    component: () => import('@/views/TaskDetail.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/home',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/operation-log',
    name: 'OperationLog',
    component: () => import('@/views/OperationLog.vue'),
    meta: { requiresAuth: true, adminOnly: true }
  },
  {
    path: '/login-log',
    name: 'LoginLog',
    component: () => import('@/views/LoginLog.vue'),
    meta: { requiresAuth: true, adminOnly: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  if (to.meta.requiresAuth && !userStore.token) {
    next('/login')
  } else if (to.path === '/login' && userStore.token) {
    next('/home')
  } else if (to.meta.adminOnly) {
    // 管理员专属页面：刷新后 userInfo 可能还没加载，先补拉一次
    if (!userStore.userInfo) {
      try { await userStore.fetchUserInfo() } catch (e) {}
    }
    const info = userStore.userInfo
    const isAdmin = !!(info && (info.role === 'ADMIN' || info.username === 'admin'))
    if (!isAdmin) {
      next('/home')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
