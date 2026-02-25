import { ConfigurationConstant } from '@kit.AbilityKit';
import { UIAbilityContext } from './UIAbilityContext';
import { resourceManager } from '@kit.LocalizationKit';

@ObservedV2
export class ColorsCommon extends UIAbilityContext {

  @Trace colorMode: resourceManager.ColorMode = resourceManager.ColorMode.LIGHT;

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
    return this.colorMode = configuration.colorMode;
  }
}