import { AICallAgentType } from 'aliyun-auikit-aicall';

export const hasVideoOutbound = (agentType?: AICallAgentType) => {
  return agentType === AICallAgentType.VideoAgent || agentType === AICallAgentType.VisionAgent;
};

export const hasVideoInbound = (agentType?: AICallAgentType) => {
  return agentType === AICallAgentType.VideoAgent || agentType === AICallAgentType.AvatarAgent;
};
