package com.alivc.auicommon.common.roombase;

import java.io.Serializable;

/**
 * 初始化参数，所有参数为必传参数，从控制台获取
 */
public class BizInitParam implements Serializable {
    public String appId;
    public String appKey;
    public String userId;
    /**
     * appServer URL
     */
    public String serverHost;
    /**
     * 签名密钥
     */
    public String serverSecret;

    @Override
    public String toString() {
        return "BizInitParam{" +
                "appId='" + appId + '\'' +
                ", appKey='" + appKey + '\'' +
                ", userId='" + userId + '\'' +
                ", serverHost='" + serverHost + '\'' +
                ", serverSecret='" + serverSecret + '\'' +
                '}';
    }
}
