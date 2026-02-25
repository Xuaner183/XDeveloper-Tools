import { ConfigurationConstant, Configuration } from '@kit.AbilityKit';
import { UIAbilityContext } from './UIAbilityContext';
import { resourceManager } from '@kit.LocalizationKit';

@ObservedV2
export class ColorsCommon extends UIAbilityContext {

  @Trace colorMode: resourceManager.ColorMode = resourceManager.ColorMode.LIGHT;

  private applicationContext = this.uiContext.getApplicationContext();

  public setDarkMode() {
    try {
      this.applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    } catch (e) {
      console.error(`[Colors] 切换深色模式失败${JSON.stringify(e)}`)
    }
  }

  public setLightMode() {
    try {
      this.applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (e) {
      console.error(`[Colors] 切换浅色模式失败${JSON.stringify(e)}`)
    }
  }

  public async getColorMode() {
    const rM: resourceManager.ResourceManager = this.uiContext.resourceManager;
    const configuration: resourceManager.Configuration = await rM.getConfiguration();
    this.colorMode = configuration.colorMode;
  }
}