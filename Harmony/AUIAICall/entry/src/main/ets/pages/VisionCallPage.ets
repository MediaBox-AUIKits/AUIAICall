import {
  ARTCAICallAgentType,
  ARTCAICallEngineInterface,
  ARTCAICallViewConfig
} from "@aliyun_video_cloud/alivcsdk_artc"
import { Route } from "@hzw/zrouter"
import { CommonConstants } from "../common/CommonConstants"
import { RouterConstants } from "../common/RouterConstants"
import { SpinKit, SpinType } from '@pura/harmony-dialog';
import { AgentConstants } from "../common/AgentConstants"
import { BaseCallPage } from "./BaseCallPage"

/**
 * @description 视觉理解通话页面。
 * **/
@Entry
@ComponentV2
@Route({ name: RouterConstants.VISION_CALL_PAGE })
struct VisionCallPage {

  private localViewConfig: ARTCAICallViewConfig = new ARTCAICallViewConfig();
  @Local isCallBegin: boolean = false;
  @Local isOpenCamera: boolean = true

  @Param @Once aiCallSDK: ARTCAICallEngineInterface | undefined = undefined;
  @Param @Once isLoadLocalXComponent: boolean = false;

  @Builder
  content() {
    Stack() {
      //加载动画
      SpinKit({ spinType: SpinType.spinG, spinColor: $r('app.color.text_extend_color_white'), spinSize: 100 })
        .visibility(this.isCallBegin === false ? Visibility.Visible : Visibility.None)

      XComponent({
        id: CommonConstants.LOCAL_XC_COMPONENT,
        type: XComponentType.SURFACE,
        controller: this.localViewConfig.controller
      })
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))
        .visibility(this.isCallBegin === true && this.isOpenCamera ? Visibility.Visible : Visibility.Hidden)
        .onLoad(()=>{
          this.isLoadLocalXComponent = true;
          if (this.aiCallSDK) {
            this.aiCallSDK.setLocalViewConfig(this.localViewConfig);
          }
        })

      Column() {
        Image($r('app.media.ic_in_call_video_mute'))
          .width(100)
          .height(100)
      }
      .justifyContent(FlexAlign.Center)
      .visibility(this.isOpenCamera === false ? Visibility.Visible : Visibility.None)
      .backgroundColor($r('app.color.start_window_background'))
    }
    .width(CommonConstants.FULL_LENGTH)
    .height('68%')
    .padding({ left: 15, right: 15 })
  }

  build() {
    Column() {
      BaseCallPage({
        title: $r('app.string.visual_understanding'),
        contentBuilder: () => {
          this.content()
        },
        agentId: AgentConstants.AGENT_ID_VISION,
        agentType: ARTCAICallAgentType.VisionAgent,
        region: AgentConstants.AGENT_REGION,
        onCameraIsOpen: (isOpen) => {
          this.isOpenCamera = isOpen
        },
        onAICallCreated: (aiCallSDK) => {
          this.aiCallSDK = aiCallSDK;
          if (this.isLoadLocalXComponent) {
            this.aiCallSDK.setLocalViewConfig(this.localViewConfig);
          }
        },
        onAICallBegin: (aiCallSDK) => {
          this.isCallBegin = true;
          aiCallSDK.setLocalViewConfig(this.localViewConfig);
        }
      })
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(CommonConstants.FULL_LENGTH)
  }
}

export { VisionCallPage }