package com.ltcmsystem.controller;

import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.ChangePasswordDTO;
import com.ltcmsystem.dto.UpdateUserDTO;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.service.UserService;
import com.ltcmsystem.util.UserContext;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/info")
    public Result<User> getCurrentUser() {
        Long userId = UserContext.getUserId();
        User user = userService.getById(userId);
        user.setPassword(null);
        return Result.success(user);
    }

    @PutMapping("/info")
    public Result<User> updateUserInfo(@Valid @RequestBody UpdateUserDTO updateUserDTO) {
        Long userId = UserContext.getUserId();
        User user = userService.updateUserInfo(userId, updateUserDTO.getNickname(), updateUserDTO.getEmail());
        user.setPassword(null);
        return Result.success(user);
    }

    @PutMapping("/password")
    public Result<Void> changePassword(@Valid @RequestBody ChangePasswordDTO changePasswordDTO) {
        Long userId = UserContext.getUserId();
        userService.changePassword(userId, changePasswordDTO.getOldPassword(), changePasswordDTO.getNewPassword());
        return Result.success();
    }
}
