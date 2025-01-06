package com.aliyun.auikits.aiagent.service;

import android.text.TextUtils;

import com.aliyun.auikits.aiagent.util.IMsgTypeDef;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;

import org.json.JSONObject;

public class ARTCAICallDepositServiceImpl extends ARTCAICallServiceImpl {

    public ARTCAICallDepositServiceImpl(ARTCAICallEngine.ARTCAICallConfig artcAiCallConfig) {
        super(artcAiCallConfig);
    }


    @Override
    public void enableVoiceInterrupt(String robotInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig, IARTCAICallServiceCallback callback) {
        if (null != mAiCallIMService) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("enable", artcaiCallConfig.mAiCallAgentTemplateConfig.enableVoiceInterrupt);
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


    public void switchAiAgentVoice(String robotInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig, IARTCAICallServiceCallback callback) {
        if (null != mAiCallIMService && !TextUtils.isEmpty(artcaiCallConfig.mAiCallAgentTemplateConfig.aiAgentVoiceId)) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("voiceId", artcaiCallConfig.mAiCallAgentTemplateConfig.aiAgentVoiceId);
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
    public boolean stopAIAgentService(String aiAgentInstanceId, IARTCAICallServiceCallback callback) {
        if (null != mAiCallIMService) {
            mAiCallIMService.sendMessage(IMsgTypeDef.MSG_TYPE_STOP_AI_AGENT, null);
        }
        callback.onSuccess(new JSONObject());
        return true;
    }
}
