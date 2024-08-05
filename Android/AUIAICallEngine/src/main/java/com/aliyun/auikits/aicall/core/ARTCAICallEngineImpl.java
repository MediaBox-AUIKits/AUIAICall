package com.aliyun.auikits.aicall.core;

import static com.alivc.rtc.AliRtcEngine.AliRtcDataMsgType.AliEngineDataMsgCustom;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.alivc.rtc.AliRtcEngine;
import com.alivc.rtc.AliRtcEngineEventListener;
import com.alivc.rtc.AliRtcEngineNotify;
import com.aliyun.auikits.aicall.core.service.ARTCAICallRtcWrapper;
import com.aliyun.auikits.aicall.core.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aicall.core.service.IARTCAICallIMService;
import com.aliyun.auikits.aicall.core.service.IARTCAICallService;
import com.aliyun.auikits.aicall.core.util.IMsgTypeDef;

import org.json.JSONObject;

import java.util.List;

public class ARTCAICallEngineImpl extends ARTCAICallEngine {
    private static final String TAG = "AUIAICall";
    private String mUserId;
    private ARTCAICallConfig mCallConfig = new ARTCAICallConfig();
    private AICallState mCallState = AICallState.None;
    private AICallMode mCallMode = AICallMode.OnlyAudio;
    private ARTCAICallRobotState mARTCAICallRobotState = ARTCAICallRobotState.Listening;

    private IARTCAICallEngineCallback mEngineCallback = null;

    private ARTCAICallRtcWrapper mARTCAICallRtcWrapper = null;
    private IARTCAICallService mARTCAICallService = null;

    private Context mContext = null;
    private String mRobotInstanceId = "";
    private String mRtcAuthToken;
    private String mRobotUserId;
    private String mChannelId;

    private boolean mIsRtcTokenRefreshing = false;
    private boolean mIsHangUp = false;

    IARTCAICallIMService mImService = new IARTCAICallIMService() {
        @Override
        public void sendMessage(int msgType, String senderId, String receiverId, JSONObject data) {
            mARTCAICallRtcWrapper.sendCustomMessage(msgType, senderId, receiverId, data);
        }
    };

    private AliRtcEngineEventListener mRtcEngineEventListener = new AliRtcEngineEventListener() {
        @Override
        public void onJoinChannelResult(int result, String channel, String userId, int elapsed) {
            super.onJoinChannelResult(result, channel, userId, elapsed);

            Log.i(TAG, "onJoinChannelResult: [result: " + result + ", channel: " + channel + ", userId: " + userId + ", elapsed: " + elapsed + "]");
            if (result == 0) {
                setCallState(AICallState.Connected);
                syncConfigToRTCEngine();
            } else {
                setCallState(AICallState.Error, AICallErrorCode.StartFailed);
            }
        }

        @Override
        public void onLeaveChannelResult(int result, AliRtcEngine.AliRtcStats stats) {
            super.onLeaveChannelResult(result, stats);
            Log.i(TAG, "onLeaveChannelResult: [result: " + result + ", stats: " + stats + "]");
            if (result == 0) {
                setCallState(AICallState.Over);
            }
        }

        @Override
        public void onConnectionStatusChange(AliRtcEngine.AliRtcConnectionStatus status, AliRtcEngine.AliRtcConnectionStatusChangeReason reason) {
            super.onConnectionStatusChange(status, reason);
            Log.i(TAG, "onConnectionStatusChange: [status: " + status + ", reason: " + reason + "]");
            if (status == AliRtcEngine.AliRtcConnectionStatus.AliRtcConnectionStatusFailed) {
                setCallState(AICallState.Error, AICallErrorCode.ConnectionFailed);
            }
        }

        @Override
        public void OnLocalDeviceException(AliRtcEngine.AliRtcEngineLocalDeviceType deviceType, AliRtcEngine.AliRtcEngineLocalDeviceExceptionType exceptionType, String msg) {
            super.OnLocalDeviceException(deviceType, exceptionType, msg);
            Log.i(TAG, "OnLocalDeviceException: [deviceType: " + deviceType + ", exceptionType: " + exceptionType + ", msg: " + msg + "]");
            setCallState(AICallState.Error, AICallErrorCode.LocalDeviceException);
        }
    };

    private AliRtcEngineNotify mRtcEngineRemoteNotify = new AliRtcEngineNotify() {
        @Override
        public void onBye(int code) {
            super.onBye(code);
            Log.i(TAG, "onBye: [code: " + code + "]");
            if (code == 1 /* AliRtcEngine.AliRtcOnByeType.AliRtcByeTypeRestoreSession */) {
                setCallState(AICallState.Error, AICallErrorCode.KickedByUserReplace);
            } else if (code == 3 /* AliRtcEngine.AliRtcOnByeType.AliRtcByeTypeKickOff */) {
                setCallState(AICallState.Error, AICallErrorCode.KickedBySystem);
            }

            handup();
        }

        @Override
        public void onAuthInfoWillExpire() {
            super.onAuthInfoWillExpire();
            Log.i(TAG, "onAuthInfoWillExpire");
            refreshRTCToken();
        }

        @Override
        public void onAuthInfoExpired() {
            super.onAuthInfoExpired();
            Log.i(TAG, "onAuthInfoExpired");
            setCallState(AICallState.Error, AICallErrorCode.TokenExpired);
        }

        @Override
        public void onDataChannelMessage(String uid, AliRtcEngine.AliRtcDataChannelMsg msg) {
            super.onDataChannelMessage(uid, msg);

            if (msg.type == AliEngineDataMsgCustom) {
                try {
                    String dataStr = new String(msg.data);
                    JSONObject jsonObject = new JSONObject(dataStr);
                    int msgType = jsonObject.optInt("type");
                    String senderId = jsonObject.optString("senderId");
                    String receiverId = jsonObject.optString("receiverId");
                    JSONObject dataJson = jsonObject.optJSONObject("data");
                    if (null != dataJson) {
                        Log.i("ARTCAICallEngineImpl", "onDataChannelMessage: " + dataStr);
                        if (msgType == IMsgTypeDef.MSG_TYPE_ROBOT_STATE_CHANGE) {
                            int robotState = dataJson.optInt("state");
                            ARTCAICallRobotState artcaiCallRobotState = null;
                            if (robotState == IMsgTypeDef.ROBOT_STATE.ROBOT_STATE_LISTENING) {
                                artcaiCallRobotState = ARTCAICallRobotState.Listening;
                            } else if (robotState == IMsgTypeDef.ROBOT_STATE.ROBOT_STATE_THINKING) {
                                artcaiCallRobotState = ARTCAICallRobotState.Thinking;
                            } else if (robotState == IMsgTypeDef.ROBOT_STATE.ROBOT_STATE_SPEAKING) {
                                artcaiCallRobotState = ARTCAICallRobotState.Speaking;
                            }
                            if (null != artcaiCallRobotState) {
                                setARTCAICallRobotState(artcaiCallRobotState);
                            }
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_ROBOT_TEXT) {
                            /**
                             * "data": {
                             *     "text": "这是AI机器人产生的文本内容",  // AI机器人生成的具体文本
                             *     "sentenceId": 1            		 // 表示回应对应sentenceId语音输入的的llm内容
                             *   }
                             */
                            String text = dataJson.optString("text");
                            int sentenceId = dataJson.optInt("sentenceId");
                            notifyRobotSubtitle(text, sentenceId);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_USER_ASR_TEXT) {
                            /**
                             *   "data": {
                             *     "text": "这是ASR识别到的目前文本内容",  // ASR识别出的具体文本
                             *     "end": false,                       // 当前文本是否为这句话的最终结果
                             *     "sentenceId": 1                     // 当前文本属于的句子ID
                             *   }
                             */
                            String text = dataJson.optString("text");
                            boolean end = dataJson.optBoolean("end");
                            int sentenceId = dataJson.optInt("sentenceId");
                            notifyUserAsrSubtitle(text, end, sentenceId);
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    };

    private AliRtcEngine.AliRtcAudioVolumeObserver mAudioVolumeObserver = new AliRtcEngine.AliRtcAudioVolumeObserver() {
        @Override
        public void onAudioVolume(List<AliRtcEngine.AliRtcAudioVolume> speakers, int totalVolume) {
            super.onAudioVolume(speakers, totalVolume);
            if (null != speakers) {
                for (AliRtcEngine.AliRtcAudioVolume speaker : speakers) {
//                    Log.i(TAG, "onAudioVolume: [userId: " + speaker.mUserId + ", state: " + speaker.mSpeechstate + ", volume: " + speaker.mVolume + "]");
                    final boolean isSpeaking = speaker.mSpeechstate == 1 && speaker.mVolume > 5;
                    if ("0".equals(speaker.mUserId)) {
                        if (null != mEngineCallback) {
                            final IARTCAICallEngineCallback engineCallback = mEngineCallback;
                            mCallbackHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    engineCallback.onUserSpeaking(isSpeaking);
                                }
                            });
                        }
                    }
                }
            }
        }
    };

    private Handler mCallbackHandler = new Handler(Looper.getMainLooper());

    public ARTCAICallEngineImpl(Context context, String userId) {
        mContext = context;
        mUserId = userId;
        mARTCAICallService = new ARTCAICallServiceImpl();
        mARTCAICallService.setIMService(mImService);
        mARTCAICallRtcWrapper = new ARTCAICallRtcWrapper();
    }

    @Override
    public void init(ARTCAICallConfig config) {
        mCallConfig = config;
        ARTCAICallServiceImpl.AppServerService.sUsePreHost = config.usePreHost;
    }

    @Override
    public void start() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                setCallState(AICallState.Connecting);
                // 调用启动服务
                mARTCAICallService.startAIGCRobotService(mUserId, mCallConfig.robotId, new IARTCAICallService.IARTCAICallServiceCallback() {
                    @Override
                    public void onSuccess(JSONObject jsonObject) {

                        mCallbackHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                mRobotInstanceId = jsonObject.optString("robot_instance_id");
                                mRtcAuthToken = jsonObject.optString("rtc_auth_token");
                                mRobotUserId = jsonObject.optString("robot_user_id");
                                mChannelId = jsonObject.optString("channel_id");

                                Log.i(TAG, "startAIGCRobotService succ result: " + jsonObject);
                                if (!mIsHangUp) {
                                    ARTCAICallRtcWrapper.ARtcConfig rtcConfig = new ARTCAICallRtcWrapper.ARtcConfig();
                                    rtcConfig.enableAudioDump = mCallConfig.enableAudioDump;
                                    mARTCAICallRtcWrapper.init(mContext, rtcConfig, mRtcEngineEventListener,
                                            mRtcEngineRemoteNotify, mAudioVolumeObserver);
                                    mARTCAICallRtcWrapper.join(mRtcAuthToken);
                                }
                            }
                        });
                    }

                    @Override
                    public void onFail(int errorCode, String errorMsg) {
                        Log.i(TAG, "startAIGCRobotService fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                        setCallState(AICallState.Error, AICallErrorCode.StartFailed);
                    }
                });
            }
        });
    }

    @Override
    public void handup() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                mIsHangUp = true;
                mARTCAICallRtcWrapper.leave();
                Log.i(TAG, "handup [mRobotInstanceId: " + mRobotInstanceId + "]");
                // 调用关闭服务
                if (!TextUtils.isEmpty(mRobotInstanceId)) {
                    mARTCAICallService.stopAIGCRobotService(mRobotInstanceId, new IARTCAICallService.IARTCAICallServiceCallback() {
                        @Override
                        public void onSuccess(JSONObject jsonObject) {
                            Log.i(TAG, "stopAIGCRobotService succ");
                        }

                        @Override
                        public void onFail(int errorCode, String errorMsg) {
                            Log.i(TAG, "stopAIGCRobotService fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                        }
                    });
                }
            }
        });
    }

    @Override
    public boolean pause() {
        if (isAICallConnected()) {
            Log.i(TAG, "pause");
            interruptSpeaking();
            mARTCAICallRtcWrapper.pauseAudioCommunication(mRobotUserId);

            mCallConfig.isCallPaused = true;
            return true;
        }
        return false;
    }

    @Override
    public boolean resume() {
        if (isAICallConnected()) {
            Log.i(TAG, "resume");
            mARTCAICallRtcWrapper.resumeAudioCommunication(mRobotUserId);

            mCallConfig.isCallPaused = false;
            return true;
        }
        return false;
    }

    @Override
    public boolean interruptSpeaking() {
        if (isAICallConnected()) {
            // 发送信令 手动打断
            Log.i("AUIAICall", "interruptSpeaking");
            mARTCAICallService.interruptRobotSpeak();
            return true;
        }
        return false;
    }

    @Override
    public boolean enableVoiceInterrupt(boolean enable) {
        if (isAICallConnected()) {
            mCallConfig.enableVoiceInterrupt = enable;

            // 发送网络请求 修改智能打断开关
            mARTCAICallService.enableVoiceInterrupt(mRobotInstanceId, enable, new IARTCAICallService.IARTCAICallServiceCallback() {
                @Override
                public void onSuccess(JSONObject jsonObject) {
                    Log.i(TAG, "enableVoiceInterrupt succ");
                }

                @Override
                public void onFail(int errorCode, String errorMsg) {
                    Log.i(TAG, "enableVoiceInterrupt fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                }
            });
            return true;
        }
        return false;
    }

    @Override
    public boolean enableSpeaker(boolean enable) {
//        Log.e("enableSpeaker", "enable: " + enable, new Throwable());
        mCallConfig.enableSpeaker = enable;
        if (isAICallConnected()) {
            // 调用rtc扬声器开关
            Log.i(TAG, "enableSpeaker [enable: " + enable + "]");
            mARTCAICallRtcWrapper.enableSpeaker(enable);
            return true;
        }
        return false;
    }

    @Override
    public boolean switchRobotVoice(String voiceId) {
        if (isAICallConnected()) {
            mCallConfig.robotVoiceId = voiceId;

            // 发送网络请求 切换音色
            mARTCAICallService.switchRobotVoice(mRobotInstanceId, voiceId, new IARTCAICallService.IARTCAICallServiceCallback() {
                @Override
                public void onSuccess(JSONObject jsonObject) {
                    Log.i(TAG, "switchRobotVoice succ [voiceId: " + voiceId + "]");
                }

                @Override
                public void onFail(int errorCode, String errorMsg) {
                    Log.i(TAG, "switchRobotVoice fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                }
            });
            return true;
        }
        return false;
    }

    @Override
    public String getRobotVoiceId() {
        return mCallConfig.robotVoiceId;
    }

    @Override
    public void setEngineCallback(IARTCAICallEngineCallback engineCallback) {
        mEngineCallback = engineCallback;
    }

    @Override
    public boolean isCallPaused() {
        return mCallConfig.isCallPaused;
    }

    @Override
    public boolean isSpeakerOn() {
        return mCallConfig.enableSpeaker;
    }

    @Override
    public boolean isVoiceInterruptEnable() {
        return mCallConfig.enableVoiceInterrupt;
    }

    @Override
    public void switchMicrophone(boolean on) {
//        Log.e("switchMicrophone", "on: " + on, new Throwable());
        mCallConfig.isMicrophoneOn = on;
        if (isAICallConnected()) {
            // 调用rtc麦克风开关
            mARTCAICallRtcWrapper.switchMicrophone(on);
            Log.i(TAG, "switchMicrophone [on: " + on + "]");
        }
    }

    @Override
    public boolean isMicrophoneOn() {
        return mCallConfig.isMicrophoneOn;
    }

    private boolean isAICallConnected() {
        return mCallState == AICallState.Connected;
    }

    private void setCallState(AICallState callState) {
        setCallState(callState, AICallErrorCode.None);
    }

    private void refreshRTCToken() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (!mIsRtcTokenRefreshing) {
                    mIsRtcTokenRefreshing = true;
                    mARTCAICallService.refreshRTCToken(mChannelId, mUserId, new IARTCAICallService.IARTCAICallServiceCallback() {
                        @Override
                        public void onSuccess(JSONObject jsonObject) {
                            mRtcAuthToken = jsonObject.optString("rtc_auth_token");
                            long expiredMillis = jsonObject.optLong("timestamp");
                            onRTCTokenResult(true, mRtcAuthToken);
                        }

                        @Override
                        public void onFail(int errorCode, String errorMsg) {
                            onRTCTokenResult(false, null);
                        }
                    });
                }
            }
        });
    }

    private void onRTCTokenResult(boolean isSucc, String rtcToken) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (isSucc) {
                    mARTCAICallRtcWrapper.refreshRTCToken(rtcToken);
                } else {
                    //TODO log
                }
                mIsRtcTokenRefreshing = false;
            }
        });
    }

    private void setCallState(AICallState callState, AICallErrorCode aiCallErrorCode) {
        Log.i(TAG, "setCallState: [callState: " + callState + ", aiCallErrorCode: " + aiCallErrorCode + "]");
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                final AICallState oldCallState = mCallState;
                final AICallState newCallState = callState;

                mCallState = newCallState;

                if (null != mEngineCallback) {
                    mEngineCallback.onAICallEngineStateChanged(oldCallState, newCallState, aiCallErrorCode);
                }
            }
        });
    }

    private void setCallMode(AICallMode callMode) {
        this.mCallMode = callMode;
    }

    private void setARTCAICallRobotState(ARTCAICallRobotState aRTCAICallRobotState) {
        Log.i(TAG, "setARTCAICallRobotState: [mRobotInstanceId: :" + mRobotInstanceId + ", aRTCAICallRobotState: " + aRTCAICallRobotState + "]");
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                final ARTCAICallRobotState oldARTCAICallRobotState = mARTCAICallRobotState;
                final ARTCAICallRobotState newARTCAICallRobotState = aRTCAICallRobotState;

                mARTCAICallRobotState = newARTCAICallRobotState;

                if (null != mEngineCallback) {
                    mEngineCallback.onAICallEngineRobotStateChanged(oldARTCAICallRobotState, newARTCAICallRobotState);
                }
            }
        });
    }

    private void syncConfigToRTCEngine() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (isAICallConnected()) {
                    switchMicrophone(mCallConfig.isMicrophoneOn);
                    enableSpeaker(mCallConfig.enableSpeaker);
                }
            }
        });
    }

    private void notifyUserAsrSubtitle(String text, boolean isSentenceEnd, int sentenceId) {
        if (!TextUtils.isEmpty(text)) {
            mCallbackHandler.post(new Runnable() {
                @Override
                public void run() {
                    if (null != mEngineCallback) {
                        mEngineCallback.onUserAsrSubtitleNotify(text, isSentenceEnd, sentenceId);
                    }
                }
            });
        }
    }

    private void notifyRobotSubtitle(String text, int userAsrSentenceId) {
        if (!TextUtils.isEmpty(text)) {
            mCallbackHandler.post(new Runnable() {
                @Override
                public void run() {
                    if (null != mEngineCallback) {
                        mEngineCallback.onRobotSubtitleNotify(text, userAsrSentenceId);
                    }
                }
            });
        }
    }
}
