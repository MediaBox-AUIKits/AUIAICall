import { TemplateConfig } from '@/service/interface.ts';
import standardService from '@/service/standard.ts';
import EventEmitter from 'eventemitter3';
import {
  AICallAgentInfo,
  AICallAgentShareConfig,
  AICallAgentState,
  AICallAgentType,
  AICallErrorCode,
  AICallSendTextToAgentRequest,
  AICallState,
  AICallSubtitleData,
  AICallTemplateConfig,
  AICallVisionCustomCaptureRequest,
  AICallVoiceprintResult,
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

  protected async initEngine() {
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
        rtcEngineConfig: this._config.rtcEngineConfig,
      });
      logger.info('Controller', 'InitEngineSuccess', { value: Date.now() - startTs });
    } catch (error) {
      logger.error('InitEngineFailed', error as Error);
      throw error;
    }
    return;
  }

  protected addEngineListener() {
    if (!this._currentEngine) {
      this._currentEngine = new ARTCAICallEngine({
        muteMicrophone: this._config.muteMicrophone,
        muteCamera: this._config.muteCamera,
        previewElement: this._config.previewView,
        templateConfig: this._config.templateConfig,
        rtcEngineConfig: this._config.rtcEngineConfig,
      });
    }

    this._currentEngine.on('errorOccurred', (errorCode: number) => {
      this._errorCode = errorCode;
      this.state = AICallState.Error;
      this.engine?.handup();
      logger.error('AICallErrorOccurred', new Error(`code: ${errorCode}`));
    });

    // Agent 状态相关
    // state of agent
    this._currentEngine.on('agentStateChange', (newState) => {
      this.emit('AICallAgentStateChanged', newState);
    });

    // 实时字幕相关
    // realtime subtitle
    this._currentEngine.on('agentSubtitleNotify', (data: AICallSubtitleData) => {
      if (this.state !== AICallState.Connected) return;
      this.emit('AICallAgentSubtitleNotify', data);
    });
    this._currentEngine.on(
      'userSubtitleNotify',
      (data: AICallSubtitleData, voiceprintResult: AICallVoiceprintResult) => {
        if (this.state !== AICallState.Connected) return;
        this.emit('AICallUserSubtitleNotify', data, voiceprintResult);
      }
    );
    this._currentEngine.on('agentEmotionNotify', (emotion, sentenceId) => {
      this.emit('AICallAgentEmotionNotify', emotion, sentenceId);
    });

    // 鉴权相关
    // auth token info
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
    // human takeover
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
    this._currentEngine.on('callEnd', () => {
      this.emit('AICallEnd');
    });

    this._currentEngine.on('llmReplyCompleted', (text, sentenceId) => {
      console.log('llmReplyCompleted', text, sentenceId);
    });
    this._currentEngine.on('agentDataChannelAvailable', () => {
      console.log('agentDataChannelAvailable');
    });
  }

  abstract start(): Promise<void>;

  protected async describeAIAgent(instanceId: string) {
    const startTs = Date.now();
    try {
      // 每次先清空当前的配置
      // clear config first
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
      logger.info('Controller', 'DescribeAIAgent', { value: Date.now() - startTs });
    } catch (error) {
      logger.error('DescribeAIAgentFailed', error as Error);
      console.log(error);
    }
  }

  async stopAIAgent(): Promise<void> {
    logger.info('Controller', 'StopAIAgent');
    this.engine?.stopAgent();
    await new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);
      }, 200);
    });
  }

  async handup(): Promise<void> {
    logger.info('Controller', 'Handup');
    const currentState = this.state;
    if (this.state === AICallState.Over || this.state === AICallState.Error) return;
    this.state = AICallState.Over;
    const agent = this.engine?.agentInfo;
    if (agent && currentState === AICallState.Connected) {
      await this.stopAIAgent();
    }
    await this.engine?.handup();
    this.engine?.removeAllListeners();
    this.removeAllListeners();
  }

  /**
   * 设置智能体视频渲染视图
   * Set agent video render view
   * @param view Video标签或 id
   * @param view HtmlVideoElement or id
   */
  setAgentView(view: HTMLVideoElement | string): void {
    logger.info('Controller', 'SetAgentView', { view: typeof view === 'string' ? `#${view}` : view.nodeType });
    this._config.agentView = view;
    this.engine?.setAgentView(view);
  }

  /**
   * 主动打断讲话
   * interrupt speaking
   */
  async interruptSpeaking(): Promise<void> {
    logger.info('Controller', 'InterruptSpeaking');
    if (this.state === AICallState.Connected) {
      this.engine?.interruptSpeaking();
    }
  }

  /**
   * 开启/关闭智能打断
   * Open/close voice interrupt
   * @param enable 是否开启
   * @param enable open or close
   */
  async enableVoiceInterrupt(enable: boolean): Promise<boolean> {
    logger.info('Controller', 'EnableVoiceInterrupt', { enable });
    if (this.state === AICallState.Connected) {
      this.engine?.enableVoiceInterrupt(enable);
    }
    return true;
  }

  /**
   * 切换智能体讲话音色
   * Switch voice id
   * @param voiceId 音色Id
   * @param voiceId voice id
   */
  async switchVoiceId(voiceId: string): Promise<boolean> {
    logger.info('Controller', 'SwitchVoiceId', { voiceId });
    if (this.state === AICallState.Connected) {
      this.engine?.switchVoiceId(voiceId);
    }
    return true;
  }

  /**
   * 请求 RTC Token
   * request rtc token
   */
  async requestRTCToken(): Promise<string> {
    logger.info('Controller', 'RequestRTCToken');
    if (this.state === AICallState.Connected) {
      this.engine?.requestRTCToken();

      // 等待返回新的 RTC token
      // wait for new RTC token
      return new Promise((resolve) => {
        this.engine?.once('newRTCToken', (token: string) => {
          resolve(token);
        });
      });
    }
    return '';
  }

  /**
   * 开启/关闭麦克风
   * open or close microphone
   * @param off 是否关闭
   * @param off mute or unmute
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
   * Open or close push to talk mode, in push to talk mode, only after finishPushToTalk is called, the agent will play the result
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
   * start push to talk
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
   * finish push to talk
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
   * cancel push to talk
   */
  cancelPushToTalk(): boolean {
    logger.info('Controller', 'CancelPushToTalk');
    if (this.state === AICallState.Connected) {
      return this.engine?.cancelPushToTalk() || false;
    }
    return false;
  }

  // 给智能体发送文本消息
  // send text to agent
  sendTextToAgent(req: AICallSendTextToAgentRequest): boolean {
    logger.info('Controller', 'SendTextToAgent');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.sendTextToAgent(req);
    }
    return false;
  }

  // 给智能体发送文本消息
  // send text to agent
  sendCustomMessageToServer(msg: string): boolean {
    logger.info('Controller', 'SendTextToAgent');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.sendCustomMessageToServer(msg);
    }
    return false;
  }

  // 更新llm的系统提示词
  // update llm system prompt
  updateLlmSystemPrompt(prompt: string): boolean {
    logger.info('Controller', 'UpdateLlmSystemPrompt');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.updateLlmSystemPrompt(prompt);
    }
    return false;
  }

  // Vision智能体，开始启动自定义截帧，启动后，无法通过语音与智能体通话
  // start vision custom capture, after start, you can not call agent by voice
  startVisionCustomCapture(req: AICallVisionCustomCaptureRequest) {
    logger.info('Controller', 'StartVisionCustomCapture');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.startVisionCustomCapture(req);
    }
    return false;
  }

  // Vision智能体，结束自定义截帧
  // stop vision custom capture
  stopVisionCustomCapture() {
    logger.info('Controller', 'StopVisionCustomCapture');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.stopVisionCustomCapture();
    }
    return false;
  }

  /**
   * 停止/恢复智能体音频流的播放
   * @param mute 是否静音
   * @return 是否成功
   */
  /****
   * Mute/unmute agent audio playing
   * @param mute Whether to mute
   * @return Whether it is successful
   */
  muteAgentAudioPlaying(mute: boolean) {
    logger.info('Controller', 'Mute');
    if (this.state === AICallState.Connected) {
      return !!this.engine?.muteAgentAudioPlaying(mute);
    }
    return false;
  }

  /**
   * 销毁引擎
   * Destroy engine
   */
  destroy() {
    logger.info('Controller', 'destroy');
    this._currentEngine?.destroy();
    this._currentEngine?.removeAllListeners();
    this.removeAllListeners();
  }
}
