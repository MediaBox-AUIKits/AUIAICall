package com.aliyun.auikits.aiagent.service;




import com.aliyun.auikits.aiagent.ARTCAICallEngine;

import org.json.JSONObject;

public interface IARTCAICallService extends IARTCAICallIMCallback {
    String AI_AGENT_TYPE_AVATAR = "AvatarChat3D";
    String AI_AGENT_TYPE_VOICE = "VoiceChat";

    interface IARTCAICallServiceCallback {
        void onSuccess(JSONObject jsonObject);
        void onFail(int errorCode, String errorMsg);
    }

    void generateAIAgentCall(String userId, String aiAgentId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, IARTCAICallServiceCallback callback);

    void startAIAgentService(String userId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, IARTCAICallServiceCallback callback);

    /**
     *
     * @param robotInstanceId
     * @param callback
     * @return 是否需要等待
     */
    boolean stopAIAgentService(String robotInstanceId, IARTCAICallServiceCallback callback);

    void refreshRTCToken(String channelId, String userId, IARTCAICallServiceCallback callback);

    void enableVoiceInterrupt(String robotInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, boolean enable, IARTCAICallServiceCallback callback);

    void switchAiAgentVoice(String robotInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, String soundId, IARTCAICallServiceCallback callback);

    void interruptAiAgentSpeak();

    void setIMService(IARTCAICallIMService imService);

    @Override
    void onReceiveMessage(int msgType, int seqId, String senderId, String receiverId, JSONObject dataJson);
}
