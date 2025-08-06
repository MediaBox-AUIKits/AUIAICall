import {
  AICallAgentError,
  AICallAgentInfo,
  AICallEngineConfig,
  AICallErrorCode,
  AICallState,
} from 'aliyun-auikit-aicall';
import AUIAICallController from './AUIAICallController';
import standardService from '../../service/standard';
import logger from '@/common/logger';

class AUIAICallStandardController extends AUIAICallController {
  constructor(userId: string, token: string, config?: AICallEngineConfig) {
    super(userId, token, config);
  }

  set appServer(appServerUrl: string) {
    standardService.setAppServer(appServerUrl);
  }

  async start(): Promise<void> {
    logger.info('StandardController', 'Start');
    const startTs = Date.now();
    if (this.state === AICallState.Connected || this.state === AICallState.Connecting) return;
    this.state = AICallState.Connecting;

    this.addEngineListener();
    let instanceInfo: AICallAgentInfo | undefined;
    try {
      [instanceInfo] = await Promise.all([this.startAIAgent(), this.initEngine()]);
      logger.setParams({
        instanceId: instanceInfo.instanceId,
        channelId: instanceInfo.channelId,
        userId: instanceInfo.userId,
        reqId: instanceInfo.reqId || '-',
      });
      logger.info('StandardController', 'GenerateAIAgentSuccess', { value: Date.now() - startTs });
    } catch (error: unknown) {
      this._errorCode = (error as AICallAgentError).code || AICallErrorCode.BeginCallFailed;
      if ((error as AICallAgentError).name === 'ServiceAuthError') {
        this.emit('AICallUserTokenExpired');
      }
      this.state = AICallState.Error;
      logger.error('StartAIAgentFailed', error as Error);
      throw error;
    }

    // 可能通话已经结束，不再继续
    // call may be ended, abort
    if (this.state !== AICallState.Connecting) return;

    this._agentInfo = instanceInfo;
    this.emit('AICallAIAgentStarted', instanceInfo, Date.now() - startTs);

    if (!this._currentEngine) {
      logger.error('StartCallFailed', new AICallAgentError('engine not init'));
      throw new AICallAgentError('engine not init');
    }

    try {
      this.engine!.once('callBegin', () => {
        const elapsedTime = Date.now() - startTs;
        logger.info('StandardController', 'StartSuccess', { value: elapsedTime });
        this.emit('AICallBegin', elapsedTime);
        this.state = AICallState.Connected;
      });

      await this.engine?.call(this.userId, instanceInfo);

      if (this.engineConfig?.agentElement) {
        this.engine?.setAgentView(this.engineConfig.agentElement);
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
      logger.info('StandardController', 'GenerateAIAgentFailed');
      throw error;
    }

    if (!agentInfo) {
      const error = new AICallAgentError('generate ai agent failed');
      logger.info('StandardController', 'NoAIAgent');
      throw error;
    }

    // 不需要等待 describeAIAgentInstance 接口返回
    // no need to wait for describeAIAgentInstance
    this.describeAIAgentInstance(agentInfo.instanceId);

    return agentInfo;
  }

  destroy() {
    logger.info('StandardController', 'destroy');
    super.destroy();
    this.appServer = '';
  }
}

export default AUIAICallStandardController;
