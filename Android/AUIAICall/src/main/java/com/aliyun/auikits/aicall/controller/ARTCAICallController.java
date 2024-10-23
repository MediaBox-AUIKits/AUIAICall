package com.aliyun.auikits.aicall.controller;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

import org.json.JSONObject;

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
        public void onAIAgentSubtitleNotify(String text, boolean end, int userAsrSentenceId) {
            if (null != mBizCallEngineCallback) {
                mBizCallEngineCallback.onAIAgentSubtitleNotify(text, end, userAsrSentenceId);
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
    };
    protected ARTCAICallController(Context context, String userId) {
        mContext = context;
        mUserId = userId;
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

    public ARTCAICallEngine getARTCAICallEngine() {
        return mARTCAICallEngine;
    }

    public String getChannelId() {
        return mChannelId;
    }

    public String getUserId() {
        return mUserId;
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

    protected IARTCAICallService.IARTCAICallServiceCallback getStartActionCallback() {
        return new IARTCAICallService.IARTCAICallServiceCallback() {
            @Override
            public void onSuccess(JSONObject jsonObject) {

                mCallbackHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        String aIAgentInstanceId = jsonObject.optString("ai_agent_instance_id");
                        String rtcAuthToken = jsonObject.optString("rtc_auth_token");
                        String aIAgentUserId = jsonObject.optString("ai_agent_user_id");
                        mChannelId = jsonObject.optString("channel_id");

                        if (jsonObject.has("workflow_type")) {
                            ARTCAICallEngine.ARTCAICallAgentType artcaiCallAgentType;
                            String workflowType = jsonObject.optString("workflow_type");
                            if (IARTCAICallService.AI_AGENT_TYPE_AVATAR.equals(workflowType)) {
                                artcaiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;
                            } else if (IARTCAICallService.AI_AGENT_TYPE_VISION.equals(workflowType)) {
                                artcaiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.VisionAgent;
                            } else {
                                artcaiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
                            }
                            mARTCAICallEngine.setAICallAgentType(artcaiCallAgentType);
                        }
                        Log.i("AUIAICall", "StartActionCallback succ result: " + jsonObject);
                        mARTCAICallEngine.call(rtcAuthToken, aIAgentInstanceId, aIAgentUserId, mChannelId);
                    }
                });
            }

            @Override
            public void onFail(int errorCode, String errorMsg) {
                Log.i("AUIAICall", "StartActionCallback fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                setCallState(AICallState.Error, ARTCAICallEngine.AICallErrorCode.StartFailed);
            }
        };
    }
}
