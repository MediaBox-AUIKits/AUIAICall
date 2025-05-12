package com.aliyun.auikits.aicall.controller;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.view.ViewGroup;

import com.alivc.rtc.AliRtcEngine;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;
import com.aliyun.auikits.aiagent.util.ARTCAIAgentUtil;
import com.aliyun.auikits.aicall.AUIAICallInCallActivity;
import com.aliyun.auikits.aicall.AUIAIChatInChatActivity;
import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.util.AUIAIConstStrKey;
import com.aliyun.auikits.aicall.util.BizStatHelper;
import com.aliyun.auikits.aiagent.util.Logger;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public abstract class ARTCAICallController {

    public enum AICallState {
        /** 初始化 */
        None,
        /** 接通中 */
        Connecting,
        /** 通话中 */
        Connected,
        /** 通话结束 */
        Over,
        /** 通话出错 */
        Error
    }

    public interface IARTCAICallStateCallback {
        /**
         * 通话状态同步
         * @param oldCallState
         * @param newCallState
         * @param errorCode
         */
        void onAICallEngineStateChanged(AICallState oldCallState, AICallState newCallState, ARTCAICallEngine.AICallErrorCode errorCode);
    }

    protected String mUserId = null;
    protected Context mContext = null;
    protected ARTCAICallEngine mARTCAICallEngine = null;
    protected ARTCAICallEngine.ARTCAICallConfig mARTCAiCallConfig = null;
    protected Handler mCallbackHandler = new Handler(Looper.getMainLooper());
    protected IARTCAICallStateCallback mCallStateCallback = null;
    protected AICallState mCallState = ARTCAICallController.AICallState.None;
    protected ARTCAICallEngine.IARTCAICallEngineCallback mBizCallEngineCallback = null;
    ARTCAICallEngine.ARTCAICallAgentType mAiAgentType;
    protected String mChannelId = "";
    protected String mAIAgentInstanceId = "";
    protected String mAIAgentUserId = "";
    protected String mRtcAuthToken = "";
    protected String mAIAgentRequestId = "";
    protected boolean mEnableVoiceIdList = false;//如果你的业务无需获取音色列表，请把这个开关关闭
    protected List<AudioToneData> mAgentVoiceIdList = new ArrayList<AudioToneData>();

    protected ARTCAICallEngine.IARTCAICallEngineCallback mCallEngineCallbackWrapper = new ARTCAICallEngine.IARTCAICallEngineCallback() {
        @Override
        public void onErrorOccurs(ARTCAICallEngine.AICallErrorCode errorCode) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onErrorOccurs(errorCode);
            }
            setCallState(AICallState.Error, errorCode);
        }

        @Override
        public void onCallBegin() {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onCallBegin();
            }
            setCallState(AICallState.Connected, ARTCAICallEngine.AICallErrorCode.None);
        }

        @Override
        public void onCallEnd() {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onCallEnd();
            }
            setCallState(AICallState.Over, ARTCAICallEngine.AICallErrorCode.None);
        }

        @Override
        public void onAICallEngineRobotStateChanged(ARTCAICallEngine.ARTCAICallRobotState oldRobotState, ARTCAICallEngine.ARTCAICallRobotState newRobotState) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAICallEngineRobotStateChanged(oldRobotState, newRobotState);
            }
        }

        @Override
        public void onUserSpeaking(boolean isSpeaking) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onUserSpeaking(isSpeaking);
            }
        }

        @Override
        public void onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onUserAsrSubtitleNotify(text, isSentenceEnd, sentenceId);
            }
        }

        @Override
        public void onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId, ARTCAICallEngine.VoicePrintStatusCode voicePrintStatusCode) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onUserAsrSubtitleNotify(text, isSentenceEnd, sentenceId, voicePrintStatusCode);
            }
        }

        @Override
        public void onAIAgentSubtitleNotify(String text, boolean end, int userAsrSentenceId) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAIAgentSubtitleNotify(text, end, userAsrSentenceId);
            }
        }

        @Override
        public void onAgentEmotionNotify(String emotion,int userAsrSentenceId) {
            if(null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAgentEmotionNotify(emotion, userAsrSentenceId);
            }
        }

        @Override
        public void onNetworkStatusChanged(String uid, ARTCAICallEngine.ARTCAICallNetworkQuality quality) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onNetworkStatusChanged(uid, quality);
            }
        }

        @Override
        public void onVoiceVolumeChanged(String uid, int volume) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onVoiceVolumeChanged(uid, volume);
            }
        }

        @Override
        public void onVoiceIdChanged(String voiceId) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onVoiceIdChanged(voiceId);
            }
        }

        @Override
        public void onVoiceInterrupted(boolean enable) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onVoiceInterrupted(enable);
            }
        }

        @Override
        public void onAgentStarted() {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAgentStarted();
            }

            ARTCAICallEngine.ARTCAICallAgentInfo agentInfo= mARTCAICallEngine.getAgentInfo();
            mAIAgentInstanceId = agentInfo.instanceId;
            mAIAgentUserId = agentInfo.agentUserId;
            mChannelId = agentInfo.channelId;
            mAIAgentRequestId = agentInfo.requestId;

            if(mEnableVoiceIdList) {
                mARTCAICallEngine.getIARTCAICallService().describeAIAgentInstance(mUserId, agentInfo.instanceId, getVoiceIdListCallback());
            }
        }

        @Override
        public void onAgentVideoAvailable(boolean available) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAgentVideoAvailable(available);
            }
        }

        @Override
        public void onAgentAudioAvailable(boolean available) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAgentAudioAvailable(available);
            }
        }

        @Override
        public void onAgentAvatarFirstFrameDrawn() {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAgentAvatarFirstFrameDrawn();
            }
        }

        @Override
        public void onUserOnLine(String uid) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onUserOnLine(uid);
            }
        }

        @Override
        public void onPushToTalk(boolean enable) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onPushToTalk(enable);
            }
        }

        @Override
        public void onVoicePrintEnable(boolean enable) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onVoicePrintEnable(enable);
            }
        }

        @Override
        public void onVoicePrintCleared() {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onVoicePrintCleared();
            }
        }

        @Override
        public void onAgentWillLeave(int reason, String message) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAgentWillLeave(reason, message);
            }
        }

        @Override
        public void onReceivedAgentCustomMessage(String data) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onReceivedAgentCustomMessage(data);
            }
        }
        @Override
        public void onHumanTakeoverWillStart(String takeoverUid, int takeoverMode) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onHumanTakeoverWillStart(takeoverUid, takeoverMode);
            }
        }

        @Override
        public void onHumanTakeoverConnected(String takeoverUid) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onHumanTakeoverConnected(takeoverUid);
            }
        }

        @Override
        public void onAudioDelayInfo(int id, int delay_ms) {
            if(null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAudioDelayInfo(id, delay_ms);
            }
        }

        @Override
        public void onVisionCustomCapture(boolean enable) {
            if(null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onVisionCustomCapture(enable);
            }
        }

        @Override
        public void onSpeakingInterrupted(ARTCAICallEngine.ARTCAICallSpeakingInterruptedReason reason) {
            if(null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onSpeakingInterrupted(reason);
            }
        }

        @Override
        public void onLLMReplyCompleted(String text, int userAsrSentenceId) {
            if(null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onLLMReplyCompleted(text, userAsrSentenceId);
            }
        }

        @Override
        public void onAliRtcEngineCreated(AliRtcEngine engine) {
            if(null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAliRtcEngineCreated(engine);
            }
        }
    };

    protected ARTCAICallController(Context context, String userId) {
        mContext = context;
        mUserId = userId;
        BizStatHelper.init(context);
    }

    public void init(ARTCAICallEngine.ARTCAICallConfig artcaiCallConfig) {
        mARTCAiCallConfig = artcaiCallConfig;
        if (null != mARTCAICallEngine) {
            mARTCAICallEngine.init(artcaiCallConfig);
        }
    }

    public void setAiAgentType(ARTCAICallEngine.ARTCAICallAgentType aiAgentType) {
        this.mAiAgentType = aiAgentType;
        if (null != mARTCAICallEngine) {
            mARTCAICallEngine.setAICallAgentType(aiAgentType);
        }
    }

    public void setCallStateCallback(IARTCAICallStateCallback callStateCallback) {
        this.mCallStateCallback = callStateCallback;
        if (null != mARTCAICallEngine) {
            mARTCAICallEngine.setEngineCallback(mCallEngineCallbackWrapper);
        }
    }

    public void setBizCallEngineCallback(ARTCAICallEngine.IARTCAICallEngineCallback bizCallEngineCallback) {
        this.mBizCallEngineCallback = bizCallEngineCallback;
    }

    public abstract void start();

    public abstract void startCall(String token);

    public ARTCAICallEngine getARTCAICallEngine() {
        return mARTCAICallEngine;
    }

    public String getChannelId() {
        return mChannelId;
    }

    public String getUserId() {
        return mUserId;
    }

    public String getAiAgentRequestId() {
        String requestId = "0";
        if (!TextUtils.isEmpty(mAIAgentRequestId)) {
            requestId = mAIAgentRequestId;
        }
        return requestId;
    }

    public void rating(int sumRate, int delay, int noise, int recognition, int interactive, int timbre) {
        try {
            JSONObject args = new JSONObject();
            /**
             * final	final	整体评分：1~5
             * delay	delay	通话延时：1~5
             * noise	noise	环境噪音：1~5
             * recognition	reco	人声识别准确率：1~5
             * interactive	intera	交互体验：1~5
             * timbre	timbre	音色拟真度：1~5
             */
            args.put("atype", mAiAgentType == ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent ? "avatar" : "voice");
            args.put("aid", mARTCAiCallConfig.mAiCallAgentTemplateConfig.aiAgentId);
            args.put("ains", mAIAgentInstanceId);
            args.put("ach", mChannelId);
            args.put("auid", mAIAgentUserId);
            args.put("uid", mUserId);
            args.put("final", sumRate);
            args.put("delay", delay);
            args.put("noise", noise);
            args.put("reco", recognition);
            args.put("intera", interactive);
            args.put("timbre", timbre);
            BizStatHelper.stat("2000", args.toString());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void commitReporting(List<Integer> reportTypeIdList, String otherTypeDesc) {

        if (null == reportTypeIdList || reportTypeIdList.isEmpty()) {
            return;
        }
        try {
            {
                JSONObject args = new JSONObject();
                args.put("req_id", mAIAgentRequestId);
                args.put("aid", mARTCAiCallConfig.mAiCallAgentTemplateConfig.aiAgentId);
                args.put("ains", mAIAgentInstanceId);
                args.put("auid", mAIAgentUserId);
                args.put("uid", mUserId);
                args.put("ach", mChannelId);
                args.put("rtc_base64_token", mRtcAuthToken);
                if(mAiAgentType == ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent) {
                    args.put("atype", "VoiceChat");
                } else if(mAiAgentType == ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent) {
                    args.put("atype", "AvatarChat3D");
                } else if (mAiAgentType == ARTCAICallEngine.ARTCAICallAgentType.VisionAgent) {
                    args.put("atype", "VisionChat");
                }
                if (!TextUtils.isEmpty(mRtcAuthToken)) {
                    String decodeJson = new String(Base64.decode(mRtcAuthToken, Base64.DEFAULT));
                    JSONObject tokenJson = new JSONObject(decodeJson);
                    String appId = tokenJson.optString("appid");
                    String userId = tokenJson.optString("userid");

                    String streamType = mAiAgentType == ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent ? "audio" : "camera";
                    args.put("rtc_stream_name", appId + "_" + mChannelId + "_" + userId + "_" + streamType);
                }
                StringBuilder idBuilder = new StringBuilder();
                for (int reportTypeId : reportTypeIdList) {
                    if (idBuilder.length() > 0) {
                        idBuilder.append(",");
                    }
                    idBuilder.append(reportTypeId);
                }
                args.put("rep_type", idBuilder.toString());
                if (!otherTypeDesc.isEmpty()) {
                    args.put("rep_desc", otherTypeDesc);
                }
                BizStatHelper.stat("2001", args.toString());
            }
            {
                JSONObject args = new JSONObject();
                args.put("req_id", mAIAgentRequestId);

                String allLog = Logger.getAllLogRecordStr();
                args.put("log_str", allLog);
                BizStatHelper.stat("2002", args.toString());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void showARTCDebugView(ViewGroup viewGroup, int showType, String userId) {
        if (null != mARTCAICallEngine && null != mARTCAICallEngine.getRtcEngine()) {
            mARTCAICallEngine.getRtcEngine().showDebugView(viewGroup, showType, userId);
        }
    }

    public void enableFetchVoiceIdList(boolean enable) {
        mEnableVoiceIdList = enable;
    }

    public List<AudioToneData> getAgentVoiceList() {
        return mAgentVoiceIdList;
    }

    protected void setCallState(AICallState callState, ARTCAICallEngine.AICallErrorCode aiCallErrorCode) {
        Log.i("AUIAICall", "setCallState: [callState: " + callState + ", aiCallErrorCode: " + aiCallErrorCode + "]");
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                final AICallState oldCallState = mCallState;
                final AICallState newCallState = callState;

                mCallState = newCallState;

                if (null != mCallStateCallback) {
                    mCallStateCallback.onAICallEngineStateChanged(oldCallState, newCallState, aiCallErrorCode);
                }
            }
        });
    }

    private void parseVoiceIdList(JSONObject jsonObject) {
        try {
            if (jsonObject.has("template_config")) {

                JSONObject templateConfig = new JSONObject(jsonObject.optString("template_config"));
                if(templateConfig.has(getAgentStrByType(mAiAgentType))) {
                    JSONObject agentConfig = templateConfig.getJSONObject(getAgentStrByType(mAiAgentType));
                    if(agentConfig.has("VoiceId")) {
                        mARTCAiCallConfig.mAiCallAgentTemplateConfig.aiAgentVoiceId = agentConfig.optString("VoiceId");
                    }
                    if(agentConfig.has("VoiceIdList")) {
                        JSONArray voiceIdList = agentConfig.getJSONArray("VoiceIdList");
                        mAgentVoiceIdList.clear();
                        for(int i = 0; i < voiceIdList.length(); i++) {
                            String voiceId = (String) voiceIdList.get(i);
                            AudioToneData audioTone = new AudioToneData(voiceId, voiceId);
                            if(i % 3 == 0)
                            {
                                audioTone.setIconResId(R.drawable.ic_audio_tone_0);
                            } else if(i % 3 == 1) {
                                audioTone.setIconResId(R.drawable.ic_audio_tone_1);
                            } else if(i % 3 == 2) {
                                audioTone.setIconResId(R.drawable.ic_audio_tone_2);
                            }
                            audioTone.setUsing(mARTCAiCallConfig.mAiCallAgentTemplateConfig.aiAgentVoiceId.equals(audioTone.getAudioToneId()));
                            mAgentVoiceIdList.add(audioTone);
                        }
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private String getAgentStrByType(ARTCAICallEngine.ARTCAICallAgentType type) {

        String agentTypeStr;
        switch (type) {
            case AvatarAgent:
                agentTypeStr = "AvatarChat3D";
                break;
            case VisionAgent:
                agentTypeStr = "VisionChat";
                break;
            case VoiceAgent:
            default:
                agentTypeStr = "VoiceChat";
                break;
        }
        return agentTypeStr;
    }

    protected IARTCAICallService.IARTCAICallServiceCallback getVoiceIdListCallback() {
        return new IARTCAICallService.IARTCAICallServiceCallback() {
            @Override
            public void onSuccess(JSONObject jsonObject) {
                mCallbackHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        parseVoiceIdList(jsonObject);
                    }
                });
            }

            @Override
            public void onFail(int errorCode, String errorMsg) {
                Log.i("AUIAICall", "getVoiceIdListCallback fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");

            }
        };
    }


    protected IARTCAICallService.IARTCAICallServiceCallback getStartActionCallback() {
        return new IARTCAICallService.IARTCAICallServiceCallback() {
            @Override
            public void onSuccess(JSONObject jsonObject) {

                mCallbackHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        ARTCAIAgentUtil.ARTCAIAgentInfo aiAgentInfo = ARTCAIAgentUtil.parseAiAgentInfo(jsonObject);

                        mAIAgentInstanceId = aiAgentInfo.aIAgentInstanceId;
                        mRtcAuthToken = aiAgentInfo.rtcAuthToken;
                        mAIAgentUserId = aiAgentInfo.aIAgentUserId;
                        mChannelId = aiAgentInfo.channelId;
                        mAIAgentRequestId = aiAgentInfo.requestId;

                        if(mEnableVoiceIdList) {
                            mARTCAICallEngine.getIARTCAICallService().describeAIAgentInstance(mUserId, mAIAgentInstanceId, getVoiceIdListCallback());
                        }

                        Log.i("AUIAICall", "StartActionCallback succ result: " + jsonObject);
                        mARTCAICallEngine.call(mRtcAuthToken, mAIAgentInstanceId, mAIAgentUserId, mChannelId);
                    }
                });
            }

            @Override
            public void onFail(int errorCode, String errorMsg) {
                Log.i("AUIAICall", "StartActionCallback fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                boolean hasSet = false;
                if (errorCode == IARTCAICallService.ERROR_CODE_CUSTOM_BUSINESS_ERROR) {
                    try {
                        JSONObject bodyJson = new JSONObject(errorMsg);
                        String customBusinessErrorCode = bodyJson.optString("error_code");
                        if ("Forbidden.SubscriptionRequired".equals(customBusinessErrorCode)) {
                            setCallState(AICallState.Error, ARTCAICallEngine.AICallErrorCode.AgentSubscriptionRequired);
                            hasSet = true;
                        } else if("AgentNotFound".equals(customBusinessErrorCode)) {
                            setCallState(AICallState.Error, ARTCAICallEngine.AICallErrorCode.AgentNotFund);
                            hasSet = true;
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
                if (!hasSet) {
                    setCallState(AICallState.Error, ARTCAICallEngine.AICallErrorCode.StartFailed);
                }
            }
        };
    }

    public static void launchCallActivity(Activity currentActivity, String shareToken, String loginUserId,
                                          String loginAuthorization) {
        ARTCAIAgentUtil.ARTCAIAgentShareInfo shareInfo =
                ARTCAIAgentUtil.parseAiAgentShareInfo(shareToken);
        // 智能体ID
        String aiAgentId = shareInfo.aiAgentId;
        String aiAgentRegion = shareInfo.region;
        // 智能体类型
        ARTCAICallEngine.ARTCAICallAgentType aiCallAgentType =
                ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
        if ("AvatarChat3D".equals(shareInfo.workflowType)) {
            aiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;
        } else if ("VisionChat".equals(shareInfo.workflowType)) {
            aiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.VisionAgent;
        } else if("MessageChat".equals(shareInfo.workflowType)) {
            aiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.ChatBot;
        }
        Intent intent = null;
        if(aiCallAgentType == ARTCAICallEngine.ARTCAICallAgentType.ChatBot) {
            intent = new Intent(currentActivity, AUIAIChatInChatActivity.class);
        } else {
            intent = new Intent(currentActivity, AUIAICallInCallActivity.class);
        }
        long expireTimestamp = shareInfo.expireTimestamp;


        // 进入rtc的用户id，建议使用业务的登录用户id
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, loginUserId);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_AUTHORIZATION, loginAuthorization);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, aiCallAgentType);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, aiAgentId);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_REGION, aiAgentRegion);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_IS_SHARED_AGENT, true);
        intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_TOKEN_EXPIRE_TIMESTAMP, expireTimestamp);

        currentActivity.startActivity(intent);
    }
}
