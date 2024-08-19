package com.aliyun.auikits.aicall.core.service;


import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.aliyun.auikits.aicall.core.base.network.DefaultOkHttpFactory;
import com.aliyun.auikits.aicall.core.util.IMsgTypeDef;

import org.json.JSONObject;

import java.io.IOException;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class ARTCAICallServiceImpl implements IARTCAICallService {
    private IARTCAICallIMService mAiCallIMService = null;
    private String mMyUserId = null;
    private String mRobotUserId = null;
    private AppServerService mAppServerService = null;

    public ARTCAICallServiceImpl() {
        mAppServerService = new AppServerService();
    }

    @Override
    public void startAIGCRobotService(String userId, String robotId, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("user_id", userId);
            if (!TextUtils.isEmpty(robotId)) {
                jsonObject.put("robot_id", robotId);
            }
            jsonObject.put("config", composeRobotConfigJson("zhixiaoxia", null, null));
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        mAppServerService.postAsync(AppServerService.getRequestUrl(AppServerService.API_START_ROBOT_PATH), jsonObject, callback);
    }

    @Override
    public void stopAIGCRobotService(String robotInstanceId, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("robot_instance_id", robotInstanceId);
        } catch (Exception ex) {
            ex.printStackTrace();;
        }
        mAppServerService.postAsync(AppServerService.getRequestUrl(AppServerService.API_STOP_ROBOT_PATH), jsonObject, callback);
    }

    @Override
    public void refreshRTCToken(String channelId, String userId, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("channel_id", channelId);
            jsonObject.put("user_id", userId);
        } catch (Exception ex) {
            ex.printStackTrace();;
        }
        mAppServerService.postAsync(AppServerService.getRequestUrl(AppServerService.API_REFRESH_TOKEN_PATH), jsonObject, callback);
    }

    @Override
    public void enableVoiceInterrupt(String robotInstanceId, boolean enable, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("robot_instance_id", robotInstanceId);
            jsonObject.put("config", composeRobotConfigJson(null, null, enable));
        } catch (Exception ex) {
            ex.printStackTrace();;
        }
        mAppServerService.postAsync(AppServerService.getRequestUrl(AppServerService.API_UPDATE_ROBOT_PATH), jsonObject, callback);
    }

    @Override
    public void switchRobotVoice(String robotInstanceId, String voiceId, IARTCAICallServiceCallback callback) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("robot_instance_id", robotInstanceId);
            jsonObject.put("config", composeRobotConfigJson(voiceId, null, null));
        } catch (Exception ex) {
            ex.printStackTrace();;
        }
        mAppServerService.postAsync(AppServerService.getRequestUrl(AppServerService.API_UPDATE_ROBOT_PATH), jsonObject, callback);
    }

    @Override
    public void interruptRobotSpeak() {
        if (null != mAiCallIMService) {
            mAiCallIMService.sendMessage(IMsgTypeDef.MSG_TYPE_INTERRUPT_ROBOT_SPEAK, mMyUserId, mRobotUserId, null);
        }
    }

    @Override
    public void setIMService(IARTCAICallIMService imService) {
        mAiCallIMService = imService;
    }

    private static String composeRobotConfigJson(String voiceId, String greeting, Boolean enableVoiceInterrupt) {
        JSONObject jsonObject = new JSONObject();
        try {
            // 音色名称，修改后下句话生效
            if (null != voiceId) {
                jsonObject.put("VoiceId", voiceId);
            }
            // 问候语，修改后下次入会生效
            if (null != greeting) {
                jsonObject.put("Greeting", greeting);
            }
            // 是否支持语音打断
            if (null != enableVoiceInterrupt) {
                jsonObject.put("EnableVoiceInterrupt", enableVoiceInterrupt.booleanValue());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static class AppServerService {

        private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

        public static boolean sUsePreHost = false;

        private static String API_START_ROBOT_PATH = "/api/v1/imsRobot/startRobot";
        private static String API_STOP_ROBOT_PATH = "/api/v1/imsRobot/stopRobot";
        private static String API_UPDATE_ROBOT_PATH = "/api/v1/imsRobot/updateRobot";
        private static String API_REFRESH_TOKEN_PATH = "/api/v1/imsRobot/getRtcAuthToken";

        public AppServerService() {}

        private static String getRequestUrl(String path) {
            if (sUsePreHost) {
                return AppServiceConst.PRE_HOST + path;
            } else {
                return AppServiceConst.HOST + path;
            }
        }

        private void postAsync(String url, JSONObject json, IARTCAICallServiceCallback callback) {
            RequestBody body = RequestBody.create(
                    null != json ? json.toString() : "",
                    JSON);
            Request request = new Request.Builder()
                    .url(url)
                    .post(body)
                    .build();

            DefaultOkHttpFactory.getHttpClient().newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(@NonNull Call call, @NonNull IOException e) {
                    if (null != callback) {
                        callback.onFail(-1, e.getMessage());
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
                        int bizResponseCode = jsonBody.optInt("code");
                        if (bizResponseCode == 200) {
                            if (null != callback) {
                                callback.onSuccess(jsonBody);
                            }
                        } else {
                            if (null != callback) {
                                callback.onFail(-1, "[bizResponseCode: " + bizResponseCode + "]");
                            }
                        }
                    } else {
                        if (null != callback) {
                            callback.onFail(-1, "[code: " + response.code() + ", msg: " + response.message() + ", body: " + bodyString + "]");
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
