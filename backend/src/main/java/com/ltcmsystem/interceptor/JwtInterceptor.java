package com.ltcmsystem.interceptor;

import com.ltcmsystem.util.JwtUtil;
import com.ltcmsystem.util.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class JwtInterceptor implements HandlerInterceptor {

    private final JwtUtil jwtUtil;

    public JwtInterceptor(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String authHeader = request.getHeader("Authorization");
        String requestUri = request.getRequestURI();
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            if (!jwtUtil.isTokenExpired(token)) {
                Long userId = jwtUtil.getUserId(token);
                UserContext.setUserId(userId);
                return true;
            }
        }
        
        if (isPublicPath(requestUri)) {
            return true;
        }
        
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        return false;
    }
    
    private boolean isPublicPath(String uri) {
        return uri.startsWith("/api/auth/") || uri.startsWith("/api/public/");
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        UserContext.clear();
    }
}
