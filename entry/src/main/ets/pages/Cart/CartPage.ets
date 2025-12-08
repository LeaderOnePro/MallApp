import { Constants } from '../../common/constants/Constants';
import httpUtil from '../../common/utils/HttpUtil';
import { CartItem } from '../../models/CartModel';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

@Component
export struct CartPage {
  @State cartList: CartItem[] = [];
  @State isLoading: boolean = true;
  @State isAllSelected: boolean = false;

  aboutToAppear(): void {
    this.loadCartData();
  }

  // 获取Token
  private async getToken(): Promise<string> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const prefs = preferences.getPreferencesSync(context, { name: 'mall_app_prefs' });
      const token = prefs.getSync(Constants.USER_TOKEN, '') as string;
      return token;
    } catch (error) {
      console.error('获取Token失败:', JSON.stringify(error));
      return '';
    }
  }

  // 加载购物车数据
  private async loadCartData(): Promise<void> {
    this.isLoading = true;
    try {
      const token = await this.getToken();
      if (!token) {
        console.warn('未登录，无法获取购物车');
        this.isLoading = false;
        return;
      }

      const response = await httpUtil.get<CartItem[]>(`${Constants.API_BASE_URL}/member/cart`, token);
      if (response.code === '1' && response.result) {
        this.cartList = response.result;
        this.updateAllSelectedState();
      }
    } catch (error) {
      console.error('加载购物车失败:', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  // 更新全选状态
  private updateAllSelectedState(): void {
    if (this.cartList.length === 0) {
      this.isAllSelected = false;
    } else {
      this.isAllSelected = this.cartList.every(item => item.selected);
    }
  }

  // 计算选中商品数量
  private getSelectedCount(): number {
    return this.cartList.filter(item => item.selected).reduce((sum, item) => sum + item.count, 0);
  }

  // 计算选中商品总价
  private getSelectedTotalPrice(): string {
    const total = this.cartList
      .filter(item => item.selected)
      .reduce((sum, item) => sum + parseFloat(item.nowPrice) * item.count, 0);
    return total.toFixed(2);
  }

  // 切换商品选中状态
  private toggleItemSelected(index: number): void {
    this.cartList[index].selected = !this.cartList[index].selected;
    this.updateAllSelectedState();
  }

  // 切换全选
  private toggleAllSelected(): void {
    this.isAllSelected = !this.isAllSelected;
    this.cartList.forEach(item => {
      item.selected = this.isAllSelected;
    });
  }

  // 修改商品数量
  private updateItemCount(index: number, delta: number): void {
    const newCount = this.cartList[index].count + delta;
    if (newCount >= 1 && newCount <= this.cartList[index].stock) {
      this.cartList[index].count = newCount;
    }
  }

  // 空购物车提示
  @Builder
  EmptyCart() {
    Column() {
      Text('🛒')
        .fontSize(60)
        .margin({ top: 100 })

      Text('购物车是空的')
        .fontSize(16)
        .fontColor(Constants.TEXT_HINT)
        .margin({ top: 20 })

      Text('快去挑选心仪的商品吧~')
        .fontSize(14)
        .fontColor(Constants.TEXT_HINT)
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  // 购物车商品项
  @Builder
  CartItemView(item: CartItem, index: number) {
    Row() {
      // 选择框
      Checkbox()
        .select(item.selected)
        .selectedColor(Constants.PRIMARY_COLOR)
        .onChange((value: boolean) => {
          this.toggleItemSelected(index);
        })
        .margin({ right: 12 })

      // 商品图片
      Image(item.picture)
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      // 商品信息
      Column() {
        Text(item.name)
          .fontSize(14)
          .fontColor(Constants.TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (item.attrsText) {
          Text(item.attrsText)
            .fontSize(12)
            .fontColor(Constants.TEXT_HINT)
            .margin({ top: 4 })
            .maxLines(1)
        }

        Row() {
          // 价格
          Row() {
            Text('¥')
              .fontSize(12)
              .fontColor(Constants.PRIMARY_COLOR)
            Text(item.nowPrice)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Constants.PRIMARY_COLOR)
          }

          Blank()

          // 数量控制
          Row() {
            Text('-')
              .fontSize(18)
              .fontColor(item.count <= 1 ? Constants.TEXT_HINT : Constants.TEXT_PRIMARY)
              .width(28)
              .height(28)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(4)
              .onClick(() => {
                this.updateItemCount(index, -1);
              })

            Text(item.count.toString())
              .fontSize(14)
              .width(40)
              .textAlign(TextAlign.Center)

            Text('+')
              .fontSize(18)
              .fontColor(item.count >= item.stock ? Constants.TEXT_HINT : Constants.TEXT_PRIMARY)
              .width(28)
              .height(28)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(4)
              .onClick(() => {
                this.updateItemCount(index, 1);
              })
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(Constants.PADDING_NORMAL)
    .backgroundColor(Color.White)
    .borderRadius(Constants.BORDER_RADIUS)
    .margin({ bottom: 12 })
  }

  // 底部结算栏
  @Builder
  BottomBar() {
    Row() {
      // 全选
      Row() {
        Checkbox()
          .select(this.isAllSelected)
          .selectedColor(Constants.PRIMARY_COLOR)
          .onChange(() => {
            this.toggleAllSelected();
          })

        Text('全选')
          .fontSize(14)
          .fontColor(Constants.TEXT_PRIMARY)
          .margin({ left: 8 })
      }

      Blank()

      // 合计
      Row() {
        Text('合计：')
          .fontSize(14)
          .fontColor(Constants.TEXT_PRIMARY)
        Text('¥')
          .fontSize(12)
          .fontColor(Constants.PRIMARY_COLOR)
        Text(this.getSelectedTotalPrice())
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Constants.PRIMARY_COLOR)
      }

      // 结算按钮
      Button(`结算(${this.getSelectedCount()})`)
        .height(40)
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor(Constants.PRIMARY_COLOR)
        .borderRadius(20)
        .margin({ left: 16 })
        .enabled(this.getSelectedCount() > 0)
    }
    .width('100%')
    .height(60)
    .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL })
    .backgroundColor(Color.White)
    .shadow({ radius: 4, color: '#1A000000', offsetY: -2 })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('购物车')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Constants.TEXT_PRIMARY)
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)

      if (this.cartList.length === 0) {
        // 空购物车
        this.EmptyCart()
      } else {
        // 购物车列表
        List() {
          ForEach(this.cartList, (item: CartItem, index: number) => {
            ListItem() {
              this.CartItemView(item, index)
            }
          })
        }
        .layoutWeight(1)
        .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 12 })
        .backgroundColor(Constants.BACKGROUND_COLOR)

        // 底部结算栏
        this.BottomBar()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
  }
}
