package com.ltcmsystem.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 这里可以修改为你想要的密码
        String plainPassword = "123456";
        
        String hashedPassword = encoder.encode(plainPassword);
        System.out.println("原始密码: " + plainPassword);
        System.out.println("BCrypt加密后: " + hashedPassword);
        System.out.println();
        System.out.println("可以使用以下SQL更新数据库中的密码:");
        System.out.println("UPDATE user SET password = '" + hashedPassword + "' WHERE username = 'admin';");
    }
}
