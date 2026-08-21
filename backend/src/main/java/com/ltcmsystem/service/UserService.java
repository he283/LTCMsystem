package com.ltcmsystem.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ltcmsystem.entity.User;
import org.springframework.web.multipart.MultipartFile;

public interface UserService extends IService<User> {
    User findByUsername(String username);
    String login(String username, String password);
    User register(String username, String password, String nickname, String email);
    User updateUserInfo(Long userId, String nickname, String email);
    void changePassword(Long userId, String oldPassword, String newPassword);
    String updateAvatar(Long userId, MultipartFile file);
}
