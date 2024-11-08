import AUIAICallController from './AUIAICallController';
import { getWorkflowType, TemplateConfig } from './service/interface';

import customService from './service/custom';
import { AICallAgentInfo, AICallState } from 'aliyun-auikit-aicall';
import AUIAICallConfig from './AUIAICallConfig';
class AUIAICallCustomController extends AUIAICallController {
  constructor(userId: string, token: string, config: AUIAICallConfig) {
    super(userId, token, config);
  }

  async startAIAgent(): Promise<AICallAgentInfo> {
    return await customService.startAIAgent(this.userId, this.token, this.config);
  }

  async stopAIAgent(instanceId: string): Promise<void> {
    await customService.stopAIAgent(instanceId);
  }

  async enableVoiceInterrupt(enable: boolean): Promise<boolean> {
    const agentInfo = this.engine?.agentInfo;
    if (this.state === AICallState.Connected && agentInfo) {
      const templateConfig: TemplateConfig = {};
      const configDict = { EnableVoiceInterrupt: enable };
      templateConfig[getWorkflowType(this.config.agentType)] = configDict;
      return await customService.updateAIAgent(agentInfo.instanceId, templateConfig);
    }
    return false;
  }

  async enablePushToTalk(enable: boolean): Promise<boolean> {
    const agentInfo = this.engine?.agentInfo;
    if (this.state === AICallState.Connected && agentInfo) {
      const templateConfig: TemplateConfig = {};
      const configDict = { EnablePushToTalk: enable };
      templateConfig[getWorkflowType(this.config.agentType)] = configDict;
      return await customService.updateAIAgent(agentInfo.instanceId, templateConfig);
    }
    return false;
  }

  async switchVoiceId(voiceId: string): Promise<boolean> {
    const agentInfo = this.engine?.agentInfo;
    if (this.state === AICallState.Connected && agentInfo) {
      const templateConfig: TemplateConfig = {};
      const configDict = { VoiceId: voiceId };
      templateConfig[getWorkflowType(this.config.agentType)] = configDict;
      return await customService.updateAIAgent(agentInfo.instanceId, templateConfig);
    }
    return false;
  }

  async requestRTCToken(): Promise<string> {
    const agentInfo = this.engine?.agentInfo;

    if (agentInfo) {
      return await customService.getRtcAuthToken(agentInfo.channelId, agentInfo.userId);
    }
    return '';
  }
}

export default AUIAICallCustomController;
