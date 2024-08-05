package com.aliyuncs.aui.service.impl;

import com.aliyuncs.aui.dto.req.LoginRequestDto;
import com.aliyuncs.aui.service.LoginService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.springframework.stereotype.Service;

/**
 * 登录服务实现类
 *
 * @author chunlei.zcl
 */
@Slf4j
@Service
public class LoginServiceImpl implements LoginService {

    /**
     * 登录实现逻辑。说明：作为Demo演示，简单判断用户名与密码是否相同
     *
     * @author chunlei.zcl
     */
    @Override
    public boolean login(LoginRequestDto loginRequestDto) {

        if (StringUtils.isNotEmpty(loginRequestDto.getUsername()) && StringUtils.isNotEmpty(loginRequestDto.getPassword())) {
            if (loginRequestDto.getUsername().equals(loginRequestDto.getPassword())) {
                return true;
            }
        }
        log.warn("incorrect Username or Password.Username:{}", loginRequestDto.getUsername());
        return false;
    }
}
