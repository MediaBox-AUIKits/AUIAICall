package com.aliyun.auikits.aicall.core.service;

import org.json.JSONObject;

public interface IARTCAICallService {
    interface IARTCAICallServiceCallback {
        void onSuccess(JSONObject jsonObject);
        void onFail(int errorCode, String errorMsg);
    }

    void startAIGCRobotService(String userId, String robotId, IARTCAICallServiceCallback callback);

    void stopAIGCRobotService(String robotInstanceId, IARTCAICallServiceCallback callback);

    void refreshRTCToken(String channelId, String userId, IARTCAICallServiceCallback callback);

    void enableVoiceInterrupt(String robotInstanceId, boolean enable, IARTCAICallServiceCallback callback);

    void switchRobotVoice(String robotInstanceId, String soundId, IARTCAICallServiceCallback callback);

    void interruptRobotSpeak();

    void setIMService(IARTCAICallIMService imService);
}
