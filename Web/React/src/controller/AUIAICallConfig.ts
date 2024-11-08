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
}

export default AUIAICallConfig;
