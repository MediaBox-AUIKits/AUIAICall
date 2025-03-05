import { AICallAgentType } from 'aliyun-auikit-aicall';

// 格式示例 https://xxxx.domain.com
// 1. 除本地 localhost 调试外，需要为 https 域名
// 2. 结尾不应包含 /
export const APP_SERVER = "你的AppServer域名";

type JSONPrimitive = string | number | boolean | null;
export interface JSONObject {
  [key: string]: JSONPrimitive | JSONPrimitive[] | JSONObject | JSONObject[];
}

export type TemplateConfig = {
  VoiceChat?: JSONObject;
  AvatarChat3D?: JSONObject;
  VisionChat?: JSONObject;
};

export enum WorkflowType {
  VoiceChat = 'VoiceChat',
  AvatarChat3D = 'AvatarChat3D',
  VisionChat = 'VisionChat',
}

const WorkflowTypeAgentTypeMap = {
  [WorkflowType.AvatarChat3D]: AICallAgentType.AvatarAgent,
  [WorkflowType.VoiceChat]: AICallAgentType.VoiceAgent,
  [WorkflowType.VisionChat]: AICallAgentType.VisionAgent,
};
export const getAgentType = (type: WorkflowType) => {
  if (WorkflowTypeAgentTypeMap[type]) return WorkflowTypeAgentTypeMap[type];
  return AICallAgentType.VoiceAgent;
};

const AgentTypeWorkflowTypeMap = {
  [AICallAgentType.AvatarAgent]: WorkflowType.AvatarChat3D,
  [AICallAgentType.VoiceAgent]: WorkflowType.VoiceChat,
  [AICallAgentType.VisionAgent]: WorkflowType.VisionChat,
};
export const getWorkflowType = (type?: AICallAgentType) => {
  if (!type) return WorkflowType.VoiceChat;
  if (AgentTypeWorkflowTypeMap[type]) return AgentTypeWorkflowTypeMap[type];
  return WorkflowType.VoiceChat;
};
