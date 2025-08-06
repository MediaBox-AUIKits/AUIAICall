package com.aliyun.auikits.aicall.util;

import android.text.TextUtils;

import com.alivc.auicommon.common.base.log.Logger;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

public class AUIAICallManager {

    public interface IAUIAICallManagerBoundCallNumberCallback {
        void onSuccess(String number);
        void onFailed(int errorCode, String errorMsg);
    }

    private static ARTCAICallServiceImpl.AppServerService mAppServerService = null;

    public static void getInBoundCallNumber(String userId, String authorization,  String agentId, String region, IAUIAICallManagerBoundCallNumberCallback callback) {
        boolean usePreHost = SettingStorage.getInstance().getBoolean(SettingStorage.KEY_APP_SERVER_TYPE, SettingStorage.DEFAULT_APP_SERVER_TYPE);

        String mAppServer = null;
        if(usePreHost) {
            mAppServer = AUIAICallAgentDebug.PRE_HOST;
        } else {
            mAppServer = AppServiceConst.HOST;
        }

        if(mAppServerService == null) {
            mAppServerService = new ARTCAICallServiceImpl.AppServerService(mAppServer);
        }

        if(mAppServerService != null) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("user_id", userId);
                jsonObject.put("ai_agent_id", agentId);
                jsonObject.put("region", region);
                mAppServerService.postAsync(mAppServer, "/api/v2/aiagent/describeAIAgent", authorization, jsonObject, new IARTCAICallService.IARTCAICallServiceCallback() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {
                        Logger.i("AUIAICallManager getInBoundCallNumber onSuccess:" + jsonObject.toString());
                        if(jsonObject.has("ai_agent")) {
                            try {
                                String description = jsonObject.getString("ai_agent");
                                if(!TextUtils.isEmpty(description)) {
                                    JSONObject descriptionJson = new JSONObject(description);
                                    if(descriptionJson != null && descriptionJson.has("InboundPhoneNumbers")) {
                                        JSONArray inboundArray = descriptionJson.optJSONArray("InboundPhoneNumbers");
                                        if(callback != null && inboundArray != null && inboundArray.length() > 0) {
                                            callback.onSuccess((String) inboundArray.get(0));
                                        }
                                    }
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }

                    }

                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        Logger.e("describeAIAgent error:" + errorCode + ", msg: " + errorMsg);
                        if(callback != null) {
                            callback.onFailed(errorCode, errorMsg);
                        }
                    }
                });
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}
