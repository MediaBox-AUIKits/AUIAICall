package com.aliyun.auikits.aiagent.service;

import com.aliyun.auikits.aiagent.util.IMsgTypeDef;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;

import org.json.JSONObject;

public class ARTCAICallDepositServiceImpl extends ARTCAICallServiceImpl {

    public ARTCAICallDepositServiceImpl(String appServerHost) {
        super(appServerHost);
    }

    @Override
    public void enableVoiceInterrupt(String aiAgentInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, boolean enable, IARTCAICallServiceCallback callback) {
        if (null != mAiCallIMService) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("enable", enable);
                mAiCallIMService.sendMessage(
                        IMsgTypeDef.MSG_TYPE_SWITCH_VOICE_INTERRUPT,
                        jsonObject
                );
                mCallbackMap.put(IMsgTypeDef.MSG_TYPE_SWITCH_VOICE_INTERRUPT_RESULT, callback);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    @Override
    public void switchAiAgentVoice(String robotInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, String soundId, IARTCAICallServiceCallback callback) {
        if (null != mAiCallIMService) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("voiceId", soundId);
                mAiCallIMService.sendMessage(
                        IMsgTypeDef.MSG_TYPE_SWITCH_VOICE_ID,
                        jsonObject
                );
                mCallbackMap.put(IMsgTypeDef.MSG_TYPE_SWITCH_VOICE_ID_RESULT, callback);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    @Override
    public void stopAIAgentService(String aiAgentInstanceId, IARTCAICallServiceCallback callback) {
        callback.onSuccess(new JSONObject());
    }
}
