import { Route, ZRouter } from '@hzw/zrouter';
import { CommonConstants } from '../common/CommonConstants';
import { RouterConstants } from '../common/RouterConstants';
import { CommonPage } from './CommonPage';
import { RegexUtil } from '@pura/harmony-utils';
import { OutboundCallReqModel } from '../model/PhoneCallModel';
import { ARTCAICallAgentConfig } from '@aliyun_video_cloud/alivcsdk_artc';
import { VoiceStyleInputParams, VoiceStyleOtherParamsType } from '../dialog/VoiceStyleDialog';
import { AgentConstants } from '../common/AgentConstants';
import { AppServer } from '../common/AppServer';


/**
 * @description AI电话呼出页面。
 * **/
@Entry
@ComponentV2
@Route({ name: RouterConstants.OUTBOUND_PAGE })
struct OutboundPage {
  @Local enableVoiceInterrupt: boolean = true;
  @Local phoneNum: string = '';

  @Local voiceStyles: VoiceStyleInputParams = new VoiceStyleInputParams(AgentConstants.DEFAULT_VOICE_STYLES, 0);

  aboutToAppear(): void {

  }

  @Builder
  content() {
    Column({ space: 10 }) {
      Text($r('app.string.pstn_out_called_number'))
        .fontSize(16)
        .fontColor($r('app.color.text_extend_color_white'))
      TextInput({ placeholder: $r('app.string.pstn_out_input_number') })
        .borderRadius(2)
        .placeholderColor($r('app.color.phone_call_out_holder_gray'))
        .placeholderFont({ size: 15 })
        .fontColor($r('app.color.text_extend_color_white'))
        .caretColor($r('app.color.text_input_care_green'))
        .backgroundColor($r('app.color.btn_control_gray'))
        .onChange((currentContent: string) => {
          this.phoneNum = currentContent
        })

      Text($r('app.string.pstn_out_called_tips'))
        .fontSize(12)
        .fontColor($r('app.color.phone_call_out_holder_gray'))

      this.interruptItemStyle()
      this.voiceItemStyle()

      Row({ space: 5 }) {
        Image($r('app.media.ic_pstn_out_notice'))
          .width(20)
          .height(20)
        Text($r('app.string.pstn_out_call_after_tips'))
          .fontSize(12)
          .padding({ right: 25 })
          .fontColor($r('app.color.phone_call_out_holder_gray'))
      }
      .width(CommonConstants.FULL_LENGTH)

      Blank()

      this.enterButton($r('app.string.room_entrance_text'), () => {
        const isPhoneNum = RegexUtil.isPhone(this.phoneNum);
        if (isPhoneNum) {

          const  config = new ARTCAICallAgentConfig();
          config.interruptConfig.enableVoiceInterrupt = this.enableVoiceInterrupt;

          const sid = this.voiceStyles.itemList[this.voiceStyles.itemIndex].sid
          if (sid !== '') {
            config.ttsConfig.agentVoiceId = sid;
          }

          const model: OutboundCallReqModel = {
            user_id: AppServer.USER_ID,
            ai_agent_id: AgentConstants.AGENT_ID_OUTBOUND,
            region: AgentConstants.AGENT_REGION,
            called_number: this.phoneNum,
            config: JSON.stringify(config),
          };
          ZRouter.getNavStack().pushPathByName(RouterConstants.OUTBOUND_CALLING_PAGE, model)
        }
      })
    }
    .margin({ top: 20 })
    .padding({ left: 20, right: 20 })
    .width(CommonConstants.FULL_LENGTH) // 容器占满父宽度
    .flexGrow(1)
    .alignItems(HorizontalAlign.Start) // 关键属性设置
  }

  @Builder
  interruptItemStyle() {
    Column() {
      Row() {
        Column({ space: 5 }) {
          Text($r('app.string.config_interrupt_title'))
            .fontSize(16)
            .fontColor($r('app.color.text_extend_color_white'))

        }.alignItems(HorizontalAlign.Start)

        Toggle({ type: ToggleType.Switch, isOn: this.enableVoiceInterrupt })
          .width(45)
          .height(25)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.FULL_LENGTH)
      .height(50)

      Divider()
        .color(Color.Gray)
        .width(CommonConstants.FULL_LENGTH)
        .height(1)
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(60)

  }

  @Builder
  voiceItemStyle() {
    Column() {
      Row() {
        Column({ space: 5 }) {
          Text($r('app.string.config_audio_tone_title'))
            .fontSize(16)
            .fontColor($r('app.color.text_extend_color_white'))

        }.alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.voiceStyles.itemList[this.voiceStyles.itemIndex].name)
            .fontSize(16)
            .fontColor($r('app.color.text_extend_color_white'))

          Image($r('app.media.ic_chevron_right_line'))
            .width(18)
            .height(18)
        }.onClick(() => {
          ZRouter.getNavStack().pushPathByName(RouterConstants.VOICE_STYLE_DIALOG, this.voiceStyles, false)
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.FULL_LENGTH)
      .height(50)

      Divider()
        .color(Color.Gray)
        .width(CommonConstants.FULL_LENGTH)
        .height(1)
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(60)

  }

  @Builder
  enterButton(text: string | Resource, click: ()=>void) {
    Column() {
      Button(text, { type: ButtonType.Normal })
        .backgroundColor($r('app.color.btn_control_black'))
        .fontColor($r('app.color.start_window_background'))
        .width('85%')
        .height(40)
        .onClick(() => {
          click();
        })
    }
    .width(CommonConstants.FULL_LENGTH)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      CommonPage({
        title: $r('app.string.AI_phone_call'),
        contentBuilder: () => {
          this.content()
        }
      })
    }
  }
}

export { OutboundPage }