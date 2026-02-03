@ObservedV2
class SwiperTabComponentModel {
  @Trace index: number;
  @Trace title?: Resource | string; // 标题
  @Trace num?: Resource | string;
  @Trace image?: Resource | string; // 图片
  @Trace description?: Resource | string; // 描述

  constructor(index: number, title?: Resource, num?: Resource | string, image?: Resource | string,
    description?: Resource) {
    this.index = index
    this.title = title
    this.image = image
    this.num = num
    this.description = description
  }
}

export { SwiperTabComponentModel }