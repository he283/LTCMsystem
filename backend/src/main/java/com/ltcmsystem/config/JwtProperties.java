package com.ltcmsystem.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {
    private String secret = "ltcm-system-secret-key-2024-default-secret-key";
    private Long expiration = 86400000L;
}
