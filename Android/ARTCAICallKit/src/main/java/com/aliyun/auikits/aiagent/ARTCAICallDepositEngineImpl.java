package com.aliyun.auikits.aiagent;

import android.content.Context;

import com.aliyun.auikits.aiagent.service.ARTCAICallDepositServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

public class ARTCAICallDepositEngineImpl extends ARTCAICallEngineImpl {

    public ARTCAICallDepositEngineImpl(Context context, String userId) {
        super(context, userId);
    }

    @Override
    protected IARTCAICallService generateAICallService(ARTCAICallConfig artcAiCallConfig) {
        return new ARTCAICallDepositServiceImpl(artcAiCallConfig.appServerHost, artcAiCallConfig.loginUserId, artcAiCallConfig.loginAuthrization);
    }
}
