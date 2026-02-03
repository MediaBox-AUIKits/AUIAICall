import { VoiceStyleModel } from '../dialog/VoiceStyleDialog';


class AgentConstants {


  static readonly AGENT_ID_VOICE: string = '你的语音通话智能体Id';
  static readonly AGENT_ID_AVATAR: string = '你的数字人通话智能体Id';
  static readonly AGENT_ID_VISION: string = '你的视觉理解通话智能体Id';
  static readonly AGENT_ID_VIDEO: string = '你的视频通话智能体Id';
  static readonly AGENT_ID_OUTBOUND: string = '你的电话呼出智能体Id';
  static readonly AGENT_ID_INBOUND: string = '你的电话呼入智能体Id';

  // 配置区域
  static readonly AGENT_REGION: string = "智能体所在的区域，详情参考官网文档";

  // 【可选】配置音色
  static readonly DEFAULT_VOICE_STYLES: Array<VoiceStyleModel> = [
  ];
}

export { AgentConstants }