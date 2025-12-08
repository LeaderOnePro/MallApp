import { Constants } from '../common/constants/Constants';
import { UserInfo, LoginParams } from '../models/UserModel';
import httpUtil, { ApiResponse } from '../common/utils/HttpUtil';
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMsg: string = '';

  // 获取Preferences实例
  private async getPreferences(): Promise<preferences.Preferences> {
    const context = getContext(this) as common.UIAbilityContext;
    return preferences.getPreferencesSync(context, { name: 'mall_app_prefs' });
  }

  // 保存用户信息到本地
  private async saveUserInfo(userInfo: UserInfo): Promise<void> {
    try {
      const prefs = await this.getPreferences();
      prefs.putSync(Constants.USER_TOKEN, userInfo.token);
      prefs.putSync(Constants.USER_INFO, JSON.stringify(userInfo));
      await prefs.flush();
    } catch (error) {
      console.error('保存用户信息失败:', JSON.stringify(error));
    }
  }

  // 登录方法
  private async handleLogin(): Promise<void> {
    // 验证输入
    if (!this.account.trim()) {
      this.errorMsg = '请输入账号';
      return;
    }
    if (!this.password.trim()) {
      this.errorMsg = '请输入密码';
      return;
    }

    this.isLoading = true;
    this.errorMsg = '';

    try {
      const loginParams: LoginParams = {
        account: this.account,
        password: this.password
      };

      const response = await httpUtil.post<UserInfo>(
        `${Constants.API_BASE_URL}/login`,
        loginParams
      );

      if (response.code === '1') {
        // 登录成功，保存用户信息
        await this.saveUserInfo(response.result);
        // 跳转到主页
        router.pushUrl({
          url: 'pages/Index'
        });
      } else {
        this.errorMsg = response.msg || '登录失败';
      }
    } catch (error) {
      console.error('登录请求失败:', JSON.stringify(error));
      this.errorMsg = '网络请求失败，请检查网络';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部Logo区域
      Column() {
        Image($r('app.media.startIcon'))
          .width(80)
          .height(80)
          .margin({ top: 80 })

        Text('美蔻商城')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Constants.TEXT_PRIMARY)
          .margin({ top: 16 })

        Text('品质生活，从这里开始')
          .fontSize(14)
          .fontColor(Constants.TEXT_HINT)
          .margin({ top: 8 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 登录表单区域
      Column() {
        // 账号输入框
        Column() {
          Text('账号')
            .fontSize(14)
            .fontColor(Constants.TEXT_SECONDARY)
            .width('100%')

          TextInput({ placeholder: '请输入账号', text: this.account })
            .height(48)
            .width('100%')
            .fontSize(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .margin({ top: 8 })
            .onChange((value: string) => {
              this.account = value;
              this.errorMsg = '';
            })
        }
        .width('100%')
        .margin({ top: 40 })

        // 密码输入框
        Column() {
          Text('密码')
            .fontSize(14)
            .fontColor(Constants.TEXT_SECONDARY)
            .width('100%')

          TextInput({ placeholder: '请输入密码', text: this.password })
            .height(48)
            .width('100%')
            .fontSize(16)
            .type(InputType.Password)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 16, right: 16 })
            .margin({ top: 8 })
            .onChange((value: string) => {
              this.password = value;
              this.errorMsg = '';
            })
        }
        .width('100%')
        .margin({ top: 20 })

        // 错误提示
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#FF4D4F')
            .width('100%')
            .margin({ top: 12 })
        }

        // 登录按钮
        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(Constants.PRIMARY_COLOR)
          .borderRadius(24)
          .margin({ top: 32 })
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin();
          })

        // 测试账号提示
        Text('测试账号: zhousg / 123456')
          .fontSize(12)
          .fontColor(Constants.TEXT_HINT)
          .margin({ top: 16 })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })

      // 底部区域
      Blank()

      Row() {
        Text('登录即表示同意')
          .fontSize(12)
          .fontColor(Constants.TEXT_HINT)
        Text('《用户协议》')
          .fontSize(12)
          .fontColor(Constants.PRIMARY_COLOR)
        Text('和')
          .fontSize(12)
          .fontColor(Constants.TEXT_HINT)
        Text('《隐私政策》')
          .fontSize(12)
          .fontColor(Constants.PRIMARY_COLOR)
      }
      .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
