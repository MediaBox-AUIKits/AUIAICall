export enum AICallType {
  AudioOnly = 1, // 纯语音
  DigitalHuman = 2, // 数字人
}

export enum AICallState {
  None = 0, // 初始化
  Connecting = 1, // 接通中
  Connected = 2, // 通话中
  Over = 3, // 通话结束
  Error = 4, // 通话结束
}

export enum AICallAgentState {
  Listening = 1, // 聆听中
  Thinking = 2, // 思考中
  Talking = 3, // 讲话中
}

export enum AICallErrorCode {
  None = 0, // 成功
  InvalidAction = -1, // 操作无效
  InvalidParames = -2, // 参数错误
  BeginCallFailed = -10000, // 启动通话失败
  ConnectionFailed = -10001, // 链接出现问题
  PublishFailed = -10002, // 推流失败
  SubscribeFailed = -10003, // 拉流失败
  TokenExpired = -10004, // 通话认证过期
  KickedByUserReplace = -10005, // 同名登录导致通话无法进行
  KickedBySystem = -10006, // 被系统踢出导致通话无法进行
  KickedByChannelTerminated = -10007,
  LocalDeviceException = -10008, // 本地设备问题导致无法进行
  AgentLeaveChannel = -10009, // 智能体离开频道了（智能体结束通话）
}

export enum AICallMessageType {
  None = 0,

  // 发起端是机器人
  AgentStateChanged = 1001,
  AgentSubtitleNotify = 1002,
  UserSubtitleNotify = 1003,
  VoiceInterruptChanged = 1004,
  VoiceIdChanged = 1005,
  RTCTokenResponsed = 1006,

  // 发起端是用户
  InterruptSpeaking = 1101,
  EnableVoiceInterrupt = 1102,
  SwitchVoiceId = 1103,
  RequestRTCToken = 1104,
}

type JSONData = {
  [key: string]: string | number | boolean | JSONData;
};

export interface AICallMessageSendData {
  type: AICallMessageType;
  data?: JSONData;
  senderId?: string;
  receiverId?: string;
}

export interface AICallMessageReceiveData {
  type: AICallMessageType;
  data: JSONData;
  seqId: number;
  senderId?: string;
  receiverId?: string;
}

export interface AICallSubtitleData {
  text: string;
  sentenceId: number;
  end: boolean;
}
