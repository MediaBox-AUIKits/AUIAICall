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
import com.aliyun.auikits.aiagent.util.BizStatHelper;
import com.aliyun.auikits.aiagent.util.IMsgTypeDef;

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

            Log.i(TAG, "onJoinChannelResult: [result: " + result + ", channel: " + channel + ", userId: " + userId + ", elapsed: " + elapsed + "]");
            if (result == 0) {
                mIsJoined.set(true);
                syncConfigToRTCEngine();
            } else {
                notifyErrorOccurs(AICallErrorCode.StartFailed);

            }
        }

        @Override
        public void onLeaveChannelResult(int result, AliRtcEngine.AliRtcStats stats) {
            super.onLeaveChannelResult(result, stats);
            Log.i(TAG, "onLeaveChannelResult: [result: " + result + ", stats: " + stats + "]");
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
            Log.i(TAG, "onVideoSubscribeStateChanged: [uid: " + uid +
                    ", oldState: " + oldState + ", newState: " + newState +
                    ", elapseSinceLastState: " + elapseSinceLastState + ", channel: " + channel + "]");

        }

        @Override
        public void onAudioSubscribeStateChanged(String uid,
                                                 AliRtcEngine.AliRtcSubscribeState oldState,
                                                 AliRtcEngine.AliRtcSubscribeState newState,
                                                 int elapseSinceLastState, String channel) {
            super.onAudioSubscribeStateChanged(uid, oldState, newState, elapseSinceLastState, channel);
            Log.i(TAG, "onAudioSubscribeStateChanged: [uid: " + uid +
                    ", oldState: " + oldState + ", newState: " + newState +
                    ", elapseSinceLastState: " + elapseSinceLastState + ", channel: " + channel + "]");
        }

        @Override
        public void onAudioSubscribeStateChanged(String uid,
                                                 AliRtcEngine.AliRtcAudioTrack track,
                                                 AliRtcEngine.AliRtcSubscribeState oldState,
                                                 AliRtcEngine.AliRtcSubscribeState newState,
                                                 int elapseSinceLastState, String channel) {
            super.onAudioSubscribeStateChanged(uid, track, oldState, newState, elapseSinceLastState, channel);
            Log.i(TAG, "onAudioSubscribeStateChanged: [uid: " + uid +
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
            Log.i(TAG, "onRemoteUserOnLineNotify: [uid: " + uid +
                    ", elapsed: " + elapsed + "]");
            notifyUserOnline(uid);
        }

        @Override
        public void onRemoteUserOffLineNotify(final String uid, final AliRtcEngine.AliRtcUserOfflineReason reason) {
            super.onRemoteUserOffLineNotify(uid, reason);
            Log.i(TAG, "onRemoteUserOffLineNotify: [uid: " + uid +
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
            Log.i(TAG, "onRemoteTrackAvailableNotify: [uid: " + uid +
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
            Log.i(TAG, "onFirstAudioPacketReceived [uid: " + uid + ", aliRtcAudioTrack: " + aliRtcAudioTrack + ", timeCost: " + timeCost + "]");
            notifyOnCallBegin();
        }

        @Override
        public void onFirstVideoPacketReceived(String uid, AliRtcEngine.AliRtcVideoTrack aliRtcVideoTrack, int timeCost) {
            Log.i(TAG, "onFirstVideoPacketReceived [uid: " + uid + ", aliRtcVideoTrack: " + aliRtcVideoTrack + ", timeCost: " + timeCost + "]");
            super.onFirstVideoPacketReceived(uid, aliRtcVideoTrack, timeCost);
        }

        @Override
        public void onFirstVideoFrameReceived(String uid, AliRtcEngine.AliRtcVideoTrack aliRtcVideoTrack, int timeCost) {
            Log.i(TAG, "onFirstVideoFrameReceived [uid: " + uid + ", aliRtcVideoTrack: " + aliRtcVideoTrack + ", timeCost: " + timeCost + "]");
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
            Log.i(TAG, "onBye: [code: " + code + "]");
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
            Log.i(TAG, "onAuthInfoWillExpire");
            refreshRTCToken();
        }

        @Override
        public void onAuthInfoExpired() {
            super.onAuthInfoExpired();
            Log.i(TAG, "onAuthInfoExpired");
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
                            notifyUserAsrSubtitle(text, end, sentenceId);
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
                        } else {
                            notifyIMMessageReceived(msgType, seqId, senderId, receiverId, dataJson);
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
    public ARTCAICallEngineImpl(Context context, String userId) {
        mContext = context;
        mUserId = userId;
        BizStatHelper.init(context);
    }

    @Override
    public void init(ARTCAICallConfig config) {
        Log.i(TAG, "init config: " + config);
        mCallConfig = config;

        mARTCAICallService = generateAICallService(mCallConfig);
        mARTCAICallService.setIMService(mImService);
        mARTCAICallRtcWrapper = new ARTCAICallRtcWrapper();
    }

    @Override
    public void call(String rtcToken, String aiAgentInstanceId, String aiAgentUserId, String channelId) {
        Log.i(TAG, "call fail [rtcToken: " + rtcToken + ", aiAgentInstanceId: " + aiAgentInstanceId + ", aiAgentUserId: " + aiAgentUserId + ", channelId: " + channelId + "]");
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
            rtcConfig.enableAudioDump = mCallConfig.enableAudioDump;
            rtcConfig.useVideo = mAgentType == ARTCAICallAgentType.AvatarAgent;
            mARTCAICallRtcWrapper.setAvatarViewGroup(mAvatarViewGroup, mAvatarLayoutParams);
            mARTCAICallRtcWrapper.init(mContext, rtcConfig, mRtcEngineEventListener,
                    mRtcEngineRemoteNotify, mAudioVolumeObserver);
            mARTCAICallRtcWrapper.join(mRtcAuthToken);
        }
    }

    @Override
    public void handup() {
        mCallbackHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mIsHangUp.compareAndSet(false, true)) {
                    Log.i(TAG, "handup begin");
                    Runnable rtcLeaveRunnable = new Runnable() {
                        @Override
                        public void run() {

                            mARTCAICallRtcWrapper.leave();
                            mARTCAICallRtcWrapper.destroy();

                            notifyOnCallEnd();

                            Log.i(TAG, "handup end");
                        }
                    };

                    String loopDelay = mARTCAICallRtcWrapper.getLoopDelay();
                    Log.i(TAG, "handup [mRobotInstanceId: " + mAIAgentInstanceId + ", loopDelay: " + loopDelay + "]");
                    boolean needCallLeaveRunnableNextLoop = false;
                    // 调用关闭服务
                    if (!TextUtils.isEmpty(mAIAgentInstanceId)) {
                        needCallLeaveRunnableNextLoop = mARTCAICallService.stopAIAgentService(mAIAgentInstanceId, new IARTCAICallService.IARTCAICallServiceCallback() {
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
            mCallConfig.enableVoiceInterrupt = enable;

            // 发送网络请求 修改智能打断开关
            mARTCAICallService.enableVoiceInterrupt(mAIAgentInstanceId, mAgentType, enable, new IARTCAICallService.IARTCAICallServiceCallback() {
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
        if (isJoinedChannel()) {
            // 调用rtc扬声器开关
            Log.i(TAG, "enableSpeaker [enable: " + enable + "]");
            mARTCAICallRtcWrapper.enableSpeaker(enable);
            return true;
        }
        return false;
    }

    @Override
    public boolean switchRobotVoice(String voiceId) {
        if (isJoinedChannel()) {
            mCallConfig.aiAgentVoiceId = voiceId;

            // 发送网络请求 切换音色
            mARTCAICallService.switchAiAgentVoice(mAIAgentInstanceId, mAgentType, voiceId, new IARTCAICallService.IARTCAICallServiceCallback() {
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
        return mCallConfig.aiAgentVoiceId;
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
        return mCallConfig.enableVoiceInterrupt;
    }

    @Override
    public void setAvatarAgentView(ViewGroup viewGroup, ViewGroup.LayoutParams avatarLayoutParams) {
        mAvatarViewGroup = viewGroup;
        mAvatarLayoutParams = avatarLayoutParams;
    }

    @Override
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
            args.put("atype", mAgentType == ARTCAICallAgentType.AvatarAgent ? "avatar" : "voice");
            args.put("aid", mCallConfig.aiAgentId);
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

    @Override
    public void switchMicrophone(boolean on) {
//        Log.e("switchMicrophone", "on: " + on, new Throwable());
        mCallConfig.isMicrophoneOn = on;
        if (isJoinedChannel()) {
            // 调用rtc麦克风开关
            mARTCAICallRtcWrapper.switchMicrophone(on);
            Log.i(TAG, "switchMicrophone [on: " + on + "]");
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
        Log.i(TAG, "onRTCTokenResult: [isSucc: " + isSucc + ", rtcToken: " + rtcToken + "]");
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
        return new ARTCAICallServiceImpl(artcAiCallConfig.appServerHost, artcAiCallConfig.loginUserId, artcAiCallConfig.loginAuthrization);
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

    private void notifyRobotSubtitle(String text, boolean end, int userAsrSentenceId) {
        if (!TextUtils.isEmpty(text)) {
            mCallbackHandler.post(new Runnable() {
                @Override
                public void run() {
                    if (null != mEngineCallback) {
                        mEngineCallback.onAIAgentSubtitleNotify(text, end, userAsrSentenceId);
                    }
                }
            });
        }
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
}
