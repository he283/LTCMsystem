package com.ltcmsystem.controller;

import com.ltcmsystem.common.OperationTypeEnum;
import com.ltcmsystem.common.Result;
import com.ltcmsystem.dto.LoginDTO;
import com.ltcmsystem.dto.RegisterDTO;
import com.ltcmsystem.entity.User;
import com.ltcmsystem.service.OperationLogService;
import com.ltcmsystem.service.UserService;
import com.ltcmsystem.util.IpUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final OperationLogService operationLogService;

    @PostMapping("/login")
    public Result<Map<String, String>> login(@Valid @RequestBody LoginDTO loginDTO, HttpServletRequest request) {
        String token = userService.login(loginDTO.getUsername(), loginDTO.getPassword());
        User user = userService.findByUsername(loginDTO.getUsername());

        String ipAddress = IpUtil.getClientIp(request);
        String userAgent = request.getHeader("User-Agent");

        operationLogService.logOperation(
                user.getId(),
                user.getUsername(),
                user.getNickname(),
                OperationTypeEnum.LOGIN.name(),
                OperationTypeEnum.LOGIN.getDesc(),
                "auth",
                null,
                null,
                ipAddress,
                userAgent
        );

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
