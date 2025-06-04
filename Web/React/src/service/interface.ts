import { AICallAgentType } from 'aliyun-auikit-aicall';

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
  VideoChat = 'VideoChat',
}

const WorkflowTypeAgentTypeMap = {
  [WorkflowType.AvatarChat3D]: AICallAgentType.AvatarAgent,
  [WorkflowType.VoiceChat]: AICallAgentType.VoiceAgent,
  [WorkflowType.VisionChat]: AICallAgentType.VisionAgent,
  [WorkflowType.VideoChat]: AICallAgentType.VideoAgent,
};
export const getAgentType = (type: WorkflowType) => {
  if (WorkflowTypeAgentTypeMap[type]) return WorkflowTypeAgentTypeMap[type];
  return AICallAgentType.VoiceAgent;
};

const AgentTypeWorkflowTypeMap = {
  [AICallAgentType.AvatarAgent]: WorkflowType.AvatarChat3D,
  [AICallAgentType.VoiceAgent]: WorkflowType.VoiceChat,
  [AICallAgentType.VisionAgent]: WorkflowType.VisionChat,
  [AICallAgentType.VideoAgent]: WorkflowType.VideoChat,
};
export const getWorkflowType = (type?: AICallAgentType) => {
  if (!type) return WorkflowType.VoiceChat;
  if (AgentTypeWorkflowTypeMap[type]) return AgentTypeWorkflowTypeMap[type];
  return WorkflowType.VoiceChat;
};
