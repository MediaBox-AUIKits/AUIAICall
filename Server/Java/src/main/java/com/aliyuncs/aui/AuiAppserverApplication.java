package com.aliyuncs.aui;

import com.alibaba.fastjson.util.TypeUtils;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AuiAppserverApplication {

    public static void main(String[] args) {
        TypeUtils.compatibleWithFieldName = true;
        SpringApplication.run(AuiAppserverApplication.class, args);
    }
}
