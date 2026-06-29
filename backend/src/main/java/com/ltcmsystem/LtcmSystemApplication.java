package com.ltcmsystem;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.ltcmsystem.mapper")
public class LtcmSystemApplication {

    public static void main(String[] args) {
        SpringApplication.run(LtcmSystemApplication.class, args);
    }

}
