package com.aliyun.auikits.aiagent.service;

import static com.alivc.rtc.AliRtcEngine.AliRtcCaptureOutputPreference.ALIRTC_CAPTURER_OUTPUT_PREFERENCE_PREVIEW;
import static com.alivc.rtc.AliRtcEngine.AliRtcDataMsgType.AliEngineDataMsgCustom;
import static com.alivc.rtc.AliRtcEngine.AliRtcRenderMirrorMode.AliRtcRenderMirrorModeOnlyFront;
import static com.alivc.rtc.AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeAuto;
import static com.alivc.rtc.AliRtcEngine.AliRtcRotationMode.AliRtcRotationMode_0;
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
import com.aliyun.auikits.aiagent.debug.ARTCAICallEngineDebuger;

public class ARTCAICallRtcWrapper {

    private AliRtcEngine mAliRtcEngine = null;
    private ARtcConfig mRtcConfig = null;
    private Context mContext = null;
    private AliRtcEngine.AliRtcVideoCanvas mRemoteVideoCanvas = null;
    private AliRtcEngine.AliRtcVideoCanvas mLocalVideoCanvas = null;

    private ViewGroup mRemoteViewGroup = null;
    private ViewGroup.LayoutParams mRemoteVideoLayoutParams = null;

    private ViewGroup mLocalViewGroup = null;
    private ViewGroup.LayoutParams mLocalLayoutParams = null;

    public static class ARtcConfig {
        public boolean enableRemoteVideo = false;
        public boolean enableLocalVideo = false;
        public boolean useHighQualityPreview = false;
        public boolean enableAudioDelayInfo = false;
        /** 是否默认启动前置摄像头 */
        public boolean useFrontCameraDefault = false;
        /** 摄像头采集帧率 */
        public int cameraCaptureFrameRate = 15;
        /** 视频编码宽度 */
        public int videoEncoderWidth = 360;
        /** 视频编码高度 */
        public int videoEncoderHeight = 640;
        /** 视频编码帧率 */
        public int videoEncoderFrameRate = 15;
        /** 视频编码码率 */
        public int videoEncoderBitRate = 512;
        /** 关键帧间隔，单位毫秒。默认值0，表示SDK内部控制关键帧间隔。 */
        public int videoEncoderKeyFrameInterval = 1000;

        public AliRtcEngine.AliRtcRenderMode mLocalRenderMode = AliRtcRenderModeAuto;
        public AliRtcEngine.AliRtcRenderMirrorMode mLocalMirrorMode = AliRtcRenderMirrorModeOnlyFront;
        public AliRtcEngine.AliRtcRotationMode mLocalRotationMode = AliRtcRotationMode_0;
        public AliRtcEngine.AliRtcRenderMode mRemoteRenderMode = AliRtcRenderModeAuto;
        public AliRtcEngine.AliRtcRenderMirrorMode mRemoteMirrorMode = AliRtcRenderMirrorModeOnlyFront;
        public AliRtcEngine.AliRtcRotationMode mRemoteRotationMode = AliRtcRotationMode_0;

    }

    private String composeParams() {
        JSONObject jsonParam = new JSONObject();
        JSONObject jsonData = new JSONObject();
        JSONObject jsonAudio = new JSONObject();
        JSONObject jsonNet = new JSONObject();
        try {
            jsonData.put("enablePubDataChannel", true);
            jsonData.put("enableSubDataChannel", true);
            jsonParam.put("data", jsonData);

            jsonParam.put("audio", jsonAudio);

            jsonNet.put("enable_ai_low_latency_channel_mode", true);
            jsonParam.put("net", jsonNet);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return jsonParam.toString();
    }

    private String composeExtra() {
        JSONObject jsonObject = new JSONObject();
        try {
            if (ARTCAICallEngineDebuger.enableDumpData) {
                jsonObject.put("user_specified_audio_dump", "TRUE");
            }
            if (ARTCAICallEngineDebuger.enableLabEnvironment) {
                jsonObject.put("user_specified_environment", "PRE_RELEASE");
            }
            if (ARTCAICallEngineDebuger.enableUserSpecifiedAudioTips) {
                jsonObject.put("user_specified_audio_tips", "TRUE");
            }
            if(mRtcConfig.enableAudioDelayInfo) {
                jsonObject.put("enable_ai_audio_cumu_delay", 1);
            }
            jsonObject.put("user_specified_codec_type", "CODEC_TYPE_HARDWARE_ENCODER_HARDWARE_DECODER");
            jsonObject.put("user_specified_dynamic_encoder", 1);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return jsonObject.toString();
    }

    public void init(Context context, ARtcConfig rtcConfig, AliRtcEngineEventListener aliRtcEngineEventListener,
                     AliRtcEngineNotify aliRtcEngineNotify,
                     AliRtcEngine.AliRtcAudioVolumeObserver aliRtcAudioVolumeObserver,  AliRtcEngine.AliRtcAudioDelayObserver aliRtcAudioDelayObserver) {
        mContext = context;
        mRtcConfig = rtcConfig;

        AliRtcEngineImpl aliRtcEngine = AliRtcEngine.getInstance(context, composeExtra());
        aliRtcEngine.setParameter(composeParams());
        this.mAliRtcEngine = aliRtcEngine;
        if (aliRtcEngine != null) {
            aliRtcEngine.setChannelProfile(AliRtcEngine.AliRTCSdkChannelProfile.AliRTCSdkInteractiveLive);
            boolean audioOnly = !mRtcConfig.enableRemoteVideo && !mRtcConfig.enableLocalVideo;
            if(audioOnly && !mRtcConfig.enableAudioDelayInfo) {
                //不需要audioDelayinfo时才可以设置，audioDelayinfo是通过插入视频sei来实现的
                aliRtcEngine.setAudioOnlyMode(audioOnly);
            }
            aliRtcEngine.setAudioProfile(AliRtcEngine.AliRtcAudioProfile.AliRtcEngineHighQualityMode, AliRtcEngine.AliRtcAudioScenario.AliRtcSceneChatroomMode);
            aliRtcEngine.startAudioPlayer();

            aliRtcEngine.setRtcEngineEventListener(aliRtcEngineEventListener);
            aliRtcEngine.setRtcEngineNotify(aliRtcEngineNotify);
            aliRtcEngine.registerAudioVolumeObserver(aliRtcAudioVolumeObserver);
            aliRtcEngine.registerAudioDelayObserver(aliRtcAudioDelayObserver);
            int ret = aliRtcEngine.enableAudioVolumeIndication(
                    500, /** 时间间隔 */
                    3, /** 平滑系数 */
                    1 /** 说话人检测开关 */
            );
            aliRtcEngine.setClientRole(AliRtcEngine.AliRTCSdkClientRole.AliRTCSdkInteractive);
            aliRtcEngine.setDefaultSubscribeAllRemoteAudioStreams(true);
            aliRtcEngine.subscribeAllRemoteAudioStreams(true);
            if(mRtcConfig.enableRemoteVideo || mRtcConfig.enableAudioDelayInfo)
            {
                //audioDelayInfo(需要通过插入视频SEI来实现)
                aliRtcEngine.setDefaultSubscribeAllRemoteVideoStreams(true);
                aliRtcEngine.subscribeAllRemoteVideoStreams(true);
            }
            else
            {
                //不需要接收视频，也不需要收集audioDelayInfo(需要通过插入视频SEI来实现)
                aliRtcEngine.setDefaultSubscribeAllRemoteVideoStreams(false);
                aliRtcEngine.subscribeAllRemoteVideoStreams(false);
            }

            aliRtcEngine.publishLocalAudioStream(false);
            aliRtcEngine.publishLocalVideoStream(false);
            aliRtcEngine.muteLocalMic(false, AliRtcEngine.AliRtcMuteLocalAudioMode.AliRtcMuteAllAudioMode);
            if (!audioOnly) {
                AliRtcEngine.AliEngineCameraCapturerConfiguration cameraCapturerConfiguration = new AliRtcEngine.AliEngineCameraCapturerConfiguration();
                cameraCapturerConfiguration.cameraDirection = mRtcConfig.useFrontCameraDefault ?
                        AliRtcEngine.AliRtcCameraDirection.CAMERA_FRONT :
                        AliRtcEngine.AliRtcCameraDirection.CAMERA_REAR;
                cameraCapturerConfiguration.fps = mRtcConfig.cameraCaptureFrameRate;
                if (mRtcConfig.useHighQualityPreview) {
                    cameraCapturerConfiguration.preference = ALIRTC_CAPTURER_OUTPUT_PREFERENCE_PREVIEW;
                }
                mAliRtcEngine.setCameraCapturerConfiguration(cameraCapturerConfiguration);
                mAliRtcEngine.setCapturePipelineScaleMode(AliRtcEngine.AliRtcCapturePipelineScaleMode.AliRtcCapturePipelineScaleModePost);

                AliRtcEngine.AliRtcVideoEncoderConfiguration aliRtcVideoEncoderConfiguration = new AliRtcEngine.AliRtcVideoEncoderConfiguration();
                aliRtcVideoEncoderConfiguration.dimensions = new AliRtcEngine.AliRtcVideoDimensions(
                        mRtcConfig.videoEncoderWidth, mRtcConfig.videoEncoderHeight);
                aliRtcVideoEncoderConfiguration.frameRate = mRtcConfig.videoEncoderFrameRate;
                aliRtcVideoEncoderConfiguration.bitrate = mRtcConfig.videoEncoderBitRate;
                aliRtcVideoEncoderConfiguration.keyFrameInterval = mRtcConfig.videoEncoderKeyFrameInterval;
                aliRtcEngine.setVideoEncoderConfiguration(aliRtcVideoEncoderConfiguration);
            }
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

    public void unSubscribeRemoteUser(String uid) {
        if(null != mAliRtcEngine) {
            mAliRtcEngine.subscribeRemoteAudioStream(uid, false);
            mAliRtcEngine.subscribeRemoteVideoStream(uid, AliRtcVideoTrackCamera, false);
        }

    }

    public void subscribeVideoStream(String uid) {
        if (null != mAliRtcEngine) {
            mAliRtcEngine.subscribeRemoteVideoStream(uid, AliRtcVideoTrackCamera, true);
        }
    }

    public boolean muteLocalCamera(boolean mute) {
        boolean ret = false;
        if (null != mAliRtcEngine) {
            ret = 0 == mAliRtcEngine.muteLocalCamera(mute, AliRtcVideoTrackCamera);
            if (ret) {
                if (mute) {
                    mAliRtcEngine.stopPreview();
                    publishLocalVideoStream(false);
                } else {
                    mAliRtcEngine.startPreview();
                    publishLocalVideoStream(true);
                }
            }
        }
        return ret;
    }

    public int enableLocalVideo(boolean enable) {
        int ret = -1;
        if (null != mAliRtcEngine) {
            ret = mAliRtcEngine.enableLocalVideo(enable);
        }
        return ret;
    }

    public boolean publishLocalAudioStream(boolean enable) {
        boolean ret = false;
        if (null != mAliRtcEngine) {
            mAliRtcEngine.publishLocalAudioStream(enable);
        }
        return ret;
    }

    public boolean publishLocalVideoStream(boolean enable) {
        boolean ret = false;
        if (null != mAliRtcEngine) {
            mAliRtcEngine.publishLocalVideoStream(enable);
        }
        return ret;
    }

    public boolean switchCamera() {
        boolean ret = false;
        if (null != mAliRtcEngine) {
            ret = 0 == mAliRtcEngine.switchCamera();
        }
        return ret;
    }


    public void setAvatarViewGroup(ViewGroup avatarViewGroup, ViewGroup.LayoutParams layoutParams) {
        mRemoteViewGroup = avatarViewGroup;
        mRemoteVideoLayoutParams = layoutParams;
    }

    public void setVisionPreviewView(ViewGroup viewGroup, ViewGroup.LayoutParams visionLayoutParams) {
        mLocalViewGroup = viewGroup;
        mLocalLayoutParams = visionLayoutParams;
    }
    public void initRemoteSurfaceView(String uid) {
        if (mRtcConfig.enableRemoteVideo && null == mRemoteVideoCanvas) {
            mRemoteVideoCanvas = new AliRtcEngine.AliRtcVideoCanvas();
            SurfaceView avatarSurfaceView = mAliRtcEngine.createRenderSurfaceView(mContext);
            if (avatarSurfaceView != null) {
                mRemoteVideoCanvas.view = avatarSurfaceView;
                avatarSurfaceView.setZOrderOnTop(true);
                avatarSurfaceView.setZOrderMediaOverlay(true);
            }
            mRemoteVideoCanvas.renderMode = mRtcConfig.mRemoteRenderMode;
            mRemoteVideoCanvas.mirrorMode = mRtcConfig.mRemoteMirrorMode;
            mRemoteVideoCanvas.rotationMode = mRtcConfig.mRemoteRotationMode;

            mRemoteViewGroup.addView(avatarSurfaceView, mRemoteVideoLayoutParams);
            mAliRtcEngine.setRemoteViewConfig(mRemoteVideoCanvas, uid, AliRtcVideoTrackCamera);
        }
    }

    public void initLocalPreview() {
        if (mRtcConfig.enableLocalVideo && null == mLocalVideoCanvas) {
            mLocalVideoCanvas = new AliRtcEngine.AliRtcVideoCanvas();
            SurfaceView avatarSurfaceView = mAliRtcEngine.createRenderSurfaceView(mContext);
            if (avatarSurfaceView != null) {
                mLocalVideoCanvas.view = avatarSurfaceView;
                avatarSurfaceView.setZOrderOnTop(true);
                avatarSurfaceView.setZOrderMediaOverlay(true);
            }
            mAliRtcEngine.startPreview();

            mLocalVideoCanvas.renderMode = mRtcConfig.mLocalRenderMode;
            mLocalVideoCanvas.mirrorMode = mRtcConfig.mLocalMirrorMode;
            mLocalVideoCanvas.rotationMode = mRtcConfig.mLocalRotationMode;

            mLocalViewGroup.addView(avatarSurfaceView, mLocalLayoutParams);
            mAliRtcEngine.setLocalViewConfig(mLocalVideoCanvas, AliRtcVideoTrackCamera);
        }
    }

    public AliRtcEngine getAliRtcEngine() {
        return mAliRtcEngine;
    }

    public String getLoopDelay() {
        String ret = "";
        if (null != mAliRtcEngine) {
            ret = mAliRtcEngine.getParameter("{\"audio\":{\"user_specified_loop_delay\":0}}");
        }
        return ret;
    }
}
