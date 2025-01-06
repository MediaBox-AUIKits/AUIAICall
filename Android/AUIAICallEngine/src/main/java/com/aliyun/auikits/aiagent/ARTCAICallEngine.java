package com.aliyun.auikits.aiagent;

import static com.alivc.rtc.AliRtcEngine.AliRtcRenderMirrorMode.AliRtcRenderMirrorModeOnlyFront;
import static com.alivc.rtc.AliRtcEngine.AliRtcRenderMode.AliRtcRenderModeAuto;
import static com.alivc.rtc.AliRtcEngine.AliRtcRotationMode.AliRtcRotationMode_0;
import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallVideoRenderMirrorMode.ARTCAICallVideoRenderMirrorModeOnlyFront;
import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallVideoRenderMode.ARTCAICallVideoRenderModeAuto;
import static com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallVideoRotationMode.ARTCAICallVideoRotationMode_0;

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
        /** 发起通话，超出每天免费体验的额度 */
        AgentSubscriptionRequired,
        /** 智能体没找到*/
        AgentNotFund,
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

    public enum ARTCAICallVideoRenderMode{
        /*! 自动模式 */
        ARTCAICallVideoRenderModeAuto,
        /*! 拉伸平铺模式 ，如果外部输入的视频宽高比和推流设置的宽高比不一致时，将输入视频拉伸到推流设置的比例，画面会变形*/
        ARTCAICallVideoRenderModeStretch,
        /*! 填充黑边模式，如果外部输入的视频宽高比和推流设置的宽高比不一致时，将输入视频上下或者左右填充黑边 */
        ARTCAICallVideoRenderModeFill,
        /*! 裁剪模式，如果外部输入的视频宽高比和推流设置的宽高比不一致时，将输入视频宽或者高进行裁剪，画面内容会丢失 */
        ARTCAICallVideoRenderModeClip,
        ARTCAICallVideoRenderModeNoChange,
    }

    public enum ARTCAICallVideoRotationMode {
        /*! 0度 */
        ARTCAICallVideoRotationMode_0 ,
        /*! 90度 */
        ARTCAICallVideoRotationMode_90 ,
        /*! 180度 */
        ARTCAICallVideoRotationMode_180 ,
        /*! 270度 */
        ARTCAICallVideoRotationMode_270 ,
    }

    public enum ARTCAICallVideoRenderMirrorMode{
        /*! 只有前置摄像头预览镜像，其他不镜像 */
        ARTCAICallVideoRenderMirrorModeOnlyFront,
        /*! 全部镜像 */
        ARTCAICallVideoRenderMirrorModeAllEnabled,
        /*! 全部不镜像 */
        ARTCAICallVideoRenderMirrorModeAllDisable;
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

    public static class ARTCAICallVideoCanvas {
        /*! 渲染模式，默认值为 ARTCAICallVideoRenderModeAuto */
        public ARTCAICallVideoRenderMode renderMode = ARTCAICallVideoRenderModeAuto;
        /*! 镜像模式 ARTCAICallVideoRenderMirrorModeOnlyFront*/
        public ARTCAICallVideoRenderMirrorMode mirrorMode = ARTCAICallVideoRenderMirrorModeOnlyFront;
        /*! 旋转角度，默认值为 ARTCAICallVideoRotationMode_0 */
        public ARTCAICallVideoRotationMode rotationMode = ARTCAICallVideoRotationMode_0;

        @Override
        public String toString() {
            return "ARTCAICallVideoCanvas{" +
                    "renderMode=" + renderMode +
                    ", mirrorMode=" + mirrorMode +
                    ", rotationMode=" + rotationMode +
                    '}';
        }
    }

    public static class ARTCAICallVideoConfig {
        /** 是否使用本地高清预览 */
        public boolean useHighQualityPreview = false;
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
        public int videoEncoderKeyFrameInterval = 3000;

        @Override
        public String toString() {
            return "ARTCAICallVideoConfig{" +
                    "useHighQualityPreview=" + useHighQualityPreview +
                    ", useFrontCameraDefault=" + useFrontCameraDefault +
                    ", videoEncoderWidth=" + videoEncoderWidth +
                    ", videoEncoderHeight=" + videoEncoderHeight +
                    ", videoEncoderFrameRate=" + videoEncoderFrameRate +
                    ", videoEncoderBitRate=" + videoEncoderBitRate +
                    ", videoEncoderKeyFrameInterval=" + videoEncoderKeyFrameInterval +
                    '}';
        }
    }

    /**
     * 创建一路AI通话可配置的参数项
     * 部分字段可参考：https://help.aliyun.com/zh/ims/developer-reference/api-ice-2020-11-09-generateaiagentcall?spm=a2c4g.11186623.0.i3
     */
    public static class ARTCAICallAgentTemplateConfig {
        public String aiAgentId = "";// 智能体Id
        public String userExtendData = null;//业务自定义扩展字段
        public String aiAgentGreeting = "";//智能体欢迎语，AI智能体在用户入会后主动说的一句话
        public int aiAgentUserOnlineTimeout = 60;//用户未入会，智能体超时关闭任务的时间。单位：秒。默认值：60 秒
        public int aiAgentUserOfflineTimeout = 5;//用户退会后，智能体超时关闭任务的时间。单位：秒。默认值：5 秒。
        public String aiAgentWorkflowOverrideParams = null;//工作流覆盖参数，默认无
        public String aiAgentBailianAppParams = null;//百炼应用中心参数。参数格式参考：https://help.aliyun.com/zh/ims/user-guide/parameters-of-bailian-application-center?spm=a2c4g.11186623.0.0.2267571d9cXxJQ
        public int aiAgentAsrMaxSilence = 400;//语音断句检测阈值，静音时长超过该阈值会被认为断句，参数范围 200ms～1200ms，默认值 400ms
        public int aiAgentVolume = -1;//智能体说话的音量, 若不填：默认使用阿里云推荐的自适应音量模式
        public boolean enableVoiceInterrupt = true;//是否支持语音打断，默认 true
        public boolean enableIntelligentSegment = true;//智能断句开关，开启智能断句后，用户说话的发生断句会智能合并成一句。默认为 true
        public boolean enableVoicePrint = false;//是否使用声纹识别的开关。默认值：false
        public String voiceprintId = "";//声纹Id，如果不为空表示当前通话开启声纹降噪能力，为空表示不启用声纹降噪能力
        public String aiAgentVoiceId = "";//智能体讲话音色Id
        public int aiAgentMaxIdleTime = 600;//智能体闲时的最大等待时间(单位：秒)，超时智能体自动下线，设置为-1表示闲时不退出。
        public boolean aiAgentGracefulShutdown = false;//是否优雅下线，默认 false
        public boolean enablePushToTalk = false;//是否开启对讲机模式。默认值：false
        public String aiAgentAvatarId = "";//当智能体类型是AvatarAgent时，可以指定数字人模型Id

        /**
         * 客户自己部署的AppServer地址,如果接入方式是含UI的方式接入，需要设置该字段
         * 服务端集成方式参考：https://help.aliyun.com/zh/ims/user-guide/app-server-reference?spm=a2c4g.11186623.help-menu-193643.d_2_5_5_1_0_4_0.7c112ea3kfQxhL&scm=20140722.H_2848445._.OR_help-T_cn#DAS#zh-V_1
         */
        public String appServerHost = "";//客户自己部署的AppServer地址

        /**
         * 以下参数共官方Demo使用，客户接入AUI及场景化可忽略
         */
        public String loginUserId;
        public String loginAuthrization;
        public String aiAgentRegion = null;// 智能体服务所在的区域，如果为空，Appserver会使用默认的region来启动智能体服务
        public boolean isSharedAgent = false;// 是否是共享智能体


        @Override
        public String toString() {
            return "ARTCAICallGenerateParameters{" +
                    "aiAgentId='" + aiAgentId + '\'' +
                    ", aiAgentAvatarId='" + aiAgentAvatarId + '\'' +
                    ", aiAgentGreeting='" + aiAgentGreeting + '\'' +
                    ", aiAgentUserOnlineTimeout='" + aiAgentUserOnlineTimeout + '\'' +
                    ", aiAgentUserOfflineTimeout='" + aiAgentUserOfflineTimeout + '\'' +
                    ", aiAgentWorkflowOverrideParams='" + aiAgentWorkflowOverrideParams + '\'' +
                    ", aiAgentBailianAppParams='" + aiAgentBailianAppParams + '\'' +
                    ", aiAgentAsrMaxSilence='" + aiAgentAsrMaxSilence + '\'' +
                    ", aiAgentVolume='" + aiAgentVolume + '\'' +
                    ", enableVoiceInterrupt='" + enableVoiceInterrupt + '\'' +
                    ", enableIntelligentSegment='" + enableIntelligentSegment + '\'' +
                    ", aiAgentVoiceId='" + aiAgentVoiceId + '\'' +
                    ", aiAgentGracefulShutdown='" + aiAgentGracefulShutdown + '\'' +
                    ", aiAgentMaxIdleTime='" + aiAgentMaxIdleTime + '\'' +
                    ", aiAgentRegion=" + aiAgentRegion + '\'' +
                    ", isSharedAgent=" + isSharedAgent + '\'' +
                    ", userExtendData='" + userExtendData + '\'' +
                    ", enableVoicePrint='" + enableVoicePrint + '\'' +
                    ", voicePrintId='" + voiceprintId + '\'' +
                    ", enablePushToTalk='" + enablePushToTalk + '\'' +
                    ", appServerHost=" + appServerHost +
                    ", loginUserId=" + loginUserId +
                    ", loginAuthrization=" + loginAuthrization +
                    '}';
        }

    }

    public static class ARTCAICallConfig {
        public boolean enableSpeaker = true;
        public boolean isMicrophoneOn = true;
        public boolean isCameraMute = false;
        public boolean enableAudioDelayInfo = true;
        /**
         * 视频相关配置
         */
        public ARTCAICallVideoConfig mAiCallVideoConfig = new ARTCAICallVideoConfig();

        /**
         * 如果使用不含UI方式接入，不需要设置mAiCallGenerateParameters
         */
        public ARTCAICallAgentTemplateConfig mAiCallAgentTemplateConfig = new ARTCAICallAgentTemplateConfig();

        @Override
        public String toString() {
            return "ARTCAICallConfig{" +
                    ", enableSpeaker=" + enableSpeaker +
                    ", isMicrophoneOn=" + isMicrophoneOn +
                    ", isCameraMute=" + isCameraMute +
                    ", mAiCallVideoConfig=" + mAiCallVideoConfig +
                    ", ARTCAICallAgentTemplateConfig=" + mAiCallAgentTemplateConfig +
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
         * 智能体情绪结果通知
         * @param emotion 情绪标签，例如：neutral\happy\angry\sad 等
         * @param userAsrSentenceId 回答用户问题的句子ID
         */
        public void onAgentEmotionNotify(String emotion,int userAsrSentenceId) {}

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

        /**
         * 当前智能体即将离开（结束当前通话）
         * @param reason 原因：2001(闲时退出), 2002(真人接管结束), 0(其他)
         * @param message 描述原因
         */
        public void onAgentWillLeave(int reason, String message) {}

        /**
         * 智能体自定义消息
         * @param data 自定义消息体，使用json字符串
         */
        public void onReceivedAgentCustomMessage(String data) {}

        /**
         * 当真人即将接管当前智能体
         * @param takeoverUid 真人uid
         * @param takeoverMode 1：表示使用真人音色输出；0：表示使用智能体音色输出
         */
        public void onHumanTakeoverWillStart(String takeoverUid, int takeoverMode) {}

        /**
         * 当真人接管已经接通
         * @param takeoverUid 真人uid
         */
        public void onHumanTakeoverConnected(String takeoverUid) {}

        /**
         * 音频回环延迟
         *  @param id 语句ID
         *  @param delay_ms 延迟
         */
        public void onAudioDelayInfo(int id, int delay_ms) {}
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
     * @param avatarLayoutParams
     * @param canvas 视频渲染模式
     */
    public abstract void setAvatarAgentView(ViewGroup viewGroup, ViewGroup.LayoutParams avatarLayoutParams, ARTCAICallVideoCanvas canvas);

    /**
     * 设置数字人视图载体
     * @param viewGroup
     * @param visionLayoutParams
     */
    public abstract void setVisionPreviewView(ViewGroup viewGroup, ViewGroup.LayoutParams visionLayoutParams);

    /**
     * 设置数字人视图载体
     * @param viewGroup
     * @param visionLayoutParams
     * @param canvas 视频渲染模式
     */
    public abstract void setVisionPreviewView(ViewGroup viewGroup, ViewGroup.LayoutParams visionLayoutParams, ARTCAICallVideoCanvas canvas);

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
