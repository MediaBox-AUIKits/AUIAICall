import {
  ARTCAICallAgentType,
  ARTCAICallViewConfig,
} from '@aliyun_video_cloud/alivcsdk_artc';
import { Route } from '@hzw/zrouter';
import { SpinKit, SpinType } from '@pura/harmony-dialog';
import { AgentConstants } from '../common/AgentConstants';
import { CommonConstants } from '../common/CommonConstants';
import { RouterConstants } from '../common/RouterConstants';
import { BaseCallPage } from './BaseCallPage';

/**
 * @description 数字人通话页面。
 * **/
@Entry
@ComponentV2
@Route({ name: RouterConstants.AVATAR_CALL_PAGE })
struct AvatarCallPage {

  private agentViewConfig: ARTCAICallViewConfig = new ARTCAICallViewConfig();
  @Local isCallBegin: boolean = false;

  @Builder
  content() {
    Stack({ alignContent: Alignment.Center }) {
      //加载动画
      SpinKit({ spinType: SpinType.spinG, spinColor: $r('app.color.text_extend_color_white'), spinSize: 100 })
        .visibility(this.isCallBegin === false ? Visibility.Visible : Visibility.None)

      XComponent({
        id: CommonConstants.AGENT_XC_COMPONENT,
        type: XComponentType.SURFACE,
        controller: this.agentViewConfig.controller,
      })
        .width('93%')
        .height('68%')
        .borderRadius(10)
        .backgroundColor($r('app.color.start_window_background'))
        .visibility(this.isCallBegin === true ? Visibility.Visible : Visibility.Hidden)
    }
  }

  build() {
    Column() {
      BaseCallPage({
        title: $r('app.string.digital_man_call'),
        contentBuilder: () => {
          this.content()
        },
        agentId: AgentConstants.AGENT_ID_AVATAR,
        agentType: ARTCAICallAgentType.AvatarAgent,
        region: AgentConstants.AGENT_REGION,
        onAICallBegin: (aiCallSDK) => {
          this.isCallBegin = true;
          aiCallSDK.setAgentViewConfig(this.agentViewConfig);
        }
      })
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(CommonConstants.FULL_LENGTH)
  }
}

export { AvatarCallPage }