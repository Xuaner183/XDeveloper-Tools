import { UIAbilityContext } from './UIAbilityContext';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';

/**
   // AppStorageV2————应用全局UI状态存储
   // 使用方法：
   private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.uiContext))!;
 */

@ObservedV2
export class AppInfo extends UIAbilityContext {
  // Colors 页的列表局部颜色模式
  @Trace public colorModeLocalInColorsPage: number = 0;
  // 应用自定义颜色模式
  @Trace public colorModeLocalInApp: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  // 系统的颜色模式
  @Trace public colorModeLocalInSys: resourceManager.ColorMode = resourceManager.ColorMode.LIGHT;
}