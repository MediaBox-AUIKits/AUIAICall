package com.alivc.auimessage.model.token;

import java.io.Serializable;

/**
 * @author keria
 * @date 2023/11/7
 * @brief
 */
public class IMNewTokenAuth implements Serializable {

    // 要登录的用户的Id
    public String user_id;

    // 格式："AK-随机串", 最长64字节
    public String nonce;

    // 过期时间, 从1970到过期时间的秒数
    public long timestamp;

    // 角色，为admin时，表示该用户可以调用管控接口
    public String role;

    @Override
    public String toString() {
        return "IMNewTokenAuth{" +
                "user_id='" + user_id + '\'' +
                ", nonce='" + nonce + '\'' +
                ", timestamp='" + timestamp + '\'' +
                ", role='" + role + '\'' +
                '}';
    }

}
