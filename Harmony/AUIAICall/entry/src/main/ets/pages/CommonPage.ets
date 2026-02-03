import { ZRouter } from "@hzw/zrouter"
import { ToastUtil } from "@pura/harmony-utils"
import { CommonConstants } from "../common/CommonConstants"

/**
 * @description 页面基类
 * **/
@ComponentV2
struct CommonPage {
  @Param title: string | Resource = ''
  @BuilderParam contentBuilder: () => void // 定义内容区域插槽（通过@BuilderParam接收子类内容）
  @BuilderParam settingBuilder?: () => void // 定义设置区域插槽（通过@BuilderParam接收子类内容）

  @Event exitCallback?: () => void;
  @Param isTwiceExit: boolean = false //是否开启二次退出
  @Param twiceExitTips: Resource | string = ''   //
  private firstBackTime: number = 0 // 记录首次返回时间
  private exitThreshold: number = 2000 // 退出时间阈值（2秒）

  //自定义导航栏
  @Builder
  customNavigation() {
    Row() {
      Row({ space: 10 }) {
        Image($r('app.media.ic_aicall_in_call_back'))
          .width(12)
          .height(15)
          .onClick(() => {
            ZRouter.getNavStack().pop()
          })

        Text(this.title)
          .fontColor($r('app.color.text_extend_color_white'))
          .fontSize(16)
      }
      .padding({ left: 18 })
      .height(56)

      Blank()

      this.settingBuilder?.()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_LENGTH)
    .height(56)
  }

  @Builder
  content() {
    this.contentBuilder()
  }

  build() {
    NavDestination() {
      Column() {
        this.customNavigation()
        this.content()
      }
      .width(CommonConstants.FULL_LENGTH)
      .height(CommonConstants.FULL_LENGTH)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (this.isTwiceExit) {
        const currentTime = new Date().getTime()
        if (currentTime - this.firstBackTime < this.exitThreshold) {
          this.exitCallback?.();
          ZRouter.getInstance().pop()
          return false
        }

        this.firstBackTime = currentTime
        ToastUtil.showShort(this.twiceExitTips, { alignment: Alignment.Center })
        return true
      }
      this.exitCallback?.();
      return false
    })
  }
}

export { CommonPage }
