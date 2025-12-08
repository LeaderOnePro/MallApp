import { Constants } from '../../common/constants/Constants';
import { UserInfo } from '../../models/UserModel';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

// 菜单项接口
interface MenuItem {
  icon: string;
  title: string;
  arrow: boolean;
}

@Component
export struct ProfilePage {
  @State userInfo: UserInfo | null = null;
  @State isLoggedIn: boolean = false;

  aboutToAppear(): void {
    this.loadUserInfo();
  }

  // 加载用户信息
  private async loadUserInfo(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const prefs = preferences.getPreferencesSync(context, { name: 'mall_app_prefs' });
      const userInfoStr = prefs.getSync(Constants.USER_INFO, '') as string;

      if (userInfoStr) {
        this.userInfo = JSON.parse(userInfoStr) as UserInfo;
        this.isLoggedIn = true;
      }
    } catch (error) {
      console.error('加载用户信息失败:', JSON.stringify(error));
    }
  }

  // 退出登录
  private async logout(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const prefs = preferences.getPreferencesSync(context, { name: 'mall_app_prefs' });
      prefs.deleteSync(Constants.USER_TOKEN);
      prefs.deleteSync(Constants.USER_INFO);
      await prefs.flush();

      router.replaceUrl({ url: 'pages/LoginPage' });
    } catch (error) {
      console.error('退出登录失败:', JSON.stringify(error));
    }
  }

  // 菜单列表
  private menuList: MenuItem[] = [
    { icon: '📦', title: '我的订单', arrow: true },
    { icon: '📍', title: '收货地址', arrow: true },
    { icon: '❤️', title: '我的收藏', arrow: true },
    { icon: '🎫', title: '优惠券', arrow: true },
    { icon: '⭐', title: '我的评价', arrow: true },
    { icon: '💬', title: '联系客服', arrow: true },
    { icon: '⚙️', title: '设置', arrow: true }
  ];

  // 用户头像区域
  @Builder
  UserHeader() {
    Row() {
      // 头像
      if (this.userInfo?.avatar) {
        Image(this.userInfo.avatar)
          .width(70)
          .height(70)
          .borderRadius(35)
          .objectFit(ImageFit.Cover)
      } else {
        Text('👤')
          .fontSize(40)
          .width(70)
          .height(70)
          .textAlign(TextAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(35)
      }

      // 用户信息
      Column() {
        Text(this.userInfo?.nickname || this.userInfo?.account || '用户')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        if (this.userInfo?.mobile) {
          Text(this.userInfo.mobile)
            .fontSize(14)
            .fontColor('#FFFFFFCC')
            .margin({ top: 6 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 40, bottom: 40 })
    .backgroundColor(Constants.PRIMARY_COLOR)
  }

  // 订单统计区域
  @Builder
  OrderStats() {
    Row() {
      Column() {
        Text('0')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Constants.TEXT_PRIMARY)
        Text('待付款')
          .fontSize(12)
          .fontColor(Constants.TEXT_SECONDARY)
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Column() {
        Text('0')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Constants.TEXT_PRIMARY)
        Text('待发货')
          .fontSize(12)
          .fontColor(Constants.TEXT_SECONDARY)
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Column() {
        Text('0')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Constants.TEXT_PRIMARY)
        Text('待收货')
          .fontSize(12)
          .fontColor(Constants.TEXT_SECONDARY)
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Column() {
        Text('0')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Constants.TEXT_PRIMARY)
        Text('待评价')
          .fontSize(12)
          .fontColor(Constants.TEXT_SECONDARY)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(Constants.BORDER_RADIUS)
    .margin({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: -20 })
  }

  // 菜单列表
  @Builder
  MenuList() {
    Column() {
      ForEach(this.menuList, (item: MenuItem) => {
        Row() {
          Text(item.icon)
            .fontSize(20)
            .width(30)

          Text(item.title)
            .fontSize(15)
            .fontColor(Constants.TEXT_PRIMARY)
            .margin({ left: 12 })

          Blank()

          if (item.arrow) {
            Text('>')
              .fontSize(16)
              .fontColor(Constants.TEXT_HINT)
          }
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })

        Divider()
          .color('#F0F0F0')
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(Constants.BORDER_RADIUS)
    .margin({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 16 })
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          this.UserHeader()
          this.OrderStats()
          this.MenuList()

          Button('退出登录')
            .width('90%')
            .height(44)
            .fontSize(16)
            .fontColor(Constants.PRIMARY_COLOR)
            .backgroundColor(Color.White)
            .borderRadius(22)
            .borderWidth(1)
            .borderColor(Constants.PRIMARY_COLOR)
            .margin({ top: 30, bottom: 30 })
            .onClick(() => {
              this.logout();
            })
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
