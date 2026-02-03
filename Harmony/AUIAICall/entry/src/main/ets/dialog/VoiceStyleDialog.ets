import { Route, ZRouter } from '@hzw/zrouter'
import { CommonConstants } from '../common/CommonConstants'
import { RouterConstants } from '../common/RouterConstants'

interface VoiceStyleModel {
  name: string,
  sid: string,
  icon?: Resource;
}

enum VoiceStyleOtherParamsType {
  Switch
}

interface VoiceStyleOtherParams {
  type: VoiceStyleOtherParamsType,
  name: string | Resource,
  detail?: string | Resource,
  isOn?: boolean,

  switchValueChangedCallback?: (isOn: boolean) => void;
}

@ObservedV2
class VoiceStyleInputParams {

  constructor(itemList: Array<VoiceStyleModel>, itemIndex: number) {
    this.itemList = itemList;
    this.itemIndex = itemIndex;
  }

  @Trace
  title: string | Resource = $r('app.string.config_audio_tone_title');

  @Trace
  otherParams: Array<VoiceStyleOtherParams> = [];

  @Trace
  itemList: Array<VoiceStyleModel> = [];
  @Trace
  itemIndex: number = 0;

  itemIndexChangedCallback?: (vs: VoiceStyleModel) => void;
}

@ComponentV2
@Route({ name: RouterConstants.VOICE_STYLE_DIALOG })
struct VoiceStyleDialog {

  @Local translateY: number = 1000

  @Local inputParams: VoiceStyleInputParams = new VoiceStyleInputParams([], 0);

  aboutToAppear(): void {
    this.inputParams = ZRouter.getInstance().getParam() as VoiceStyleInputParams;
  }

  @Builder
  voiceStyle(vs: VoiceStyleModel) {
    Row() {
      Row({ space: 10 }) {
        Image(vs.icon ?? $r('app.media.ic_audio_tone_3') )
          .width(30)
          .height(30)
        Text(vs.name)
          .fontSize(15)
          .fontColor($r('app.color.text_extend_color_white'))
      }

      Text($r('app.string.audio_tone_selector'))
        .fontSize(15)
        .fontColor($r('app.color.text_extend_color_white'))
        .onClick(() => {
          this.inputParams.itemIndex = this.inputParams.itemList.indexOf(vs)
          this.inputParams.itemIndexChangedCallback?.(vs);
        })
        .visibility(this.inputParams.itemList[this.inputParams.itemIndex] === vs ? Visibility.None : Visibility.Visible)

      Image($r('app.media.ic_checkmark_filled'))
        .width(15)
        .height(15)
        .visibility(this.inputParams.itemList[this.inputParams.itemIndex] === vs ? Visibility.Visible : Visibility.None)

    }
    .borderRadius(4)
    .height(50)
    .padding({ left: 20, right: 20 })
    .width(CommonConstants.FULL_LENGTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.btn_audio_model_gray'))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  voiceStylesComponent() {
    Column({ space: 10 }) {
      ForEach(this.inputParams.itemList, (item: VoiceStyleModel) => {
        this.voiceStyle(item);
      })
    }
    .padding({ left: 20, right: 20 })
    .width(CommonConstants.FULL_LENGTH)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  switchItemStyle(otherItem: VoiceStyleOtherParams) {
    Column() {
      Row() {
        Column({ space: 5 }) {
          Text(otherItem.name)
            .fontSize(15)
            .fontColor($r('app.color.text_extend_color_white'))

          Text(otherItem.detail)
            .fontSize(10)
            .fontColor($r('app.color.item_style_gray_text'))
            .visibility(otherItem.detail === undefined ? Visibility.None : Visibility.Visible)
        }.alignItems(HorizontalAlign.Start)

        Toggle({ type: ToggleType.Switch, isOn: otherItem.isOn })
          .width(40)
          .height(20)
          .onChange((isOn)=>{
            otherItem.isOn = isOn;
            otherItem.switchValueChangedCallback?.(isOn);
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(CommonConstants.FULL_LENGTH)
      .height(CommonConstants.FULL_LENGTH)
    }
    .width(CommonConstants.FULL_LENGTH)
    .height(40)
    .visibility(otherItem.type === VoiceStyleOtherParamsType.Switch ? Visibility.Visible : Visibility.None)
  }

  @Builder
  otherItemStyle() {
    Column() {
      ForEach(this.inputParams.otherParams, (other: VoiceStyleOtherParams)=>{
        if (other.type === VoiceStyleOtherParamsType.Switch) {
          this.switchItemStyle(other);
        }
      })
    }
    .width(CommonConstants.FULL_LENGTH)
    .padding({ left: 25, right: 25, top: 20, bottom: 20 })
  }

  build() {
    NavDestination() {
      Column() {
        Blank()
          .onClick(() => {
            ZRouter.getNavStack().pop()
          })

        Column() {
          Row() {
            Text(this.inputParams.title)
              .fontSize(15)
              .fontColor($r('app.color.text_extend_color_white'))

            Image($r('app.media.ic_push_to_talk_cancel'))
              .width(12)
              .height(15)
              .onClick(() => ZRouter.getInstance().pop()) // 点击关闭
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstants.FULL_LENGTH)
          .height(20)
          .padding({ left: 25, right: 25 })
          .margin({ top: 20 })

          Scroll() {
            Column() {

              this.otherItemStyle()

              Text($r('app.string.config_audio_tone_title'))
                .textAlign(TextAlign.Start)
                .fontSize(15)
                .fontColor($r('app.color.text_extend_color_white'))
                .padding({ left: 25, right: 25 })
                .height(20)
                .width(CommonConstants.FULL_LENGTH)
                .visibility(this.inputParams.otherParams.length > 0 ? Visibility.Visible : Visibility.None)

              Column({ space: 12 }) {
                this.voiceStylesComponent()
              }
              .margin({ top: 20 })
            }
            .margin({ top: 5 })
          }

          .scrollBar(BarState.On)
          .width(CommonConstants.FULL_LENGTH)

        }
        .backgroundColor($r('app.color.start_window_background'))
        .width(CommonConstants.FULL_LENGTH)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .translate({ y: this.translateY })
        .onAppear(() => {
          this.translateY = 0 // 触发向上滑动
        })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
        .constraintSize({ maxHeight: 600 })

      }
      .justifyContent(FlexAlign.End)
      .backgroundColor('#80000000') // 半透明遮罩
      .height(CommonConstants.FULL_LENGTH)
      .translate({ y: this.translateY })
    }
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
  }
}

export { VoiceStyleModel, VoiceStyleOtherParamsType, VoiceStyleOtherParams, VoiceStyleInputParams, VoiceStyleDialog }