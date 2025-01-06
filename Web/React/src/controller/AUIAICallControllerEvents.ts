import { AICallAgentInfo, AICallAgentState, AICallState, AICallSubtitleData } from 'aliyun-auikit-aicall';

interface AUIAICallControllerEvents {
  /**
   * AI智能体已被启动
   */
  AICallAIAgentStarted: (agentInfo: AICallAgentInfo) => void;

  /**
   * AI智能体开始通话
   */
  AICallBegin: () => void;

  /**
   * 当前通话状态改变
   */
  AICallStateChanged: (state: AICallState) => void;
  /**
   * 智能体状态改变
   */
  AICallAgentStateChanged: (state: AICallAgentState) => void;
  /**
   * 当前讲话Id及音量
   * @param userId 当前讲话人Id
   * @param volume 音量[0-100]
   */
  AICallActiveSpeakerVolumeChanged: (userId: string, volume: number) => void;

  /**
   * 对讲机模式变化
   * @param enable 对讲机模式状态
   */
  AICallPushToTalkChanged: (enable: boolean) => void;
  /**
   * 用户提问被智能体识别字幕通知
   */
  AICallUserSubtitleNotify: (data: AICallSubtitleData) => void;
  /**
   * 智能体回答字幕通知
   */
  AICallAgentSubtitleNotify: (data: AICallSubtitleData) => void;

  /**
   * 智能体情绪结果通知
   * @param emotion 情绪标签，例如：neutral\happy\angry\sad 等
   * @param userAsrSentenceId 回答用户问题的句子ID
   */
  AICallAgentEmotionNotify: (emotion: string, userAsrSentenceId: number) => void;
  /**
   * 用户token过期
   */
  AICallUserTokenExpired: () => void;

  /**
   * 智能体音频流订阅成功
   */
  AICallAgentAudioSubscribed: (audioElement?: HTMLAudioElement) => void;

  /**
   * 智能体即将结束通话
   * @param reason 原因：2001(闲时退出) , 2002(真人接管结束)   0(其他)
   */
  AICallAgentWillLeave: (reason: number, message: string) => void;

  /**
   * 智能体自定义消息
   */
  AICallReceivedAgentCustomMessage: (data: {
    [key: string]: string | number | boolean | object | null | undefined;
  }) => void;

  /*
   * 智能体转人工
   */
  AICallHumanTakeoverWillStart: (uid: string, takeoverMode: number) => void;
  /**
   * 智能体转人工成功
   */
  AICallHumanTakeoverConnected: (uid: string) => void;
}

export default AUIAICallControllerEvents;
