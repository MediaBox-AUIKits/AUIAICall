import AliRtcEngine, {
  AliRtcDataChannelMsg,
  AliRtcSdkClientRole,
  AliRtcEngine as AliRtcEngineInner,
} from 'aliyun-rtc-sdk';
import { AICallAgentInfo } from '../api/type';
import {
  AICallAgentState,
  AICallMessageReceiveData,
  AICallMessageSendData,
  AICallMessageType,
  AICallSubtitleData,
  AICallType,
} from './type';
import EventEmitter from 'eventemitter3';

interface AICallEngineEvents {
  agentStateChange: (newState: AICallAgentState) => void;
  agentSubtitleNotify: (subtitle: AICallSubtitleData) => void;
  userSubtitleNotify: (subtitle: AICallSubtitleData) => void;
  voiceInterruptChanged: (enable: boolean) => void;
  voiceIdChanged: (voiceId: string) => void;
  newRTCToken: (token: string) => void;

  bye: (code: number) => void;

  authInfoWillExpire: () => void;
  authInfoExpired: () => void;
  speakingStatusChanged: (isSpeaking: boolean) => void;
}

class AICallEngine extends EventEmitter<AICallEngineEvents> {
  static getMicrophoneList = AliRtcEngine.getMicrophoneList;

  // @ts-ignore
  private _isCalling = false;
  private _rtcEngine?: AliRtcEngineInner;
  private _seqId = 1;

  private _isOnCall = false;
  private _callType = AICallType.AudioOnly;

  private _userId?: string;
  private _agentInfo?: AICallAgentInfo;

  private _isSpeaking = false;

  get isOnCall() {
    return this._isOnCall;
  }
  get callType() {
    return this._callType;
  }
  get userId() {
    return this._userId;
  }
  get agentInfo() {
    return this._agentInfo;
  }

  private onDataChannelMsg = (_: string, msg: AliRtcDataChannelMsg) => {
    try {
      const dataChannelMsg = JSON.parse(new TextDecoder().decode(msg.data)) as AICallMessageReceiveData;
      if (dataChannelMsg.type === AICallMessageType.AgentStateChanged) {
        this.emit('agentStateChange', dataChannelMsg.data.state as AICallAgentState);
      } else if (dataChannelMsg.type === AICallMessageType.AgentSubtitleNotify) {
        this.emit('agentSubtitleNotify', dataChannelMsg.data as unknown as AICallSubtitleData);
      } else if (dataChannelMsg.type === AICallMessageType.UserSubtitleNotify) {
        this.emit('userSubtitleNotify', dataChannelMsg.data as unknown as AICallSubtitleData);
      } else if (dataChannelMsg.type === AICallMessageType.VoiceInterruptChanged) {
        this.emit('voiceInterruptChanged', dataChannelMsg.data.enable as boolean);
      } else if (dataChannelMsg.type === AICallMessageType.VoiceIdChanged) {
        this.emit('voiceIdChanged', dataChannelMsg.data.voiceId as string);
      } else if (dataChannelMsg.type === AICallMessageType.RTCTokenResponsed) {
        this.emit('newRTCToken', dataChannelMsg.data.token as string);
      }
    } catch (error) {
      console.log(`ARTCAICallEngine dataChannelMsg failed: ${error}`);
    }
  };
  private handleLocalUserVolume = (isSpeaking: boolean) => {
    if (this._isSpeaking !== isSpeaking) {
      this.emit('speakingStatusChanged', isSpeaking);
      this._isSpeaking = isSpeaking;
    }
  };

  /**
   * 呼叫
   * @param userId 用户 id
   * @param token 鉴权 token
   * @param callType 呼叫类型
   * @param agentInfo 智能体信息
   */
  async call(userId: string, token: string, callType: AICallType, agentInfo: AICallAgentInfo) {
    this._callType = callType;
    this._userId = userId;
    this._agentInfo = agentInfo;

    this._isCalling = true;

    this._rtcEngine = AliRtcEngine.getInstance();

    // 启用 DataChannel
    this._rtcEngine.setParameter(
      JSON.stringify({
        data: {
          enablePubDataChannel: true,
          enableSubDataChannel: true,
        },
      })
    );

    this._rtcEngine.setClientRole(AliRtcSdkClientRole.AliRtcSdkInteractive);
    this._rtcEngine.setAudioOnlyMode(true);
    this._rtcEngine.enableAudioVolumeIndication(200);
    this._rtcEngine.on('dataChannelMsg', this.onDataChannelMsg);
    this._rtcEngine.on('audioVolume', (list) => {
      list.forEach(({ volume, userId }) => {
        // 本地用户 userId 为空
        if (userId === '') {
          // 判断正在说话的阈值，目前定义为 30
          this.handleLocalUserVolume(volume > 30);
        }
      });
    });
    this._rtcEngine.on('onOccurError', (error) => {
      console.log(error);
    });
    this._rtcEngine.on('bye', (code) => {
      this.emit('bye', code);
    });
    this._rtcEngine.on('authInfoWillExpire', () => {
      this.emit('authInfoWillExpire');
    });
    this._rtcEngine.on('authInfoExpired', () => {
      this.emit('authInfoExpired');
    });

    try {
      await this._rtcEngine.joinChannel(token, userId);

      this._isOnCall = true;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      console.log(`ARTCAICallEngine joinChannel failed: ${error.code} - ${error.message}`);
      throw error;
    }

    this._isCalling = false;
  }

  /**
   * 挂断
   */
  async handup() {
    this._rtcEngine?.off('dataChannelMsg', this.onDataChannelMsg);
    this._rtcEngine?.destroy();
    this._userId = undefined;
    this._agentInfo = undefined;
    this._isCalling = false;
    this._isOnCall = false;
  }

  /**
   * 静音
   */
  async mute(mute: boolean) {
    if (!this.isOnCall) return;
    if (!this._rtcEngine) return;
    this._rtcEngine.muteLocalMic(mute);
  }

  async updateToken(token: string) {
    if (!this.isOnCall) return;
    if (!this._rtcEngine) return;
    this._rtcEngine.refreshAuthInfo(token);
  }

  /**
   * 主动打断讲话
   */
  async interruptSpeaking() {
    if (!this.isOnCall) return;
    const data: AICallMessageSendData = {
      type: AICallMessageType.InterruptSpeaking,
    };

    this.sendMsgToDataChannel(data);
  }

  /**
   * 开启/关闭智能打断
   */
  async enableVoiceInterrupt(enable: boolean) {
    if (!this.isOnCall) return;
    const data: AICallMessageSendData = {
      type: AICallMessageType.EnableVoiceInterrupt,
      data: {
        enable,
      },
    };
    this.sendMsgToDataChannel(data);
  }

  /**
   * 设置语音识别
   */
  async switchVoiceId(voiceId: string) {
    if (!this.isOnCall) return;
    const data: AICallMessageSendData = {
      type: AICallMessageType.SwitchVoiceId,
      data: {
        voiceId,
      },
    };
    this.sendMsgToDataChannel(data);
  }

  private async sendMsgToDataChannel(data: AICallMessageSendData) {
    if (!this._rtcEngine) {
      return;
    }
    const msg = JSON.stringify({
      type: data.type,
      data: data.data,
      seqId: this._seqId++,
      senderId: this._userId,
      receiverId: this._agentInfo?.ai_agent_user_id,
    });
    const msgBuffer = new TextEncoder().encode(msg);
    this._rtcEngine.sendDataChannelMessage(new AliRtcDataChannelMsg(msgBuffer));
  }
}

export default AICallEngine;
