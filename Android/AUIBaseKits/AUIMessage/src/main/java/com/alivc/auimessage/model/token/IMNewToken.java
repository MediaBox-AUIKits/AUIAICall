package com.alivc.auimessage.model.token;

import java.io.Serializable;

/**
 * @author keria
 * @date 2023/11/7
 * @brief
 */
public class IMNewToken implements Serializable {

    // 用户的AppID
    public String app_id;

    // 服务器生成的加密串，包含接入域名等信息
    public String app_sign;

    // 登录鉴权
    public String app_token;

    // IM鉴权
    public IMNewTokenAuth auth;

    @Override
    public String toString() {
        return "IMNewToken{" +
                "app_id='" + app_id + '\'' +
                ", app_sign='" + app_sign + '\'' +
                ", app_token='" + app_token + '\'' +
                ", auth=" + auth +
                '}';
    }
}
