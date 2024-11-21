import { AICallAgentType } from 'aliyun-auikit-aicall';

class AUIAICallConfig {
  /**
   * 智能体Id
   */
  agentId?: string;
  /**
   * 智能体类型
   */
  agentType = AICallAgentType.VoiceAgent;
  /**
   * 智能体讲话音色Id
   */
  agentVoiceId = '';
  /**
   * 数字人模型Id
   */
  agentAvatarId = '';
  /**
   * 智能体欢迎语，AI智能体在用户入会后主动说的一句话
   */
  agentGreeting?: string;
  /**
   * 是否开启智能打断
   */
  enableVoiceInterrupt = true;
  /**
   * 是否开启PushToTalk
   */
  enablePushToTalk = false;
  /**
   * 是否关闭麦克风（静音）
   */
  muteMicrophone = false;
  /**
   * 是否关闭摄像头
   */
  muteCamera = false;
  /**
   * 通话限制时间，为0表示不限制，否则通话时间到达秒数后，会自动结束通话
   */
  limitSecond = 0;

  /**
   * 智能体闲时的最大等待时间(单位：秒)，超时智能体自动下线，设置为-1表示闲时不退出。
   */
  agentMaxIdleTime = 600;

  /**
   * 语音对话头像地址
   */
  voiceAvatarUrl?: string;

  /**
   * 本地摄像头预览渲染视图
   */
  previewView?: HTMLVideoElement | string;

  /**
   * 智能体视频渲染视图
   */
  agentView?: HTMLVideoElement | string;
}

export default AUIAICallConfig;
