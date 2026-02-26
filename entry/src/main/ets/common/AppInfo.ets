import { UIAbilityContext } from './UIAbilityContext';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import map from '@hms.core.map.map';

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
  // 系统颜色资源的HEX字符串版
  public SYS_RESOURCE_HEX_STRING?: Array<string>;

  @Trace public modalOpen: boolean[] = [];

  // public setModalBoolean(index: number) {
  //   this.modalOpen[index] = false;
  // }
  //
  // @Monitor('modalOpen')
  // onStrChange(monitor: IMonitor) {
  //   monitor.value()?.now
  // }
}