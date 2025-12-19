// 图像识别工具类
// 使用Vision Kit实现图片文字识别功能

import { textRecognition } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { camera, cameraPicker } from '@kit.CameraKit';

// 图像识别回调接口
export interface ImageRecognitionCallback {
  onResult: (text: string) => void;
  onError: (error: string) => void;
}

export class ImageRecognitionUtil {
  private static instance: ImageRecognitionUtil;

  private constructor() {}

  public static getInstance(): ImageRecognitionUtil {
    if (!ImageRecognitionUtil.instance) {
      ImageRecognitionUtil.instance = new ImageRecognitionUtil();
    }
    return ImageRecognitionUtil.instance;
  }

  // 检查相机权限
  public async checkCameraPermission(): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.CAMERA'];
    return await this.checkPermissions(permissions);
  }

  // 检查媒体读取权限
  public async checkMediaPermission(): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.READ_IMAGEVIDEO'];
    return await this.checkPermissions(permissions);
  }

  // 检查权限
  private async checkPermissions(permissions: Permissions[]): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();

    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const tokenId = bundleInfo.appInfo.accessTokenId;

      for (const permission of permissions) {
        const grantStatus = atManager.checkAccessTokenSync(tokenId, permission);
        if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          return false;
        }
      }
      return true;
    } catch (error) {
      console.error('检查权限失败:', JSON.stringify(error));
      return false;
    }
  }

  // 请求相机权限
  public async requestCameraPermission(context: Context): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.CAMERA'];
    return await this.requestPermissions(context, permissions);
  }

  // 请求媒体读取权限
  public async requestMediaPermission(context: Context): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.READ_IMAGEVIDEO'];
    return await this.requestPermissions(context, permissions);
  }

  // 请求权限
  private async requestPermissions(context: Context, permissions: Permissions[]): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();

    try {
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      return result.authResults.every(status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
    } catch (error) {
      console.error('请求权限失败:', JSON.stringify(error));
      return false;
    }
  }

  // 从相机拍照获取图片
  public async pickFromCamera(context: Context): Promise<string | null> {
    try {
      // 检查权限
      let hasPermission = await this.checkCameraPermission();
      if (!hasPermission) {
        hasPermission = await this.requestCameraPermission(context);
        if (!hasPermission) {
          console.error('相机权限被拒绝');
          return null;
        }
      }

      // 配置相机选择器（使用正确的camera模块枚举）
      const pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      // 拍照
      const result = await cameraPicker.pick(context, [cameraPicker.PickerMediaType.PHOTO], pickerProfile);

      if (result && result.resultUri) {
        return result.resultUri;
      }
      return null;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`相机拍照失败: ${err.code} - ${err.message}`);
      return null;
    }
  }

  // 从相册选择图片
  public async pickFromGallery(context: Context): Promise<string | null> {
    try {
      // 创建图片选择器选项
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      // 创建图片选择器
      const photoPicker = new photoAccessHelper.PhotoViewPicker();

      // 选择图片
      const result = await photoPicker.select(photoSelectOptions);

      if (result && result.photoUris && result.photoUris.length > 0) {
        return result.photoUris[0];
      }
      return null;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`相册选择失败: ${err.code} - ${err.message}`);
      return null;
    }
  }

  // 识别图片中的文字
  public async recognizeText(imageUri: string, callback: ImageRecognitionCallback): Promise<void> {
    try {
      // 从URI加载图片
      const imageSource = image.createImageSource(imageUri);
      if (!imageSource) {
        callback.onError('无法加载图片');
        return;
      }

      // 创建PixelMap
      const pixelMap = await imageSource.createPixelMap();
      if (!pixelMap) {
        callback.onError('无法创建图片像素数据');
        return;
      }

      // 配置识别参数
      const visionInfo: textRecognition.VisionInfo = {
        pixelMap: pixelMap
      };

      const config: textRecognition.TextRecognitionConfiguration = {
        isDirectionDetectionSupported: true
      };

      // 执行文字识别
      const result = await textRecognition.recognizeText(visionInfo, config);

      // 释放资源
      pixelMap.release();
      imageSource.release();

      if (result && result.value) {
        // 提取识别到的文字
        const recognizedText = result.value;
        console.info(`识别结果: ${recognizedText}`);

        // 提取关键词（取前几个字作为搜索关键词）
        const keywords = this.extractKeywords(recognizedText);
        callback.onResult(keywords);
      } else {
        callback.onError('未识别到文字');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`文字识别失败: ${err.code} - ${err.message}`);
      callback.onError(`识别失败: ${err.message}`);
    }
  }

  // 从识别文本中提取关键词
  private extractKeywords(text: string): string {
    // 移除空白字符和特殊符号
    let cleanText = text.replace(/[\s\n\r\t]/g, ' ').trim();

    // 如果文本过长，取前20个字符
    if (cleanText.length > 20) {
      cleanText = cleanText.substring(0, 20);
    }

    // 按空格分割，取第一个有意义的词
    const words = cleanText.split(' ').filter(w => w.length > 0);

    if (words.length > 0) {
      // 返回第一个词作为搜索关键词
      return words[0];
    }

    return cleanText;
  }
}

export default ImageRecognitionUtil.getInstance();
