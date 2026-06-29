package com.ltcmsystem.controller;

import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.LoginDTO;
import com.ltcmsystem.dto.RegisterDTO;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.service.UserService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/login")
    public Result<Map<String, String>> login(@Valid @RequestBody LoginDTO loginDTO) {
        String token = userService.login(loginDTO.getUsername(), loginDTO.getPassword());
        Map<String, String> data = new HashMap<>();
        data.put("token", token);
        return Result.success(data);
    }

    @PostMapping("/register")
    public Result<User> register(@Valid @RequestBody RegisterDTO registerDTO) {
        User user = userService.register(
            registerDTO.getUsername(),
            registerDTO.getPassword(),
            registerDTO.getNickname(),
            registerDTO.getEmail()
        );
        user.setPassword(null);
        return Result.success(user);
    }
}
