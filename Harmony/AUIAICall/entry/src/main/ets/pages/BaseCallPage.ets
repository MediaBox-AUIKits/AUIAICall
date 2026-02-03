import { ZRouter } from "@hzw/zrouter"
import { DialogUtil, LogUtil, PermissionUtil, ToastUtil } from "@pura/harmony-utils"
import { CommonConstants } from "../common/CommonConstants"
import { ButtonWithWaterRipples } from "../component/ButtonWithWaterRipples"
import { Permissions } from "@kit.AbilityKit";
import {
  ARTCAICallAgentState,
  ARTCAICallAgentSubtitleResult,
  ARTCAICallAgentType,
  ARTCAICallConfig,
  ARTCAICallEngineFactory,
  ARTCAICallEngineInterface,
  ARTCAICallEngineListener,
  ARTCAICallErrorCode,
  ARTCAICallLog,
  ARTCAICallLogType,
  ARTCAICallNetworkQuality,
  ARTCAICallSpeakingInterruptedReason,
  ARTCAICallUserSubtitleResult,
  ARTCAICallUtils,
} from "@aliyun_video_cloud/alivcsdk_artc";
import { SubTitleModel } from "../model/SubTitleModel"
import { CommonPage } from "./CommonPage"
import { TokenHelper } from "../common/TokenHelper"
import { AgentConstants } from "../common/AgentConstants"
import { AppServer } from "../common/AppServer"
import { VoiceStyleInputParams, VoiceStyleOtherParamsType } from "../dialog/VoiceStyleDialog";
import { RouterConstants } from "../common/RouterConstants";

/**
 * @description 页面基类
 * **/
@ComponentV2
struct BaseCallPage {
  @Param title: string | Resource = ''
  @BuilderParam contentBuilder: () => void // 定义内容区域插槽（通过@BuilderParam接收子类内容）

  @Param agentId: string = ''
  @Param agentType: ARTCAICallAgentType = ARTCAICallAgentType.VoiceAgent
  @Param region: string = ''
  @Local voiceStyles: VoiceStyleInputParams = new VoiceStyleInputParams(AgentConstants.DEFAULT_VOICE_STYLES, 0);

  @Param @Once aiCallSDK: ARTCAICallEngineInterface | undefined = undefined;
  @Event onAICallCreated: (sdk: ARTCAICallEngineInterface) => void
  @Event onAICallBegin: (sdk: ARTCAICallEngineInterface) => void


  @Local waterRipplesColumnX: number = CommonConstants.COLUMN_WIDTH; // Column宽度
  @Local waterRipplesYMax: number = 35; // Column高度最大值
  @Local waterRipplesYMin: number = 10; // Column高度最小值
  @Local waterRipplesTimerId: number = 0;

  @Param @Once isOpenSubTitle: boolean = false // 是否打开字幕
  @Local subTitleListItems: Array<SubTitleModel> = []
  @Local subtitleItemHeight: Length = 0

  @Local isMicrophoneOn: boolean = true
  @Local isSpeakerOn: boolean = true
  @Local isOpenCamera: boolean = true;
  @Event onCameraIsOpen: (isOpen: boolean) => void;

  @Local agentState: ARTCAICallAgentState = ARTCAICallAgentState.Listening;
  @Event onAgentStateChanged: (agentState: ARTCAICallAgentState) => void;

  @Event onAgentInterrupted: (reason: ARTCAICallSpeakingInterruptedReason) => void
  @Event onAgentEmotionChanged: (emotion: string) => void

  private scroller: Scroller = new Scroller();

  //初始化Call
  initCall() {

    // log设置
    ARTCAICallLog.enableLogType(ARTCAICallLogType.Debug);
    ARTCAICallLog.printLogBlock = (logType: ARTCAICallLogType, logString: string) => {
      if (logType === ARTCAICallLogType.Debug) {
        LogUtil.debug('AICallSDK', '%{public}s', logString);
      } else if (logType === ARTCAICallLogType.Info) {
        LogUtil.info('AICallSDK', '%{public}s', logString);
      } else {
        LogUtil.error('AICallSDK', '%{public}s', logString);
      }
    };

    this.aiCallSDK = ARTCAICallEngineFactory.createEngine(getContext(this));
    // 初始化Listener
    const listener = new ARTCAICallEngineListener();
    this.aiCallSDK.listener = listener;
    listener.onErrorOccursCallback = (code: ARTCAICallErrorCode) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Error, 'onErrorOccursCallback:', code);

      DialogUtil.showConfirmDialog({
        message: $r('app.string.start_call_failed'),
        confirm: {
          value: $r('app.string.dialog_robot_confirm'),
          action: () => {
            this.handup();
            ZRouter.getInstance().pop();
          }
        }
      });
    };
    listener.onCallBeginCallback = () => {
      const agentInfo = this.aiCallSDK?.agentInfo!;
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, `onCallBeginCallback: AgentInfo {
        instanceId: ${ agentInfo.instanceId },
        agentId: ${ agentInfo.agentId },
        agentType: ${ agentInfo.agentType },
        channelId: ${ agentInfo.channelId },
        uid: ${ agentInfo.uid },
        requestId: ${ agentInfo.requestId },
        region:, ${ agentInfo.region }
      }`);
      this.onAICallBegin(this.aiCallSDK!);
    };
    listener.onCallEndCallback = () => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onCallEndCallback');
    };
    listener.onAgentStartedCallback = () => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onAgentStartedCallback');
    };
    listener.onRTCEngineCreatedCallback = () => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onRTCEngineCreatedCallback');
    };
    listener.onAgentDataChannelAvailableCallback = () => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onAgentDataChannelAvailableCallback');
    };
    listener.onAgentAvatarFirstFrameDrawnCallback = () => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onAgentAvatarFirstFrameDrawnCallback');
    };
    listener.onAgentStateChangedCallback = (state: ARTCAICallAgentState) => {
      this.agentState = state;
      this.onAgentStateChanged(state);
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onAgentStateChangedCallback:', state);
    };
    listener.onNetworkStatusChangedCallback = (uid: string, quality: ARTCAICallNetworkQuality) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onNetworkStatusChangedCallback:', uid, 'quality:', quality);
    };
    listener.onVoiceVolumeChangedCallback = (uid: string, volume: number) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Debug, 'onVoiceVolumeChangedCallback:', uid, 'volume:', volume);
    };
    listener.onUserSubtitleNotifyCallback = (data: ARTCAICallUserSubtitleResult) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onUserSubtitleNotifyCallback:',
        ARTCAICallUtils.jsonString(data.toData()));
      if (data.isSentenceEnd) {
        this.subTitleListItems.push({
          sentenceId: data.sentenceId,
          userText: data.text,
          agentText: '',
          timestamp: Date.now()
        });
        this.scroller.scrollTo({ yOffset: this.subtitleItemHeight as number, xOffset: 0, animation: true })
      }
    };
    listener.onVoiceAgentSubtitleNotifyCallback = (data: ARTCAICallAgentSubtitleResult) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onVoiceAgentSubtitleNotifyCallback:',
        ARTCAICallUtils.jsonString(data.toData()))
      if (!data.isSentenceEnd) {
        this.subTitleListItems.push({
          sentenceId: data.userAsrSentenceId,
          userText: '',
          agentText: data.text,
          timestamp: Date.now()
        });
        this.scroller.scrollTo({ yOffset: this.subtitleItemHeight as number, xOffset: 0, animation: true })
      }
    };
    listener.onAgentEmotionNotifyCallback = (emotion: string, userAsrSentenceId: number) => {
      //表情
      this.onAgentEmotionChanged(emotion)
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onAgentEmotionNotifyCallback:', emotion, 'userAsrSentenceId:',
        userAsrSentenceId);
    };
    listener.onVoiceIdChangedCallback = (voiceId: string) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onVoiceIdChangedCallback:', voiceId);
    };
    listener.onVoiceInterruptedCallback = (enable: boolean) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onVoiceInterruptedCallback:', enable);
    };
    listener.onSpeakingInterruptedCallback = (reason: ARTCAICallSpeakingInterruptedReason) => {
      //打断的结果，一种动画
      this.onAgentInterrupted(reason)
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onSpeakingInterruptedCallback:', reason);
    };
    listener.onPushToTalkCallback = (enable: boolean) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onPushToTalkCallback:', enable);
    };
    listener.onAgentWillLeaveCallback = (reason: number, message: string) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onAgentWillLeaveCallback:', reason, 'message:', message);

      this.handup();
      DialogUtil.showConfirmDialog({
        message: '智能体结束了通话。',
        confirm: {
          value: $r('app.string.dialog_robot_confirm'),
          action: () => {
            ZRouter.getInstance().pop();
          }
        }
      });
    };
    listener.onAudioDelayInfoCallback = (sentenceId: number, delayMs: number) => {
      ARTCAICallLog.writeLog(ARTCAICallLogType.Info, 'onAudioDelayInfoCallback:', sentenceId, 'delayMs:', delayMs);
    };

    this.onAICallCreated(this.aiCallSDK) // 触发回调

  }

  // 呼叫
  startCall() {
    TokenHelper.shared.fetchAuthToken((joinToken) => {
      if (joinToken === undefined) {
        // failed
        return;
      }

      const aiCallConfig = new ARTCAICallConfig();
      aiCallConfig.agentId = this.agentId;
      aiCallConfig.agentType = this.agentType;
      aiCallConfig.region = AgentConstants.AGENT_REGION;
      aiCallConfig.userId = AppServer.USER_ID;
      aiCallConfig.userJoinToken = joinToken;
      const result = this.aiCallSDK?.callWithConfig(aiCallConfig);
      if (result !== true) {
        // failed
      }
    });
  }

  // 挂断
  handup() {
    if (this.aiCallSDK !== undefined) {
      this.aiCallSDK.handup(true);
      this.aiCallSDK = undefined;
    }
  }

  aboutToAppear(): void {
    // 每隔100ms获取一次振幅
    this.waterRipplesTimerId = setInterval(() => {
      this.getUIContext().animateTo({ duration: CommonConstants.ANIMATION_DURATION, curve: Curve.EaseInOut }, () => {
        this.waterRipplesYMax = Math.round(Math.random() * 35);
        this.waterRipplesYMin = Math.round(Math.random() * 10);
      })
    }, CommonConstants.SET_INTERVAL_TIME);

    this.voiceStyles.title = $r('app.string.dialog_robot_title');
    this.voiceStyles.otherParams = [
      {
        type: VoiceStyleOtherParamsType.Switch,
        name: $r('app.string.config_interrupt_title'),
        detail: $r('app.string.config_interrupt_tips'),
        isOn: true,
        switchValueChangedCallback: (isOn) => {
          this.aiCallSDK?.enableVoiceInterrupt(isOn);
        }
      }
    ]
    this.voiceStyles.itemIndexChangedCallback = (vs) => {
      this.aiCallSDK?.switchVoiceId(vs.sid);
    }

    const permissions: Permissions[] = [
      'ohos.permission.MICROPHONE',
      'ohos.permission.CAMERA'
    ];
    PermissionUtil.requestPermissions(permissions).then((result) => {
      if (result) {
        this.initCall();
        this.startCall();
      } else { //拒绝权限，二次向用户申请授权
        PermissionUtil.requestPermissionOnSettingEasy(permissions).then((result) => {
          ToastUtil.showToast(`申请授权，结果：${result}`);
        });
      }
    })
  }

  aboutToDisappear(): void {
    clearInterval(this.waterRipplesTimerId);

    this.handup();
  }

  @Builder
  setting() {
    Row({ space: 20 }) {
      Text($r('app.string.btn_text_ai_call_full_screen_subtitle'))
        .padding(12)
        .backgroundColor(this.isOpenSubTitle ? $r('app.color.text_extend_color_white') :  Color.Transparent)
        .fontColor(this.isOpenSubTitle ? $r('app.color.start_window_background') :  $r('app.color.text_extend_color_white'))
        .fontSize(16)
        .onClick(() => {
          this.isOpenSubTitle = !this.isOpenSubTitle
        })

      Image($r('app.media.ic_setting'))
        .width(25)
        .height(25)
        .onClick(() => {
          ZRouter.getNavStack().pushPathByName(RouterConstants.VOICE_STYLE_DIALOG, this.voiceStyles, false)
        })
    }
    .padding({ right: 20 })
    .height(56)
  }

  @Builder
  subTitleItemStyle(item: SubTitleModel) {
    Column() {
      Text(item.agentText)
        .fontSize(15)
        .fontColor(Color.Gray)

      Text(item.userText)
        .fontSize(15)
        .fontColor($r('app.color.text_extend_color_white'))
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 18, right: 18, top: 8 })
    .width(CommonConstants.FULL_LENGTH)
  }

  //字幕列表
  @Builder
  subTitleList() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          ForEach(this.subTitleListItems, (item: SubTitleModel, index) => {
            this.subTitleItemStyle(item)
          }, (item: SubTitleModel) => JSON.stringify(item.sentenceId))
        }
        .onAreaChange((_, newVal) => {
          this.subtitleItemHeight = newVal.height
        })
        .width(CommonConstants.FULL_LENGTH)
      }
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .width(CommonConstants.FULL_LENGTH)
      .height(CommonConstants.FULL_LENGTH)
    }
    .position({x:0, y: 0})
    .padding(20)
    .visibility(this.isOpenSubTitle ? Visibility.Visible : Visibility.None)
    .width(CommonConstants.FULL_LENGTH)
    .height('75%')
    .backgroundColor($r('app.color.main_page_background_color')) // 带透明度的背景色
    .opacity(0.8)
    .backdropBlur(20) // 模糊半径参数
  }

  //底部区域
  @Builder
  BottomContent() {
    Column({ space: 10 }) {
      Column({ space: 5 }) {
        ButtonWithWaterRipples({
          columnX: this.waterRipplesColumnX,
          yMax: this.waterRipplesYMax,
          yMin: this.waterRipplesYMin,
        })
          .height(10)
          .width(CommonConstants.FULL_LENGTH)
          .align(Alignment.Center)
          .visibility(this.isOpenSubTitle ? Visibility.Hidden : Visibility.Visible)

        Text(this.agentState === ARTCAICallAgentState.Listening ?
          $r('app.string.robot_listening_tips') :
          (this.agentState === ARTCAICallAgentState.Thinking) ? $r('app.string.robot_thinking_tips') : $r('app.string.robot_speaking_tips'))
          .textAlign(TextAlign.Center)
          .fontSize(13)
          .width(CommonConstants.FULL_LENGTH)
          .visibility(this.isOpenSubTitle ? Visibility.Hidden : Visibility.Visible)
      }

      this.bottomAudio()
      this.bottomVideo()

      Text($r('app.string.bot_message_cankao'))
        .fontColor($r('app.color.bottom_message_gray_text'))
        .fontSize(8)
        .textAlign(TextAlign.Center)
        .width(CommonConstants.FULL_LENGTH)
    }
    .width(CommonConstants.FULL_LENGTH)
    .align(Alignment.BottomEnd) // 子组件自身底部对齐
  }

  //底部控制器(音频,数字人)
  @Builder
  bottomAudio() {
    Row({ space: 50 }) {
      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image(this.isMicrophoneOn ? $r('app.media.ic_microphone_open') : $r('app.media.ic_microphone_close'))
          .botImage()
          .onClick(() => {
            this.isMicrophoneOn = !this.isMicrophoneOn
            this.aiCallSDK?.muteMicrophone(!this.isMicrophoneOn)
          })
      }
      .botControl(0, this.isMicrophoneOn)

      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image($r('app.media.ic_hang_up'))
          .botImage()
      }
      .onClick(() => {
        this.handup();
        ZRouter.getInstance().pop()
      })
      .botControl(1)

      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image(this.isSpeakerOn ? $r('app.media.ic_speaker_open') : $r('app.media.ic_speaker_close'))
          .botImage()
          .onClick(() => {
            this.isSpeakerOn = !this.isSpeakerOn;
            //关闭扬声器
            this.aiCallSDK?.enableSpeaker(this.isSpeakerOn)
          })
      }.botControl(0, this.isSpeakerOn)
    }
    .visibility(this.agentType === ARTCAICallAgentType.VoiceAgent || this.agentType === ARTCAICallAgentType.AvatarAgent
        ? Visibility.Visible : Visibility.None)
    .width(CommonConstants.FULL_LENGTH)
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 25 })
  }

  //底部控制器(视觉理解,视频通话)
  @Builder
  bottomVideo() {
    Row({ space: 10 }) {
      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image(this.isMicrophoneOn ? $r('app.media.ic_microphone_open') : $r('app.media.ic_microphone_close'))
          .botImage()
          .onClick(() => {
            this.isMicrophoneOn = !this.isMicrophoneOn;
            this.aiCallSDK?.muteMicrophone(!this.isMicrophoneOn)
          })
      }
      .botControl(0, this.isMicrophoneOn)

      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image(this.isSpeakerOn ? $r('app.media.ic_speaker_open') : $r('app.media.ic_speaker_close'))
          .botImage()
          .onClick(() => {
            this.isSpeakerOn = !this.isSpeakerOn;
            this.aiCallSDK?.enableSpeaker(this.isSpeakerOn)
          })
      }.botControl(0, this.isSpeakerOn)

      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image($r('app.media.ic_hang_up'))
          .botImage()
      }
      .onClick(() => {
        this.handup();
        ZRouter.getInstance().pop()
      })
      .botControl(1)

      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image(this.isOpenCamera ? $r('app.media.ic_video_camera_on') : $r('app.media.ic_video_camera_off'))
          .botImage()
          .onClick(() => {
            this.isOpenCamera = !this.isOpenCamera;
            this.onCameraIsOpen(this.isOpenCamera)
            if (this.isOpenCamera) {
              this.aiCallSDK?.muteLocalCamera(false)
            } else {
              this.aiCallSDK?.muteLocalCamera(true)
            }
          })
      }.botControl(0, this.isOpenCamera)

      Button({ type: ButtonType.Circle, stateEffect: false }) {
        Image($r('app.media.ic_camera_switch'))
          .botImage()
          .onClick(() => {
            this.aiCallSDK?.switchCamera()
          })
      }.botControl(0, true)
    }
    .visibility(
      this.agentType === ARTCAICallAgentType.VisionAgent || this.agentType === ARTCAICallAgentType.VideoAgent
        ? Visibility.Visible : Visibility.None)
    .width(CommonConstants.FULL_LENGTH)
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 25 })
  }

  @Builder
  content() {
    Stack({alignContent: Alignment.BottomEnd}) {
      Column() {
        this.contentBuilder()
      }
      .position({x: 0, y: 0})
      .width(CommonConstants.FULL_LENGTH)
      .flexGrow(1)
      .onClick(() => {
        this.aiCallSDK?.interruptSpeaking()
      })
      this.BottomContent()

      this.subTitleList()
    }
    .width(CommonConstants.FULL_LENGTH)
    .flexGrow(1)
  }

  build() {
    Column() {
      CommonPage({
        title: this.title,
        isTwiceExit: true,
        twiceExitTips: $r('app.string.tips_exit'),
        exitCallback: () => {
          this.handup();
        },
        settingBuilder: () => {
          this.setting()
        },
        contentBuilder: () => {
          this.content();
        }
      })
    }
  }
}

@Extend(Image)
function botImage() {
  .width(20)
  .height(20)
}

@Extend(Button)
function botControl(color: number, isM?: boolean,) {
  .backgroundColor(color === 0 ? (isM ? $r('app.color.btn_control_gray') : $r('app.color.text_extend_color_white')) :
    $r('app.color.btn_control_red'))
  .width(60)
  .height(60)
}


@Extend(Button)
function btnBottom() {
  .backgroundColor($r('app.color.btn_control_black'))
  .fontColor($r('app.color.start_window_background'))
  .width('85%')
  .height(40)
}

export { BaseCallPage }

