package com.alivc.auimessage;

import com.alivc.auimessage.model.token.IMNewToken;
import com.alivc.auimessage.model.token.IMOldToken;

/**
 * @author puke
 * @version 2023/4/19
 */
public class AUIMessageConfig {

    public String deviceId;

    // 不直接存储Token属性，是为了防止模块耦合依赖

    /**
     * IM
     */
    public IMOldToken oldToken;

    public IMNewToken newToken;

    @Override
    public String toString() {
        return "AUIMessageConfig{" +
                "deviceId='" + deviceId + '\'' +
                ", oldToken=" + oldToken +
                ", newToken=" + newToken +
                '}';
    }
}
