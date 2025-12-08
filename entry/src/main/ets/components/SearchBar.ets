import { Constants } from '../common/constants/Constants';

// 搜索栏组件
@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索商品';
  @Prop showIcon: boolean = true;
  @Prop clickable: boolean = true;
  onSearchClick?: () => void = undefined;
  onSearchSubmit?: (value: string) => void = undefined;

  @State searchText: string = '';

  build() {
    Row() {
      // 搜索图标
      if (this.showIcon) {
        Image($r('sys.media.ohos_ic_public_search_filled'))
          .width(20)
          .height(20)
          .fillColor(Constants.TEXT_HINT)
          .margin({ left: 12 })
      }

      if (this.clickable) {
        // 可点击模式 - 显示占位文本
        Text(this.placeholder)
          .fontSize(14)
          .fontColor(Constants.TEXT_HINT)
          .layoutWeight(1)
          .margin({ left: 8, right: 12 })
      } else {
        // 输入模式
        TextInput({ placeholder: this.placeholder, text: this.searchText })
          .fontSize(14)
          .placeholderColor(Constants.TEXT_HINT)
          .placeholderFont({ size: 14 })
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .margin({ left: 8, right: 12 })
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            if (this.onSearchSubmit) {
              this.onSearchSubmit(this.searchText);
            }
          })
      }
    }
    .height(36)
    .width('100%')
    .backgroundColor('#F5F5F5')
    .borderRadius(18)
    .onClick(() => {
      if (this.clickable && this.onSearchClick) {
        this.onSearchClick();
      }
    })
  }
}
