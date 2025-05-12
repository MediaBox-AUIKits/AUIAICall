import logger from '@/common/logger.ts';
import AUIAICallAuthTokenHelper from '@/controller/call/AUIAICallAuthTokenHelper.ts';
import { AICallAgentError, AICallErrorCode, AICallState } from 'aliyun-auikit-aicall';
import AUIAICallController from './AUIAICallController.ts';

class AUIAICallProxyController extends AUIAICallController {
  async start(): Promise<void> {
    logger.info('ProxyController', 'Start');
    const startTs = Date.now();
    if (this.state === AICallState.Connected || this.state === AICallState.Connecting) return;
    this.state = AICallState.Connecting;

    this.addEngineListener();

    try {
      this.engine!.once('agentStarted', () => {
        const instanceInfo = this.engine!.agentInfo!;
        logger.setParams({
          instanceId: instanceInfo.instanceId,
          channelId: instanceInfo.channelId,
          userId: instanceInfo.userId,
          reqId: instanceInfo.reqId || '-',
        });
        const elapsedTime = Date.now() - startTs;
        logger.info('ProxyController', 'GenerateAIAgentSuccess', { value: elapsedTime });

        this._agentInfo = instanceInfo;
        this.emit('AICallAIAgentStarted', instanceInfo, elapsedTime);

        // 不需要等待 describeAIAgent 接口返回
        // no need to wait for describeAIAgent
        this.describeAIAgent(instanceInfo.instanceId);
      });

      this.engine!.once('callBegin', () => {
        const elapsedTime = Date.now() - startTs;
        logger.info('ProxyController', 'StartSuccess', { value: elapsedTime });
        this.emit('AICallBegin', elapsedTime);
        this.state = AICallState.Connected;
      });

      const authToken = await AUIAICallAuthTokenHelper.shared.fetchAuthToken(this.userId);
      await this.engine!.callWithConfig({
        agentId: this.config.agentId!,
        agentType: this.config.agentType,
        region: this.config.region ?? 'cn-shanghai',
        userId: this.userId,
        userData: this.config.userData,
        templateConfig: this.config.templateConfig,
        chatSyncConfig: this.config.chatSyncConfig,
        userJoinToken: authToken,
      });

      AUIAICallAuthTokenHelper.shared.requestNewAuthToken(); // Request for next call

      if (this.config.agentView) {
        this.engine?.setAgentView(this.config.agentView);
      }

      // @ts-expect-error state may change
      if (this.state === AICallState.Over) {
        this.handup();
        throw new AICallAgentError('call has been over');
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      this._errorCode = error.errorCode || AICallErrorCode.BeginCallFailed;
      this.state = AICallState.Error;
      this.handup();
      logger.error('StartCallFailed', error);
      throw error;
    }
  }
}

export default AUIAICallProxyController;
