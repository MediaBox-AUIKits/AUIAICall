import { ARTCAICallAgentType,
  ARTCAICallEngineInterface,
  ARTCAICallViewConfig } from '@aliyun_video_cloud/alivcsdk_artc';
import { Route } from '@hzw/zrouter';
import { CommonConstants } from '../common/CommonConstants';
import { RouterConstants } from '../common/RouterConstants';
import { SpinKit, SpinType } from '@pura/harmony-dialog';
import { BaseCallPage } from './BaseCallPage';
import { AgentConstants } from '../common/AgentConstants';

/**
 * @description 视频通话页面。
 * **/
@Entry
@ComponentV2
@Route({ name: RouterConstants.VIDEO_CALL_PAGE })
struct VideoCallPage {

  private localViewConfig: ARTCAICallViewConfig = new ARTCAICallViewConfig();
  private agentViewConfig: ARTCAICallViewConfig = new ARTCAICallViewConfig();
  @Local isOpenCamera: boolean = true
  @Local isCallBegin: boolean = false;

  @Local isConvertXC: boolean = true

  @Local offsetX: number = 0
  @Local offsetY: number = 0
  @Local lastOffsetX: number = 245 // 上次拖拽结束时的x偏移
  @Local lastOffsetY: number = 50 // 上次拖拽结束时的y偏移
  @Local offsetBottomX: number = 0
  @Local offsetBottomY: number = 0
  @Local lastOffsetBottomX: number = 245 // 上次拖拽结束时的x偏移
  @Local lastOffsetBottomY: number = 50 // 上次拖拽结束时的y偏移

  @Param @Once aiCallSDK: ARTCAICallEngineInterface | undefined = undefined;
  @Param @Once isLoadLocalXComponent: boolean = false;
  @Param @Once isLoadAgentXComponent: boolean = false;

  @Builder
  content() {
    Stack({ alignContent: Alignment.Center }) {
      //底层stack
      Stack({ alignContent: Alignment.BottomEnd }) {
        XComponent({
          id: CommonConstants.AGENT_XC_COMPONENT,
          type: XComponentType.SURFACE,
          controller: this.agentViewConfig.controller
        })
          .borderRadius(10)
          .backgroundColor($r('app.color.start_window_background'))
          .onLoad(()=>{
            this.isLoadAgentXComponent = true;
            if (this.aiCallSDK) {
              this.aiCallSDK.setAgentViewConfig(this.agentViewConfig);
            }
          })

        Button({ type: ButtonType.Circle, stateEffect: false }) {
          Image($r('app.media.ic_call_small_video_change'))
            .width(20)
            .height(20)
        }
        .width(30)
        .height(30)
        .margin({ right: 5, bottom: 5 })
        .backgroundColor($r('app.color.video_convert_button_gray'))
        .visibility(this.isConvertXC ? Visibility.Hidden : Visibility.Visible)
        .onClick(() => {
          this.isConvertXC = !this.isConvertXC
        })
      }
      .padding({ left: this.isConvertXC ? 0 : 15, right: this.isConvertXC ? 0 : 15, bottom: 15 })
      .position({
        x: this.isConvertXC ? '' : this.lastOffsetX,
        y: this.isConvertXC ? '' : this.lastOffsetY
      })
      .width(this.isConvertXC ? '93%' : '35%')
      .height(this.isConvertXC ? '100%' : '28%')
      .visibility(this.isCallBegin === true ? Visibility.Visible : Visibility.Hidden)
      .zIndex(this.isConvertXC ? 0 : 2)
      .translate({
        x: this.isConvertXC ? 0 : this.offsetBottomX,
        y: this.isConvertXC ? 0 : this.offsetBottomY
      })
      .gesture(
        PanGesture()
          .onActionStart((event: GestureEvent) => {
            if (!this.isConvertXC) {
              this.lastOffsetBottomX = this.offsetBottomX
              this.lastOffsetBottomY = this.offsetBottomY
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            // 基于上次位置累加当前偏移
            const newOffsetX = this.lastOffsetBottomX + event.offsetX;
            const newOffsetY = this.lastOffsetBottomY + event.offsetY;

            if (!this.isConvertXC) {
              this.offsetBottomX = newOffsetX;
              this.offsetBottomY = newOffsetY;
            }
          })
          .onActionEnd(() => {
            if (!this.isConvertXC) {
              // 计算最终绝对坐标
              const finalX = 245 + this.offsetBottomX; // 245是position.x初始值
              const finalY = 50 + this.offsetBottomY; // 50是position.y初始值
              // 保存当前位置，作为下次拖拽的起点
              this.lastOffsetBottomX = finalX;
              this.lastOffsetBottomY = finalY;
            }
          })
      )

      //加载动画（中间层）
      SpinKit({ spinType: SpinType.spinG, spinColor: $r('app.color.text_extend_color_white'), spinSize: 100 })
        .visibility(this.isCallBegin === false ? Visibility.Visible : Visibility.None)
        .zIndex(1)

      //顶层stack
      Stack({ alignContent: Alignment.BottomEnd }) {
        XComponent({
          id: CommonConstants.LOCAL_XC_COMPONENT,
          type: XComponentType.SURFACE,
          controller: this.localViewConfig.controller
        })
          .borderRadius(10)
          .backgroundColor($r('app.color.start_window_background'))
          .onLoad(()=>{
            this.isLoadLocalXComponent = true;
            if (this.aiCallSDK) {
              this.aiCallSDK.setLocalViewConfig(this.localViewConfig);
            }
          })

        Column() {
          Image($r('app.media.ic_in_call_video_mute'))
            .width(this.isConvertXC ? 55 : 100)
            .height(this.isConvertXC ? 55 : 100)
        }
        .borderRadius(10)
        .visibility(this.isOpenCamera === false ? Visibility.Visible : Visibility.None)
        .justifyContent(FlexAlign.Center)
        .width(CommonConstants.FULL_LENGTH)
        .height(CommonConstants.FULL_LENGTH)
        .backgroundColor($r('app.color.start_window_background'))

        Button({ type: ButtonType.Circle, stateEffect: false }) {
          Image($r('app.media.ic_call_small_video_change'))
            .width(20)
            .height(20)
        }
        .width(30)
        .height(30)
        .margin({ right: 5, bottom: 5 })
        .backgroundColor($r('app.color.video_convert_button_gray'))
        .visibility(this.isConvertXC ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.isConvertXC = !this.isConvertXC
        })
      }
      .visibility(this.isCallBegin === true ? Visibility.Visible : Visibility.Hidden)
      .zIndex(this.isConvertXC ? 2 : 0)
      .position({
        x: this.isConvertXC ? this.lastOffsetBottomX : '',
        y: this.isConvertXC ? this.lastOffsetBottomY : ''
      }) // 相对定位偏移
      .width(this.isConvertXC ? '35%' : '93%')
      .height(this.isConvertXC ? '28%' : '100%')
      .padding({ left: this.isConvertXC ? 15 : 0, right: this.isConvertXC ? 15 : 0, bottom: 15 })
      .translate({ x: this.isConvertXC ? this.offsetX : 0, y: this.isConvertXC ? this.offsetY : 0 })
      .gesture(
        PanGesture()
          .onActionStart((event: GestureEvent) => {
            if (this.isConvertXC) {
              this.lastOffsetX = this.offsetX;
              this.lastOffsetY = this.offsetY;
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            // 基于上次位置累加当前偏移
            let newOffsetX = this.lastOffsetX + event.offsetX;
            let newOffsetY = this.lastOffsetY + event.offsetY;

            if (this.isConvertXC) {
              this.offsetX = newOffsetX;
              this.offsetY = newOffsetY;
            }
          })
          .onActionEnd(() => {
            if (this.isConvertXC) {
              // 计算最终绝对坐标
              const finalX = 245 + this.offsetX; // 245是position.x初始值
              const finalY = 50 + this.offsetY; // 50是position.y初始值
              // 保存当前位置，作为下次拖拽的起点
              this.lastOffsetX = finalX
              this.lastOffsetY = finalY
            }
          })
      )
    }
    .zIndex(3)
    .width(CommonConstants.FULL_LENGTH)
    .height('68%')
  }

  build() {
    Column() {
      BaseCallPage({
        title: $r('app.string.video_call'),
        contentBuilder: () => {
          this.content()
        },
        agentId: AgentConstants.AGENT_ID_VIDEO,
        agentType: ARTCAICallAgentType.VideoAgent,
        region: AgentConstants.AGENT_REGION,
        onCameraIsOpen: (isOpen) => {
          this.isOpenCamera = isOpen
        },
        onAICallCreated: (aiCallSDK) => {
          this.aiCallSDK = aiCallSDK;
          if (this.isLoadLocalXComponent) {
            this.aiCallSDK.setLocalViewConfig(this.localViewConfig);
          }
          if (this.isLoadAgentXComponent) {
            this.aiCallSDK.setAgentViewConfig(this.agentViewConfig);
          }
        },
        onAICallBegin: (aiCallSDK) => {
          this.isCallBegin = true;
        }
      })
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(CommonConstants.FULL_LENGTH)
  }
}

export { VideoCallPage }