import { AICallAgentType, AICallTemplateConfig } from 'aliyun-auikit-aicall';

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
   * 通话限制时间，为0表示不限制，否则通话时间到达秒数后，会自动结束通话
   */
  limitSecond = 0;

  /**
   * 是否关闭麦克风（静音）
   */
  muteMicrophone = false;
  /**
   * 是否关闭摄像头
   */
  muteCamera = false;

  /**
   * 本地摄像头预览渲染视图
   */
  previewView?: HTMLVideoElement | string;

  /**
   * 智能体视频渲染视图
   */
  agentView?: HTMLVideoElement | string;

  /**
   * 智能体所在区域
   */
  region?: string;

  /**
   * 智能体模板配置
   */
  templateConfig: AICallTemplateConfig = new AICallTemplateConfig();

  /**
   * 智能体支持的音色列表
   */
  agentVoiceIdList: string[] = [];

  /**
   * 用户自定义信息，该信息最终传给智能体
   */
  userData?: string;

  /**
   * 是否来自分享链接
   */
  fromShare?: boolean;
}

export default AUIAICallConfig;
