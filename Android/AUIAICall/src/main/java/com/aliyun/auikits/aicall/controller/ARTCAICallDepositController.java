package com.aliyun.auikits.aicall.controller;

import android.content.Context;

import com.aliyun.auikits.aiagent.ARTCAICallDepositEngineImpl;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;

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
                mARTCAICallEngine.getIARTCAICallService().generateAIAgentCall(mUserId, mARTCAiCallConfig.aiAgentId, mAiAgentType, getStartActionCallback());
            }
        });
    }
}
