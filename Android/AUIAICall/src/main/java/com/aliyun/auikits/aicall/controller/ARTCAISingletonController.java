package com.aliyun.auikits.aicall.controller;

import android.content.Context;

import com.aliyun.auikits.aiagent.ARTCAICallCustomEngineImpl;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.ARTCAICallEngineImpl;
import com.aliyun.auikits.aicall.util.SettingStorage;

public class ARTCAISingletonController extends ARTCAICallController{

    public ARTCAISingletonController(Context context, String userId) {
        super(context, userId);

        mARTCAICallEngine = ARTCAICallEngineSingleton.getInstance().getEngineInstance(context, userId);

    }

    @Override
    public void start() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                setCallState(AICallState.Connecting, ARTCAICallEngine.AICallErrorCode.None);
                boolean shareBootUseDemoAppServer = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHARE_BOOT_USE_DEMO_APP_SERVER, SettingStorage.DEFAULT_SHARE_BOOT_USE_DEMO_APP_SERVER);
                if (!mARTCAiCallConfig.mAiCallAgentTemplateConfig.isSharedAgent || shareBootUseDemoAppServer) {
                    mARTCAICallEngine.getIARTCAICallService().generateAIAgentCall(mUserId, mARTCAiCallConfig.agentId, mAiAgentType, mARTCAiCallConfig, getStartActionCallback());
                } else {
                    mARTCAICallEngine.getIARTCAICallService().generateAIAgentShareCall(mUserId, mARTCAiCallConfig.agentId, mAiAgentType, mARTCAiCallConfig, getStartActionCallback());
                }
            }
        });
    }

    @Override
    public void startCall(String token) {
        if(!mARTCAiCallConfig.mAiCallAgentTemplateConfig.isSharedAgent) {
            setCallState(AICallState.Connecting, ARTCAICallEngine.AICallErrorCode.None);
            mRtcAuthToken = token;
            mARTCAICallEngine.call(token);
        } else {
            mCallbackHandler.post(new Runnable() {
                @Override
                public void run() {
                    setCallState(AICallState.Connecting, ARTCAICallEngine.AICallErrorCode.None);
                    mRtcAuthToken = token;
                    mARTCAICallEngine.getIARTCAICallService().generateAIAgentShareCall(mUserId, mARTCAiCallConfig.agentId, mAiAgentType, mARTCAiCallConfig, getStartActionCallback());
                }
            });
        }
    }
}
