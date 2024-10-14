import EventEmitter from 'eventemitter3';
import {
  AICallAgentInfo,
  AICallAgentState,
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

  constructor(userId: string, token: string) {
    super();
    this._userId = userId;
    this._token = token;
    this._config = new AUIAICallConfig();
  }

  protected _currentEngine?: ARTCAICallEngine;
  public get currentEngine() {
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

    this.emit('AICallAIAgentStarted', instanceInfo);

    this._currentEngine = new ARTCAICallEngine();

    this._currentEngine.on('errorOccurred', (errorCode: number) => {
      this._errorCode = errorCode;
      this.state = AICallState.Error;
      this.currentEngine?.handup();
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
      this.currentEngine?.updateToken(token);
    });
    this._currentEngine.on('authInfoExpired', async () => {
      const token = await this.requestRTCToken();
      this.currentEngine?.updateToken(token);
    });

    // 本地说话状态
    this._currentEngine.on('speakingVolumeChanged', (userId, volume) => {
      this.emit('AICallActiveSpeakerVolumeChanged', userId, volume);
    });

    try {
      await this.currentEngine?.call(this.userId, instanceInfo);

      // 默认静音麦克风
      if (this.config.muteMicrophone) {
        this.currentEngine?.mute(true);
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
    const agent = this.currentEngine?.agentInfo;
    if (agent) {
      await this.stopAIAgent(agent.ai_agent_instance_id);
    }
    this.removeAllListeners();
    this.currentEngine?.handup();
    this.state = AICallState.Over;
  }
  /**
   * 设置智能体视频渲染视图
   * @param view Video标签或 id
   */
  setAgentView(view: HTMLVideoElement | string): void {
    this.currentEngine?.setAgentView(view);
  }

  /**
   * 主动打断讲话
   */
  async interruptSpeaking(): Promise<void> {
    if (this.state === AICallState.Connected) {
      this.currentEngine?.interruptSpeaking();
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
  switchMicrophone(off: boolean): boolean {
    if (this.state === AICallState.Connected) {
      this.currentEngine?.mute(off);
      return true;
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
