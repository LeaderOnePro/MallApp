import { BreakpointTypeEnum } from '../constants/Constants';

// 断点系统，用于一多适配
@ObservedV2
export class BreakpointSystem {
  // 当前断点类型
  @Trace currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.SM;

  // 根据宽度更新断点
  updateBreakpoint(windowWidth: number): void {
    if (windowWidth < 600) {
      this.currentBreakpoint = BreakpointTypeEnum.SM;
    } else if (windowWidth < 840) {
      this.currentBreakpoint = BreakpointTypeEnum.MD;
    } else {
      this.currentBreakpoint = BreakpointTypeEnum.LG;
    }
  }

  // 判断是否为手机模式
  isPhone(): boolean {
    return this.currentBreakpoint === BreakpointTypeEnum.SM;
  }

  // 判断是否为折叠屏模式
  isFoldable(): boolean {
    return this.currentBreakpoint === BreakpointTypeEnum.MD;
  }

  // 判断是否为平板模式
  isTablet(): boolean {
    return this.currentBreakpoint === BreakpointTypeEnum.LG;
  }

  // 获取商品列表的列数
  getGoodsColumns(): number {
    switch (this.currentBreakpoint) {
      case BreakpointTypeEnum.SM:
        return 2;
      case BreakpointTypeEnum.MD:
        return 3;
      case BreakpointTypeEnum.LG:
        return 4;
      default:
        return 2;
    }
  }
}

// 全局断点系统实例
export const breakpointSystem = new BreakpointSystem();
