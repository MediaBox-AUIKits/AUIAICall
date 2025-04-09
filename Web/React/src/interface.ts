import { JSONObject } from '@/service/interface.ts';
import { AICallAgentType, AIChatAgentType, AICallTemplateConfig, AIChatTemplateConfig } from 'aliyun-auikit-aicall';

export interface AICallRunConfig {
  // 可选，默认使用上海区域 cn-shanghai
  region?: string;
  // 必选，应用服务器地址
  // 格式示例 https://xxxx.domain.com
  // 1. 除本地 localhost 调试外，需要为 https 域名
  // 2. 结尾不应包含 /
  appServer: string;

  // 智能体类型，如果配置则不展示智能体类型选择页面
  agentType?: AICallAgentType | AIChatAgentType;
  // 可选，通话智能体模板
  callTemplateConfig?: AICallTemplateConfig;
  // 可选，通话智能体用户数据
  callUserData?: string;

  // 智能体 id 可通过控制台获取 https://ice.console.aliyun.com/ai/robot/list
  // 可选，语音通话智能体 id，不传入则由 AppServer 决定
  voiceAgentId?: string;
  // 可选，数字人智能体 id，不传入则由 AppServer 决定
  avatarAgentId?: string;
  // 可选，视觉智能体 id，不传入则由 AppServer 决定
  visionAgentId?: string;
  // 必选，消息通话智能体 id
  chatAgentId: string;

  // 可选，消息通话智能体模板
  chatTemplateConfig?: AIChatTemplateConfig;

  // 可选，消息通话智能体用户数据
  chatUserData?: JSONObject;
}

export type AICallUserRunConfig = AICallRunConfig | (() => AICallRunConfig);
export const getRuntimeConfig = (runConfig: AICallUserRunConfig) => {
  const rc = typeof runConfig === 'function' ? runConfig() : runConfig;
  return rc;
};
export const getCallAgentId = (rc: AICallRunConfig, agentType?: AICallAgentType) => {
  if (agentType === undefined || agentType < AICallAgentType.VoiceAgent || agentType > AICallAgentType.VisionAgent) {
    return;
  }
  if (agentType === AICallAgentType.VoiceAgent) {
    return rc.voiceAgentId;
  }
  if (agentType === AICallAgentType.AvatarAgent) {
    return rc.avatarAgentId;
  }
  if (agentType === AICallAgentType.VisionAgent) {
    return rc.visionAgentId;
  }
};
