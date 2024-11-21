import { AICallAgentInfo, AICallAgentType, AICallState } from 'aliyun-auikit-aicall';
import AUIAICallController from './AUIAICallController';

import standardService from './service/standard';
import AUIAICallConfig from './AUIAICallConfig';
import { APP_SERVER } from './service/interface';

class AUIAICallStandardController extends AUIAICallController {
  constructor(userId: string, token: string, config?: AUIAICallConfig) {
    super(userId, token, config);
  }

  set appServer(appServerUrl: string) {
    standardService.setAppServer(appServerUrl);
  }

  async startAIAgent(): Promise<AICallAgentInfo> {
    let agentInfo: AICallAgentInfo;
    if (this.shareConfig) {
      agentInfo = await this.engine?.generateShareAgentCall(this.shareConfig, this.userId);
    } else {
      agentInfo = await standardService.generateAIAgent(this.userId, this.token, this.config);
    }

    try {
      if (agentInfo.agentType === AICallAgentType.VoiceAgent) {
        // 每次先清空当前的 AvatarUrl
        this.config.voiceAvatarUrl = '';
        const templateConfig = await standardService.describeAIAgent(this.userId, this.token, agentInfo.instanceId);
        if (templateConfig.VoiceChat?.AvatarUrl) {
          this.config.voiceAvatarUrl = templateConfig.VoiceChat?.AvatarUrl as string;
        }
      }
    } catch (error) {
      console.log(error);
    }

    return agentInfo;
  }

  async stopAIAgent(): Promise<void> {
    this.engine?.stopAgent();
    await new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);
      }, 200);
    });
  }

  async enableVoiceInterrupt(enable: boolean): Promise<boolean> {
    if (this.state === AICallState.Connected) {
      this.engine?.enableVoiceInterrupt(enable);
    }
    return true;
  }

  async switchVoiceId(voiceId: string): Promise<boolean> {
    if (this.state === AICallState.Connected) {
      this.engine?.switchVoiceId(voiceId);
    }
    return true;
  }

  async requestRTCToken(): Promise<string> {
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

  destory() {
    super.destory();
    this.appServer = APP_SERVER;
  }
}

export default AUIAICallStandardController;
