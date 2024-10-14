export const APP_SERVER = "你的AppServer域名";

export type JSONData = {
  [key: string]: string | number | boolean;
};

export type TemplateConfig = {
  VoiceChat?: JSONData;
  AvatarChat3D?: JSONData;
  MessageChat?: JSONData;
};

export enum WorkflowType {
  VoiceChat = 'VoiceChat',
  AvatarChat3D = 'AvatarChat3D',
}

export class ServiceAuthError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'AuthError';
  }
}
