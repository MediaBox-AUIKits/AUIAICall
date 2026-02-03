import { Route } from '@hzw/zrouter';
import { LogUtil, PasteboardUtil, StrUtil, ToastUtil } from '@pura/harmony-utils';
import { CommonConstants } from '../common/CommonConstants';
import { RouterConstants } from '../common/RouterConstants';
import { JSON } from '@kit.ArkTS';
import { CommonPage } from './CommonPage';
import { call } from '@kit.TelephonyKit';
import { AppServer } from '../common/AppServer';
import { AgentConstants } from '../common/AgentConstants';

/**
 * @description AI电话呼入页面。
 * **/
@Entry
@ComponentV2
@Route({ name: RouterConstants.INBOUND_PAGE })
struct InboundPage {
  @Local phoneNumber: string = '';

  aboutToAppear(): void {
    this.fetchPhoneNumber();
  }

  fetchPhoneNumber: () => void = async ()=> {
    const phoneNumber = await AppServer.getInboundPhoneNumber(AgentConstants.AGENT_ID_INBOUND, AgentConstants.AGENT_REGION)
    if (phoneNumber !== undefined) {
      this.phoneNumber = phoneNumber;
    }
    else {
      LogUtil.debug("获取电话号码失败。")
    }
  }

  //调用打电话
  callPhoneNum: () => void = () => {
  if (canIUse("SystemCapability.Telephony.CallManager")) {
    let isSupport = call.hasVoiceCapability();
    if (isSupport) {
      if (canIUse("SystemCapability.Applications.Contacts")) {
        call.makeCall(this.phoneNumber, (err) => {
          if (!err) {
            LogUtil.info("拨号成功");
          } else {
            LogUtil.error("拨号失败: " + JSON.stringify(err));
          }
        });
      } else {
        // Fallback for unsupported SystemCapability
      }

    } else {
      LogUtil.error("设备不支持语音通话");
    }
  } else {
    // Fallback for unsupported SystemCapability
  }

}

  @Builder
  content() {
    Column({ space: 15 }) {
      Text($r('app.string.pstn_in_called_number'))
        .fontSize(16)
        .fontColor($r('app.color.text_extend_color_white'))

      Stack({ alignContent: Alignment.End }) {
        TextInput({ placeholder: $r('app.string.pstn_in_input_number'), text: this.phoneNumber })
          .borderRadius(2)
          .caretColor($r('app.color.text_input_care_green'))
          .backgroundColor($r('app.color.btn_control_gray'))
          .fontColor($r('app.color.text_extend_color_white'))
          .fontSize(16)
          .enabled(false)

        Image(StrUtil.isEmpty(this.phoneNumber) ? $r('app.media.copy_line') : $r('app.media.ic_pstn_in_call_copy'))
          .width(20)
          .height(20)
          .margin({ right: 20 })
          .onClick(() => {
            if (StrUtil.isNotEmpty(this.phoneNumber)) {
              PasteboardUtil.setDataText(this.phoneNumber).then(async () => {
                ToastUtil.showShort('坐席号码已复制', { alignment: Alignment.Center })
              })
            }
          })
      }.width(CommonConstants.FULL_LENGTH)

      Row({ space: 10 }) {
        Text($r('app.string.pstn_in_called_tips'))
          .fontSize(12)
          .fontColor($r('app.color.text_only_support_gray'))

        Image($r('app.media.ic_pstn_in_get_number_again'))
          .width(15)
          .height(15)
          .onClick(() => {
            this.fetchPhoneNumber();
          })
      }.width(CommonConstants.FULL_LENGTH)

      Blank()

      this.enterButton($r('app.string.pstn_in_call_entrance_text'), () => {
        this.callPhoneNum();
      })
    }
    .margin({ top: 20 })
    .padding({ left: 20, right: 20 })
    .width(CommonConstants.FULL_LENGTH) // 容器占满父宽度
    .flexGrow(1)
    .alignItems(HorizontalAlign.Start) // 关键属性设置
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
        .enabled(StrUtil.isNotEmpty(this.phoneNumber))
    }
    .width(CommonConstants.FULL_LENGTH)
    .alignItems(HorizontalAlign.Center)
  }


  build() {
    Column() {
      CommonPage({
        title: $r('app.string.AI_phone_import'),
        contentBuilder: () => {
          this.content()
        }
      })
    }
  }
}

export { InboundPage }