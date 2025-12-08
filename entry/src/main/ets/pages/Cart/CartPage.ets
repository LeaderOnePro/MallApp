import { Constants } from '../../common/constants/Constants';
import httpUtil from '../../common/utils/HttpUtil';
import { CartItem } from '../../models/CartModel';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

@Component
export struct CartPage {
  @State cartList: CartItem[] = [];
  @State isLoading: boolean = true;
  @State selectedTotal: number = 0;
  @State selectedCount: number = 0;
  @State allSelected: boolean = false;

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
        this.calculateStats();
      }
    } catch (error) {
      console.error('加载购物车失败:', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  // 计算统计数据
  private calculateStats(): void {
    let total = 0;
    let count = 0;
    let allSel = this.cartList.length > 0;

    for (let i = 0; i < this.cartList.length; i++) {
      const item = this.cartList[i];
      if (item.selected) {
        total += parseFloat(item.nowPrice) * item.count;
        count += item.count;
      } else {
        allSel = false;
      }
    }

    this.selectedTotal = total;
    this.selectedCount = count;
    this.allSelected = allSel;
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
        this.EmptyCart()
      } else {
        // 购物车列表
        Scroll() {
          Column() {
            ForEach(this.cartList, (item: CartItem, index: number) => {
              Row() {
                // 选择框
                Checkbox()
                  .select(item.selected)
                  .selectedColor(Constants.PRIMARY_COLOR)
                  .onChange((value: boolean) => {
                    this.cartList[index].selected = value;
                    this.calculateStats();
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

                    // 数量控制 - 使用Counter组件
                    Counter() {
                      Text(this.cartList[index].count.toString())
                        .fontSize(14)
                    }
                    .onInc(() => {
                      if (this.cartList[index].count < this.cartList[index].stock) {
                        this.cartList[index].count = this.cartList[index].count + 1;
                        this.calculateStats();
                      }
                    })
                    .onDec(() => {
                      if (this.cartList[index].count > 1) {
                        this.cartList[index].count = this.cartList[index].count - 1;
                        this.calculateStats();
                      }
                    })
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
            }, (item: CartItem, index: number) => item.id + '_' + item.count.toString() + '_' + item.selected.toString())
          }
          .width('100%')
        }
        .layoutWeight(1)
        .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 12 })
        .backgroundColor(Constants.BACKGROUND_COLOR)
        .scrollBar(BarState.Off)

        // 底部结算栏
        Row() {
          // 全选
          Row() {
            Checkbox()
              .select(this.allSelected)
              .selectedColor(Constants.PRIMARY_COLOR)
              .onChange((value: boolean) => {
                for (let i = 0; i < this.cartList.length; i++) {
                  this.cartList[i].selected = value;
                }
                this.allSelected = value;
                this.calculateStats();
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
            Text(this.selectedTotal.toFixed(2))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Constants.PRIMARY_COLOR)
          }

          // 结算按钮
          Button('结算(' + this.selectedCount.toString() + ')')
            .height(40)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor(this.selectedCount > 0 ? Constants.PRIMARY_COLOR : '#CCCCCC')
            .borderRadius(20)
            .margin({ left: 16 })
        }
        .width('100%')
        .height(60)
        .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL })
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#1A000000', offsetY: -2 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
  }
}
