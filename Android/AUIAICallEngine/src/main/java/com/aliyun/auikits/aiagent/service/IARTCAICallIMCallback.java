package com.aliyun.auikits.aiagent.service;

import org.json.JSONObject;

public interface IARTCAICallIMCallback {
    /**
     * 消息接受
     * @param msgType 消息类型
     * @param seqId 消息序号
     * @param senderId 发送者userId
     * @param receiverId 接受者UserId
     * @param dataJson 自定义数据结构
     */
    void onReceiveMessage(
            int msgType,
            int seqId,
            String senderId,
            String receiverId,
            JSONObject dataJson
    );
}
