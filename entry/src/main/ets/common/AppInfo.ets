import { UIAbilityContext } from './UIAbilityContext';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { ClientGlobalPrefKeys, PreferencesControl, ColorModeSwitch } from './Index';
import { emitter } from '@kit.BasicServicesKit';
import { CurrentModeData } from './Index';

export enum SwitchColorModeIndex {
  Auto,
  Light,
  Dark
}

/**
   // AppStorageV2————应用全局UI状态存储
   // 使用方法：
   private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.uiContext))!;
 */

@ObservedV2
export class AppInfo extends UIAbilityContext {
  private usePreferencesControl = new PreferencesControl(this.uiContext);
  private useColorModeSwitch = new ColorModeSwitch(this.uiContext);
  // 切换颜色模式条的索引0-2
  @Trace public switchColorModeIndex: SwitchColorModeIndex = 0;
  // 应用自定义颜色模式
  @Trace public colorModeLocalInApp: ConfigurationConstant.ColorMode | undefined;
  // 系统颜色资源的HEX字符串版
  public SYS_RESOURCE_HEX_STRING?: Array<string>;

  @Trace public modalOpen: boolean[] = [];

  /**
   * 切换颜色模式条的控制器
   */
  public switchColorModeIndexManager(index: number) {
    const prefPutManager = (colorMode: ConfigurationConstant.ColorMode) => {
      this.usePreferencesControl.prefPut(
        ClientGlobalPrefKeys.PREF_NAME,
        ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_APP,
        colorMode
      );
    }
    switch (index) {
      // 跟随系统
      case SwitchColorModeIndex.Auto:
        this.useColorModeSwitch.setFollowSystem();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        return this.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
      // 设置浅色
      case SwitchColorModeIndex.Light:
        this.useColorModeSwitch.setLight();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        return this.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      // 设置深色
      case SwitchColorModeIndex.Dark:
        this.useColorModeSwitch.setDark();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        return this.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      // 兜底
      default:
        this.useColorModeSwitch.setFollowSystem();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
        return this.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    }
  }

  /**
   * 监听应用颜色变化（防止跟随系统颜色模式，但应用不知道）
   */
  public listenAppColorModeChange() {
    const event: emitter.InnerEvent = {
      eventId: 1001, // 深浅色变化事件
    };
    emitter.on(event, (eventData: emitter.EventData) => {
      const data = eventData.data;
      console.info(`[Colors] 接收颜色模式事件: ${JSON.stringify(data)}`);
      if (data) {
        this.colorModeLocalInApp = (data as CurrentModeData).themeMode;
      }
    })
  }
}