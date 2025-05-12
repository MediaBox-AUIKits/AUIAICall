import { AICallAgentType, AICallTemplateConfig, AICallChatSyncConfig } from 'aliyun-auikit-aicall';

class AUIAICallConfig {
  /**
   * 智能体Id
   * AgentId
   */
  agentId?: string;
  /**
   * 智能体类型
   * AgentType
   */
  agentType = AICallAgentType.VoiceAgent;

  /**
   * 通话限制时间，为0表示不限制，否则通话时间到达秒数后，会自动结束通话
   * CallLimitSecond, 0 - no limit, otherwise call will be ended after the second
   */
  limitSecond = 0;

  /**
   * 是否关闭麦克风（静音）
   * muteMicrophone
   */
  muteMicrophone = false;
  /**
   * 是否关闭摄像头
   * muteCamera
   */
  muteCamera = false;

  /**
   * 本地摄像头预览渲染视图
   * local camera preview view
   */
  previewView?: HTMLVideoElement | string;

  /**
   * 智能体视频渲染视图
   * agent video render view
   */
  agentView?: HTMLVideoElement | string;

  /**
   * 智能体所在区域
   * agent region
   */
  region?: string;

  /**
   * 智能体模板配置
   * agent template config
   */
  templateConfig: AICallTemplateConfig = new AICallTemplateConfig();

  /**
   * 智能体支持的音色列表
   * agent voice id list
   */
  agentVoiceIdList: string[] = [];

  /**
   * 用户自定义信息，该信息最终传给智能体
   * custom user data, which will be passed to agent
   */
  userData?: string;

  /**
   * 是否来自分享链接
   * from share link
   */
  fromShare?: boolean;

  /**
   * 关联的chat智能体配置，如果设置了，那么在通话过程中会把通话记录同步到chat智能体上
   * related chat agent config, if set, the call record will be synced to chat agent
   */
  chatSyncConfig?: AICallChatSyncConfig;

  /**
   * RTC 引擎配置
   * rtc engine config
   */
  rtcEngineConfig?: {
    environment?: 'PRE' | 'PROD';
    useAudioPlugin?: boolean;
    dumpAudioData?: boolean;
  };
}

export default AUIAICallConfig;
