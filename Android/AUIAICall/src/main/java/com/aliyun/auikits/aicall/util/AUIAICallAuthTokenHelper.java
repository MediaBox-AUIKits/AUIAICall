package com.aliyun.auikits.aicall.util;

import android.text.TextUtils;
import android.util.Base64;

import com.alibaba.fastjson.JSON;
import com.alivc.auicommon.common.base.log.Logger;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

public class AUIAICallAuthTokenHelper {
    // 设置为true，启动Develop模式
    private static final boolean EnableDevelopToken = false;

    //从控制台拷贝音视频通话RTCAppId
    private static final String AICallRTCDevelopAppId = "";
    // 从控制台拷贝音视频通话RTCAppKey
    private static final String AICallRTCDevelopAppKey = "";

    public interface IAUIAICallAuthTokenCallback {
        void onSuccess(JSONObject token);
        void onFail(int errorCode, String errorMsg);
    }
    private static final String TAG = "AUIAICallAuthTokenHelper";
    private static ARTCAICallServiceImpl.AppServerService mAppServerService = null;

    public static void getAICallAuthToken(String userId, String authorization, IAUIAICallAuthTokenCallback callback) {
        if(EnableDevelopToken) {
            String channelId = UUID.randomUUID().toString();
            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("rtc_auth_token", generateAICallAuthToken(AICallRTCDevelopAppId, AICallRTCDevelopAppKey, channelId, userId, getTimesTamp()));
                if(callback != null) {
                    callback.onSuccess(jsonObject);
                }
            } catch (JSONException e) {
                e.printStackTrace();
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
    }


    public static String generateAICallAuthToken(String appid, String appkey, String channelId, String userId, long timestamp) {
        StringBuilder stringBuilder = new StringBuilder()
                .append(appid)
                .append(appkey)
                .append(channelId)
                .append(userId)
                .append(timestamp);
        String token =  getSHA256(stringBuilder.toString());
        try{
            JSONObject tokenJson = new JSONObject();
            tokenJson.put("appid", appid);
            tokenJson.put("channelid", channelId);
            tokenJson.put("userid", userId);
            tokenJson.put("nonce", "");
            tokenJson.put("timestamp", timestamp);
            tokenJson.put("token", token);
            String base64Token = Base64.encodeToString(tokenJson.toString().getBytes(StandardCharsets.UTF_8), Base64.NO_WRAP);
            return base64Token;
        }catch (Exception e) {
            e.printStackTrace();
        }
        return null;
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
