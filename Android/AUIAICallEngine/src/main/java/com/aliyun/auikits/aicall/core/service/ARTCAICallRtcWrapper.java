package com.aliyun.auikits.aicall.core.service;

import static com.alivc.rtc.AliRtcEngine.AliRtcDataMsgType.AliEngineDataMsgCustom;

import android.content.Context;

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

    public static class ARtcConfig {
        public boolean enableAudioDump = false;
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
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return jsonObject.toString();
    }

    public void init(Context context, ARtcConfig rtcConfig, AliRtcEngineEventListener aliRtcEngineEventListener,
                     AliRtcEngineNotify aliRtcEngineNotify,
                     AliRtcEngine.AliRtcAudioVolumeObserver aliRtcAudioVolumeObserver) {
        mRtcConfig = rtcConfig;

        AliRtcEngineImpl aliRtcEngine = AliRtcEngine.getInstance(context, composeExtra());
        aliRtcEngine.setParameter(composeParams());
        this.mAliRtcEngine = aliRtcEngine;
        if (aliRtcEngine != null) {
            aliRtcEngine.setChannelProfile(AliRtcEngine.AliRTCSdkChannelProfile.AliRTCSdkInteractiveLive);
            aliRtcEngine.setAudioOnlyMode(true);
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
}
