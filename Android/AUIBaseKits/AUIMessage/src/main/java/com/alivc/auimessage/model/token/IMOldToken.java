package com.alivc.auimessage.model.token;

/**
 * @author keria
 * @date 2023/11/7
 * @brief 适用于aliyun_old服务
 */
public class IMOldToken {

    public String access_token;

    public String refresh_token;

    @Override
    public String toString() {
        return "IMOldToken{" +
                "access_token='" + access_token + '\'' +
                ", refresh_token='" + refresh_token + '\'' +
                '}';
    }

}
