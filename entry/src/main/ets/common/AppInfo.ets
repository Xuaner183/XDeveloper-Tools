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
enum RGBA {
  red,
  green,
  blue,
  alpha
}

interface ColorValue {
  colorRgba: Array<RGBA>;
  colorHex: string;
  colorHSL: string;
}

interface AllColorArray {
  colorRgbaArray: Array<Array<RGBA>>;
  colorHexArray: Array<string>;
  color10Array: Array<string>;
}

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
  // 浅色模式真实颜色值RGBA
  @Trace public LIGHT_MODE_COLORS_ARRAY: Array<Array<RGBA>> = [];
  // 深色模式真实颜色值RGBA
  @Trace public DARK_MODE_COLORS_ARRAY: Array<Array<RGBA>> = [];
  // 存储各种类型颜色Map
  @Trace public ALL_COLORS: Array<AllColorArray> = [];

  @Trace public LIGHT_MODE_RGBA_ARRAY: Array<string> = [];
  @Trace public DARK_MODE_RGBA_ARRAY: Array<string> = [];
  // 判断颜色数组是否存在，避免重复循环
  public isLightColorFull = false;
  public isDarkColorFull = false;
  // 判断Colors页是否需要初始化
  public isLoadDown = false;


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

  /**
   * 检测颜色数组是否满
   */
  public isFull(isDark: boolean) {
    if (isDark && this.DARK_MODE_COLORS_ARRAY.length > 1 ||
      this.DARK_MODE_RGBA_ARRAY.length > 1) {
      return true;
    } else if (!isDark && this.LIGHT_MODE_COLORS_ARRAY.length > 1 ||
      this.LIGHT_MODE_RGBA_ARRAY.length > 1) {
      return true
    } else {
      return false;
    }
  }
}