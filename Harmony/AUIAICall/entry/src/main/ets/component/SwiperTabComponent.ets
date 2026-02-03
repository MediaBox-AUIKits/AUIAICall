import { ZRouter } from "@hzw/zrouter"
import { ToastUtil } from "@pura/harmony-utils"
import { CommonConstants } from "../common/CommonConstants"
import { RouterConstants } from "../common/RouterConstants"
import { SwiperTabComponentModel } from "../model/SwiperTabComponentModel"
import { SwiperTabComponentViewModel } from "../viewmodel/SwiperTabComponentViewModel"

/**
 * Tab与Swiper组件联动实现
 * @description 实现带有楼梯层次感的图片切换动画，支持手势滑动和标签点击切换
 */

@ComponentV2
struct SwiperTabComponent {
  @Param @Once currentIndex: number = 0 // 当前选中索引
  @Local btnText: string | Resource = $r('app.string.room_entrance_text') // 按钮文本
  @Local btnTextEmpty: string = '' // 按钮空文本（用于样式）
  private tabTopItem: SwiperTabComponentModel[] = SwiperTabComponentViewModel.getSwiperTabData() // 标签数据
  private tabsController: TabsController = new TabsController() // 标签控制器
  private swiperController: SwiperController = new SwiperController() // 滑动控制器
  private DISPLAY_COUNT: number = 1;
  private MIN_SCALE: number = 0.75;
  @Local opacityList: number[] = [];
  @Local scaleList: number[] = [];
  @Local translateList: number[] = [];
  @Local zIndexList: number[] = [];

  aboutToAppear(): void {
    for (let i = 0; i < this.tabTopItem.length; i++) {
      this.opacityList.push(1.0);
      this.scaleList.push(1.0);
      this.translateList.push(0.0);
      this.zIndexList.push(0);
    }
  }

  @Builder
  bottomCom() {
    Column() {
      // 标题和数量行
      Row({ space: 10 }) {
        Text(this.tabTopItem[this.currentIndex].title)
          .textExtend()
        Blank()
        Text(this.tabTopItem[this.currentIndex].num)
          .textExtend()
          .fontSize(15)
      }
      .width(CommonConstants.FULL_LENGTH)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Blank()
        Text(this.tabTopItem[this.currentIndex].description)
          .textExtend()
          .fontSize(15)
          .maxLines(2)
          .constraintSize({ maxWidth: '80%' })
      }
      .width(CommonConstants.FULL_LENGTH)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .margin({ top: 10 })
  }

  /**
   * 构建标签项
   * @param index 标签索引
   * @param title 标签标题
   */
  @Builder
  tabBuilder(index: number, title: string | Resource) {
    Column() {
      Text(title)
        .fontColor($r('app.color.text_extend_color_white'))
        .fontSize(15)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Medium)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
        .padding({
          right: 25
        })

      // 选中状态指示器
      Divider()
        .width(60)
        .strokeWidth(CommonConstants.STROKE_WIDTH)
        .color($r('app.color.text_extend_color_white'))
        .opacity(this.currentIndex === index ? 1 : 0)
        .margin({ top: 5 })
        .padding({
          right: 25
        })
    }
  }

  /**
   * 更新按钮文本
   * @description 根据当前选中的索引更新按钮显示文本
   */
  updateButtonText() {
    if (0 <= this.currentIndex && this.currentIndex <= 4) {
      this.btnText = $r('app.string.room_entrance_text')
    } else if (this.currentIndex === 5) {
      this.btnText = $r('app.string.pstn_in_call_entrance_text')
    } else if (this.currentIndex === 6) {
      this.btnText = $r('app.string.custom_agent_room_entrance_text')
    }
  }

  build() {
    Column() {
      Tabs({ index: this.currentIndex, barPosition: BarPosition.Start, controller: this.tabsController }) {
        ForEach(this.tabTopItem, (item: SwiperTabComponentModel) => {
          TabContent()
            .backgroundColor(Color.Transparent)
            .tabBar(this.tabBuilder(item.index, item.title ?? ''))
        })
      }
      .barMode(BarMode.Scrollable)
      .barWidth(CommonConstants.FULL_LENGTH)
      .height(70)
      .width(CommonConstants.FULL_LENGTH)
      .animationDuration(CommonConstants.ANIMATION_DURATION)
      .onChange((index: number) => {
        this.currentIndex = index
        this.swiperController.changeIndex(index, false)
        this.updateButtonText()
      })
      .onTabBarClick((index: number) => {
        this.currentIndex = index
        this.swiperController.changeIndex(index, false)
        this.updateButtonText()
      })

      Column() {
        Image($r('app.media.ic_ai_agent_text'))
          .height(60)
          .width('80%')
          .objectFit(ImageFit.Contain)
          .margin({ left: 105 })
      }
      .width('100%')
      .height(30)
      .clip(true)
      .alignSelf(ItemAlign.End)

      Column() {
        Swiper(this.swiperController) {
          ForEach(this.tabTopItem, (item: SwiperTabComponentModel, index: number) => {
            Image(item.image)
              .width('100%')
              .borderRadius({
                topLeft: 10,
                bottomLeft: 10,
                topRight: 0,
                bottomRight: 0
              })
              .opacity(this.opacityList[index])
              .scale({ x: this.scaleList[index], y: this.scaleList[index] })
              .translate({ x: this.translateList[index] })
              .zIndex(this.zIndexList[index])
          })
        }
        .height('42%')
        .indicator(false)
        .loop(true)
        .displayCount(this.DISPLAY_COUNT, true)
        .onChange((index: number) => {
          this.currentIndex = index
          this.tabsController.changeIndex(index)
          this.updateButtonText()
        })
        .customContentTransition({
          timeout: 1000,
          transition: (proxy: SwiperContentTransitionProxy) => {
            if (proxy.position <= proxy.index % this.DISPLAY_COUNT ||
              proxy.position >= this.DISPLAY_COUNT + proxy.index % this.DISPLAY_COUNT) {
              this.opacityList[proxy.index] = 1.0;
              this.scaleList[proxy.index] = 1.0;
              this.translateList[proxy.index] = 0.0;
              this.zIndexList[proxy.index] = 0;
            } else {
              if (proxy.index % this.DISPLAY_COUNT === 0) {
                this.opacityList[proxy.index] = 1 - proxy.position / this.DISPLAY_COUNT;
                this.scaleList[proxy.index] =
                  this.MIN_SCALE + (1 - this.MIN_SCALE) * (1 - proxy.position / this.DISPLAY_COUNT);
                this.translateList[proxy.index] = -proxy.position * proxy.mainAxisLength +
                  (1 - this.scaleList[proxy.index]) * proxy.mainAxisLength / 2.0;
              } else {
                this.opacityList[proxy.index] = 1 - (proxy.position - 1) / this.DISPLAY_COUNT;
                this.scaleList[proxy.index] =
                  this.MIN_SCALE + (1 - this.MIN_SCALE) * (1 - (proxy.position - 1) / this.DISPLAY_COUNT);
                this.translateList[proxy.index] = -(proxy.position - 1) * proxy.mainAxisLength -
                  (1 - this.scaleList[proxy.index]) * proxy.mainAxisLength / 2.0;
              }
              this.zIndexList[proxy.index] = -1;
            }
          }
        })

        this.bottomCom()
      }
      .width(CommonConstants.FULL_LENGTH)
      .margin({ top: 35 })

      Button(this.btnTextEmpty, { stateEffect: true }) {
        Row() {
          Text(this.btnText)
            .fontColor(Color.White)
            .fontSize(15)
            .fontColor($r('app.color.btn_route_next_page_white'))

          Image($r('app.media.ic_scan'))
            .width(22)
            .height(22)
            .margin({ left: 8 })
            .visibility(this.currentIndex === 6 ? Visibility.Visible : Visibility.None)
        }
        .height(45)
        .alignItems(VerticalAlign.Center)
      }
      .type(ButtonType.Normal)
      .backgroundColor($r('app.color.btn_route_next_page_black'))
      .fontColor(0xFFFFFF)
      .width('96%')
      .position({ bottom: 110 })
      .zIndex(1)
      .onClick(() => {
        const itemIndex = this.tabTopItem[this.currentIndex].index
        if (itemIndex === 0) {
          ZRouter.getInstance().push(RouterConstants.AUDIO_CALL_PAGE)
        } else if (itemIndex === 1) {
          ZRouter.getInstance().push(RouterConstants.AVATAR_CALL_PAGE)
        } else if (itemIndex === 2) {
          ZRouter.getInstance().push(RouterConstants.VISION_CALL_PAGE)
        } else if (itemIndex === 3) {
          ZRouter.getInstance().push(RouterConstants.VIDEO_CALL_PAGE)
        } else if (itemIndex === 4) {
          ZRouter.getInstance().push(RouterConstants.OUTBOUND_PAGE)
        } else if (itemIndex === 5) {
          ZRouter.getInstance().push(RouterConstants.INBOUND_PAGE)
        } else if (itemIndex === 6) {
          // if (ScanUtil.canIUseScan()) {
          //   ScanUtil.startScanForResult({ enableAlbum: false }).then((scanResult) => {
          //     const scanStr1 = JSON.stringify(scanResult, null, 2)
          //     const token = JSONUtil.jsonToBean(scanStr1, JoinTokenModel)
          //     const scanStr = StrUtil.unit8ArrayToStr(Base64Util.decodeSync(token?.originalValue ?? ""))
          //     const params = JSONUtil.jsonToBean(scanStr, DecodeBase64Model)
          //
          //     if (params?.WorkflowType === CommonConstants.VOICE_TYPE) {
          //       ZRouter.getInstance().push(RouterConstants.AUDIO_CALL_PAGE)
          //     } else if (params?.WorkflowType === CommonConstants.AVATAR_CHAT_TYPE) {
          //       ZRouter.getInstance().push(RouterConstants.AVATAR_CALL_PAGE)
          //     } else if (params?.WorkflowType === CommonConstants.VISION_CHAT_TYPE) {
          //       ZRouter.getInstance().push(RouterConstants.VISION_CALL_PAGE)
          //     } else if (params?.WorkflowType === CommonConstants.VIDEO_CHAT_TYPE) {
          //       ZRouter.getInstance().push(RouterConstants.VIDEO_CALL_PAGE)
          //     }
          //   })
          // } else {
          //   ToastUtil.showToast("当前设备不支持码能力！")
          // }
          ToastUtil.showShort("暂不支持！！！", { alignment: Alignment.Center })
        }
      })
    }
    .height(CommonConstants.FULL_LENGTH)
  }
}

@Extend(Text)
function textExtend() {
  .fontColor($r('app.color.text_extend_color_white'))
  .fontWeight(FontWeight.Medium)
  .margin({ top: 17, bottom: 7 })
  .padding({ left: 10, right: 10 })
  .fontSize(15)
}

export { SwiperTabComponent }