package com.aliyun.auikits.aiagent.service;


import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.aliyun.auikits.aiagent.network.DefaultOkHttpFactory;
import com.aliyun.auikits.aiagent.util.IMsgTypeDef;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;

import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class ARTCAICallServiceImpl implements IARTCAICallService {
    // 内置appServer
    private static final String DEFAULT_HOST = "https://ice-smart-aiagent-fcapp-appserver.aliyuncs.com";

    protected IARTCAICallIMService mAiCallIMService = null;
    private AppServerService mAppServerService = null;
    protected Map<Integer, IARTCAICallServiceCallback> mCallbackMap = new HashMap<>();
    protected String mAiAgentRegion = null;
    protected String mLoginUserId;
    protected String mLoginAuthorization;
    protected String mUserData;

    public ARTCAICallServiceImpl(ARTCAICallEngine.ARTCAICallConfig artcAiCallConfig) {
        mAiAgentRegion = artcAiCallConfig.aiAgentRegion;
        mAppServerService = new AppServerService(artcAiCallConfig.appServerHost);
        mLoginUserId = artcAiCallConfig.loginUserId;
        mLoginAuthorization = artcAiCallConfig.loginAuthrization;
        mUserData = artcAiCallConfig.userExtendData;
    }

    private String agentTypeId(ARTCAICallEngine.ARTCAICallAgentType aiAgentType) {
        String agentTypeStr;
        switch (aiAgentType) {
            case AvatarAgent:
                agentTypeStr = AI_AGENT_TYPE_AVATAR;
                break;
            case VisionAgent:
                agentTypeStr = AI_AGENT_TYPE_VISION;
                break;
            case VoiceAgent:
            default:
                agentTypeStr = AI_AGENT_TYPE_VOICE;
                break;
        }
        return agentTypeStr;
    }

    private String defaultVoiceId(ARTCAICallEngine.ARTCAICallAgentType aiAgentType) {
//        if (aiAgentType == ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent) {
//            return null;
//        } else {
//            return "zhixiaoxia";
//        }
        return null;
    }

    @Override
    public void generateAIAgentShareCall(String userId, String aiAgentId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            if (!TextUtils.isEmpty(aiAgentId)) {
                jsonObject.put("ai_agent_id", aiAgentId);
            }
            jsonObject.put("user_id", userId);
            jsonObject.put("workflow_type", agentTypeId(aiAgentType));
            jsonObject.put("expire", 3600*24);
            jsonObject.put("template_config",
                    composeAiAgentConfigJson(aiAgentType, defaultVoiceId(aiAgentType), null, null, null, null,
                            null != artcaiCallConfig ? artcaiCallConfig.enablePushToTalk : null,
                            null != artcaiCallConfig ? artcaiCallConfig.enableVoicePrint : null,
                            null != artcaiCallConfig ? artcaiCallConfig.loginUserId : null)
            );
            jsonObject.put("user_id", mLoginUserId);
            if (!TextUtils.isEmpty(mAiAgentRegion)) {
                jsonObject.put("region", mAiAgentRegion);
            }
            if (!TextUtils.isEmpty(mUserData)) {
                jsonObject.put("user_data", mUserData);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(DEFAULT_HOST, AppServerService.API_GENERATE_AI_AGENT_SHARE_CALL_PATH, mLoginAuthorization, jsonObject, callback);
    }

    @Override
    public void generateAIAgentCall(String userId, String aiAgentId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, IARTCAICallServiceCallback callback) {
        generateAIAgentCall(userId, aiAgentId, aiAgentType, null, callback);
    }

    @Override
    public void generateAIAgentCall(String userId, String aiAgentId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig, IARTCAICallServiceCallback callback) {

        JSONObject jsonObject = new JSONObject();
        try {
            if (!TextUtils.isEmpty(aiAgentId)) {
                jsonObject.put("ai_agent_id", aiAgentId);
            }
            jsonObject.put("user_id", userId);
            jsonObject.put("workflow_type", agentTypeId(aiAgentType));
            jsonObject.put("expire", 3600*24);
            jsonObject.put("template_config",
                    composeAiAgentConfigJson(aiAgentType, defaultVoiceId(aiAgentType), null, null, null, null,
                            null != artcaiCallConfig ? artcaiCallConfig.enablePushToTalk : null,
                            null != artcaiCallConfig ? artcaiCallConfig.enableVoicePrint : null,
                            null != artcaiCallConfig ? artcaiCallConfig.loginUserId : null)
            );
            jsonObject.put("user_id", mLoginUserId);
            if (!TextUtils.isEmpty(mAiAgentRegion)) {
                jsonObject.put("region", mAiAgentRegion);
            }
            if (!TextUtils.isEmpty(mUserData)) {
                jsonObject.put("user_data", mUserData);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(null, AppServerService.API_GENERATE_AI_AGENT_CALL_PATH, mLoginAuthorization, jsonObject, callback);
    }

    @Override
    public void startAIAgentService(String userId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, IARTCAICallServiceCallback callback) {
        startAIAgentService(userId, aiAgentType, null, callback);
    }

    @Override
    public void startAIAgentService(String userId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("user_id", userId);
            jsonObject.put("workflow_type", agentTypeId(aiAgentType));
            jsonObject.put("template_config",
                    composeAiAgentConfigJson(aiAgentType, defaultVoiceId(aiAgentType), null, null, null, null,
                            null != artcaiCallConfig ? artcaiCallConfig.enablePushToTalk : null,
                            null != artcaiCallConfig ? artcaiCallConfig.enableVoicePrint : null,
                            null != artcaiCallConfig ? artcaiCallConfig.loginUserId : null)
            );
            jsonObject.put("user_id", mLoginUserId);
            if (!TextUtils.isEmpty(mUserData)) {
                jsonObject.put("user_data", mUserData);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(null, AppServerService.API_START_AI_AGENT_PATH, mLoginAuthorization, jsonObject, callback);
    }

    @Override
    public boolean stopAIAgentService(String aiAgentInstanceId, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("ai_agent_instance_id", aiAgentInstanceId);
            jsonObject.put("user_id", mLoginUserId);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(null, AppServerService.API_STOP_AI_AGENT_PATH, mLoginAuthorization, jsonObject, callback);
        return false;
    }

    @Override
    public void refreshRTCToken(String channelId, String userId, IARTCAICallServiceCallback callback) {
//        JSONObject jsonObject = new JSONObject();
//        try {
//            jsonObject.put("channel_id", channelId);
//            jsonObject.put("user_id", userId);
//        } catch (Exception ex) {
//            ex.printStackTrace();
//        }
//        mAppServerService.postAsync(null, AppServerService.API_REFRESH_TOKEN_PATH, jsonObject, callback);
        if (null != mAiCallIMService) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("userId", userId);
                mAiCallIMService.sendMessage(
                        IMsgTypeDef.MSG_TYPE_REFRESH_RTC_TOKEN,
                        jsonObject
                        );
                mCallbackMap.put(IMsgTypeDef.MSG_TYPE_RTC_TOKEN_REFRESH_RESULT, callback);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    @Override
    public void enableVoiceInterrupt(String aiAgentInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, boolean enable, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("ai_agent_instance_id", aiAgentInstanceId);
            jsonObject.put("template_config", composeAiAgentConfigJson(aiAgentType, null, null,
                    enable, null, null, null, null, null));
            jsonObject.put("user_id", mLoginUserId);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(null, AppServerService.API_UPDATE_AI_AGENT_PATH, mLoginAuthorization, jsonObject, callback);
    }

    @Override
    public void switchAiAgentVoice(String robotInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, String soundId, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("ai_agent_instance_id", robotInstanceId);
            jsonObject.put("template_config", composeAiAgentConfigJson(aiAgentType, soundId, null,
                    null, null, null, null, null, null));
            jsonObject.put("user_id", mLoginUserId);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(null, AppServerService.API_UPDATE_AI_AGENT_PATH, mLoginAuthorization, jsonObject, callback);
    }

    @Override
    public void interruptAiAgentSpeak() {
        if (null != mAiCallIMService) {
            mAiCallIMService.sendMessage(IMsgTypeDef.MSG_TYPE_INTERRUPT_ROBOT_SPEAK, null);
        }
    }

    @Override
    public void enablePushToTalk(boolean enable) {
        if (null != mAiCallIMService) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("enable", enable);
                mAiCallIMService.sendMessage(
                        IMsgTypeDef.MSG_TYPE_ENABLE_PUSH_TO_TALK,
                        jsonObject
                );
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    @Override
    public void enableVoicePrint(boolean enable) {
        if (null != mAiCallIMService) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("enable", enable);
                mAiCallIMService.sendMessage(
                        IMsgTypeDef.MSG_TYPE_ENABLE_VOICE_PRINT,
                        jsonObject
                );
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    @Override
    public void deleteVoicePrint() {
        if (null != mAiCallIMService) {
            mAiCallIMService.sendMessage(IMsgTypeDef.MSG_TYPE_CLEAR_VOICE_PRINT, null);
        }
    }

    @Override
    public void startPushToTalk() {
        if (null != mAiCallIMService) {
            mAiCallIMService.sendMessage(IMsgTypeDef.MSG_TYPE_START_PUSH_TO_TALK, null);
        }
    }

    @Override
    public void finishPushToTalk() {
        if (null != mAiCallIMService) {
            mAiCallIMService.sendMessage(IMsgTypeDef.MSG_TYPE_FINISH_PUSH_TO_TALK, null);
        }
    }

    @Override
    public void cancelPushToTalk() {
        if (null != mAiCallIMService) {
            mAiCallIMService.sendMessage(IMsgTypeDef.MSG_TYPE_CANCEL_PUSH_TO_TALK, null);
        }
    }

    @Override
    public void setIMService(IARTCAICallIMService imService) {
        mAiCallIMService = imService;
    }

    @Override
    public void onReceiveMessage(int msgType, int seqId, String senderId, String receiverId, JSONObject dataJson) {
        IARTCAICallServiceCallback callback = mCallbackMap.get(msgType);
        if (null != callback) {
            callback.onSuccess(dataJson);
        }
    }

    private static String composeAiAgentConfigJson(ARTCAICallEngine.ARTCAICallAgentType aiAgentType, String voiceId, String greeting, Boolean enableVoiceInterrupt,
                                                   Boolean gracefulShutdown, Integer volume, Boolean enablePushToTalk, Boolean useVoicePrint, String voicePrintId) {
        List<ARTCAICallEngine.ARTCAICallAgentType> aiAgentTypeList = new ArrayList<>();
        aiAgentTypeList.add(aiAgentType);
        return composeAiAgentConfigJson(aiAgentTypeList, voiceId, greeting, enableVoiceInterrupt, gracefulShutdown, volume, enablePushToTalk, useVoicePrint, voicePrintId);
    }

    private static String composeAiAgentConfigJson(List<ARTCAICallEngine.ARTCAICallAgentType> agentTypeList, String voiceId, String greeting, Boolean enableVoiceInterrupt,
                                                   Boolean gracefulShutdown, Integer volume, Boolean enablePushToTalk, Boolean useVoicePrint, String voicePrintId) {
        JSONObject jsonObject = new JSONObject();
        if (null != agentTypeList && !agentTypeList.isEmpty()) {
            try {
                JSONObject configJsonObject = new JSONObject();
                // 音色名称，修改后下句话生效
                if (null != voiceId) {
                    configJsonObject.put("VoiceId", voiceId);
                }
                // 问候语，修改后下次入会生效
                if (null != greeting) {
                    configJsonObject.put("Greeting", greeting);
                }
                // 是否支持语音打断
                if (null != enableVoiceInterrupt) {
                    configJsonObject.put("EnableVoiceInterrupt", enableVoiceInterrupt.booleanValue());
                }
                // 优雅下线
                if (null != gracefulShutdown) {
                    configJsonObject.put("GracefulShutdown", gracefulShutdown.booleanValue());
                }
                // 启动音量
                if (null != volume) {
                    configJsonObject.put("Volume", volume.intValue());
                }
                // 是否开启对讲机模式
                if (null != enablePushToTalk) {
                    configJsonObject.put("EnablePushToTalk", enablePushToTalk.booleanValue());
                }
                // 是否开启声纹识别
                if (null != useVoicePrint) {
                    configJsonObject.put("UseVoiceprint", useVoicePrint.booleanValue());
                }
                if (null != voicePrintId) {
                    configJsonObject.put("VoiceprintId", voicePrintId);
                }

                String agentTypeKey = null;

                for (ARTCAICallEngine.ARTCAICallAgentType agentType: agentTypeList) {
                    switch (agentType) {
                        case VisionAgent:
                            agentTypeKey = AI_AGENT_TYPE_VISION;
                            break;
                        case AvatarAgent:
                            agentTypeKey = AI_AGENT_TYPE_AVATAR;
                            break;
                        case VoiceAgent:
                        default:
                            agentTypeKey = AI_AGENT_TYPE_VOICE;
                            break;
                    }
                    jsonObject.put(agentTypeKey, configJsonObject);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        return jsonObject.toString();
    }

    public static class AppServerService {
        private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

        private static String API_GENERATE_AI_AGENT_SHARE_CALL_PATH = "/api/v1/aiagent/generateAIAgentCall";
        private static String API_GENERATE_AI_AGENT_CALL_PATH = "/api/v2/aiagent/generateAIAgentCall";
        private static String API_START_AI_AGENT_PATH = "/api/v2/aiagent/startAIAgentInstance";
        private static String API_STOP_AI_AGENT_PATH = "/api/v2/aiagent/stopAIAgentInstance";
        private static String API_UPDATE_AI_AGENT_PATH = "/api/v2/aiagent/updateAIAgentInstance";
//        private static String API_REFRESH_TOKEN_PATH = "/api/v1/aiagent/getRtcAuthToken";

        private String mHost = "";

        public AppServerService(String host) {
            mHost = host;
        }

        private String getRequestUrl(String host, String path) {
            if (TextUtils.isEmpty(host)) {
                return mHost + path;
            } else {
                return host + path;
            }
        }

        private void postAsync(String host, String path, String authorization, JSONObject json, IARTCAICallServiceCallback callback) {
            RequestBody body = RequestBody.create(
                    null != json ? json.toString() : "",
                    JSON);
            Request.Builder requestBuilder = new Request.Builder()
                    .url(getRequestUrl(host, path));
            if (!TextUtils.isEmpty(authorization)) {
                requestBuilder.header("Authorization", authorization);
            }
            Request request = requestBuilder
                    .post(body)
                    .build();

            DefaultOkHttpFactory.getHttpClient().newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(@NonNull Call call, @NonNull IOException e) {
                    if (null != callback) {
                        callback.onFail(ERROR_CODE_NETWORK_ERROR, e.getMessage());
                    }
                }

                @Override
                public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
                    ResponseBody responseBody = response.body();
                    String bodyString = null;
                    if (null != responseBody) {
                        try {
                            bodyString = responseBody.string();
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                    if (response.code() == 200) {
                        JSONObject jsonBody = convertResponseJson(bodyString);
                        if (null != jsonBody) {
                            int bizResponseCode = jsonBody.optInt("code");
                            if (bizResponseCode == 200) {
                                if (null != callback) {
                                    callback.onSuccess(jsonBody);
                                }
                            } else {
                                if (null != callback) {
                                    callback.onFail(ERROR_CODE_CUSTOM_BUSINESS_ERROR, bodyString);
                                }
                            }
                        } else {
                            if (null != callback) {
                                callback.onFail(ERROR_CODE_UNKNOWN_BUSINESS_ERROR, bodyString);
                            }
                        }
                    } else {
                        if (null != callback) {
                            callback.onFail(response.code(), "[msg: " + response.message() + ", body: " + bodyString + "]");
                        }
                    }
                }
            });
        }

        private static JSONObject convertResponseJson(String bodyString) {
            JSONObject jsonObject = null;
            if (null != bodyString) {
                try {
                    jsonObject = new JSONObject(bodyString);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            return jsonObject;
        }
    }

}
