package com.aliyun.auikits.aicall.core.service;

import org.json.JSONObject;

public interface IARTCAICallIMService {
    void sendMessage(int msgType, String senderId, String receiverId, JSONObject data);
}
