import { GoodsItem } from '../models/HomeModel';
import { Constants } from '../common/constants/Constants';

// 商品卡片组件
@Component
export struct GoodsCard {
  @Prop goods: GoodsItem = {} as GoodsItem;
  onItemClick?: (goods: GoodsItem) => void = undefined;

  build() {
    Column() {
      // 商品图片
      Image(this.goods.picture)
        .width('100%')
        .aspectRatio(1)
        .borderRadius({ topLeft: Constants.BORDER_RADIUS, topRight: Constants.BORDER_RADIUS })
        .objectFit(ImageFit.Cover)

      // 商品信息
      Column() {
        // 商品名称
        Text(this.goods.name)
          .fontSize(14)
          .fontColor(Constants.TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 商品描述
        if (this.goods.desc) {
          Text(this.goods.desc)
            .fontSize(12)
            .fontColor(Constants.TEXT_HINT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 4 })
        }

        // 价格
        Row() {
          Text('¥')
            .fontSize(12)
            .fontColor(Constants.PRIMARY_COLOR)
          Text(this.goods.price)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Constants.PRIMARY_COLOR)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .padding(Constants.PADDING_SMALL)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(Constants.BORDER_RADIUS)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.goods);
      }
    })
  }
}
