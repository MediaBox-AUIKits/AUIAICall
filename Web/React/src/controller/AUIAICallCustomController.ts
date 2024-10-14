import { AICallAgentType, AICallState } from '../core/interface';
import AUIAICallController from './AUIAICallController';
import { AICallAgentInfo, TemplateConfig } from './service/interface';

import customService from './service/custom';
class AUIAICallCustomController extends AUIAICallController {
  constructor(userId: string, token: string) {
    super(userId, token);
  }

  async startAIAgent(): Promise<AICallAgentInfo> {
    return await customService.startAIAgent(this.userId, this.token, this.config);
  }

  async stopAIAgent(instanceId: string): Promise<void> {
    await customService.stopAIAgent(instanceId);
  }

  async enableVoiceInterrupt(enable: boolean): Promise<boolean> {
    const agentInfo = this.currentEngine?.agentInfo;
    if (this.state === AICallState.Connected && agentInfo) {
      const templateConfig: TemplateConfig = {};
      const configDict = { EnableVoiceInterrupt: enable };
      if (this.config.agentType === AICallAgentType.VoiceAgent) {
        templateConfig.VoiceChat = configDict;
      } else {
        templateConfig.AvatarChat3D = configDict;
      }
      return await customService.updateAIAgent(agentInfo.ai_agent_instance_id, templateConfig);
    }
    return false;
  }

  async switchVoiceId(voiceId: string): Promise<boolean> {
    const agentInfo = this.currentEngine?.agentInfo;
    if (this.state === AICallState.Connected && agentInfo) {
      const templateConfig: TemplateConfig = {};
      const configDict = { VoiceId: voiceId };
      if (this.config.agentType === AICallAgentType.VoiceAgent) {
        templateConfig.VoiceChat = configDict;
      } else {
        templateConfig.AvatarChat3D = configDict;
      }
      return await customService.updateAIAgent(agentInfo.ai_agent_instance_id, templateConfig);
    }
    return false;
  }

  async requestRTCToken(): Promise<string> {
    const agentInfo = this.currentEngine?.agentInfo;

    if (agentInfo) {
      return await customService.getRtcAuthToken(agentInfo.channel_id, agentInfo.ai_agent_user_id);
    }
    return '';
  }
}

export default AUIAICallCustomController;
