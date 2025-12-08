// 常量配置
export class Constants {
  // API基础地址
  static readonly API_BASE_URL: string = 'https://meikou-api.itheima.net';

  // 存储键名
  static readonly USER_TOKEN: string = 'user_token';
  static readonly USER_INFO: string = 'user_info';

  // 颜色常量
  static readonly PRIMARY_COLOR: string = '#FA5151';
  static readonly BACKGROUND_COLOR: string = '#F5F5F5';
  static readonly TEXT_PRIMARY: string = '#333333';
  static readonly TEXT_SECONDARY: string = '#666666';
  static readonly TEXT_HINT: string = '#999999';

  // 尺寸常量
  static readonly BORDER_RADIUS: number = 8;
  static readonly PADDING_NORMAL: number = 16;
  static readonly PADDING_SMALL: number = 8;
}

// 断点类型枚举
export enum BreakpointTypeEnum {
  SM = 'sm',  // 手机 <600vp
  MD = 'md',  // 折叠屏 600-840vp
  LG = 'lg'   // 平板 >840vp
}
