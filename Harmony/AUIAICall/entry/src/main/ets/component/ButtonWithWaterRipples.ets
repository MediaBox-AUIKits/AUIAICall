import { CommonConstants, CommonConstants as Const } from '../common/CommonConstants';

/**
 * @description 使用Foreach渲染出7个宽度相等，高度随机的Column。
 *              当音频振幅传过来的时候，column高度会随之随机变化
 */

@ComponentV2
export struct ButtonWithWaterRipples {
  @Param columnX: number = 2; // 矩形width
  @Param yMax: number = 50; // 矩形height最大值
  @Param yMin: number = 10; // 矩形height最小值
  @Local arr: Array<number> = [1, 2, 3, 4, 5, 6, 7];

  build() {
    Column() {
      Row({ space: Const.COLUMN_WIDTH }) {
        //高性能知识点：列表循环应使用懒加载，但是这里列表数量极少，且不存在滚动加载情况，故不使用懒加载
        ForEach(this.arr, (_: number) => {
          Column()
            .width(this.columnX)
            .height(Math.floor(Math.random() * (this.yMin - this.yMax + Const.OPACITY_TRUE) + this.yMax))
            .backgroundColor('#457AFC')
        }, (index: number) => index.toString())
      }
      .width(CommonConstants.FULL_LENGTH)
      .height(10)
      .justifyContent(FlexAlign.Center)
    }
    .borderRadius(Const.BLANK_COLUMN)
    .backgroundColor(Color.Transparent)
    .width('80%')
    .height(Const.COLUMN_HEIGHT)
    .alignItems(HorizontalAlign.Center)
  }
}