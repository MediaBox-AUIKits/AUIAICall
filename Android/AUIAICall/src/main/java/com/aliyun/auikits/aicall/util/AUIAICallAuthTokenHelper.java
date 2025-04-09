package com.aliyun.auikits.aicall.util;

import android.text.TextUtils;

import com.alivc.auicommon.common.base.log.Logger;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

import org.json.JSONObject;

public class AUIAICallAuthTokenHelper {

    public interface IAUIAICallAuthTokenCallback {
        void onSuccess(JSONObject token);
        void onFail(int errorCode, String errorMsg);
    }
    private static final String TAG = "AUIAICallAuthTokenHelper";
    private static ARTCAICallServiceImpl.AppServerService mAppServerService = null;

    public static void getAICallAuthToken(String userId, String authorization, IAUIAICallAuthTokenCallback callback) {

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
                mAppServerService.postAsync(mAppServer, "/api/v2/aiagent/getRtcAuthToken", authorization, jsonObject, new IARTCAICallService.IARTCAICallServiceCallback() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {
                        if(callback != null) {
                            callback.onSuccess(jsonObject);
                        }
                    }

                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        Logger.e("getAICallAuthToken error:" + errorCode + ", msg: " + errorMsg);
                        if(callback != null) {
                            callback.onFail(errorCode, errorMsg);
                        }
                    }
                });
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    public static void getAIChatAuthToken(String userId, String authorization,  String mAgentId, String mAgentRegion, IAUIAICallAuthTokenCallback callback) {
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
                jsonObject.put("expire", 1 * 60 * 60);
                if(!TextUtils.isEmpty(mAgentId)) {
                    jsonObject.put("ai_agent_id", mAgentId);
                }
                if(!TextUtils.isEmpty(mAgentRegion)) {
                    jsonObject.put("region", mAgentRegion);
                }

                mAppServerService.postAsync(mAppServer, "/api/v2/aiagent/generateMessageChatToken", authorization, jsonObject, new IARTCAICallService.IARTCAICallServiceCallback() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {
                        if(callback != null) {
                            callback.onSuccess(jsonObject);
                        }
                    }
                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        Logger.e("generateMessageChatToken failed: " + errorMsg);
                        if(callback != null) {
                            callback.onFail(errorCode, errorMsg);
                        }
                    }
                });

            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}
