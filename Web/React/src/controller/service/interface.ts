import { AICallAgentType } from 'aliyun-auikit-aicall';

export const APP_SERVER = "你的AppServer域名";

export type JSONData = {
  [key: string]: string | number | boolean;
};

export type TemplateConfig = {
  VoiceChat?: JSONData;
  AvatarChat3D?: JSONData;
  VisionChat?: JSONData;
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
