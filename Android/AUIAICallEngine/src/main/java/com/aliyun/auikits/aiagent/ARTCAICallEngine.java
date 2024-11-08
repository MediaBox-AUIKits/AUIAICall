package com.aliyun.auikits.aiagent;

import android.view.ViewGroup;

import com.alivc.rtc.AliRtcEngine;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

public abstract class ARTCAICallEngine {

    /**
     * 机器人状态
     */
    public enum ARTCAICallRobotState {
        /** 聆听中 */
        Listening,
        /** 思考中 */
        Thinking,
        /** 讲话中 */
        Speaking
    };

    public enum AICallErrorCode {
        /** 无 */
        None,
        /** 操作无效 */
        InvalidAction,
        /** 参数错误 */
        InvalidParams,
        /** 无法启动通话 */
        StartFailed,
        /** 通话认证过期 */
        TokenExpired,
        /** 链接出现问题 */
        ConnectionFailed,
        /** 同名登录导致通话无法进行 */
        KickedByUserReplace,
        /** 被系统踢出导致通话无法进行 */
        KickedBySystem,
        /** 本地设备问题导致无法进行 */
        LocalDeviceException,
        /** 智能体离开频道了（智能体结束通话） */
        AgentLeaveChannel,
        /** 数字人-智能体到达并发限制 */
        AgentConcurrentLimit,
        /** 数字人-智能体订阅音频失败 */
        AgentAudioSubscribeFailed,
        /** 第三方ASR服务启动失败 */
        AiAgentAsrUnavailable,
        /** 数字人服务不可用 */
        AvatarAgentUnavailable,
    }

    public enum ARTCAICallNetworkQuality {
        /** 网络极好，流程度清晰度质量好 */
        Excellent,
        /** 网络好，流畅度清晰度和极好差不多 */
        Good,
        /** 网络较差，音视频流畅度清晰度有瑕疵，不影响沟通 */
        Poor,
        /** 网络差，视频卡顿严重，音频能正常沟通 */
        Bad,
        /** 网络极差，基本无法沟通 */
        VeryBad,
        /** 网络中断 */
        Disconnect,
        /** 未知 */
        Unknow,
    }

    public enum ARTCAICallAgentType {
        /** 纯语音 */
        VoiceAgent,
        /** 数字人 */
        AvatarAgent,
        /** 视觉理解 */
        VisionAgent
    }

    public enum VoicePrintStatusCode {
        /**
         * 声纹识别未开启
         */
        Disable,
        /**
         * 声纹识别开启，未注册
         */
        EnableWithoutRegister,
        /**
         * 开启了，识别到主讲人
         */
        SpeakerRecognized,
        /**
         * 开启了，没识别到主讲人
         */
        SpeakerNotRecognized,
        /**
         * 未知状态
         */
        Unknown,
    }

    public static class ARTCAICallConfig {
        public String aiAgentRegion = null;
        public String loginUserId;
        public String loginAuthrization;
        public String aiAgentRequestId = "";
        public String aiAgentId = "";
        public boolean enableVoiceInterrupt = true;
        public String aiAgentVoiceId = "";
        public boolean enableSpeaker = true;
        public boolean isMicrophoneOn = true;
        public boolean isCameraMute = false;
        public boolean enableAudioDump = false;
        public String appServerHost = "";
        /**
         * 是否使用全托管方案
         */
        public boolean useDeposit = false;
        public boolean useRtcPreEnv = false;
        public boolean enablePushToTalk = false;
        public boolean enableVoicePrint = false;

        @Override
        public String toString() {
            return "ARTCAICallConfig{" +
                    "aiAgentRegion='" + aiAgentRegion + '\'' +
                    ", loginUserId='" + loginUserId + '\'' +
                    ", loginAuthorization='" + loginAuthrization + '\'' +
                    ", aiAgentRequestId='" + aiAgentRequestId + '\'' +
                    ", aiAgentId='" + aiAgentId + '\'' +
                    ", enableVoiceInterrupt=" + enableVoiceInterrupt +
                    ", aiAgentVoiceId='" + aiAgentVoiceId + '\'' +
                    ", enableSpeaker=" + enableSpeaker +
                    ", isMicrophoneOn=" + isMicrophoneOn +
                    ", isCameraMute=" + isCameraMute +
                    ", enableAudioDump=" + enableAudioDump +
                    ", appServerHost='" + appServerHost + '\'' +
                    ", useDeposit=" + useDeposit +
                    ", useRtcPreEnv=" + useRtcPreEnv +
                    '}';
        }
    }

    public static class IARTCAICallEngineCallback {

        /**
         * 发生了错误
         */
        public void onErrorOccurs(AICallErrorCode errorCode) {}

        /**
         * 通话开始（入会）
         */
        public void onCallBegin() {}

        /**
         * 通话结束（离会）
         */
        public void onCallEnd() {}

        /**
         * 机器人状态同步
         * @param oldRobotState
         * @param newRobotState
         */
        public void onAICallEngineRobotStateChanged(ARTCAICallRobotState oldRobotState, ARTCAICallRobotState newRobotState) {}

        /**
         * 用户说话回调
         * @param isSpeaking
         */
        public void onUserSpeaking(boolean isSpeaking) {}


        /**
         * 同步ASR识别用户的话
         * @param text ASR识别出的具体文本
         * @param isSentenceEnd 当前文本是否为这句话的最终结果
         * @param sentenceId 当前文本属于的句子ID
         * @deprecated 使用onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId, VoicePrintStatusCode voicePrintStatusCode)
         */
        public void onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId) {}

        /**
         * 同步ASR识别用户的话
         * @param text ASR识别出的具体文本
         * @param isSentenceEnd 当前文本是否为这句话的最终结果
         * @param sentenceId 当前文本属于的句子ID
         * @param voicePrintStatusCode 声纹识别状态
         */
        public void onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId, VoicePrintStatusCode voicePrintStatusCode) {}

        /**
         * 同步智能体回应的话
         * @param text 智能体的话
         * @param end 当前回复是否结束
         * @param userAsrSentenceId 表示回应对应sentenceId语音输入的的llm内容
         */
        public void onAIAgentSubtitleNotify(String text, boolean end, int userAsrSentenceId) {}

        /**
         * 网络状态回调
         * @param uid
         * @param quality
         */
        public void onNetworkStatusChanged(String uid, ARTCAICallNetworkQuality quality) {}

        /**
         * 音量变化
         * @param uid 用户id
         * @param volume 音量[0-255]
         */
        public void onVoiceVolumeChanged(String uid, int volume) {}

        /**
         * 当前通话的音色发生了改变
         */
        public void onVoiceIdChanged(String voiceId) {}

        /**
         * 当前通话的语音打断设置改变
         */
        public void onVoiceInterrupted(boolean enable) {}

        /**
         * 智能体视频是否可用（推流）
         */
        public void onAgentVideoAvailable(boolean available) {}

        /**
         * 智能体音频是否可用（推流）
         */
        public void onAgentAudioAvailable(boolean available) {}
        /**
         * 智能体数字人首帧渲染
         */
        public void onAgentAvatarFirstFrameDrawn() {}

        /**
         * 用户入会回调
         */
        public void onUserOnLine(String uid) {}

        /**
         * 回调当前通话的对讲机模式状态变更
         * @param enable
         */
        public void onPushToTalk(boolean enable) {}

        /**
         * 回调当前通话的声纹状态变更
         * @param enable
         */
        public void onVoicePrintEnable(boolean enable) {}

        /**
         * 声纹信息被清除
         */
        public void onVoicePrintCleared() {}
    }

    /**
     * 初始化
     * @param config 初始化配置
     */
    public abstract void init(ARTCAICallConfig config);

    /**
     * 设置智能体类型
     * @param aiAgentType
     */
    public abstract void setAICallAgentType(ARTCAICallAgentType aiAgentType);

    /**
     * 创建&开始通话
     */
    public abstract void call(String rtcToken, String aiAgentInstanceId, String aiAgentUserId, String channelId);

    /**
     * 挂断
     */
    public abstract void handup();

    /**
     * 切换麦克风状态
     * @param on
     */
    public abstract void switchMicrophone(boolean on);

    /**
     * 打断机器人说话
     */
    public abstract boolean interruptSpeaking();

    /**
     * 开启/关闭智能打断
     */
    public abstract boolean enableVoiceInterrupt(boolean enable);

    /**
     * 开启/关闭扬声器
     */
    public abstract boolean enableSpeaker(boolean enable);

    /**
     * 切换音色
     */
    public abstract boolean switchRobotVoice(String voiceId);

    /**
     * 获取正在使用的音色
     * @return
     */
    public abstract String getRobotVoiceId();

    /**
     * 注册回调
     * @param engineCallback
     */
    public abstract void setEngineCallback(IARTCAICallEngineCallback engineCallback);

    /**
     * 是否关闭麦克风
     * @return
     */
    public abstract boolean isMicrophoneOn();

    /**
     * 扬声器是否开启
     * @return
     */
    public abstract boolean isSpeakerOn();

    /**
     * 智能打断是否开启
     * @return
     */
    public abstract boolean isVoiceInterruptEnable();

    /**
     * 设置数字人视图载体
     * @param viewGroup
     * @param avatarLayoutParams
     */
    public abstract void setAvatarAgentView(ViewGroup viewGroup, ViewGroup.LayoutParams avatarLayoutParams);

    /**
     * 设置数字人视图载体
     * @param viewGroup
     * @param visionLayoutParams
     */
    public abstract void setVisionPreviewView(ViewGroup viewGroup, ViewGroup.LayoutParams visionLayoutParams);

    /**
     * 关闭/取消关闭摄像头
     */
    public abstract boolean muteLocalCamera(boolean mute);

    /**
     * 摄像头是否关闭
     * @return
     */
    public abstract boolean isLocalCameraMute();

    /**
     * 切换前后摄像头
     */
    public abstract boolean switchCamera();

    /**
     * 获取rtc引擎实例
     * @return
     */
    public abstract AliRtcEngine getRtcEngine();

    /**
     * 获取官方协议实现
     * @return
     */
    public abstract IARTCAICallService getIARTCAICallService();

    /**
     * 开启/关闭对讲机模式，对讲机模式下，只有在finishPushToTalk被调用后，智能体才会播报结果
     * @param enable
     * @return
     */
    public abstract boolean enablePushToTalk(boolean enable);

    /**
     * 对讲机模式是否开启
     * @return
     */
    public abstract boolean isPushToTalkEnable();

    /**
     * 对讲机模式：开始讲话
     * @return
     */
    public abstract boolean startPushToTalk();
    /**
     * 对讲机模式：结束讲话
     * @return
     */
    public abstract boolean finishPushToTalk();
    /**
     * 对讲机模式：取消这次通话
     * @return
     */
    public abstract boolean cancelPushToTalk();

    /**
     * 开启/关闭声纹降噪
     * @note 邀测阶段，如需体验，请联系相关人员
     * @return
     */
    public abstract boolean useVoicePrint(boolean enable);

    /**
     * 声纹降噪是否开启
     * @note 邀测阶段，如需体验，请联系相关人员
     * @return
     */
    public abstract boolean isUsingVoicePrint();

    /**
     * 清除声纹信息，相当于重置状态，将会重新识别新的声纹
     * @note 邀测阶段，如需体验，请联系相关人员
     * @return
     */
    public abstract boolean clearVoicePrint();

    /**
     *
     * @param sumRate
     * @param delay
     * @param noise
     * @param recognition
     * @param interactive
     * @param timbre
     * @deprecated
     */
    public void rating(int sumRate, int delay, int noise, int recognition, int interactive, int timbre) {
    }
}
