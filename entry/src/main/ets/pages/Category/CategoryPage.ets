import { Constants } from '../../common/constants/Constants';
import httpUtil from '../../common/utils/HttpUtil';
import { MainCategory, SubCategoryItem } from '../../models/CategoryModel';
import { GoodsItem } from '../../models/HomeModel';
import { GoodsCard } from '../../components/GoodsCard';

@Component
export struct CategoryPage {
  @State categoryList: MainCategory[] = [];
  @State currentCategoryIndex: number = 0;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadCategories();
  }

  // 加载分类数据
  private async loadCategories(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await httpUtil.get<MainCategory[]>(`${Constants.API_BASE_URL}/home/category/head`);
      if (response.code === '1' && response.result) {
        this.categoryList = response.result;
      }
    } catch (error) {
      console.error('加载分类失败:', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  // 获取当前选中分类
  private getCurrentCategory(): MainCategory | null {
    if (this.categoryList.length > this.currentCategoryIndex) {
      return this.categoryList[this.currentCategoryIndex];
    }
    return null;
  }

  // 左侧分类列表
  @Builder
  LeftCategoryList() {
    List() {
      ForEach(this.categoryList, (item: MainCategory, index: number) => {
        ListItem() {
          Row() {
            // 选中指示器
            if (this.currentCategoryIndex === index) {
              Column()
                .width(3)
                .height(20)
                .backgroundColor(Constants.PRIMARY_COLOR)
                .borderRadius(2)
            }

            Text(item.name)
              .fontSize(14)
              .fontColor(this.currentCategoryIndex === index ? Constants.PRIMARY_COLOR : Constants.TEXT_PRIMARY)
              .fontWeight(this.currentCategoryIndex === index ? FontWeight.Medium : FontWeight.Normal)
              .margin({ left: this.currentCategoryIndex === index ? 8 : 11 })
          }
          .width('100%')
          .height(50)
          .alignItems(VerticalAlign.Center)
          .backgroundColor(this.currentCategoryIndex === index ? Color.White : '#F5F5F5')
          .onClick(() => {
            this.currentCategoryIndex = index;
          })
        }
      })
    }
    .width(100)
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 右侧分类内容
  @Builder
  RightContent() {
    Scroll() {
      Column() {
        // 二级分类展示
        if (this.getCurrentCategory()?.children && this.getCurrentCategory()!.children.length > 0) {
          // 分类标题
          Row() {
            Text('全部分类')
              .fontSize(14)
              .fontColor(Constants.TEXT_SECONDARY)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 16, bottom: 12 })

          // 二级分类网格
          Grid() {
            ForEach(this.getCurrentCategory()!.children, (item: SubCategoryItem) => {
              GridItem() {
                Column() {
                  Image(item.picture)
                    .width(60)
                    .height(60)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)

                  Text(item.name)
                    .fontSize(12)
                    .fontColor(Constants.TEXT_PRIMARY)
                    .margin({ top: 8 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Center)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsGap(16)
          .columnsGap(8)
          .padding({ left: 12, right: 12 })
        }

        // 分类商品展示
        if (this.getCurrentCategory()?.goods && this.getCurrentCategory()!.goods.length > 0) {
          // 商品标题
          Row() {
            Text('热门推荐')
              .fontSize(14)
              .fontColor(Constants.TEXT_SECONDARY)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 20, bottom: 12 })

          // 商品网格
          Grid() {
            ForEach(this.getCurrentCategory()!.goods, (item: GoodsItem) => {
              GridItem() {
                GoodsCard({ goods: item })
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .padding({ left: 12, right: 12 })
        }

        // 底部留白
        Column()
          .height(20)
      }
      .width('100%')
    }
    .layoutWeight(1)
    .height('100%')
    .backgroundColor(Color.White)
    .scrollBar(BarState.Off)
  }

  build() {
    Row() {
      // 左侧分类导航
      this.LeftCategoryList()

      // 右侧内容区域
      this.RightContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
  }
}
