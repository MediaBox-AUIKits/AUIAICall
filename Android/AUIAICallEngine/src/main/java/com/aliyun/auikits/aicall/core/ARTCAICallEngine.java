package com.aliyun.auikits.aicall.core;

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
        LocalDeviceException
    }

    public enum AICallMode {
        /** 纯语音 */
        OnlyAudio,
        /** 数字人(暂不支持) */
        DigitalHuman
    }

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

    public static class ARTCAICallConfig {
        public String robotId = "";
        public boolean enableVoiceInterrupt = true;
        public String robotVoiceId = "";
        public boolean enableSpeaker = true;
        public boolean isCallPaused = false;
        public boolean isMicrophoneOn = true;
        public boolean enableAudioDump = false;
        public boolean usePreHost = false;
    }

    public interface IARTCAICallEngineCallback {
        /**
         * 通话状态同步
         * @param oldCallState
         * @param newCllState
         * @param errorCode
         */
        void onAICallEngineStateChanged(AICallState oldCallState, AICallState newCllState, AICallErrorCode errorCode);

        /**
         * 机器人状态同步
         * @param oldRobotState
         * @param newRobotState
         */
        void onAICallEngineRobotStateChanged(ARTCAICallRobotState oldRobotState, ARTCAICallRobotState newRobotState);

        /**
         * 用户说话回调
         * @param isSpeaking
         */
        void onUserSpeaking(boolean isSpeaking);

        /**
         * 同步ASR识别用户的话
         * @param text ASR识别出的具体文本
         * @param isSentenceEnd 当前文本是否为这句话的最终结果
         * @param sentenceId 当前文本属于的句子ID
         */
        void onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId);

        /**
         * 同步机器人回应的话
         * @param text 机器人的话
         * @param end 当前回复是否结束
         * @param userAsrSentenceId 表示回应对应sentenceId语音输入的的llm内容
         */
        void onRobotSubtitleNotify(String text, boolean end, int userAsrSentenceId);
    }

    /**
     * 初始化
     * @param config 初始化配置
     */
    public abstract void init(ARTCAICallConfig config);

    /**
     * 创建&开始通话
     */
    public abstract void start();

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
     * 暂停通话
     */
    public abstract boolean pause();

    /**
     * 继续通话
     */
    public abstract boolean resume();

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
     * 通话是否处于暂停暂停
     * @return
     */
    public abstract boolean isCallPaused();

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
}
