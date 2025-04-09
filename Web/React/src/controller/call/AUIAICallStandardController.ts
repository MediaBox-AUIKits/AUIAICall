import { AICallAgentError, AICallAgentInfo, AICallState, AICallTemplateConfig } from 'aliyun-auikit-aicall';
import AUIAICallController from './AUIAICallController';

import standardService from '../../service/standard';
import AUIAICallConfig from './AUIAICallConfig';
import { TemplateConfig } from '../../service/interface';
import logger from '@/common/logger';

class AUIAICallStandardController extends AUIAICallController {
  constructor(userId: string, token: string, config?: AUIAICallConfig) {
    super(userId, token, config);
  }

  set appServer(appServerUrl: string) {
    standardService.setAppServer(appServerUrl);
  }

  private async describeAIAgent(instanceId: string) {
    const startTs = Date.now();
    try {
      // 每次先清空当前的配置
      this.config.templateConfig.avatarUrl = '';
      this.config.templateConfig.agentVoiceId = '';
      this.config.agentVoiceIdList = [];
      const templateConfig = await standardService.describeAIAgent(this.userId, this.token, instanceId);
      const configKey = AICallTemplateConfig.getTemplateConfigKey(this.config.agentType) as keyof TemplateConfig;
      const configValue = templateConfig[configKey];
      if (configValue?.AvatarUrl) {
        this.config.templateConfig.avatarUrl = configValue?.AvatarUrl as string;
      }
      if (configValue?.VoiceId) {
        this.config.templateConfig.agentVoiceId = configValue?.VoiceId as string;
      }
      if (configValue?.VoiceIdList) {
        this.config.agentVoiceIdList = configValue.VoiceIdList as string[];
      }
      logger.info('StandardController', 'DescribeAIAgent', { value: Date.now() - startTs });
    } catch (error) {
      logger.error('DescribeAIAgentFailed', error as Error);
      console.log(error);
    }
  }

  async startAIAgent(): Promise<AICallAgentInfo> {
    let agentInfo: AICallAgentInfo | null = null;
    const startTs = Date.now();
    try {
      if (this.shareConfig) {
        agentInfo = await this.engine?.generateShareAgentCall(this.shareConfig, this.userId);
      } else {
        agentInfo = await standardService.generateAIAgent(this.userId, this.token, this.config);
      }
      logger.info('StandardController', 'StartAIAgent', {
        share: !!this.shareConfig,
        value: Date.now() - startTs,
      });
    } catch (error) {
      logger.error('GenerateAIAgentFailed', error as Error);
      throw error;
    }

    if (!agentInfo) {
      const error = new AICallAgentError('generate ai agent failed');
      logger.error('NoAIAgent', error);
      throw error;
    }

    // 不需要等待 describeAIAgent 接口返回
    this.describeAIAgent(agentInfo.instanceId);

    return agentInfo;
  }

  async stopAIAgent(): Promise<void> {
    logger.info('StandardController', 'StopAIAgent');
    this.engine?.stopAgent();
    await new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);
      }, 200);
    });
  }

  async enableVoiceInterrupt(enable: boolean): Promise<boolean> {
    logger.info('StandardController', 'EnableVoiceInterrupt', { enable });
    if (this.state === AICallState.Connected) {
      this.engine?.enableVoiceInterrupt(enable);
    }
    return true;
  }

  async switchVoiceId(voiceId: string): Promise<boolean> {
    logger.info('StandardController', 'SwitchVoiceId', { voiceId });
    if (this.state === AICallState.Connected) {
      this.engine?.switchVoiceId(voiceId);
    }
    return true;
  }

  async requestRTCToken(): Promise<string> {
    logger.info('StandardController', 'RequestRTCToken');
    if (this.state === AICallState.Connected) {
      this.engine?.requestRTCToken();

      // 等待返回新的 RTC token
      return new Promise((resolve) => {
        this.engine?.once('newRTCToken', (token: string) => {
          resolve(token);
        });
      });
    }
    return '';
  }

  destroy() {
    logger.info('StandardController', 'destroy');
    super.destroy();
    this.appServer = '';
  }
}

export default AUIAICallStandardController;
