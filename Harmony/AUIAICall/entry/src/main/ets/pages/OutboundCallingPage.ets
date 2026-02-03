import { Route, ZRouter } from '@hzw/zrouter';
import { LogUtil, PasteboardUtil, ToastUtil } from '@pura/harmony-utils';
import { AppServer } from '../common/AppServer';
import { CommonConstants } from '../common/CommonConstants';
import { RouterConstants } from '../common/RouterConstants';
import { OutboundCallReqModel } from '../model/PhoneCallModel';
import { CommonPage } from './CommonPage';

/**
 * @description AI电话呼出呼叫页面。
 * **/
@Entry
@ComponentV2
@Route({ name: RouterConstants.OUTBOUND_CALLING_PAGE })
struct OutboundCallingPage {
  private model: OutboundCallReqModel | undefined;
  @Local instanceId: string = '';
  @Local callOutResult: string | Resource = $r('app.string.pstn_out_calling_tips');
  @Local isCallSuccess: boolean = false;

  aboutToAppear(): void {
    this.model = ZRouter.getInstance().getParam() as OutboundCallReqModel;
    if (this.model === undefined) {
      return;
    }

    AppServer.startOutbound(this.model).then((instance_id: string | undefined) => {
      this.instanceId = instance_id ?? '';
      this.isCallSuccess = instance_id !== undefined && instance_id !== '';
      this.callOutResult = this.isCallSuccess ? $r('app.string.pstn_out_call_tips') : $r('app.string.pstn_out_call_failed_tips');
    }).catch(()=>{
      this.isCallSuccess = false;
      this.callOutResult = $r('app.string.pstn_out_call_failed_tips')
    });
  }

  @Builder
  content() {
    Column({ space: 20 }) {
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_pstn_phone_call'))
          .width(35)
          .height(35)
      }
      .width(80)
      .height(80)
      .backgroundColor($r('app.color.btn_control_gray'))

      Text(this.callOutResult)
        .fontSize(15)
        .fontColor($r('app.color.text_extend_color_white'))
        .constraintSize({ maxWidth: '90%' })

      Row({ space: 5 }) {
        Text(this.isCallSuccess ? "ID " + this.instanceId : " ")
          .fontSize(15)
          .fontColor($r('app.color.text_extend_color_white'))

        Button($r('app.string.copy'), { type: ButtonType.Capsule })
          .width(55)
          .height(20)
          .fontSize(10)
          .fontColor($r('app.color.text_extend_color_white'))
          .backgroundColor($r('app.color.start_window_background'))
          .borderWidth(1)
          .borderColor(Color.Gray)
          .onClick(() => {
            PasteboardUtil.setDataText(this.instanceId).then(async () => {
              ToastUtil.showShort($r('app.string.pstn_out_call_instanceid_copied'), { alignment: Alignment.Center })
            })
          })
      }
      .justifyContent(FlexAlign.Center)
      .visibility(this.isCallSuccess ? Visibility.Visible : Visibility.None)
      .width(CommonConstants.FULL_LENGTH)

    }
    .justifyContent(FlexAlign.Center)
    .width(CommonConstants.FULL_LENGTH)
    .flexGrow(1)
  }

  build() {
    Column() {
      CommonPage({
        title: $r('app.string.AI_phone_call_Add_space'),
        contentBuilder: () => {
          this.content()
        }
      })
    }
  }
}

export { OutboundCallingPage }