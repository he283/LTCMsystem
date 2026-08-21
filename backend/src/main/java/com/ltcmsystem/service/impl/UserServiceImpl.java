package com.ltcmsystem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.mapper.UserMapper;
import com.ltcmsystem.service.UserService;
import com.ltcmsystem.util.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public UserServiceImpl(PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @Override
    public User findByUsername(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username);
        return getOne(wrapper);
    }

    @Override
    public String login(String username, String password) {
        User user = findByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("密码错误");
        }
        return jwtUtil.generateToken(user.getId(), user.getUsername());
    }

    @Override
    public User register(String username, String password, String nickname, String email) {
        User existUser = findByUsername(username);
        if (existUser != null) {
            throw new RuntimeException("用户名已存在");
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setNickname(nickname != null ? nickname : username);
        user.setEmail(email);
        save(user);
        return user;
    }

    @Override
    public User updateUserInfo(Long userId, String nickname, String email) {
        User user = getById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (nickname != null) {
            user.setNickname(nickname);
        }
        if (email != null) {
            user.setEmail(email);
        }
        updateById(user);
        return user;
    }

    @Override
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = getById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("旧密码错误");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        updateById(user);
    }

    @Override
    public String updateAvatar(Long userId, MultipartFile file) {
        User user = getById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("请选择图片文件");
        }
        // 校验扩展名（白名单）
        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf('.')).toLowerCase();
        }
        if (!ext.matches("\\.(jpg|jpeg|png|gif|webp)")) {
            throw new RuntimeException("仅支持 jpg/jpeg/png/gif/webp 格式的图片");
        }
        // 限制 2MB
        if (file.getSize() > 2 * 1024 * 1024) {
            throw new RuntimeException("图片大小不能超过 2MB");
        }
        try {
            // 保存目录：<运行目录>/uploads/avatar，文件名 user{id}{ext}，同一用户覆盖旧头像
            java.io.File dir = new java.io.File(System.getProperty("user.dir"), "uploads/avatar");
            if (!dir.exists() && !dir.mkdirs()) {
                throw new RuntimeException("头像目录创建失败");
            }
            String filename = "user" + userId + ext;
            file.transferTo(new java.io.File(dir, filename));
            String avatarUrl = "/uploads/avatar/" + filename;
            user.setAvatar(avatarUrl);
            updateById(user);
            return avatarUrl;
        } catch (Exception e) {
            throw new RuntimeException("头像上传失败: " + e.getMessage());
        }
    }
}
