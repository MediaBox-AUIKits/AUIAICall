package com.aliyun.auikits.aiagent;

import static com.alivc.rtc.AliRtcEngine.AliRtcAudioTrack.AliRtcAudioTrackMic;
import static com.alivc.rtc.AliRtcEngine.AliRtcDataMsgType.AliEngineDataMsgCustom;
import static com.alivc.rtc.AliRtcEngine.AliRtcVideoTrack.AliRtcVideoTrackCamera;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.ViewGroup;

import com.alivc.rtc.AliRtcEngine;
import com.alivc.rtc.AliRtcEngineEventListener;
import com.alivc.rtc.AliRtcEngineNotify;
import com.aliyun.auikits.aiagent.service.ARTCAICallRtcWrapper;
import com.aliyun.auikits.aiagent.service.ARTCAICallServiceImpl;
import com.aliyun.auikits.aiagent.service.IARTCAICallIMService;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;
import com.aliyun.auikits.aiagent.util.IMsgTypeDef;
import com.aliyun.auikits.aiagent.util.Logger;

import org.json.JSONObject;

import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class ARTCAICallEngineImpl extends ARTCAICallEngine {
    private static final String TAG = "AUIAICall";
    private String mUserId;
    private ARTCAICallConfig mCallConfig = new ARTCAICallConfig();
    private ARTCAICallAgentType mAgentType = ARTCAICallAgentType.VoiceAgent;
    private ARTCAICallRobotState mARTCAICallRobotState = ARTCAICallRobotState.Listening;
    private ViewGroup mAvatarViewGroup = null;
    private ViewGroup.LayoutParams mAvatarLayoutParams = null;
    private ARTCAICallVideoCanvas mPreviewVideoCanvas = new ARTCAICallVideoCanvas();
    private ARTCAICallVideoCanvas mAvatarViewCanvas = new ARTCAICallVideoCanvas();

    private ViewGroup mVisionViewGroup = null;
    private ViewGroup.LayoutParams mVisionLayoutParams = null;

    private IARTCAICallEngineCallback mEngineCallback = null;

    private ARTCAICallRtcWrapper mARTCAICallRtcWrapper = null;
    private IARTCAICallService mARTCAICallService = null;

    private Context mContext = null;
    private String mAIAgentInstanceId = "";
    private String mRtcAuthToken;
    private String mAIAgentUserId;
    private String mAIAgentAvatarUserId = "";
    private String mChannelId;

    private AtomicBoolean mIsJoined = new AtomicBoolean(false);
    private boolean mIsRtcTokenRefreshing = false;
    private AtomicBoolean mIsHangUp = new AtomicBoolean(false);
    private Boolean isMicrophoneEnableBeforePushToTalkMode = null;

    private Handler mCallbackHandler = new Handler(Looper.getMainLooper());

    IARTCAICallIMService mImService = new IARTCAICallIMService() {
        @Override
        public void sendMessage(int msgType, JSONObject data) {
            Log.i(TAG, "sendMessage im : [msgType: " + msgType + ", data: " + (null != data ? data.toString() : "null") + "]");
            mARTCAICallRtcWrapper.sendCustomMessage(msgType, mUserId, mAIAgentUserId, data);
        }
    };

    private AliRtcEngineEventListener mRtcEngineEventListener = new AliRtcEngineEventListener() {
        @Override
        public void onJoinChannelResult(int result, String channel, String userId, int elapsed) {
            super.onJoinChannelResult(result, channel, userId, elapsed);

            Logger.i("onJoinChannelResult: [result: " + result + ", channel: " + channel + ", userId: " + userId + ", elapsed: " + elapsed + "]");
            if (result == 0) {
                mIsJoined.set(true);
                syncConfigToRTCEngine();

                mCallbackHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mARTCAICallRtcWrapper.initLocalPreview();
                    }
                });
            } else {
                notifyErrorOccurs(AICallErrorCode.StartFailed);
            }
        }

        @Override
        public void onLeaveChannelResult(int result, AliRtcEngine.AliRtcStats stats) {
            super.onLeaveChannelResult(result, stats);
            Logger.i("onLeaveChannelResult: [result: " + result + ", stats: " + stats + "]");
            if (result == 0) {
                notifyOnCallEnd();
            }
        }

        @Override
        public void onConnectionStatusChange(AliRtcEngine.AliRtcConnectionStatus status, AliRtcEngine.AliRtcConnectionStatusChangeReason reason) {
            super.onConnectionStatusChange(status, reason);
            Log.i(TAG, "onConnectionStatusChange: [status: " + status + ", reason: " + reason + "]");
            if (status == AliRtcEngine.AliRtcConnectionStatus.AliRtcConnectionStatusFailed) {
                notifyErrorOccurs(AICallErrorCode.ConnectionFailed);
            }
        }

        @Override
        public void OnLocalDeviceException(AliRtcEngine.AliRtcEngineLocalDeviceType deviceType, AliRtcEngine.AliRtcEngineLocalDeviceExceptionType exceptionType, String msg) {
            super.OnLocalDeviceException(deviceType, exceptionType, msg);
            Log.i(TAG, "OnLocalDeviceException: [deviceType: " + deviceType + ", exceptionType: " + exceptionType + ", msg: " + msg + "]");
            notifyErrorOccurs(AICallErrorCode.LocalDeviceException);
        }

        @Override
        public void onVideoSubscribeStateChanged(String uid,
                                                 AliRtcEngine.AliRtcSubscribeState oldState,
                                                 AliRtcEngine.AliRtcSubscribeState newState,
                                                 int elapseSinceLastState, String channel) {
            super.onVideoSubscribeStateChanged(uid, oldState, newState, elapseSinceLastState, channel);
            Logger.i("onVideoSubscribeStateChanged: [uid: " + uid +
                    ", oldState: " + oldState + ", newState: " + newState +
                    ", elapseSinceLastState: " + elapseSinceLastState + ", channel: " + channel + "]");

        }

        @Override
        public void onAudioSubscribeStateChanged(String uid,
                                                 AliRtcEngine.AliRtcSubscribeState oldState,
                                                 AliRtcEngine.AliRtcSubscribeState newState,
                                                 int elapseSinceLastState, String channel) {
            super.onAudioSubscribeStateChanged(uid, oldState, newState, elapseSinceLastState, channel);
//            Log.i(TAG, "onAudioSubscribeStateChanged: [uid: " + uid +
//                    ", oldState: " + oldState + ", newState: " + newState +
//                    ", elapseSinceLastState: " + elapseSinceLastState + ", channel: " + channel + "]");
        }

        @Override
        public void onAudioSubscribeStateChanged(String uid,
                                                 AliRtcEngine.AliRtcAudioTrack track,
                                                 AliRtcEngine.AliRtcSubscribeState oldState,
                                                 AliRtcEngine.AliRtcSubscribeState newState,
                                                 int elapseSinceLastState, String channel) {
            super.onAudioSubscribeStateChanged(uid, track, oldState, newState, elapseSinceLastState, channel);
            Logger.i("onAudioSubscribeStateChanged: [uid: " + uid +
                    ", track: " + track +
                    ", oldState: " + oldState + ", newState: " + newState +
                    ", elapseSinceLastState: " + elapseSinceLastState + ", channel: " + channel + "]");
        }

        @Override
        public void onNetworkQualityChanged(String uid, AliRtcEngine.AliRtcNetworkQuality upQuality, AliRtcEngine.AliRtcNetworkQuality downQuality) {
            super.onNetworkQualityChanged(uid, upQuality, downQuality);
            notifyNetworkStatusChanged(uid, downQuality);
        }
    };

    private AliRtcEngineNotify mRtcEngineRemoteNotify = new AliRtcEngineNotify() {
        @Override
        public void onRemoteUserOnLineNotify(final String uid, final int elapsed) {
            super.onRemoteUserOnLineNotify(uid, elapsed);
            Logger.i("onRemoteUserOnLineNotify: [uid: " + uid +
                    ", elapsed: " + elapsed + "]");
            notifyUserOnline(uid);
        }

        @Override
        public void onRemoteUserOffLineNotify(final String uid, final AliRtcEngine.AliRtcUserOfflineReason reason) {
            super.onRemoteUserOffLineNotify(uid, reason);
            Logger.i("onRemoteUserOffLineNotify: [uid: " + uid +
                    ", reason: " + reason + "]");
            // 关闭智能体离会通知
            if ((!TextUtils.isEmpty(mAIAgentAvatarUserId) && TextUtils.equals(mAIAgentAvatarUserId, uid)) ||
                    (!TextUtils.isEmpty(mAIAgentUserId) && TextUtils.equals(mAIAgentUserId, uid))) {
                notifyErrorOccurs(AICallErrorCode.AgentLeaveChannel);
            }
        }

        @Override
        public void onRemoteTrackAvailableNotify(String uid, AliRtcEngine.AliRtcAudioTrack audioTrack, AliRtcEngine.AliRtcVideoTrack videoTrack) {
            super.onRemoteTrackAvailableNotify(uid, audioTrack, videoTrack);
            Logger.i("onRemoteTrackAvailableNotify: [uid: " + uid +
                    ", audioTrack: " + audioTrack +
                    ", videoTrack: " + videoTrack + "]");

            if (videoTrack == AliRtcVideoTrackCamera) {
                mCallbackHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mARTCAICallRtcWrapper.initRemoteSurfaceView(uid);
                    }
                });
                mAIAgentAvatarUserId = uid;
                notifyOnAgentVideoAvailable(true);
            } else if (audioTrack == AliRtcAudioTrackMic) {
                notifyOnAgentAudioAvailable(true);
            }
        }

        @Override
        public void onFirstAudioPacketReceived(String uid, AliRtcEngine.AliRtcAudioTrack aliRtcAudioTrack, int timeCost) {
            super.onFirstAudioPacketReceived(uid, aliRtcAudioTrack, timeCost);
            Logger.i("onFirstAudioPacketReceived [uid: " + uid + ", aliRtcAudioTrack: " + aliRtcAudioTrack + ", timeCost: " + timeCost + "]");
            notifyOnCallBegin();
        }

        @Override
        public void onFirstVideoPacketReceived(String uid, AliRtcEngine.AliRtcVideoTrack aliRtcVideoTrack, int timeCost) {
            Logger.i("onFirstVideoPacketReceived [uid: " + uid + ", aliRtcVideoTrack: " + aliRtcVideoTrack + ", timeCost: " + timeCost + "]");
            super.onFirstVideoPacketReceived(uid, aliRtcVideoTrack, timeCost);
        }

        @Override
        public void onFirstVideoFrameReceived(String uid, AliRtcEngine.AliRtcVideoTrack aliRtcVideoTrack, int timeCost) {
            Logger.i("onFirstVideoFrameReceived [uid: " + uid + ", aliRtcVideoTrack: " + aliRtcVideoTrack + ", timeCost: " + timeCost + "]");
            super.onFirstVideoFrameReceived(uid, aliRtcVideoTrack, timeCost);
        }

        @Override
        public void onFirstRemoteVideoFrameDrawn(String uid, AliRtcEngine.AliRtcVideoTrack videoTrack, int width, int height, int elapsed) {
            Log.i(TAG, "onFirstRemoteVideoFrameDrawn [uid: " + uid + ", videoTrack: " + videoTrack + "width: " + width + ", height: " + height + ", elapsed: " + elapsed + "]");
            super.onFirstLocalVideoFrameDrawn(width, height, elapsed);
            notifyAgentAvatarFirstFrameDrawn();
        }

        @Override
        public void onUserAudioInterruptedBegin(String uid) {
            Log.i(TAG, "onUserAudioInterruptedBegin");
            super.onUserAudioInterruptedBegin(uid);
            notifyOnAudioInterruptedBegin();
        }

        @Override
        public void onUserAudioInterruptedEnded(String uid) {
            Log.i(TAG, "onUserAudioInterruptedEnded");
            super.onUserAudioInterruptedEnded(uid);
            notifyOnAudioInterruptedEnd();
        }

        @Override
        public void onBye(int code) {
            super.onBye(code);
            Logger.i("onBye: [code: " + code + "]");
            if (code == 1 /* AliRtcEngine.AliRtcOnByeType.AliRtcByeTypeRestoreSession */) {
                notifyErrorOccurs(AICallErrorCode.KickedByUserReplace);
            } else if (code == 3 /* AliRtcEngine.AliRtcOnByeType.AliRtcByeTypeKickOff */) {
                notifyErrorOccurs(AICallErrorCode.KickedBySystem);
            }

            mIsJoined.set(false);
            handup();
        }

        @Override
        public void onAuthInfoWillExpire() {
            super.onAuthInfoWillExpire();
            Logger.i("onAuthInfoWillExpire");
            refreshRTCToken();
        }

        @Override
        public void onAuthInfoExpired() {
            super.onAuthInfoExpired();
            Logger.i("onAuthInfoExpired");
            notifyErrorOccurs(AICallErrorCode.TokenExpired);
        }

        @Override
        public void onDataChannelMessage(String uid, AliRtcEngine.AliRtcDataChannelMsg msg) {
            super.onDataChannelMessage(uid, msg);

            if (msg.type == AliEngineDataMsgCustom) {
                try {
                    String dataStr = new String(msg.data);
                    JSONObject jsonObject = new JSONObject(dataStr);
                    int msgType = jsonObject.optInt("type");
                    int seqId = jsonObject.optInt("seqId");
                    String senderId = jsonObject.optString("senderId");
                    String receiverId = jsonObject.optString("receiverId");
                    JSONObject dataJson = jsonObject.optJSONObject("data");
                    if (null != dataJson) {
                        Log.i(TAG, "onDataChannelMessage: " + dataStr);
                        if (msgType == IMsgTypeDef.MSG_TYPE_AI_AGENT_STATE_CHANGE) {
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
                            boolean end = dataJson.optBoolean("end");
                            int sentenceId = dataJson.optInt("sentenceId");
                            notifyRobotSubtitle(text, end, sentenceId);
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
                            // 1表示识别到主讲人，0表示没有识别到主讲人
                            int voicePrintFlag = dataJson.optInt("voiceprint");
                            notifyUserAsrSubtitle(text, end, sentenceId, voicePrintFlag);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_AI_AGENT_ERROR_NOTIFY) {
                            /**
                             *   "data": {
                             *     "code": 4001,
                             *     "message": "Concurrent routes exhausted"             // 错误描述
                             *   }
                             */
                            int aiAgentErrorCode = dataJson.optInt("code");
                            if (aiAgentErrorCode == IMsgTypeDef.AI_AGENT_ERROR_CODE.AI_AGENT_AUDIO_SUBSCRIBE_FAILED) {
                                notifyErrorOccurs(AICallErrorCode.AgentAudioSubscribeFailed);
                            } else if (aiAgentErrorCode == IMsgTypeDef.AI_AGENT_ERROR_CODE.AI_AGENT_CONCURRENT_ROUTES_EXHAUSTED) {
                                notifyErrorOccurs(AICallErrorCode.AgentConcurrentLimit);
                            } else if (aiAgentErrorCode == IMsgTypeDef.AI_AGENT_ERROR_CODE.AI_AGENT_ASR_UNAVAILABLE) {
                                notifyErrorOccurs(AICallErrorCode.AiAgentAsrUnavailable);
                            } else if (aiAgentErrorCode == IMsgTypeDef.AI_AGENT_ERROR_CODE.AI_AGENT_AVATAR_AGENT_UNAVAILABLE) {
                                notifyErrorOccurs(AICallErrorCode.AvatarAgentUnavailable);
                            }
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_AI_AGENT_LEAVE_NOTIFY) {
                            /**
                             *   {
                             *     "reason": 2001,           // 原因: 2001（智能体触发了闲时退出）
                             *     "message": "闲时退出"      // 描述
                             *   }
                             */
                            int reason = dataJson.optInt("reason");
                            String message = dataJson.optString("message");
                            notifyAiAgentWillLeave(reason, message);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_AI_AGENT_CUSTOM_MESSAGE_NOTIFY) {
                            /**
                             *   {
                             *     "message": "{}"         // 消息内容，使用json字符串
                             *   }
                             */
                            String message = dataJson.optString("message");
                            notifyReceivedAgentCustomMessage(message);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_AI_AGENT_HUMAN_WILL_TAKE_OVER_AGENT) {
                            /**
                             * human take over agent hosting will start soon
                             * "data": {
                             *     "takeoverUid": "human"   // 真人接管的uid
                             *     "takeoverMode": 1//1:表示使用真人音色输出，0:表示使用智能体音色输出
                             *   }
                             */
                            String remoteUserId = dataJson.optString("takeoverUid");
                            int takeMode = dataJson.optInt("takeoverMode");
                            //使用智能体音色输出，不需要订阅真人端
                            if(!TextUtils.isEmpty(remoteUserId) && (takeMode == 0))
                            {
                                mCallbackHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        mARTCAICallRtcWrapper.unSubscribeRemoteUser(remoteUserId);
                                    }
                                });
                            }
                            notifyHumanTakeOverWillStart(remoteUserId, takeMode);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_AI_AGENT_HUMAN_CONNECT_TAKE_OVER_AGENT) {
                            /**
                             * human take over agent hosting connected
                             * "data": {
                             *     "takeoverUid": "human"   // 真人接管的uid
                             *   }
                             */
                            String remoteUserId = dataJson.optString("takeoverUid");
                            if(!TextUtils.isEmpty(remoteUserId))
                            {
                                notifyHumanTakeoverConnected(remoteUserId);
                            }
                        } else if(msgType == IMsgTypeDef.MSG_TYPE_AI_AGENT_EMOTION_NOTIFY) {
                            String motionStr = dataJson.optString("emotion");
                            int sentenceId = dataJson.optInt("sentenceId");
                            notifyAgentEmotionNotify(motionStr, sentenceId);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_PUSH_TO_TALK_ENABLE_RESULT) {
                            boolean enable = dataJson.optBoolean("enable");
                            notifyPushToTalkEnableResult(enable);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_VOICE_PRINT_ENABLE_RESULT) {
                            boolean enable = dataJson.optBoolean("enable");
                            notifyVoicePrintEnableResult(enable);
                        } else if (msgType == IMsgTypeDef.MSG_TYPE_DELETE_PRINT_ENABLE_RESULT) {
                            notifyVoicePrintClearResult();
                        } else {
                            notifyIMMessageReceived(msgType, seqId, senderId, receiverId, dataJson);
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }

        @Override
        public void onAliRtcStats(AliRtcEngine.AliRtcStats aliRtcStats) {
            super.onAliRtcStats(aliRtcStats);
            Log.i(TAG, "onAliRtcStats: " + aliRtcStats);
        }

    };

    private AliRtcEngine.AliRtcAudioVolumeObserver mAudioVolumeObserver = new AliRtcEngine.AliRtcAudioVolumeObserver() {
        @Override
        public void onAudioVolume(List<AliRtcEngine.AliRtcAudioVolume> speakers, int totalVolume) {
            super.onAudioVolume(speakers, totalVolume);
            if (null != speakers) {
                for (AliRtcEngine.AliRtcAudioVolume speaker : speakers) {
                    final boolean isSpeaking = speaker.mSpeechstate == 1 && speaker.mVolume > 5;
                    notifyVoiceVolumeChanged(speaker.mUserId, speaker.mVolume);

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

    private AliRtcEngine.AliRtcAudioDelayObserver mAudioDelayObserver = new AliRtcEngine.AliRtcAudioDelayObserver() {
        @Override
        public void onAudioDelayInfo(int id, long questionEndTime, long answerStartTime) {
            int delay_ms = (int)(answerStartTime - questionEndTime);
            super.onAudioDelayInfo(id, questionEndTime, answerStartTime);
            Log.i(TAG, "onAudioDelayInfo: id:" + id + ", delay: " + delay_ms);
            notifyAudioDelayInfo(id, delay_ms);
        }
    };

    public ARTCAICallEngineImpl(Context context, String userId) {
        mContext = context;
        mUserId = userId;
    }

    @Override
    public void init(ARTCAICallConfig config) {
        Logger.i("init config: " + config);
        mCallConfig = config;

        mARTCAICallService = generateAICallService(mCallConfig);
        mARTCAICallService.setIMService(mImService);
        mARTCAICallRtcWrapper = new ARTCAICallRtcWrapper();
    }

    @Override
    public void call(String rtcToken, String aiAgentInstanceId, String aiAgentUserId, String channelId) {
        Logger.i("call [rtcToken: " + rtcToken + ", aiAgentInstanceId: " + aiAgentInstanceId + ", aiAgentUserId: " + aiAgentUserId + ", channelId: " + channelId + "]");
        if (mIsHangUp.get()) {
            // 回调错误
            notifyErrorOccurs(AICallErrorCode.InvalidAction);
        } else if (TextUtils.isEmpty(aiAgentInstanceId) || TextUtils.isEmpty(rtcToken) || TextUtils.isEmpty(aiAgentUserId) || TextUtils.isEmpty(channelId)) {
            // 回调错误
            notifyErrorOccurs(AICallErrorCode.InvalidParams);
        } else {
            mAIAgentInstanceId = aiAgentInstanceId;
            mRtcAuthToken = rtcToken;
            mAIAgentUserId = aiAgentUserId;
            mChannelId = channelId;

            ARTCAICallRtcWrapper.ARtcConfig rtcConfig = new ARTCAICallRtcWrapper.ARtcConfig();
            rtcConfig.enableRemoteVideo = mAgentType == ARTCAICallAgentType.AvatarAgent;
            rtcConfig.enableLocalVideo = mAgentType == ARTCAICallAgentType.VisionAgent;
            rtcConfig.useHighQualityPreview = mCallConfig.mAiCallVideoConfig.useHighQualityPreview;
            rtcConfig.useFrontCameraDefault = mCallConfig.mAiCallVideoConfig.useFrontCameraDefault;
            rtcConfig.cameraCaptureFrameRate = mCallConfig.mAiCallVideoConfig.cameraCaptureFrameRate;
            rtcConfig.videoEncoderWidth = mCallConfig.mAiCallVideoConfig.videoEncoderWidth;
            rtcConfig.videoEncoderHeight = mCallConfig.mAiCallVideoConfig.videoEncoderHeight;
            rtcConfig.videoEncoderFrameRate = mCallConfig.mAiCallVideoConfig.videoEncoderFrameRate;
            rtcConfig.videoEncoderBitRate = mCallConfig.mAiCallVideoConfig.videoEncoderBitRate;
            rtcConfig.videoEncoderKeyFrameInterval = mCallConfig.mAiCallVideoConfig.videoEncoderKeyFrameInterval;
            rtcConfig.enableAudioDelayInfo = mCallConfig.enableAudioDelayInfo;
            rtcConfig.mLocalRenderMode = getRenderMode(mPreviewVideoCanvas.renderMode);
            rtcConfig.mLocalMirrorMode = getRenderMirrorMode(mPreviewVideoCanvas.mirrorMode);
            rtcConfig.mLocalRotationMode = getRotationMode(mPreviewVideoCanvas.rotationMode);
            rtcConfig.mRemoteRenderMode = getRenderMode(mAvatarViewCanvas.renderMode);
            rtcConfig.mRemoteMirrorMode = getRenderMirrorMode(mAvatarViewCanvas.mirrorMode);
            rtcConfig.mRemoteRotationMode = getRotationMode(mAvatarViewCanvas.rotationMode);
            mARTCAICallRtcWrapper.setAvatarViewGroup(mAvatarViewGroup, mAvatarLayoutParams);
            mARTCAICallRtcWrapper.setVisionPreviewView(mVisionViewGroup, mVisionLayoutParams);
            mARTCAICallRtcWrapper.init(mContext, rtcConfig, mRtcEngineEventListener,
                    mRtcEngineRemoteNotify, mAudioVolumeObserver, mAudioDelayObserver);
            mARTCAICallRtcWrapper.join(mRtcAuthToken);
        }
    }

    @Override
    public void handup() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mIsHangUp.compareAndSet(false, true)) {
                    Logger.i("handup begin");
                    Runnable rtcLeaveRunnable = new Runnable() {
                        @Override
                        public void run() {

                            mARTCAICallRtcWrapper.leave();
                            mARTCAICallRtcWrapper.destroy();

                            notifyOnCallEnd();

                            Logger.i("handup end");
                        }
                    };

                    String loopDelay = mARTCAICallRtcWrapper.getLoopDelay();
                    Logger.i("handup [mRobotInstanceId: " + mAIAgentInstanceId + ", loopDelay: " + loopDelay + "]");
                    boolean needCallLeaveRunnableNextLoop = false;
                    // 调用关闭服务
                    if (!TextUtils.isEmpty(mAIAgentInstanceId)) {
                        needCallLeaveRunnableNextLoop = mARTCAICallService.stopAIAgentService(mAIAgentInstanceId, new IARTCAICallService.IARTCAICallServiceCallback() {
                            @Override
                            public void onSuccess(JSONObject jsonObject) {
                                Logger.i("stopAIGCRobotService succ");
                            }

                            @Override
                            public void onFail(int errorCode, String errorMsg) {
                                Logger.i("stopAIGCRobotService fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                            }
                        });
                    }

                    if (!needCallLeaveRunnableNextLoop) {
                        rtcLeaveRunnable.run();
                    } else {
                        mCallbackHandler.postDelayed(rtcLeaveRunnable, 100);
                    }
                }
            }
        });
    }

    @Override
    public boolean interruptSpeaking() {
        if (isJoinedChannel()) {
            // 发送信令 手动打断
            Log.i("AUIAICall", "interruptSpeaking");
            mARTCAICallService.interruptAiAgentSpeak();
            return true;
        }
        return false;
    }

    @Override
    public boolean enableVoiceInterrupt(boolean enable) {
        if (isJoinedChannel()) {
            mCallConfig.mAiCallAgentTemplateConfig.enableVoiceInterrupt = enable;

            // 发送网络请求 修改智能打断开关
            mARTCAICallService.enableVoiceInterrupt(mAIAgentInstanceId, mAgentType, mCallConfig, new IARTCAICallService.IARTCAICallServiceCallback() {
                @Override
                public void onSuccess(JSONObject jsonObject) {
                    if (null != jsonObject) {
                        boolean enable = jsonObject.optBoolean("enable");
                        notifyVoiceInterruptedSwitch(enable);
                    }
                    Logger.i("enableVoiceInterrupt succ");
                }

                @Override
                public void onFail(int errorCode, String errorMsg) {
                    Logger.i("enableVoiceInterrupt fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
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
        if (isJoinedChannel()) {
            // 调用rtc扬声器开关
            Logger.i("enableSpeaker [enable: " + enable + "]");
            mARTCAICallRtcWrapper.enableSpeaker(enable);
            return true;
        }
        return false;
    }

    @Override
    public boolean switchRobotVoice(String voiceId) {
        if (isJoinedChannel()) {
            mCallConfig.mAiCallAgentTemplateConfig.aiAgentVoiceId = voiceId;

            // 发送网络请求 切换音色
            mARTCAICallService.switchAiAgentVoice(mAIAgentInstanceId, mAgentType, mCallConfig, new IARTCAICallService.IARTCAICallServiceCallback() {
                @Override
                public void onSuccess(JSONObject jsonObject) {
                    if (null != jsonObject) {
                        String voiceId = jsonObject.optString("voiceId");
                        notifyVoiceIdChanged(voiceId);
                    }
                    Logger.i("switchRobotVoice succ [voiceId: " + voiceId + "]");
                }

                @Override
                public void onFail(int errorCode, String errorMsg) {
                    Logger.i("switchRobotVoice fail [errorCode: " + errorCode + ", errorMsg: " + errorMsg + "]");
                }
            });
            return true;
        }
        return false;
    }

    @Override
    public String getRobotVoiceId() {
        return mCallConfig.mAiCallAgentTemplateConfig.aiAgentVoiceId;
    }

    @Override
    public void setEngineCallback(IARTCAICallEngineCallback engineCallback) {
        mEngineCallback = engineCallback;
    }

    @Override
    public boolean isSpeakerOn() {
        return mCallConfig.enableSpeaker;
    }

    @Override
    public boolean isVoiceInterruptEnable() {
        return mCallConfig.mAiCallAgentTemplateConfig.enableVoiceInterrupt;
    }

    @Override
    public void setAvatarAgentView(ViewGroup viewGroup, ViewGroup.LayoutParams avatarLayoutParams) {
        mAvatarViewGroup = viewGroup;
        mAvatarLayoutParams = avatarLayoutParams;
    }

    @Override
    public void setAvatarAgentView(ViewGroup viewGroup, ViewGroup.LayoutParams avatarLayoutParams, ARTCAICallVideoCanvas canvas) {
        mAvatarViewGroup = viewGroup;
        mAvatarLayoutParams = avatarLayoutParams;
        if(canvas != null) {
            mAvatarViewCanvas = canvas;
        }
    }

    @Override
    public void setVisionPreviewView(ViewGroup viewGroup, ViewGroup.LayoutParams visionLayoutParams) {
        mVisionViewGroup = viewGroup;
        mVisionLayoutParams = visionLayoutParams;
    }

    @Override
    public  void setVisionPreviewView(ViewGroup viewGroup, ViewGroup.LayoutParams visionLayoutParams, ARTCAICallVideoCanvas canvas) {
        mVisionViewGroup = viewGroup;
        mVisionLayoutParams = visionLayoutParams;
        if(canvas != null) {
            mPreviewVideoCanvas = canvas;
        }
    }

    @Override
    public boolean muteLocalCamera(boolean mute) {
        mCallConfig.isCameraMute = mute;
        return mARTCAICallRtcWrapper.muteLocalCamera(mute);
    }

    @Override
    public boolean isLocalCameraMute() {
        return mCallConfig.isCameraMute;
    }

    @Override
    public boolean switchCamera() {
        return mARTCAICallRtcWrapper.switchCamera();
    }

    @Override
    public void switchMicrophone(boolean on) {
//        Log.e("switchMicrophone", "on: " + on, new Throwable());
        mCallConfig.isMicrophoneOn = on;
        if (isJoinedChannel()) {
            // 调用rtc麦克风开关
            mARTCAICallRtcWrapper.switchMicrophone(on);
            Logger.i("switchMicrophone [on: " + on + "]");
        }
    }

    @Override
    public boolean isMicrophoneOn() {
        return mCallConfig.isMicrophoneOn;
    }

    @Override
    public AliRtcEngine getRtcEngine() {
        return mARTCAICallRtcWrapper.getAliRtcEngine();
    }

    @Override
    public IARTCAICallService getIARTCAICallService() {
        return mARTCAICallService;
    }

    @Override
    public boolean useVoicePrint(boolean enable) {
        if (isJoinedChannel()) {
            Logger.i("enableVoicePrint: " + enable);
            mCallConfig.mAiCallAgentTemplateConfig.enableVoicePrint = enable;
            mARTCAICallService.enableVoicePrint(enable);
            return true;
        }
        return false;
    }

    @Override
    public boolean isUsingVoicePrint() {
        return mCallConfig.mAiCallAgentTemplateConfig.enableVoicePrint;
    }

    @Override
    public boolean clearVoicePrint() {
        if (isJoinedChannel()) {
            Logger.i("deleteVoicePrint");
            mARTCAICallService.deleteVoicePrint();
            return true;
        }
        return false;
    }

    @Override
    public boolean enablePushToTalk(boolean enable) {
        if (isJoinedChannel()) {
            Logger.i("enablePushToTalk: " + enable);
            mCallConfig.mAiCallAgentTemplateConfig.enablePushToTalk = enable;
            mARTCAICallService.enablePushToTalk(enable);
            onPushToTalkModeChanged();
            return true;
        }
        return false;
    }

    @Override
    public boolean isPushToTalkEnable() {
        return mCallConfig.mAiCallAgentTemplateConfig.enablePushToTalk;
    }

    @Override
    public boolean startPushToTalk() {
        if (isJoinedChannel()) {
            Logger.i("startToPushToTalk");
            switchMicrophone(true);
            if (mCallConfig.enableAudioDelayInfo || mAgentType == ARTCAICallAgentType.VisionAgent) {
                //visionAgent 或者需要AudioDelayInfo，都需要推送视频
                mARTCAICallRtcWrapper.publishLocalVideoStream(true);
            }
            if(mCallConfig.enableAudioDelayInfo && mAgentType != ARTCAICallAgentType.VisionAgent) {
                //如果不是visionAgent，需要把视频采集关掉
                mARTCAICallRtcWrapper.enableLocalVideo(false);
            }
            mARTCAICallService.startPushToTalk();
            return true;
        }
        return false;
    }

    @Override
    public boolean finishPushToTalk() {
        if (isJoinedChannel()) {
            Logger.i("finishToPushToTalk");
            switchMicrophone(false);
            if (mCallConfig.enableAudioDelayInfo || mAgentType == ARTCAICallAgentType.VisionAgent) {
                //visionAgent 或者需要AudioDelayInfo，都需要推送视频
                mARTCAICallRtcWrapper.publishLocalVideoStream(false);
            }
            if(mCallConfig.enableAudioDelayInfo && mAgentType != ARTCAICallAgentType.VisionAgent) {
                //如果不是visionAgent，需要把视频采集关掉
                mARTCAICallRtcWrapper.enableLocalVideo(false);
            }
            mARTCAICallService.finishPushToTalk();
            return true;
        }
        return false;
    }

    @Override
    public boolean cancelPushToTalk() {
        if (isJoinedChannel()) {
            Logger.i("cancelToPushToTalk");
            mARTCAICallService.cancelPushToTalk();
            return true;
        }
        return false;
    }

    private boolean isJoinedChannel() {
        return mIsJoined.get();
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
                            if (jsonObject.has("rtc_auth_token")) {
                                mRtcAuthToken = jsonObject.optString("rtc_auth_token");
                            } else if (jsonObject.has("token")) {
                                mRtcAuthToken = jsonObject.optString("token");
                            }
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
        Logger.i("onRTCTokenResult: [isSucc: " + isSucc + ", rtcToken: " + rtcToken + "]");
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (isSucc) {
                    mARTCAICallRtcWrapper.refreshRTCToken(rtcToken);
                }
                mIsRtcTokenRefreshing = false;
            }
        });
    }

    @Override
    public void setAICallAgentType(ARTCAICallAgentType aiAgentType) {
        this.mAgentType = aiAgentType;
    }

    protected IARTCAICallService generateAICallService(ARTCAICallConfig artcAiCallConfig) {
        return new ARTCAICallServiceImpl(artcAiCallConfig);
    }

    private void setARTCAICallRobotState(ARTCAICallRobotState aRTCAICallRobotState) {
        Log.i(TAG, "setARTCAICallRobotState: [mRobotInstanceId: :" + mAIAgentInstanceId + ", aRTCAICallRobotState: " + aRTCAICallRobotState + "]");
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
                if (isJoinedChannel()) {
                    enableSpeaker(mCallConfig.enableSpeaker);

                    onPushToTalkModeChanged();
                }
            }
        });
    }

    private void onPushToTalkModeChanged() {
        if (isPushToTalkEnable()) {
            isMicrophoneEnableBeforePushToTalkMode = mCallConfig.isMicrophoneOn;
            switchMicrophone(false);
            mARTCAICallRtcWrapper.publishLocalAudioStream(true);
            mARTCAICallRtcWrapper.publishLocalVideoStream(false);
        } else {
            if (null != isMicrophoneEnableBeforePushToTalkMode) {
                mCallConfig.isMicrophoneOn = isMicrophoneEnableBeforePushToTalkMode;
            }
            switchMicrophone(mCallConfig.isMicrophoneOn);
            mARTCAICallRtcWrapper.publishLocalAudioStream(true);
            if (mCallConfig.enableAudioDelayInfo || mAgentType == ARTCAICallAgentType.VisionAgent) {
                //visionAgent 或者需要AudioDelayInfo，都需要推送视频
                mARTCAICallRtcWrapper.publishLocalVideoStream(true);
            }
            if(mCallConfig.enableAudioDelayInfo && mAgentType != ARTCAICallAgentType.VisionAgent) {
                //如果不是visionAgent，需要把视频采集关掉
                mARTCAICallRtcWrapper.enableLocalVideo(false);
            }
        }

        notifyPushToTalkEnableResult(isPushToTalkEnable());
    }

    private void notifyUserAsrSubtitle(String text, boolean isSentenceEnd, int sentenceId, int voicePrintFlag) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    VoicePrintStatusCode voicePrintStatusCode = VoicePrintStatusCode.Unknown;
                    switch (voicePrintFlag) {
                        case 0:
                            voicePrintStatusCode = VoicePrintStatusCode.Disable;
                            break;
                        case 1:
                            voicePrintStatusCode = VoicePrintStatusCode.EnableWithoutRegister;
                            break;
                        case 2:
                            voicePrintStatusCode = VoicePrintStatusCode.SpeakerRecognized;
                            break;
                        case 3:
                            voicePrintStatusCode = VoicePrintStatusCode.SpeakerNotRecognized;
                            break;
                        default:
                            break;
                    }
                    mEngineCallback.onUserAsrSubtitleNotify(text, isSentenceEnd, sentenceId, voicePrintStatusCode);
                }
            }
        });
    }

    private void notifyRobotSubtitle(String text, boolean end, int userAsrSentenceId) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onAIAgentSubtitleNotify(text, end, userAsrSentenceId);
                }
            }
        });
    }

    protected void notifyNetworkStatusChanged(String uid, AliRtcEngine.AliRtcNetworkQuality quality) {

        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    ARTCAICallNetworkQuality artcaiCallNetworkQuality;
                    switch (quality) {
                        case AliRtcNetworkExcellent:
                            artcaiCallNetworkQuality = ARTCAICallNetworkQuality.Excellent;
                            break;
                        case AliRtcNetworkGood:
                            artcaiCallNetworkQuality = ARTCAICallNetworkQuality.Good;
                            break;
                        case AliRtcNetworkPoor:
                            artcaiCallNetworkQuality = ARTCAICallNetworkQuality.Poor;
                            break;
                        case AliRtcNetworkBad:
                            artcaiCallNetworkQuality = ARTCAICallNetworkQuality.Bad;
                            break;
                        case AliRtcNetworkVeryBad:
                            artcaiCallNetworkQuality = ARTCAICallNetworkQuality.VeryBad;
                            break;
                        case AliRtcNetworkDisconnected:
                            artcaiCallNetworkQuality = ARTCAICallNetworkQuality.Disconnect;
                            break;
                        case AliRtcNetworkUnknow:
                        default:
                            artcaiCallNetworkQuality = ARTCAICallNetworkQuality.Unknow;
                            break;
                    }
                    mEngineCallback.onNetworkStatusChanged(uid, artcaiCallNetworkQuality);
                }
            }
        });
    }

    protected void notifyVoiceVolumeChanged(String uid, int volume) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onVoiceVolumeChanged(uid, volume);
                }
            }
        });
    }

    protected void notifyVoiceIdChanged(String voiceId) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onVoiceIdChanged(voiceId);
                }
            }
        });
    }

    protected void notifyVoiceInterruptedSwitch(boolean enable) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onVoiceInterrupted(enable);
                }
            }
        });
    }

    protected void notifyIMMessageReceived(int msgType, int seqId, String senderId,
            String receiverId, JSONObject dataJson) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mARTCAICallService) {
                    mARTCAICallService.onReceiveMessage(msgType, seqId, senderId, receiverId, dataJson);
                }
            }
        });
    }

    protected void notifyErrorOccurs(AICallErrorCode errorCode) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onErrorOccurs(errorCode);
                }
            }
        });
    }

    protected void notifyOnCallBegin() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onCallBegin();
                }
            }
        });
    }

    protected void notifyOnCallEnd() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onCallEnd();
                }
            }
        });
    }

    protected void notifyOnAudioInterruptedBegin() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
//                if (null != mEngineCallback) {
//                    mEngineCallback.onAudioInterruptedBegin();
//                }
            }
        });
    }

    protected void notifyOnAudioInterruptedEnd() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
//                if (null != mEngineCallback) {
//                    mEngineCallback.onAudioInterruptedEnd();
//                }
            }
        });
    }

    protected void notifyOnAgentVideoAvailable(boolean available) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onAgentVideoAvailable(available);
                }
            }
        });
    }

    protected void notifyOnAgentAudioAvailable(boolean available) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onAgentAudioAvailable(available);
                }
            }
        });
    }

    protected void notifyAgentAvatarFirstFrameDrawn() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onAgentAvatarFirstFrameDrawn();
                }
            }
        });
    }

    protected void notifyUserOnline(String uid) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (null != mEngineCallback) {
                    mEngineCallback.onUserOnLine(uid);
                }
            }
        });
    }

    protected void notifyPushToTalkEnableResult(boolean enable) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("onPushToTalk: " + enable);
                if (null != mEngineCallback) {
                    mEngineCallback.onPushToTalk(enable);
                }
            }
        });
    }

    private void notifyVoicePrintEnableResult(boolean enable) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("onVoicePrintEnable: " + enable);
                if (null != mEngineCallback) {
                    mEngineCallback.onVoicePrintEnable(enable);
                }
            }
        });
    }

    private void notifyVoicePrintClearResult() {

        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("notifyVoicePrintClearResult");
                if (null != mEngineCallback) {
                    mEngineCallback.onVoicePrintCleared();
                }
            }
        });
    }

    private void notifyAiAgentWillLeave(int reason, String message) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("notifyAiAgentWillLeave reason: " + reason + ", message: " + message);
                if (null != mEngineCallback) {
                    mEngineCallback.onAgentWillLeave(reason, message);
                }
            }
        });
    }

    private void notifyReceivedAgentCustomMessage(String data) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("notifyReceivedAgentCustomMessage: " + data);
                if (null != mEngineCallback) {
                    mEngineCallback.onReceivedAgentCustomMessage(data);
                }
            }
        });
    }

    private void notifyHumanTakeOverWillStart(String takeoverUid, int takeMode) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("notifyHumanTakeOverWillStart: " + takeoverUid + ", mode: " + takeMode);
                if (null != mEngineCallback) {
                    mEngineCallback.onHumanTakeoverWillStart(takeoverUid, takeMode);
                }
            }
        });
    }

    private void notifyHumanTakeoverConnected(String takeoverUid) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("notifyHumanTakeoverConnected: " + takeoverUid);
                if (null != mEngineCallback) {
                    mEngineCallback.onHumanTakeoverConnected(takeoverUid);
                }
            }
        });
    }

    private void notifyAgentEmotionNotify(String emotion,int sentenceId ) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("notifyAgentEmotionNotify: emotion :" + emotion + ", sentenceId: " + sentenceId );
                if (null != mEngineCallback) {
                    mEngineCallback.onAgentEmotionNotify(emotion, sentenceId);
                }
            }
        });
    }

    private void notifyAudioDelayInfo(int id, int delay_ms) {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                Logger.i("notifyAudioDelayInfo: id :" + id + ", delay: " + delay_ms );
                if (null != mEngineCallback) {
                    mEngineCallback.onAudioDelayInfo(id, delay_ms);
                }
            }
        });
    }

    private AliRtcEngine.AliRtcRenderMode getRenderMode(ARTCAICallVideoRenderMode renderMode) {
        AliRtcEngine.AliRtcRenderMode aliRtcRenderMode = AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeNoChange;
        switch (renderMode) {
            case ARTCAICallVideoRenderModeAuto:
                aliRtcRenderMode = AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeAuto;
                break;
            case ARTCAICallVideoRenderModeStretch:
                aliRtcRenderMode = AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeStretch;
                break;
            case ARTCAICallVideoRenderModeFill:
                aliRtcRenderMode = AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeFill;
                break;
            case ARTCAICallVideoRenderModeClip:
                aliRtcRenderMode = AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeClip;
                break;
            case ARTCAICallVideoRenderModeNoChange:
                aliRtcRenderMode = AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeNoChange;
                break;
        }
        return aliRtcRenderMode;
    }

    private AliRtcEngine.AliRtcRenderMirrorMode getRenderMirrorMode(ARTCAICallVideoRenderMirrorMode mirrorMode) {
        AliRtcEngine.AliRtcRenderMirrorMode aliRtcRenderMirrorMode = AliRtcEngine.AliRtcRenderMirrorMode.AliRtcRenderMirrorModeOnlyFront;
        switch (mirrorMode) {
            case ARTCAICallVideoRenderMirrorModeOnlyFront:
                aliRtcRenderMirrorMode = AliRtcEngine.AliRtcRenderMirrorMode.AliRtcRenderMirrorModeOnlyFront;
                break;
            case ARTCAICallVideoRenderMirrorModeAllEnabled:
                aliRtcRenderMirrorMode = AliRtcEngine.AliRtcRenderMirrorMode.AliRtcRenderMirrorModeAllEnabled;
                break;
            case ARTCAICallVideoRenderMirrorModeAllDisable:
                aliRtcRenderMirrorMode = AliRtcEngine.AliRtcRenderMirrorMode.AliRtcRenderMirrorModeAllDisable;
                break;
        }
        return aliRtcRenderMirrorMode;
    }

    private AliRtcEngine.AliRtcRotationMode getRotationMode(ARTCAICallVideoRotationMode rotationMode) {
        AliRtcEngine.AliRtcRotationMode aliRtcRotationMode = AliRtcEngine.AliRtcRotationMode.AliRtcRotationMode_0;
        switch (rotationMode) {
            case ARTCAICallVideoRotationMode_0:
                aliRtcRotationMode = AliRtcEngine.AliRtcRotationMode.AliRtcRotationMode_0;
                break;
            case ARTCAICallVideoRotationMode_90:
                aliRtcRotationMode = AliRtcEngine.AliRtcRotationMode.AliRtcRotationMode_90;
                break;
            case ARTCAICallVideoRotationMode_180:
                aliRtcRotationMode = AliRtcEngine.AliRtcRotationMode.AliRtcRotationMode_180;
                break;
            case ARTCAICallVideoRotationMode_270:
                aliRtcRotationMode = AliRtcEngine.AliRtcRotationMode.AliRtcRotationMode_270;
                break;
        }
        return aliRtcRotationMode;
    }
}
