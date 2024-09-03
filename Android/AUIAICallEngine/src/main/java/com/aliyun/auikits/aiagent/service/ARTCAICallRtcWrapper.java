package com.aliyun.auikits.aiagent.service;

import static com.alivc.rtc.AliRtcEngine.AliRtcDataMsgType.AliEngineDataMsgCustom;
import static com.alivc.rtc.AliRtcEngine.AliRtcVideoTrack.AliRtcVideoTrackCamera;

import android.content.Context;
import android.view.SurfaceView;
import android.view.ViewGroup;

import com.alivc.rtc.AliRtcEngine;
import com.alivc.rtc.AliRtcEngineEventListener;
import com.alivc.rtc.AliRtcEngineImpl;
import com.alivc.rtc.AliRtcEngineNotify;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.charset.StandardCharsets;

public class ARTCAICallRtcWrapper {

    private AliRtcEngine mAliRtcEngine = null;
    private ARtcConfig mRtcConfig = null;
    private Context mContext = null;
    private AliRtcEngine.AliRtcVideoCanvas mCanvas = null;

    private ViewGroup mAvatarViewGroup = null;
    private ViewGroup.LayoutParams mLayoutParams = null;

    public static class ARtcConfig {
        public boolean enableAudioDump = false;
        public boolean useVideo = false;
        public boolean usePreEnv = false;
    }

    private String composeParams() {
        JSONObject jsonParam = new JSONObject();
        JSONObject jsonData = new JSONObject();
        try {
            jsonData.put("enablePubDataChannel", true);
            jsonData.put("enableSubDataChannel", true);
            jsonParam.put("data", jsonData);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return jsonParam.toString();
    }

    private String composeExtra() {
        JSONObject jsonObject = new JSONObject();
        try {
            if (mRtcConfig.enableAudioDump) {
                jsonObject.put("user_specified_audio_dump", "TRUE");
            }
            if (mRtcConfig.usePreEnv) {
//                jsonObject.put("user_specified_environment", "PRE_RELEASE");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return jsonObject.toString();
    }

    public void init(Context context, ARtcConfig rtcConfig, AliRtcEngineEventListener aliRtcEngineEventListener,
                     AliRtcEngineNotify aliRtcEngineNotify,
                     AliRtcEngine.AliRtcAudioVolumeObserver aliRtcAudioVolumeObserver) {
        mContext = context;
        mRtcConfig = rtcConfig;

        AliRtcEngineImpl aliRtcEngine = AliRtcEngine.getInstance(context, composeExtra());
        aliRtcEngine.setParameter(composeParams());
        this.mAliRtcEngine = aliRtcEngine;
        if (aliRtcEngine != null) {
            aliRtcEngine.setChannelProfile(AliRtcEngine.AliRTCSdkChannelProfile.AliRTCSdkInteractiveLive);
            aliRtcEngine.setAudioOnlyMode(!mRtcConfig.useVideo);
            aliRtcEngine.setAudioProfile(AliRtcEngine.AliRtcAudioProfile.AliRtcEngineHighQualityMode, AliRtcEngine.AliRtcAudioScenario.AliRtcSceneChatroomMode);

            aliRtcEngine.setRtcEngineEventListener(aliRtcEngineEventListener);
            aliRtcEngine.setRtcEngineNotify(aliRtcEngineNotify);
            aliRtcEngine.registerAudioVolumeObserver(aliRtcAudioVolumeObserver);
            int ret = aliRtcEngine.enableAudioVolumeIndication(
                    500, /** 时间间隔 */
                    3, /** 平滑系数 */
                    1 /** 说话人检测开关 */
            );
            aliRtcEngine.setClientRole(AliRtcEngine.AliRTCSdkClientRole.AliRTCSdkInteractive);
            aliRtcEngine.setDefaultSubscribeAllRemoteAudioStreams(true);
            aliRtcEngine.subscribeAllRemoteAudioStreams(true);
            aliRtcEngine.setDefaultSubscribeAllRemoteVideoStreams(mRtcConfig.useVideo);
            aliRtcEngine.subscribeAllRemoteVideoStreams(mRtcConfig.useVideo);
            aliRtcEngine.publishLocalAudioStream(true);
            aliRtcEngine.publishLocalVideoStream(false);
            aliRtcEngine.muteLocalMic(false, AliRtcEngine.AliRtcMuteLocalAudioMode.AliRtcMuteAllAudioMode);
        }
    }

    public void join(String token) {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.joinChannel(token, null, null, null);
        }
    }

    public void leave() {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.leaveChannel();
        }
    }

    public void destroy() {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.destroy();
            mAliRtcEngine = null;
        }
    }

    public void refreshRTCToken(String token) {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.refreshAuthInfo(token);
        }
    }

    public void sendCustomMessage(int msgType, String senderId, String receiverId, JSONObject data) {
        if (null != mAliRtcEngine) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("type", msgType);
                jsonObject.put("senderId", senderId);
                jsonObject.put("receiverId", receiverId);
                if (null != data) {
                    jsonObject.put("data", data);
                }
                AliRtcEngine.AliRtcDataChannelMsg rtcDataChannelMsg = new AliRtcEngine.AliRtcDataChannelMsg();
                rtcDataChannelMsg.type = AliEngineDataMsgCustom;
                rtcDataChannelMsg.data = jsonObject.toString().getBytes(StandardCharsets.UTF_8);
                mAliRtcEngine.sendDataChannelMsg(rtcDataChannelMsg);
            } catch (JSONException ex) {
                ex.printStackTrace();
            }
        }
    }

    public void enableSpeaker(boolean enable) {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.enableSpeakerphone(enable);
        }
    }

    public void switchMicrophone(boolean on) {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.muteLocalMic(!on, AliRtcEngine.AliRtcMuteLocalAudioMode.AliRtcMuteAllAudioMode);
        }
    }

    public void pauseAudioCommunication(String robotUserId) {
        if (null != mAliRtcEngine) {
            // 暂停本地音频推流
            mAliRtcEngine.muteLocalMic(true, AliRtcEngine.AliRtcMuteLocalAudioMode.AliRtcMuteAllAudioMode);
            // 静音远端流
            mAliRtcEngine.setRemoteAudioVolume(robotUserId, 0);
        }
    }

    public void resumeAudioCommunication(String robotUserId) {
        if (null != mAliRtcEngine) {
            // 恢复本地音频推流
            mAliRtcEngine.muteLocalMic(false, AliRtcEngine.AliRtcMuteLocalAudioMode.AliRtcMuteAllAudioMode);
            // 恢复远端流音量
            mAliRtcEngine.setRemoteAudioVolume(robotUserId, 100);

        }
    }

    public void subscribeVideoStream(String uid) {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.subscribeRemoteVideoStream(uid, AliRtcVideoTrackCamera, true);
        }
    }

    public void setAvatarViewGroup(ViewGroup avatarViewGroup, ViewGroup.LayoutParams layoutParams) {
        mAvatarViewGroup = avatarViewGroup;
        mLayoutParams = layoutParams;
    }

    public void initRemoteSurfaceView(String uid) {
        if (mRtcConfig.useVideo && null == mCanvas) {
            mCanvas = new AliRtcEngine.AliRtcVideoCanvas();
            SurfaceView avatarSurfaceView = mAliRtcEngine.createRenderSurfaceView(mContext);
            if (avatarSurfaceView != null) {
                mCanvas.view = avatarSurfaceView;
                avatarSurfaceView.setZOrderOnTop(true);
                avatarSurfaceView.setZOrderMediaOverlay(true);
            }
//        canvas.backgroundColor = mBackgroundColor;
//        canvas.renderMode = mRtcCanvasRenderMode;
//        canvas.rotationMode = mRemoteRotationMode;

            mAvatarViewGroup.addView(avatarSurfaceView, mLayoutParams);
            mAliRtcEngine.setRemoteViewConfig(mCanvas, uid, AliRtcVideoTrackCamera);
        }
    }

    public AliRtcEngine getAliRtcEngine() {
        return mAliRtcEngine;
    }
}
