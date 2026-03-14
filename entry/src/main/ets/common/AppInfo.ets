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
// export enum RGBA {
//   red,
//   green,
//   blue,
//   alpha
// }

export enum ColorArray {
  RgbaArray,
  readableHexArray,
  HexArray,
  CmykArray,
  HslArray,
  HsvArray
}

namespace ColorType {
  export type RGBA = string;
  export type readableHEX = string;
  export type HEX  = string;
  export type CMYK = string;
  export type HSL  = string;
  export type HSV  = string;
}
type DARK   = [ColorType.RGBA[], ColorType.readableHEX[], ColorType.HEX[], ColorType.CMYK[], ColorType.HSL[], ColorType.HSV[]];
type LIGHT  = [ColorType.RGBA[], ColorType.readableHEX[], ColorType.HEX[], ColorType.CMYK[], ColorType.HSL[], ColorType.HSV[]];

export { DARK, LIGHT, ColorType }

/**
   // AppStorageV2————应用全局UI状态存储
   // 使用方法：
   import { AppStorageV2 } from '@kit.ArkUI';
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
  // 用于绑定每个色块的模态窗口状态
  @Trace public modalOpen: boolean[] = [];
  // 绑定搜索页的色块的模态窗口状态
  @Trace public searchPageModalOpen: boolean[] = [];
  // 判断颜色数组是否存在，避免重复循环
  public isLightColorFull = false;
  public isDarkColorFull = false;
  // 判断Colors页是否需要初始化
  public isLoadDown = false;
  // 所有颜色值字符串数组
  public COLOR_VALUE: [LIGHT, DARK] = [[[], [], [], [], [], []], [[], [], [], [], [], []]];
  public appName: string = 'unknown';
  public appVersion: string = 'unknown';
  public pushColorsPageTimeId: number = 0;
  public privacyPolicyUrl: string = 'https://github.com/Xuaner183/XDeveloper-Tools/blob/main/PRIVACY.md';


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
      // 跟随系统
      default:
        this.useColorModeSwitch.setFollowSystem();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        return this.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    }
  }

  /**
   * 监听应用颜色变化
   * 只有ColorMode的COLOR_MODE_LIGHT和COLOR_MODE_DARK两种值，不会返回COLOR_MODE_NOT_SET
   */
  public listenAppColorModeChange(callback: (data: CurrentModeData) => void = () => {}) {
    const event: emitter.InnerEvent = {
      eventId: 1001, // 深浅色变化事件
    };
    emitter.on(event, (eventData: emitter.EventData) => {
      const data = eventData.data;
      console.info(`[Colors] 接收颜色模式事件: ${JSON.stringify(data)}`);
      if (data) {
        this.colorModeLocalInApp = (data as CurrentModeData).themeMode;
        callback(data as CurrentModeData);
      }
    })
  }

}