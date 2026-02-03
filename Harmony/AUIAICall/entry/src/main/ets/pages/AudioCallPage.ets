import {
  ARTCAICallAgentState,
  ARTCAICallAgentType,
} from '@aliyun_video_cloud/alivcsdk_artc';
import { Route } from '@hzw/zrouter';
import { AgentConstants } from '../common/AgentConstants';
import { CommonConstants } from '../common/CommonConstants';
import { RouterConstants } from '../common/RouterConstants';
import { FrameModel } from '../model/FrameModel';
import { BaseCallPage } from './BaseCallPage';

/**
 * @description 音频通话页面。
 * **/

@Entry
@ComponentV2
@Route({ name: RouterConstants.AUDIO_CALL_PAGE })
struct AudioCallPage {
  @Local isFirstAnimatorVisible: boolean = true
  @Local firstAnimatorState: AnimationStatus = AnimationStatus.Initial
  @Local secondAnimatorState: AnimationStatus = AnimationStatus.Initial

  private frames: Array<ImageFrameInfo> = FrameModel.framesEnter
  private framesHand: Array<ImageFrameInfo> = FrameModel.framesHand
  private framesHead: Array<ImageFrameInfo> = FrameModel.framesHead
  private framesCoveringEyes: Array<ImageFrameInfo> = FrameModel.framesCoveringEyes
  private framesEyeEmotionsListening: Array<ImageFrameInfo> = FrameModel.framesEyeEmotionsListening
  private framesEyeEmotionsThinking: Array<ImageFrameInfo> = FrameModel.framesEyeEmotionsThinking
  private framesEyeEmotionsSpeaking: Array<ImageFrameInfo> = FrameModel.framesEyeEmotionsSpeaking
  private framesEyeEmotionsInterrupting: Array<ImageFrameInfo> = FrameModel.framesEyeEmotionsInterrupting

  @Local agentState: ARTCAICallAgentState = ARTCAICallAgentState.Listening;
  @Local agentEmotion: string = 'happy';
  @Local agentInterrupting: boolean = false;

  aboutToAppear(): void {
    //开启帧动画
    this.firstAnimatorState = AnimationStatus.Running
  }

  aboutToDisappear(): void {
    this.firstAnimatorState = AnimationStatus.Stopped
    this.secondAnimatorState = AnimationStatus.Stopped
  }

  @Builder
  content() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.bg_ai_agent_avatar'))
          .width(130)
          .height(130)

        //进入动画
        ImageAnimator()
          .images(this.frames)
          .state(this.firstAnimatorState)    // 控制播放状态
          .ImageAnimators()
          .iterations(1)
          .onFinish(() => {
            this.isFirstAnimatorVisible = false
            this.secondAnimatorState = AnimationStatus.Running
          })
          .visibility(this.isFirstAnimatorVisible ? Visibility.Visible : Visibility.None)


        // 第二组动画
        ImageAnimator()
          .images(this.framesHead)
          .state(this.secondAnimatorState)
          .iterations(-1)  //循环播放
          .ImageAnimators()
          .visibility(this.isFirstAnimatorVisible ? Visibility.None : Visibility.Visible)

        // 第二组动画
        ImageAnimator()
          .images(this.framesHand)
          .state(this.secondAnimatorState)
          .iterations(-1)  //循环播放
          .ImageAnimators()
          .visibility(this.isFirstAnimatorVisible || this.agentInterrupting ? Visibility.None : Visibility.Visible)

        ImageAnimator()
          .images(this.framesEyeEmotionsInterrupting)
          .state(this.secondAnimatorState)
          .iterations(1)  //循环播放
          .ImageAnimators()
          .visibility(this.isFirstAnimatorVisible || this.agentInterrupting === false ? Visibility.None : Visibility.Visible)

        ImageAnimator()
          .images(this.agentState === ARTCAICallAgentState.Listening ? this.framesEyeEmotionsListening :
            this.agentState === ARTCAICallAgentState.Thinking ? this.framesEyeEmotionsThinking :
              this.agentState === ARTCAICallAgentState.Speaking ? this.framesEyeEmotionsSpeaking :
                this.framesEyeEmotionsListening)
          .state(this.secondAnimatorState)
          .iterations(-1)  //循环播放
          .ImageAnimators()
          .visibility(this.isFirstAnimatorVisible || this.agentInterrupting ? Visibility.None : Visibility.Visible)

        ImageAnimator()
          .images(this.framesCoveringEyes)
          .state(this.secondAnimatorState)
          .iterations(1)
          .ImageAnimators()
          .visibility(this.isFirstAnimatorVisible || this.agentInterrupting === false ? Visibility.None : Visibility.Visible)
          .reverse(true)
          .onFinish(() => {
            this.agentInterrupting = false
          })

      }
      .margin({ top: 50 })
    }
    .zIndex(-2)
    .width(CommonConstants.FULL_LENGTH)
    .flexGrow(1)
  }

  build() {
    Column() {
      BaseCallPage({
        title: $r('app.string.audio_call'),
        contentBuilder: () => {
          this.content()
        },
        agentId: AgentConstants.AGENT_ID_VOICE,
        agentType: ARTCAICallAgentType.VoiceAgent,
        region: AgentConstants.AGENT_REGION,
        onAgentStateChanged: (state) => {
          this.agentState = state;
        },
        onAgentInterrupted: (reason) => {
          this.agentInterrupting = true;
        },
        onAgentEmotionChanged: (emotion) => {

        },
      })
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(CommonConstants.FULL_LENGTH)
  }
}

@Extend(ImageAnimator)
function ImageAnimators() {
  .reverse(false)
  .fixedSize(true)
  .width(400)
  .height(400)
  .margin({ top: 45 })
}


export { AudioCallPage }
