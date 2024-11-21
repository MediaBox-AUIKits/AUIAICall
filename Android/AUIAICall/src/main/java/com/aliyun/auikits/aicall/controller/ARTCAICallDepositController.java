package com.aliyun.auikits.aicall.controller;

import android.content.Context;
import android.text.TextUtils;

import com.aliyun.auikits.aiagent.ARTCAICallDepositEngineImpl;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aicall.util.SettingStorage;

public class ARTCAICallDepositController extends ARTCAICallController {

    public ARTCAICallDepositController(Context context, String userId) {
        super(context, userId);
        mARTCAICallEngine = new ARTCAICallDepositEngineImpl(context, userId);
    }

    @Override
    public void start() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                setCallState(AICallState.Connecting, ARTCAICallEngine.AICallErrorCode.None);
                boolean shareBootUseDemoAppServer = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_SHARE_BOOT_USE_DEMO_APP_SERVER, SettingStorage.DEFAULT_SHARE_BOOT_USE_DEMO_APP_SERVER);
                if (TextUtils.isEmpty(mARTCAiCallConfig.aiAgentId) || shareBootUseDemoAppServer) {
                    mARTCAICallEngine.getIARTCAICallService().generateAIAgentCall(mUserId, mARTCAiCallConfig.aiAgentId, mAiAgentType, mARTCAiCallConfig, getStartActionCallback());
                } else {
                    mARTCAICallEngine.getIARTCAICallService().generateAIAgentShareCall(mUserId, mARTCAiCallConfig.aiAgentId, mAiAgentType, mARTCAiCallConfig, getStartActionCallback());
                }
            }
        });
    }
}
