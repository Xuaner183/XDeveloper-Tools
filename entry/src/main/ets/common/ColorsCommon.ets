import { ConfigurationConstant } from '@kit.AbilityKit';
import { UIAbilityContext, type common } from './UIAbilityContext';
import { resourceManager } from '@kit.LocalizationKit';
import { type AppInfo } from './AppInfo';
import { ResourceManager as RM } from './ResourceManager';
import { ColorSysResourseId, multiConvertDecimalColorToHex } from './ColorArray';

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

  public async init() {
    const colorDecimal: number[] = await this.useRM.getMultipleResourceColorSys(ColorSysResourseId);
    const colorHexString: string[] | null = multiConvertDecimalColorToHex(colorDecimal);
    colorHexString && (this.useAppInfo.SYS_RESOURCE_HEX_STRING = colorHexString);
  }

  constructor(uiContext: common.UIAbilityContext, AppInfo: AppInfo) {
    super(uiContext);
    this.useAppInfo = AppInfo;
  }
}