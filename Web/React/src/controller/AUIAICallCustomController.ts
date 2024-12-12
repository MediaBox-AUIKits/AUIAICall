import AUIAICallController from './AUIAICallController';
import { getWorkflowType, TemplateConfig } from './service/interface';

import customService from './service/custom';
import { AICallAgentError, AICallAgentInfo, AICallState } from 'aliyun-auikit-aicall';
import AUIAICallConfig from './AUIAICallConfig';
import logger from '@/common/logger';
class AUIAICallCustomController extends AUIAICallController {
  constructor(userId: string, token: string, config: AUIAICallConfig) {
    super(userId, token, config);
  }

  async startAIAgent(): Promise<AICallAgentInfo> {
    logger.info('CustomController', 'StartAIAgent');
    let agentInfo: AICallAgentInfo | null = null;
    try {
      agentInfo = await customService.startAIAgent(this.userId, this.token, this.config);
    } catch (error) {
      logger.error('StartAIAgentFailed', error as Error);
    }

    if (!agentInfo) {
      const error = new AICallAgentError('start ai agent failed');
      logger.error('NoAIAgent', error);
      throw error;
    }
    return agentInfo;
  }

  async stopAIAgent(instanceId: string): Promise<void> {
    logger.info('CustomController', 'StopAIAgent', { instanceId });
    await customService.stopAIAgent(instanceId);
  }

  async enableVoiceInterrupt(enable: boolean): Promise<boolean> {
    logger.info('CustomController', 'EnableVoiceInterrupt', { enable: enable ? 'on' : 'off' });
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
    logger.info('CustomController', 'EnablePushToTalk', { enable: enable ? 'on' : 'off' });
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
    logger.info('CustomController', 'SwitchVoiceId', { voiceId });
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
    logger.info('CustomController', 'RequestRTCToken');
    const agentInfo = this.engine?.agentInfo;

    if (agentInfo) {
      return await customService.getRtcAuthToken(agentInfo.channelId, agentInfo.userId);
    }
    return '';
  }
}

export default AUIAICallCustomController;
