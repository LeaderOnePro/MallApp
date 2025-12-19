import { Constants } from '../../common/constants/Constants';
import httpUtil from '../../common/utils/HttpUtil';
import { GoodsItem } from '../../models/HomeModel';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import speechRecognizerUtil, { SpeechRecognitionCallback } from '../../common/utils/SpeechRecognizerUtil';
import imageRecognitionUtil, { ImageRecognitionCallback } from '../../common/utils/ImageRecognitionUtil';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SearchPage {
  @State searchKeyword: string = '';
  @State searchResults: GoodsItem[] = [];
  @State isSearching: boolean = false;
  @State hasSearched: boolean = false;
  @State searchHistory: string[] = [];

  // 语音识别相关状态
  @State isRecording: boolean = false;
  // 图像识别相关状态
  @State isImageRecognizing: boolean = false;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    // 可以从本地存储加载搜索历史
  }

  // 执行搜索
  private async doSearch(): Promise<void> {
    if (!this.searchKeyword.trim()) {
      return;
    }

    this.isSearching = true;
    this.hasSearched = true;

    // 添加到搜索历史
    if (!this.searchHistory.includes(this.searchKeyword)) {
      this.searchHistory = [this.searchKeyword, ...this.searchHistory.slice(0, 9)];
    }

    try {
      // 搜索商品API
      const response = await httpUtil.get<GoodsItem[]>(
        `${Constants.API_BASE_URL}/home/goods?keyword=${encodeURIComponent(this.searchKeyword)}`
      );
      if (response.code === '1' && response.result) {
        this.searchResults = response.result;
      } else {
        this.searchResults = [];
      }
    } catch (error) {
      console.error('搜索失败:', JSON.stringify(error));
      this.searchResults = [];
    } finally {
      this.isSearching = false;
    }
  }

  // 清空搜索历史
  private clearHistory(): void {
    this.searchHistory = [];
  }

  // 返回上一页
  private goBack(): void {
    router.back();
  }

  // 切换语音识别
  private async toggleVoiceRecognition(): Promise<void> {
    if (this.isRecording) {
      // 停止录音
      speechRecognizerUtil.stopListening();
      this.isRecording = false;
    } else {
      // 开始录音
      const callback: SpeechRecognitionCallback = {
        onResult: (text: string) => {
          this.searchKeyword = text;
          promptAction.showToast({ message: `识别结果: ${text}` });
          // 自动执行搜索
          this.doSearch();
        },
        onError: (error: string) => {
          promptAction.showToast({ message: error });
        },
        onStart: () => {
          this.isRecording = true;
          promptAction.showToast({ message: '请开始说话...' });
        },
        onEnd: () => {
          this.isRecording = false;
        }
      };

      const success = await speechRecognizerUtil.startListening(this.context, callback);
      if (!success) {
        this.isRecording = false;
      }
    }
  }

  // 显示图片选择对话框
  private showImagePickerDialog(): void {
    promptAction.showActionMenu({
      title: '选择图片来源',
      buttons: [
        { text: '拍照', color: Constants.PRIMARY_COLOR },
        { text: '从相册选择', color: Constants.TEXT_PRIMARY }
      ]
    }).then(async (result) => {
      if (result.index === 0) {
        // 拍照
        await this.pickAndRecognize('camera');
      } else if (result.index === 1) {
        // 相册
        await this.pickAndRecognize('gallery');
      }
    }).catch((error: Error) => {
      console.info('用户取消选择');
    });
  }

  // 选择图片并识别
  private async pickAndRecognize(source: 'camera' | 'gallery'): Promise<void> {
    this.isImageRecognizing = true;
    promptAction.showToast({ message: '正在获取图片...' });

    try {
      let imageUri: string | null = null;

      if (source === 'camera') {
        imageUri = await imageRecognitionUtil.pickFromCamera(this.context);
      } else {
        imageUri = await imageRecognitionUtil.pickFromGallery(this.context);
      }

      if (!imageUri) {
        this.isImageRecognizing = false;
        return;
      }

      promptAction.showToast({ message: '正在识别图片文字...' });

      // 识别图片文字
      const callback: ImageRecognitionCallback = {
        onResult: (text: string) => {
          this.searchKeyword = text;
          this.isImageRecognizing = false;
          promptAction.showToast({ message: `识别结果: ${text}` });
          // 自动执行搜索
          this.doSearch();
        },
        onError: (error: string) => {
          this.isImageRecognizing = false;
          promptAction.showToast({ message: error });
        }
      };

      await imageRecognitionUtil.recognizeText(imageUri, callback);
    } catch (error) {
      this.isImageRecognizing = false;
      promptAction.showToast({ message: '图片识别失败' });
    }
  }

  // 搜索栏
  @Builder
  SearchHeader() {
    Row() {
      // 返回按钮
      Text('←')
        .fontSize(24)
        .fontColor(Constants.TEXT_PRIMARY)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.goBack();
        })

      // 搜索输入框
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12 })

        TextInput({ placeholder: '搜索商品', text: this.searchKeyword })
          .layoutWeight(1)
          .height(36)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.doSearch();
          })
      }
      .layoutWeight(1)
      .height(40)
      .backgroundColor('#F5F5F5')
      .borderRadius(20)

      // 语音按钮
      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(20)
          .height(20)
          .fillColor(this.isRecording ? '#FF4444' : Constants.TEXT_SECONDARY)
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 8 })
      .backgroundColor(this.isRecording ? '#FFEBEE' : '#F5F5F5')
      .borderRadius(18)
      .onClick(() => {
        this.toggleVoiceRecognition();
      })

      // 拍照识图按钮
      Row() {
        if (this.isImageRecognizing) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(Constants.PRIMARY_COLOR)
        } else {
          Image($r('sys.media.ohos_ic_public_scan'))
            .width(20)
            .height(20)
            .fillColor(Constants.TEXT_SECONDARY)
        }
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 4 })
      .backgroundColor('#F5F5F5')
      .borderRadius(18)
      .onClick(() => {
        if (!this.isImageRecognizing) {
          this.showImagePickerDialog();
        }
      })

      // 搜索按钮
      Text('搜索')
        .fontSize(14)
        .fontColor(Constants.PRIMARY_COLOR)
        .margin({ left: 8 })
        .onClick(() => {
          this.doSearch();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 16 })
    .backgroundColor(Color.White)
  }

  // 搜索历史
  @Builder
  SearchHistory() {
    Column() {
      Row() {
        Text('搜索历史')
          .fontSize(14)
          .fontColor(Constants.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('清空')
          .fontSize(12)
          .fontColor(Constants.TEXT_HINT)
          .onClick(() => {
            this.clearHistory();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.searchHistory, (keyword: string) => {
          Text(keyword)
            .fontSize(13)
            .fontColor(Constants.TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#F5F5F5')
            .borderRadius(14)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.searchKeyword = keyword;
              this.doSearch();
            })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ top: 12 })
    .borderRadius(Constants.BORDER_RADIUS)
  }

  // 热门搜索
  @Builder
  HotSearch() {
    Column() {
      Text('热门搜索')
        .fontSize(14)
        .fontColor(Constants.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(['手机', '电脑', '耳机', '平板', '智能手表', '键盘', '鼠标', '显示器'], (keyword: string) => {
          Text(keyword)
            .fontSize(13)
            .fontColor(Constants.TEXT_SECONDARY)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#F5F5F5')
            .borderRadius(14)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.searchKeyword = keyword;
              this.doSearch();
            })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ top: 12 })
    .borderRadius(Constants.BORDER_RADIUS)
  }

  // 搜索结果
  @Builder
  SearchResults() {
    if (this.searchResults.length === 0) {
      // 无结果
      Column() {
        Text('😔')
          .fontSize(48)
          .margin({ top: 60 })

        Text('未找到相关商品')
          .fontSize(14)
          .fontColor(Constants.TEXT_HINT)
          .margin({ top: 16 })

        Text('换个关键词试试吧~')
          .fontSize(12)
          .fontColor(Constants.TEXT_HINT)
          .margin({ top: 8 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    } else {
      // 结果列表
      List() {
        ForEach(this.searchResults, (item: GoodsItem) => {
          ListItem() {
            Row() {
              Image(item.picture)
                .width(100)
                .height(100)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)

              Column() {
                Text(item.name)
                  .fontSize(14)
                  .fontColor(Constants.TEXT_PRIMARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(item.desc)
                  .fontSize(12)
                  .fontColor(Constants.TEXT_HINT)
                  .margin({ top: 6 })
                  .maxLines(1)

                Row() {
                  Text('¥')
                    .fontSize(12)
                    .fontColor(Constants.PRIMARY_COLOR)
                  Text(item.price)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Constants.PRIMARY_COLOR)
                }
                .margin({ top: 8 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(Constants.BORDER_RADIUS)
          }
          .margin({ bottom: 12 })
        }, (item: GoodsItem) => item.id)
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  build() {
    Column() {
      // 搜索栏
      this.SearchHeader()

      if (!this.hasSearched) {
        // 未搜索时显示历史和热门
        Scroll() {
          Column() {
            if (this.searchHistory.length > 0) {
              this.SearchHistory()
            }
            this.HotSearch()
          }
          .width('100%')
        }
        .layoutWeight(1)
        .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL })
      } else {
        // 搜索结果
        Column() {
          if (this.isSearching) {
            LoadingProgress()
              .width(40)
              .height(40)
              .margin({ top: 60 })
          } else {
            this.SearchResults()
          }
        }
        .layoutWeight(1)
        .padding({ left: Constants.PADDING_NORMAL, right: Constants.PADDING_NORMAL, top: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
  }
}
