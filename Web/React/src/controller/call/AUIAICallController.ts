import EventEmitter from 'eventemitter3';
import {
  AICallAgentError,
  AICallAgentInfo,
  AICallAgentShareConfig,
  AICallAgentState,
  AICallAgentType,
  AICallErrorCode,
  AICallSendTextToAgentRequest,
  AICallState,
  AICallSubtitleData,
  AICallVisionCustomCaptureRequest,
} from 'aliyun-auikit-aicall';
import ARTCAICallEngine from 'aliyun-auikit-aicall';
import AUIAICallConfig from './AUIAICallConfig';
import AUIAICallControllerEvents from './AUIAICallControllerEvents';
import logger from '@/common/logger';

export default abstract class AUIAICallController extends EventEmitter<AUIAICallControllerEvents> {
  protected _userId: string;
  protected _token: string;

  constructor(userId: string, token: string, config?: AUIAICallConfig) {
    super();
    this._userId = `${userId}`;
    this._token = token;
    this._config = config || new AUIAICallConfig();
  }

  protected _currentEngine?: ARTCAICallEngine;
  public get engine() {
    return this._currentEngine;
  }
  public get userId() {
    return this._userId;
  }
  public get token() {
    return this._token;
  }

  updateToken(token: string) {
    this._token = token;
  }

  private _state: AICallState = AICallState.None;
  public get state() {
    return this._state;
  }
  protected set state(state: AICallState) {
    this.emit('AICallStateChanged', state);
    this._state = state;
  }

  protected _config: AUIAICallConfig;
  public get config() {
    return this._config;
  }

  protected _errorCode?: AICallErrorCode;
  public get errorCode() {
    return this._errorCode;
  }

  protected _agentInfo?: AICallAgentInfo;
  public get agentInfo() {
    return this._agentInfo;
  }

  protected _agentState?: AICallAgentState;
  public get agentState() {
    return this._agentState;
  }

  protected _shareConfig?: AICallAgentShareConfig;
  public get shareConfig(): AICallAgentShareConfig | undefined {
    return this._shareConfig;
  }
  public set shareConfig(shareToken: string) {
    logger.info('Controller', 'SetShareConfig', { shareToken });
    try {
      this._shareConfig = ARTCAICallEngine.parseShareAgentCall(shareToken);
      if (this._shareConfig.agentType !== undefined) {
        this.config.agentType = this._shareConfig.agentType;
      }
    } catch (error) {
      logger.error('ParseShareAgentCallFailed', error as Error);
    }
  }

  protected _agentAudioElement?: HTMLAudioElement;
  public get agentAudioElement() {
    return this._agentAudioElement;
  }

  abstract startAIAgent(): Promise<AICallAgentInfo>;

  private async initEngine() {
    const startTs = Date.now();
    if (!this._currentEngine) {
      this._currentEngine = new ARTCAICallEngine();
    }

    try {
      await this._currentEngine.init(this.config.agentType, {
        muteMicrophone: this._config.muteMicrophone,
        muteCamera: this._config.muteCamera,
        previewElement: this._config.previewView,
        templateConfig: this._config.templateConfig,
      });
      logger.info('Controller', 'InitEngineSuccess', { value: Date.now() - startTs });
    } catch (error) {
      logger.error('InitEngineFailed', error as Error);
      throw error;
    }
    return;
  }

  async start(): Promise<void> {
    logger.info('Controller', 'Start');
    const startTs = Date.now();
    if (this.state === AICallState.Connected || this.state === AICallState.Connecting) return;
    this.state = AICallState.Connecting;

    let instanceInfo: AICallAgentInfo | undefined;
    try {
      if (!this._currentEngine) {
        this._currentEngine = new ARTCAICallEngine();
      }
      [instanceInfo] = await Promise.all([this.startAIAgent(), this.initEngine()]);
      logger.setParams({
        instanceId: instanceInfo.instanceId,
        channelId: instanceInfo.channelId,
        userId: instanceInfo.userId,
        reqId: instanceInfo.reqId || '-',
      });
      logger.info('Controller', 'GenerateAIAgentSuccess', { value: Date.now() - startTs });
    } catch (error: unknown) {
      this._errorCode = (error as AICallAgentError).code || AICallErrorCode.BeginCallFailed;
      if ((error as AICallAgentError).name === 'ServiceAuthError') {
        this.emit('AICallUserTokenExpired');
      }
      this.state = AICallState.Error;
      logger.error('StartAIAgentFailed', error as Error);
      throw error;
    }

    this._agentInfo = instanceInfo;
    this.emit('AICallAIAgentStarted', instanceInfo);

    if (!this._currentEngine) {
      logger.error('StartCallFailed', new AICallAgentError('engine not init'));
      throw new AICallAgentError('engine not init');
    }

    this._currentEngine.on('errorOccurred', (errorCode: number) => {
      this._errorCode = errorCode;
      this.state = AICallState.Error;
      this.engine?.handup();
      logger.error('AICallErrorOccurred', new Error(`code: ${errorCode}`));
    });

    // Agent 状态相关
    this._currentEngine.on('agentStateChange', (newState) => {
      this.emit('AICallAgentStateChanged', newState);
    });

    // 实时字幕相关呢
    this._currentEngine.on('agentSubtitleNotify', (data: AICallSubtitleData) => {
      if (this.state !== AICallState.Connected) return;
      this.emit('AICallAgentSubtitleNotify', data);
    });
    this._currentEngine.on('userSubtitleNotify', (data: AICallSubtitleData) => {
      if (this.state !== AICallState.Connected) return;
      this.emit('AICallUserSubtitleNotify', data);
    });
    this._currentEngine.on('agentEmotionNotify', (emotion, sentenceId) => {
      this.emit('AICallAgentEmotionNotify', emotion, sentenceId);
    });

    // 鉴权相关
    this._currentEngine.on('authInfoWillExpire', async () => {
      const token = await this.requestRTCToken();
      this.engine?.updateToken(token);
    });
    this._currentEngine.on('authInfoExpired', async () => {
      const token = await this.requestRTCToken();
      this.engine?.updateToken(token);
    });

    // 本地说话状态
    this._currentEngine.on('speakingVolumeChanged', (userId, volume) => {
      this.emit('AICallActiveSpeakerVolumeChanged', userId, volume);
    });
    this._currentEngine.on('pushToTalkChanged', (enable) => {
      this.emit('AICallPushToTalkChanged', enable);
    });
    this._currentEngine.on('agentWillLeave', (reason, message) => {
      this.emit('AICallAgentWillLeave', reason, message);
    });

    this._currentEngine.on('receivedAgentCustomMessage', (data) => {
      this.emit('AICallReceivedAgentCustomMessage', data);
    });

    this._currentEngine.on('audioSubscribed', (_userId, audioElement) => {
      if (audioElement) {
        this._agentAudioElement = audioElement;
      }
      this.emit('AICallAgentAudioSubscribed', audioElement);
    });

    // 真人接管相关
    this._currentEngine.on('humanTakeoverWillStart', (uid: string, mode: number) => {
      this.emit('AICallHumanTakeoverWillStart', uid, mode);
    });
    this._currentEngine.on('humanTakeoverConnected', (uid: string) => {
      this.emit('AICallHumanTakeoverConnected', uid);
    });

    this._currentEngine.on('visionCustomCaptureChanged', (enable) => {
      this.emit('AICallVisionCustomCaptureChanged', enable);
    });
    this._currentEngine.on('speakingInterrupted', (reason) => {
      this.emit('AICallSpeakingInterrupted', reason);
    });

    try {
      await this.engine?.call(this.userId, instanceInfo);

      if (this.config.agentView) {
        this.engine?.setAgentView(this.config.agentView);
      }

      // 默认静音麦克风
      if (this.config.muteMicrophone) {
        this.engine?.mute(true);
      }
      if (this.config.muteCamera) {
        this.engine?.muteLocalCamera(true);
      }

      // @ts-expect-error state may change
      if (this.state === AICallState.Over) {
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

    logger.info('Controller', 'StartSuccess', { value: Date.now() - startTs });
    this.emit('AICallBegin');
    this.state = AICallState.Connected;
  }

  abstract stopAIAgent(instanceId: string): Promise<void>;

  async handup(): Promise<void> {
    logger.info('Controller', 'Handup');
    const agent = this.engine?.agentInfo;
    if (agent) {
      await this.stopAIAgent(agent.instanceId);
    }
    this.state = AICallState.Over;
    await this.engine?.handup();
    this.engine?.removeAllListeners();
    this.removeAllListeners();
  }
  /**
   * 设置智能体视频渲染视图
   * @param view Video标签或 id
   */
  setAgentView(view: HTMLVideoElement | string): void {
    logger.info('Controller', 'SetAgentView', { view: typeof view === 'string' ? `#${view}` : view.nodeType });
    this._config.agentView = view;
    this.engine?.setAgentView(view);
  }

  /**
   * 主动打断讲话
   */
  async interruptSpeaking(): Promise<void> {
    logger.info('Controller', 'InterruptSpeaking');
    if (this.state === AICallState.Connected) {
      this.engine?.interruptSpeaking();
    }
  }

  /**
   * 开启/关闭智能打断
   * @param enable 是否开启
   */
  abstract enableVoiceInterrupt(enable: boolean): Promise<boolean>;

  /**
   * 切换智能体讲话音色
   * @param voiceId 音色Id
   */
  abstract switchVoiceId(voiceId: string): Promise<boolean>;

  /**
   * 请求 RTC Token
   */
  abstract requestRTCToken(): Promise<string>;

  /**
   * 开启/关闭麦克风
   * @param off 是否关闭
   */
  muteMicrophone(mute: boolean): boolean {
    logger.info('Controller', 'MuteMicrophone', { mute: mute ? 'off' : 'on' });
    if (this.state === AICallState.Connected) {
      this.engine?.mute(mute);
      return true;
    }
    return false;
  }

  switchMicrophone(deviceId: string): boolean {
    logger.info('Controller', 'SwitchMicrophone', { deviceId });
    if (this.state === AICallState.Connected) {
      this.engine?.switchMicrophone(deviceId);
      return true;
    }
    return false;
  }

  muteCamera(mute: boolean): boolean {
    logger.info('Controller', 'MuteCamera', { mute: mute ? 'off' : 'on' });
    if (this.config.agentType === AICallAgentType.VisionAgent && this.state === AICallState.Connected) {
      this.engine?.muteLocalCamera(mute);
      return true;
    }
    return false;
  }

  switchCamera(deviceId?: string): boolean {
    logger.info('Controller', 'SwitchCamera', { deviceId: deviceId || '-' });
    if (this.config.agentType === AICallAgentType.VisionAgent && this.state === AICallState.Connected) {
      this.engine?.switchCamera(deviceId);
      return true;
    }
    return false;
  }

  startPreview(elementOrId: string | HTMLVideoElement) {
    logger.info('Controller', 'StartPreview', {
      elementOrId: typeof elementOrId === 'string' ? `#${elementOrId}` : elementOrId.nodeType,
    });
    this.config.previewView = elementOrId;
    this.engine?.startPreview(elementOrId);
  }

  stopPreview() {
    this.engine?.stopPreview();
  }

  /**
   * 开启/关闭对讲机模式，对讲机模式下，只有在finishPushToTalk被调用后，智能体才会播报结果
   */
  async enablePushToTalk(enable: boolean): Promise<boolean> {
    logger.info('Controller', 'EnablePushToTalk', { enable: enable ? 'on' : 'off' });
    if (this.state === AICallState.Connected) {
      return this.engine?.enablePushToTalk(enable) || false;
    }
    return false;
  }

  /**
   * 开始讲话
   */
  startPushToTalk(): boolean {
    logger.info('Controller', 'StartPushToTalk');
    if (this.state === AICallState.Connected) {
      return this.engine?.startPushToTalk() || false;
    }
    return false;
  }

  /**
   * 结束讲话
   */
  finishPushToTalk(): boolean {
    logger.info('Controller', 'FinishPushToTalk');
    if (this.state === AICallState.Connected) {
      return this.engine?.finishPushToTalk() || false;
    }
    return false;
  }

  /**
   * 取消这次讲话
   */
  cancelPushToTalk(): boolean {
    logger.info('Controller', 'CancelPushToTalk');
    if (this.state === AICallState.Connected) {
      return this.engine?.cancelPushToTalk() || false;
    }
    return false;
  }

  // 给智能体发送文本消息
  sendTextToAgent(req: AICallSendTextToAgentRequest): boolean {
    logger.info('Controller', 'SendTextToAgent');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.sendTextToAgent(req);
    }
    return false;
  }

  // 给智能体发送文本消息
  sendCustomMessageToServer(msg: string): boolean {
    logger.info('Controller', 'SendTextToAgent');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.sendCustomMessageToServer(msg);
    }
    return false;
  }

  // 更新llm的系统提示词
  updateLlmSystemPrompt(prompt: string): boolean {
    logger.info('Controller', 'UpdateLlmSystemPrompt');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.updateLlmSystemPrompt(prompt);
    }
    return false;
  }

  // Vision智能体，开始启动自定义截帧，启动后，无法通过语音与智能体通话
  startVisionCustomCapture(req: AICallVisionCustomCaptureRequest) {
    logger.info('Controller', 'StartVisionCustomCapture');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.startVisionCustomCapture(req);
    }
    return false;
  }

  // Vision智能体，结束自定义截帧
  stopVisionCustomCapture() {
    logger.info('Controller', 'StopVisionCustomCapture');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.stopVisionCustomCapture();
    }
    return false;
  }

  /**
   * 销毁引擎
   */
  destroy() {
    logger.info('Controller', 'destroy');
    this._currentEngine?.destroy();
    this._currentEngine?.removeAllListeners();
    this.removeAllListeners();
  }
}
