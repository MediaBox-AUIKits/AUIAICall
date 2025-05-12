package com.aliyun.auikits.aicall.util;


import android.text.TextUtils;

import com.alivc.auicommon.common.base.log.Logger;
import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class AUIAIChatAuthTokenHelper {

    // 设置为true，启动Develop模式
    private static final boolean EnableDevelopToken = false;

    //从控制台拷贝的互动消息的AppId
    private static final String AIChatIMDevelopAppId = "";
    //从控制台拷贝互动消息的AppKey
    private static final String AIChatIMDevelopAppKey = "";
    //从控制台拷贝互动消息的AppKey
    private static final String AIChatIMDevelopAppSign = "";

    public interface IAUIAIChatAuthTokenCallback {
        void onSuccess(ARTCAIChatEngine.ARTCAIChatAuthToken auth);
        void onFail(int errorCode, String errorMsg);
    }

    private static final String TAG = "AUIAIChatAuthTokenHelper";
    private static ARTCAICallServiceImpl.AppServerService mAppServerService = null;

    public static void getAIChatAuthToken(String userId, String authorization,  String mAgentId, String mAgentRegion, AUIAIChatAuthTokenHelper.IAUIAIChatAuthTokenCallback callback) {
        if(EnableDevelopToken) {
            ARTCAIChatEngine.ARTCAIChatAuthToken auth = generateAIChatAuthToken(AIChatIMDevelopAppId, AIChatIMDevelopAppKey, AIChatIMDevelopAppSign, userId, getTimesTamp());
            if(callback != null ) {
                if(auth != null) {
                    callback.onSuccess(auth);
                }
            }
        } else {
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

                            ARTCAIChatEngine.ARTCAIChatAuthToken auth = new ARTCAIChatEngine.ARTCAIChatAuthToken(jsonObject);
                            if(auth != null) {
                                if(callback != null) {
                                    callback.onSuccess(auth);
                                }
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

    public static ARTCAIChatEngine.ARTCAIChatAuthToken generateAIChatAuthToken(String appid, String appkey, String appSign, String userId, long timestamp) {
        String role = "";
        String nonce = "AK_4";
        StringBuilder stringBuilder = new StringBuilder()
                .append(appid)
                .append(appkey)
                .append(userId)
                .append(nonce)
                .append(role)
                .append(timestamp);
        String appToken = getSHA256(stringBuilder.toString());

        ARTCAIChatEngine.ARTCAIChatAuthToken auth = new ARTCAIChatEngine.ARTCAIChatAuthToken(appid, appSign, appToken, timestamp, role, nonce);
        return auth;
    }

    public static String getSHA256(String str) {
        try {
            MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
            byte[] hash = messageDigest.digest(str.getBytes(StandardCharsets.UTF_8));
            return byte2Hex(hash);
        } catch (NoSuchAlgorithmException e) {
            // Consider logging the exception and/or re-throwing as a RuntimeException
            e.printStackTrace();
        }
        return "";
    }

    private static String byte2Hex(byte[] bytes) {
        StringBuilder stringBuilder = new StringBuilder();
        for (byte b : bytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                // Use single quote for char
                stringBuilder.append('0');
            }
            stringBuilder.append(hex);
        }
        return stringBuilder.toString();
    }

    public static long getTimesTamp() {
        return System.currentTimeMillis() / 1000 + 60 * 60 * 24;
    }

}
