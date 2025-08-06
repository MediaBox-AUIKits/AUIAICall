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
        this.describeAIAgentInstance(instanceInfo.instanceId);
      });

      this.engine!.once('callBegin', () => {
        const elapsedTime = Date.now() - startTs;
        logger.info('ProxyController', 'StartSuccess', { value: elapsedTime });
        this.emit('AICallBegin', elapsedTime);
        this.state = AICallState.Connected;
      });

      this.engine!.once('agentDataChannelAvailable', () => {
        const elapsedTime = Date.now() - startTs;
        logger.info('ProxyController', 'AgentDataChannelAvailable', { value: elapsedTime });
      });

      const authToken = await AUIAICallAuthTokenHelper.shared.fetchAuthToken(this.userId);
      this.config.userJoinToken = authToken;
      await this.engine!.callWithConfig(this.config);

      AUIAICallAuthTokenHelper.shared.requestNewAuthToken(); // Request for next call

      if (this.engineConfig.agentElement) {
        this.engine?.setAgentView(this.engineConfig.agentElement);
      }

      // @ts-expect-error state may change
      if (this.state === AICallState.Over) {
        this.handup();
        throw new AICallAgentError('call has been over');
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      this._errorCode = error.code || error.errorCode || AICallErrorCode.BeginCallFailed;
      this.state = AICallState.Error;
      this.handup();
      logger.error('StartCallFailed', error);
      throw error;
    }
  }
}

export default AUIAICallProxyController;
