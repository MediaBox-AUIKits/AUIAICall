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
        mAiAgentRegion = artcAiCallConfig.mAiCallAgentTemplateConfig.aiAgentRegion;
        mAppServerService = new AppServerService(artcAiCallConfig.mAiCallAgentTemplateConfig.appServerHost);
        mLoginUserId = artcAiCallConfig.mAiCallAgentTemplateConfig.loginUserId;
        mLoginAuthorization = artcAiCallConfig.mAiCallAgentTemplateConfig.loginAuthrization;
        mUserData = artcAiCallConfig.mAiCallAgentTemplateConfig.userExtendData;
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
                    composeAiAgentTemplateConfigJson(aiAgentType, artcaiCallConfig.mAiCallAgentTemplateConfig, false)
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
            jsonObject.put("template_config",composeAiAgentTemplateConfigJson(aiAgentType, artcaiCallConfig.mAiCallAgentTemplateConfig, false)
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
            jsonObject.put("template_config",composeAiAgentTemplateConfigJson(aiAgentType, artcaiCallConfig.mAiCallAgentTemplateConfig, false));
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
    public void describeAIAgentInstance(String userId, String aiAgentInstanceId, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("user_id", userId);
            jsonObject.put("ai_agent_instance_id", aiAgentInstanceId);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        mAppServerService.postAsync(null, AppServerService.API_DESCRIBE_AI_AGENT_PATH, mLoginAuthorization, jsonObject, callback);
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
    public void enableVoiceInterrupt(String aiAgentInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("ai_agent_instance_id", aiAgentInstanceId);
            jsonObject.put("template_config", composeAiAgentTemplateConfigJson(aiAgentType, artcaiCallConfig.mAiCallAgentTemplateConfig, true));
            jsonObject.put("user_id", mLoginUserId);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(null, AppServerService.API_UPDATE_AI_AGENT_PATH, mLoginAuthorization, jsonObject, callback);
    }


    @Override
    public void switchAiAgentVoice(String robotInstanceId, ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("ai_agent_instance_id", robotInstanceId);
            jsonObject.put("template_config", composeAiAgentTemplateConfigJson(aiAgentType, artcaiCallConfig.mAiCallAgentTemplateConfig, true));
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

    private static String composeAiAgentTemplateConfigJson(ARTCAICallEngine.ARTCAICallAgentType aiAgentType, ARTCAICallEngine.ARTCAICallAgentTemplateConfig templateConfig, boolean isUpdate) {

        JSONObject jsonObject = new JSONObject();
        if (null != templateConfig) {
            try {
                JSONObject configJsonObject = new JSONObject();
                // 问候语，修改后下次入会生效
                if (!TextUtils.isEmpty(templateConfig.aiAgentGreeting)) {
                    configJsonObject.put("Greeting", templateConfig.aiAgentGreeting);
                }
                configJsonObject.put("UserOnlineTimeout", templateConfig.aiAgentUserOnlineTimeout);
                configJsonObject.put("UserOfflineTimeout", templateConfig.aiAgentUserOfflineTimeout);
                if(!TextUtils.isEmpty(templateConfig.aiAgentWorkflowOverrideParams)) {
                    configJsonObject.put("WorkflowOverrideParams", templateConfig.aiAgentWorkflowOverrideParams);
                }
                if(!TextUtils.isEmpty(templateConfig.aiAgentBailianAppParams)) {
                    configJsonObject.put("BailianAppParams", templateConfig.aiAgentBailianAppParams);
                }
                configJsonObject.put("AsrMaxSilence", templateConfig.aiAgentAsrMaxSilence);
                if(templateConfig.aiAgentVolume >= 0) {
                    configJsonObject.put("Volume", templateConfig.aiAgentVolume);
                }
                configJsonObject.put("EnableVoiceInterrupt", templateConfig.enableVoiceInterrupt);
                configJsonObject.put("EnableIntelligentSegment", templateConfig.enableIntelligentSegment);
                if(templateConfig.enableVoicePrint && !TextUtils.isEmpty(templateConfig.voiceprintId)) {
                    configJsonObject.put("UseVoiceprint", templateConfig.enableVoicePrint);
                    if (!isUpdate) {
                        configJsonObject.put("VoiceprintId", templateConfig.voiceprintId);
                    }
                }
                configJsonObject.put("MaxIdleTime", templateConfig.aiAgentMaxIdleTime);

                // 音色名称，修改后下句话生效
                if (!TextUtils.isEmpty(templateConfig.aiAgentVoiceId)) {
                    configJsonObject.put("VoiceId", templateConfig.aiAgentVoiceId);
                }
                // 优雅下线
                if (templateConfig.aiAgentGracefulShutdown) {
                    configJsonObject.put("GracefulShutdown", templateConfig.aiAgentGracefulShutdown);
                }
                // 是否开启对讲机模式
                if (templateConfig.enablePushToTalk) {
                    configJsonObject.put("EnablePushToTalk", templateConfig.enablePushToTalk);
                }

                if(aiAgentType == ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent) {
                    if(!TextUtils.isEmpty(templateConfig.aiAgentAvatarId)) {
                        configJsonObject.put("AvatarId", templateConfig.aiAgentAvatarId);
                    }
                }

                String agentTypeKey = null;
                switch (aiAgentType) {
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
        private static String API_DESCRIBE_AI_AGENT_PATH = "/api/v2/aiagent/describeAIAgentInstance";
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
