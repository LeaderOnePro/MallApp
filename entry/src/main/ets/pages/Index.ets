import { Constants } from '../common/constants/Constants';
import { BreakpointTypeEnum } from '../common/constants/Constants';
import { display } from '@kit.ArkUI';
import { HomePage } from './Home/HomePage';
import { CategoryPage } from './Category/CategoryPage';
import { CartPage } from './Cart/CartPage';

// Tab项数据
interface TabItem {
  title: string;
  icon: string;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.SM;

  // Tab配置 - 使用Unicode符号作为图标
  private tabList: TabItem[] = [
    { title: '首页', icon: '🏠' },
    { title: '分类', icon: '📋' },
    { title: '购物车', icon: '🛒' },
    { title: '我的', icon: '👤' }
  ];

  // 更新断点
  private updateBreakpoint(windowWidth: number): void {
    if (windowWidth < 600) {
      this.currentBreakpoint = BreakpointTypeEnum.SM;
    } else if (windowWidth < 840) {
      this.currentBreakpoint = BreakpointTypeEnum.MD;
    } else {
      this.currentBreakpoint = BreakpointTypeEnum.LG;
    }
  }

  aboutToAppear(): void {
    // 获取窗口宽度并设置断点
    try {
      const displayInfo = display.getDefaultDisplaySync();
      const widthVp = displayInfo.width / displayInfo.densityDPI * 160;
      this.updateBreakpoint(widthVp);
    } catch (error) {
      console.error('获取显示信息失败:', JSON.stringify(error));
    }
  }

  // 构建Tab按钮
  @Builder
  TabBuilder(index: number) {
    Column() {
      Text(this.tabList[index].icon)
        .fontSize(22)

      Text(this.tabList[index].title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? Constants.PRIMARY_COLOR : Constants.TEXT_HINT)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }



  // 我的内容
  @Builder
  ProfileContent() {
    Column() {
      Text('我的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('个人中心开发中...')
        .fontSize(14)
        .fontColor(Constants.TEXT_HINT)
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
  }

  build() {
    Column() {
      // 根据断点类型决定布局
      if (this.currentBreakpoint === BreakpointTypeEnum.LG) {
        // 平板布局：左侧导航
        Row() {
          // 左侧导航栏
          Column() {
            ForEach(this.tabList, (item: TabItem, index: number) => {
              Column() {
                Text(item.icon)
                  .fontSize(24)

                Text(item.title)
                  .fontSize(12)
                  .fontColor(this.currentIndex === index ? Constants.PRIMARY_COLOR : Constants.TEXT_HINT)
                  .margin({ top: 6 })
              }
              .width('100%')
              .padding({ top: 20, bottom: 20 })
              .backgroundColor(this.currentIndex === index ? '#FFF1F0' : Color.Transparent)
              .onClick(() => {
                this.currentIndex = index;
              })
            })

            Blank()
          }
          .width(80)
          .height('100%')
          .backgroundColor(Color.White)

          // 右侧内容区域
          Column() {
            if (this.currentIndex === 0) {
              HomePage()
            } else if (this.currentIndex === 1) {
              CategoryPage()
            } else if (this.currentIndex === 2) {
              CartPage()
            } else {
              this.ProfileContent()
            }
          }
          .layoutWeight(1)
          .height('100%')
        }
        .width('100%')
        .height('100%')
      } else {
        // 手机/折叠屏布局：底部导航
        Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
          TabContent() {
            HomePage()
          }
          .tabBar(this.TabBuilder(0))

          TabContent() {
            CategoryPage()
          }
          .tabBar(this.TabBuilder(1))

          TabContent() {
            CartPage()
          }
          .tabBar(this.TabBuilder(2))

          TabContent() {
            this.ProfileContent()
          }
          .tabBar(this.TabBuilder(3))
        }
        .scrollable(false)
        .barHeight(56)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}