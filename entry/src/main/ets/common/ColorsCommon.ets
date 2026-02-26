import { ConfigurationConstant } from '@kit.AbilityKit';
import { UIAbilityContext, type common } from './UIAbilityContext';
import { resourceManager } from '@kit.LocalizationKit';
import { type AppInfo } from './AppInfo';
import { ResourceManager as RM } from './ResourceManager';
import { multiConvertDecimalColorToHex, ColorSysString } from './ColorArray';
import { ClientGlobalPrefKeys } from './ClientGlobalPrefKeys';
import { PreferencesControl } from './PreferencesManager';

export class ColorsCommon extends UIAbilityContext {

  private applicationContext = this.uiContext.getApplicationContext();

  public setDarkMode(): void {
    try {
      this.applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    } catch (e) {
      console.error(`[Colors] 设置深色模式失败 ${JSON.stringify(e)}`);
    }
  }

  public setLightMode(): void {
    try {
      this.applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (e) {
      console.error(`[Colors] 设置浅色模式失败 ${JSON.stringify(e)}`);
    }
  }

  public setSystemMode(): void {
    try {
      this.applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (e) {
      console.error(`[Colors] 设置跟随系统模式式失败 ${JSON.stringify(e)}`);
    }
  }

  public async getColorMode(): Promise<resourceManager.ColorMode> {
    const rM: resourceManager.ResourceManager = this.uiContext.resourceManager;
    const configuration: resourceManager.Configuration = await rM.getConfiguration();
    return configuration.colorMode;
  }
}

export class ColorsPageInit extends UIAbilityContext {
  private useAppInfo: AppInfo;
  private useRM: RM = new RM(this.uiContext);
  private usePreferencesControl: PreferencesControl = new PreferencesControl(this.uiContext);

  public async init() {
    const sysColorResHexStringPref = await this.usePreferencesControl.prefGet(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.SYS_RESOURCE_HEX_STRING, []);
    if (Array.isArray(sysColorResHexStringPref) && sysColorResHexStringPref.length >= 10 &&
    (sysColorResHexStringPref as Array<string | number | boolean | Object>)
      .every((item) => (typeof item === 'string'))) {
      this.useAppInfo.SYS_RESOURCE_HEX_STRING = sysColorResHexStringPref as string[];
      return;
    }
    let colorDecimal: number[] | null = null;
    try {
      colorDecimal = await this.useRM.getMultipleResourceColorSys(ColorSysString);
    } catch (e) {
      console.error(e);
    } finally {
      if (!colorDecimal) { console.error('[Colors] 初始化失败'); return }
      const colorHexString: string[] | null = multiConvertDecimalColorToHex(colorDecimal);
      if (colorHexString) {
        this.useAppInfo.SYS_RESOURCE_HEX_STRING = colorHexString;
        this.usePreferencesControl.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.SYS_RESOURCE_HEX_STRING, colorHexString);
        // colorHexString.forEach((v: string, index: number) => {
          // console.log(`[ColorsPageInit] ${index}: ${v}`);
        // })
      }
    }
  }

  constructor(uiContext: common.UIAbilityContext, AppInfo: AppInfo) {
    super(uiContext);
    this.useAppInfo = AppInfo;
  }
}