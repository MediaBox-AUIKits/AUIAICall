import { Route, ZRouter } from '@hzw/zrouter';
import { CommonConstants } from '../common/CommonConstants';
import { RouterConstants } from '../common/RouterConstants';
import { SwiperTabComponent } from '../component/SwiperTabComponent';
import { DeviceUtils } from '../utils/DeviceUtils';

/**
 * @description 主页面
 * **/
@Entry
@ComponentV2
@Route({ name: RouterConstants.MAIN_PAGE })
struct MainPage {

  @Local selectTabIndex: number = 0

  aboutToDisappear(): void {
  }

  //顶部导航
  @Builder
  NavigationBar() {
    Row() {
      Button() {
        Image($r('app.media.ic_theme'))
          .width(20)
          .height(20)
      }
      .btnTopStyle()
      .onClick(() => {
        DeviceUtils.changeDarkOrLightMode(AppStorage.get('currentColorMode') as number)
      })
    }
    .height(56)
    .width(CommonConstants.FULL_LENGTH)
    .padding({
      top: 10,
      bottom: 10,
      right: 20
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Navigation(ZRouter.getNavStack()) {
      Column() {
        this.NavigationBar()
        Image($r('app.media.ic_title'))
          .width(140)
          .height(25)
          .margin({ top: 8 })
          .objectFit(ImageFit.Contain) // 或根据需求选择其他模式
        SwiperTabComponent({ currentIndex: this.selectTabIndex })
      }
      .width(CommonConstants.FULL_LENGTH)
      .height(CommonConstants.FULL_LENGTH)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20 })
      .backgroundColor($r('app.color.main_page_background_color'))
      .onAppear(() => {
      })
    }
    .hideTitleBar(true)
  }
}

@Extend(Button)
function btnTopStyle() {
  .backgroundColor($r('app.color.start_window_background'))
  .width(36)
  .height(36)
}

export { MainPage }