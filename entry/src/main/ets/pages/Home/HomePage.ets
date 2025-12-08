import { Constants, BreakpointTypeEnum } from '../../common/constants/Constants';
import httpUtil from '../../common/utils/HttpUtil';
import { BannerItem, CategoryItem, GoodsItem } from '../../models/HomeModel';
import { SearchBar } from '../../components/SearchBar';
import { GoodsCard } from '../../components/GoodsCard';
import { router, display } from '@kit.ArkUI';

@Component
export struct HomePage {
  @State bannerList: BannerItem[] = [];
  @State categoryList: CategoryItem[] = [];
  @State hotGoods: GoodsItem[] = [];
  @State newGoods: GoodsItem[] = [];
  @State isLoading: boolean = true;
  @State currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.SM;

  aboutToAppear(): void {
    this.loadHomeData();
    this.updateBreakpoint();
  }

  // 更新断点
  private updateBreakpoint(): void {
    try {
      const screenInfo = display.getDefaultDisplaySync();
      const widthVp = screenInfo.width / screenInfo.densityPixels;
      if (widthVp >= 840) {
        this.currentBreakpoint = BreakpointTypeEnum.LG;
      } else if (widthVp >= 600) {
        this.currentBreakpoint = BreakpointTypeEnum.MD;
      } else {
        this.currentBreakpoint = BreakpointTypeEnum.SM;
      }
    } catch (e) {
      console.error('获取屏幕信息失败');
    }
  }

  // 获取网格列数模板
  private getGridColumns(): string {
    if (this.currentBreakpoint === BreakpointTypeEnum.LG) {
      return '1fr 1fr 1fr 1fr';
    } else if (this.currentBreakpoint === BreakpointTypeEnum.MD) {
      return '1fr 1fr 1fr';
    } else {
      return '1fr 1fr';
    }
  }

  // 加载首页数据
  private async loadHomeData(): Promise<void> {
    this.isLoading = true;
    try {
      // 并行请求所有数据
      await Promise.all([
        this.loadBanner(),
        this.loadCategories(),
        this.loadHotGoods(),
        this.loadNewGoods()
      ]);
    } catch (error) {
      console.error('加载首页数据失败:', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  // 加载Banner
  private async loadBanner(): Promise<void> {
    try {
      const response = await httpUtil.get<BannerItem[]>(`${Constants.API_BASE_URL}/home/banner`);
      if (response.code === '1' && response.result) {
        this.bannerList = response.result;
      }
    } catch (error) {
      console.error('加载Banner失败:', JSON.stringify(error));
    }
  }

  // 加载分类
  private async loadCategories(): Promise<void> {
    try {
      const response = await httpUtil.get<CategoryItem[]>(`${Constants.API_BASE_URL}/home/category/head`);
      if (response.code === '1' && response.result) {
        this.categoryList = response.result.slice(0, 10); // 只取前10个分类
      }
    } catch (error) {
      console.error('加载分类失败:', JSON.stringify(error));
    }
  }

  // 加载爆款推荐
  private async loadHotGoods(): Promise<void> {
    try {
      const response = await httpUtil.get<GoodsItem[]>(`${Constants.API_BASE_URL}/home/hot`);
      if (response.code === '1' && response.result) {
        this.hotGoods = response.result;
      }
    } catch (error) {
      console.error('加载爆款推荐失败:', JSON.stringify(error));
    }
  }

  // 加载新鲜好物
  private async loadNewGoods(): Promise<void> {
    try {
      const response = await httpUtil.get<GoodsItem[]>(`${Constants.API_BASE_URL}/home/new`);
      if (response.code === '1' && response.result) {
        this.newGoods = response.result;
      }
    } catch (error) {
      console.error('加载新鲜好物失败:', JSON.stringify(error));
    }
  }

  // Banner构建器
  @Builder
  BannerSection() {
    if (this.bannerList.length > 0) {
      Swiper() {
        ForEach(this.bannerList, (item: BannerItem) => {
          Image(item.imgUrl)
            .width('100%')
            .height(180)
            .borderRadius(Constants.BORDER_RADIUS)
            .objectFit(ImageFit.Cover)
        })
      }
      .autoPlay(true)
      .interval(3000)
      .indicator(Indicator.dot()
        .color('#CCCCCC')
        .selectedColor(Constants.PRIMARY_COLOR))
      .margin({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 12 })
    }
  }

  // 分类网格构建器
  @Builder
  CategorySection() {
    if (this.categoryList.length > 0) {
      Column() {
        Grid() {
          ForEach(this.categoryList, (item: CategoryItem) => {
            GridItem() {
              Column() {
                Image(item.picture)
                  .width(48)
                  .height(48)
                  .borderRadius(24)
                  .objectFit(ImageFit.Cover)

                Text(item.name)
                  .fontSize(12)
                  .fontColor(Constants.TEXT_PRIMARY)
                  .margin({ top: 6 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
        .rowsGap(16)
        .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 16, bottom: 16 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(Constants.BORDER_RADIUS)
      .margin({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 12 })
    }
  }

  // 商品区块标题构建器
  @Builder
  SectionTitle(title: string, subtitle: string) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Constants.TEXT_PRIMARY)

      Text(subtitle)
        .fontSize(12)
        .fontColor(Constants.TEXT_HINT)
        .margin({ left: 8 })

      Blank()

      Text('查看更多 >')
        .fontSize(12)
        .fontColor(Constants.TEXT_HINT)
    }
    .width('100%')
    .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL })
    .margin({ top: 20

, bottom: 12 })
  }

  // 商品网格构建器
  @Builder
  GoodsGrid(goodsList: GoodsItem[]) {
    Grid() {
      ForEach(goodsList, (item: GoodsItem) => {
        GridItem() {
          GoodsCard({ goods: item })
        }
      })
    }
    .columnsTemplate(this.getGridColumns())
    .columnsGap(12)
    .rowsGap(12)
    .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL })
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        SearchBar({
          placeholder: '搜索商品',
          clickable: true,
          onSearchClick: () => {
            router.pushUrl({ url: 'pages/Search/SearchPage' });
          }
        })
      }
      .width('100%')
      .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 12 })

      // 可滚动内容区域
      Scroll() {
        Column() {
          // Banner轮播
          this.BannerSection()

          // 分类导航
          this.CategorySection()

          // 爆款推荐
          if (this.hotGoods.length > 0) {
            this.SectionTitle('爆款推荐', '人气热卖榜单')
            this.GoodsGrid(this.hotGoods.slice(0, 4))
          }

          // 新鲜好物
          if (this.newGoods.length > 0) {
            this.SectionTitle('新鲜好物', '新品首发')
            this.GoodsGrid(this.newGoods.slice(0, 4))
          }

          // 底部留白
          Column()
            .height(20)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
  }
}
