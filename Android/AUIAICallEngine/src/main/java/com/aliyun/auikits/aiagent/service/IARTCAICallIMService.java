package com.aliyun.auikits.aiagent.service;

import org.json.JSONObject;

public interface IARTCAICallIMService {
    void sendMessage(int msgType, JSONObject data);
}
