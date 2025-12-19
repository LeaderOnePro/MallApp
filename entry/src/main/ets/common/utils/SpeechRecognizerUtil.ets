// 语音识别工具类
// 使用Core Speech Kit实现语音转文字功能

import { speechRecognizer } from '@kit.CoreSpeechKit';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 语音识别回调接口
export interface SpeechRecognitionCallback {
  onResult: (text: string) => void;
  onError: (error: string) => void;
  onStart?: () => void;
  onEnd?: () => void;
}

export class SpeechRecognizerUtil {
  private static instance: SpeechRecognizerUtil;
  private asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null;
  private sessionId: string = '';
  private isListening: boolean = false;
  private callback: SpeechRecognitionCallback | null = null;

  private constructor() {}

  public static getInstance(): SpeechRecognizerUtil {
    if (!SpeechRecognizerUtil.instance) {
      SpeechRecognizerUtil.instance = new SpeechRecognizerUtil();
    }
    return SpeechRecognizerUtil.instance;
  }

  // 检查麦克风权限
  public async checkPermission(context: Context): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.MICROPHONE'];
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

  // 请求麦克风权限
  public async requestPermission(context: Context): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.MICROPHONE'];
    const atManager = abilityAccessCtrl.createAtManager();

    try {
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      return result.authResults.every(status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
    } catch (error) {
      console.error('请求权限失败:', JSON.stringify(error));
      return false;
    }
  }

  // 初始化语音识别引擎
  private async initEngine(): Promise<boolean> {
    if (this.asrEngine) {
      return true;
    }

    try {
      // 创建引擎参数
      const extraParams: Record<string, Object> = {
        "locate": "CN",
        "recognizerMode": "short"
      };

      const initParams: speechRecognizer.CreateEngineParams = {
        language: 'zh-CN',
        online: 1, // 离线模式
        extraParams: extraParams
      };

      // 创建引擎
      this.asrEngine = await speechRecognizer.createEngine(initParams);

      // 设置回调
      this.setCallback();

      console.info('语音识别引擎初始化成功');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`语音识别引擎初始化失败: ${err.code} - ${err.message}`);
      return false;
    }
  }

  // 设置识别回调
  private setCallback(): void {
    if (!this.asrEngine) return;

    const listener: speechRecognizer.RecognitionListener = {
      onStart: (sessionId: string, eventMessage: string) => {
        this.sessionId = sessionId;
        console.info(`语音识别开始: ${sessionId}`);
        if (this.callback?.onStart) {
          this.callback.onStart();
        }
      },

      onEvent: (sessionId: string, eventCode: number, eventMessage: string) => {
        console.info(`语音识别事件: ${eventCode} - ${eventMessage}`);
      },

      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        console.info(`语音识别结果: ${JSON.stringify(result)}`);
        if (result.isFinal && result.result) {
          if (this.callback) {
            this.callback.onResult(result.result);
          }
        }
      },

      onComplete: (sessionId: string, eventMessage: string) => {
        console.info(`语音识别完成: ${eventMessage}`);
        this.isListening = false;
        if (this.callback?.onEnd) {
          this.callback.onEnd();
        }
      },

      onError: (sessionId: string, errorCode: number, errorMessage: string) => {
        console.error(`语音识别错误: ${errorCode} - ${errorMessage}`);
        this.isListening = false;
        if (this.callback) {
          this.callback.onError(`识别失败(${errorCode}): ${errorMessage}`);
        }
        if (this.callback?.onEnd) {
          this.callback.onEnd();
        }
      }
    };

    this.asrEngine.setListener(listener);
  }

  // 开始语音识别
  public async startListening(context: Context, callback: SpeechRecognitionCallback): Promise<boolean> {
    this.callback = callback;

    // 检查权限
    let hasPermission = await this.checkPermission(context);
    if (!hasPermission) {
      hasPermission = await this.requestPermission(context);
      if (!hasPermission) {
        callback.onError('麦克风权限被拒绝');
        return false;
      }
    }

    // 初始化引擎
    const initialized = await this.initEngine();
    if (!initialized) {
      callback.onError('语音识别引擎初始化失败');
      return false;
    }

    if (this.isListening) {
      return true;
    }

    try {
      // 识别参数
      const extraParams: Record<string, Object> = {
        "vadBegin": 2000,
        "vadEnd": 3000,
        "maxAudioDuration": 20000
      };

      const recognizerParams: speechRecognizer.StartParams = {
        sessionId: this.sessionId || Date.now().toString(),
        audioInfo: {
          audioType: 'pcm',
          sampleRate: 16000,
          soundChannel: 1,
          sampleBit: 16
        },
        extraParams: extraParams
      };

      // 开始识别
      this.asrEngine?.startListening(recognizerParams);
      this.isListening = true;

      console.info('开始语音识别');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`开始语音识别失败: ${err.code} - ${err.message}`);
      callback.onError(`开始识别失败: ${err.message}`);
      return false;
    }
  }

  // 停止语音识别
  public stopListening(): void {
    if (!this.isListening || !this.asrEngine) {
      return;
    }

    try {
      this.asrEngine.finish(this.sessionId);
      this.isListening = false;
      console.info('停止语音识别');
    } catch (error) {
      console.error('停止语音识别失败:', JSON.stringify(error));
    }
  }

  // 取消语音识别
  public cancel(): void {
    if (!this.asrEngine) {
      return;
    }

    try {
      this.asrEngine.cancel(this.sessionId);
      this.isListening = false;
      console.info('取消语音识别');
    } catch (error) {
      console.error('取消语音识别失败:', JSON.stringify(error));
    }
  }

  // 释放资源
  public release(): void {
    if (this.asrEngine) {
      try {
        this.asrEngine.shutdown();
        this.asrEngine = null;
        this.isListening = false;
        console.info('语音识别引擎已释放');
      } catch (error) {
        console.error('释放语音识别引擎失败:', JSON.stringify(error));
      }
    }
  }

  // 是否正在识别
  public isRecording(): boolean {
    return this.isListening;
  }
}

export default SpeechRecognizerUtil.getInstance();
