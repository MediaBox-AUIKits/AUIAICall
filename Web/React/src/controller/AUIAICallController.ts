import EventEmitter from 'eventemitter3';
import {
  AICallAgentInfo,
  AICallAgentState,
  AICallAgentType,
  AICallErrorCode,
  AICallState,
  AICallSubtitleData,
} from 'aliyun-auikit-aicall';
import ARTCAICallEngine from 'aliyun-auikit-aicall';
import AUIAICallConfig from './AUIAICallConfig';
import AUIAICallControllerEvents from './AUIAICallControllerEvents';
import { ServiceAuthError } from './service/interface';

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

  /**
   * 检查麦克风
   */
  async checkMicrophone() {
    try {
      const microphoneList = await ARTCAICallEngine.getMicrophoneList();
      if (microphoneList?.length === 0) {
        throw new Error('no microphone');
      }
    } catch (error) {
      this.state = AICallState.Error;
      this._errorCode = AICallErrorCode.LocalDeviceException;
      throw error;
    }
  }

  abstract startAIAgent(): Promise<AICallAgentInfo>;

  async start(): Promise<void> {
    if (this.state === AICallState.Connected || this.state === AICallState.Connecting) return;
    this.state = AICallState.Connecting;

    await this.checkMicrophone();

    let instanceInfo: AICallAgentInfo | undefined;
    try {
      // 此处的 userId 应该从 AppServer 获取
      instanceInfo = await this.startAIAgent();
      if (!instanceInfo) {
        this._errorCode = AICallErrorCode.BeginCallFailed;
        throw new Error();
      }
    } catch (error) {
      this._errorCode = AICallErrorCode.BeginCallFailed;
      if (error instanceof ServiceAuthError) {
        this.emit('AICallUserTokenExpired');
      }
      this.state = AICallState.Error;
      throw error;
    }

    this._agentInfo = instanceInfo;
    this.emit('AICallAIAgentStarted', instanceInfo);

    this._currentEngine = new ARTCAICallEngine();

    this._currentEngine.on('errorOccurred', (errorCode: number) => {
      this._errorCode = errorCode;
      this.state = AICallState.Error;
      this.engine?.handup();
    });

    // Agent 状态相关
    this._currentEngine.on('agentStateChange', (newState) => {
      this.emit('AICallAgentStateChanged', newState);
    });

    // 实时字幕相关呢
    this._currentEngine.on('agentSubtitleNotify', (data: AICallSubtitleData) => {
      this.emit('AICallAgentSubtitleNotify', data);
    });
    this._currentEngine.on('userSubtitleNotify', (data: AICallSubtitleData) => {
      this.emit('AICallUserSubtitleNotify', data);
    });

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

    try {
      await this.engine?.call(this.userId, instanceInfo, {
        muteMicrophone: this._config.muteMicrophone,
        muteCamera: this._config.muteCamera,
        enablePushToTalk: this._config.enablePushToTalk,
      });

      // 默认静音麦克风
      if (this.config.muteMicrophone) {
        this.engine?.mute(true);
      }
      if (this.config.muteCamera) {
        this.engine?.muteLocalCamera(true);
      }

      // @ts-expect-error state may change
      if (this.state === AICallState.Over) {
        throw new Error();
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      this._errorCode = error.errorCode || AICallErrorCode.BeginCallFailed;
      this.state = AICallState.Error;
      this.handup();
      throw error;
    }

    this.emit('AICallBegin');
    this.state = AICallState.Connected;
  }

  abstract stopAIAgent(instanceId: string): Promise<void>;

  async handup(): Promise<void> {
    const agent = this.engine?.agentInfo;
    if (agent) {
      await this.stopAIAgent(agent.instanceId);
    }
    this.removeAllListeners();
    this.engine?.handup();
    this.state = AICallState.Over;
  }
  /**
   * 设置智能体视频渲染视图
   * @param view Video标签或 id
   */
  setAgentView(view: HTMLVideoElement | string): void {
    this.engine?.setAgentView(view);
  }

  /**
   * 主动打断讲话
   */
  async interruptSpeaking(): Promise<void> {
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
    if (this.state === AICallState.Connected) {
      this.engine?.mute(mute);
      return true;
    }
    return false;
  }

  switchMicrophone(deviceId: string): boolean {
    if (this.state === AICallState.Connected) {
      this.engine?.switchMicrophone(deviceId);
      return true;
    }
    return false;
  }

  muteCamera(mute: boolean): boolean {
    if (this.config.agentType === AICallAgentType.VisionAgent && this.state === AICallState.Connected) {
      this.engine?.muteLocalCamera(mute);
      return true;
    }
    return false;
  }

  switchCamera(deviceId: string): boolean {
    if (this.config.agentType === AICallAgentType.VisionAgent && this.state === AICallState.Connected) {
      this.engine?.switchCamera(deviceId);
      return true;
    }
    return false;
  }

  startPreview(elementOrId: string | HTMLVideoElement) {
    this.engine?.startPreview(elementOrId);
  }

  stopPreview() {
    this.engine?.stopPreview();
  }

  /**
   * 开启/关闭对讲机模式，对讲机模式下，只有在finishPushToTalk被调用后，智能体才会播报结果
   */
  async enablePushToTalk(enable: boolean): Promise<boolean> {
    if (this.state === AICallState.Connected) {
      return this.engine?.enablePushToTalk(enable) || false;
    }
    return false;
  }

  /**
   * 开始讲话
   */
  startPushToTalk(): boolean {
    if (this.state === AICallState.Connected) {
      return this.engine?.startPushToTalk() || false;
    }
    return false;
  }

  /**
   * 结束讲话
   */
  finishPushToTalk(): boolean {
    if (this.state === AICallState.Connected) {
      return this.engine?.finishPushToTalk() || false;
    }
    return false;
  }

  /**
   * 取消这次讲话
   */
  cancelPushToTalk(): boolean {
    if (this.state === AICallState.Connected) {
      return this.engine?.cancelPushToTalk() || false;
    }
    return false;
  }

  /**
   * 销毁引擎
   */
  destory() {
    this._currentEngine?.destory();
    this._currentEngine?.removeAllListeners();
    this.removeAllListeners();
  }
}
