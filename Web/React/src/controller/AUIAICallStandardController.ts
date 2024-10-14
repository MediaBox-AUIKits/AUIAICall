import { AICallAgentInfo, AICallState } from 'aliyun-auikit-aicall';
import AUIAICallController from './AUIAICallController';

import standardService from './service/standard';

class AUIAICallStandardController extends AUIAICallController {
  constructor(userId: string, token: string) {
    super(userId, token);
  }

  async startAIAgent(): Promise<AICallAgentInfo> {
    return await standardService.generateAIAgent(this.userId, this.token, this.config);
  }

  async stopAIAgent(): Promise<void> {
    this.currentEngine?.stopAgent();
    await new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);
      }, 200);
    });
  }

  async enableVoiceInterrupt(enable: boolean): Promise<boolean> {
    if (this.state === AICallState.Connected) {
      this.currentEngine?.enableVoiceInterrupt(enable);
    }
    return true;
  }

  async switchVoiceId(voiceId: string): Promise<boolean> {
    if (this.state === AICallState.Connected) {
      this.currentEngine?.switchVoiceId(voiceId);
    }
    return true;
  }

  async requestRTCToken(): Promise<string> {
    if (this.state === AICallState.Connected) {
      this.currentEngine?.requestRTCToken();

      // 等待返回新的 RTC token
      return new Promise((resolve) => {
        this.currentEngine?.once('newRTCToken', (token: string) => {
          resolve(token);
        });
      });
    }
    return '';
  }
}

export default AUIAICallStandardController;
