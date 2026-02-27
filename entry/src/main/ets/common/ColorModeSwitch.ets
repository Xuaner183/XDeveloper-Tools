import { ConfigurationConstant } from '@kit.AbilityKit';
import { UIAbilityContext } from './UIAbilityContext';

export class ColorModeSwitch extends UIAbilityContext {
  /**
   * 切换深色模式
   */
  public setDark() {
    try {
      this.uiContext.getApplicationContext().setColorMode(
        ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      );
    } catch (e) {
      console.error(`[ColorModeSwitch] setDark错误：${(e as BusinessError).message} code: ${(e as BusinessError).code}`)
    }
  }
  /**
   * 切换浅色模式
   */
  public setLight() {
    try {
      this.uiContext.getApplicationContext().setColorMode(
        ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      );
    } catch (e) {
      console.error(`[ColorModeSwitch] setLight错误：${(e as BusinessError).message} code: ${(e as BusinessError).code}`)
    }
  }
  /**
   * 切换跟随系统
   */
  public setFollowSystem() {
    try {
      this.uiContext.getApplicationContext().setColorMode(
        ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
      );
    } catch (e) {
      console.error(`[ColorModeSwitch] setFollowSystem错误：${(e as BusinessError).message} code: ${(e as BusinessError).code}`)
    }
  }

  public getColorMode() {
    this.uiContext.getApplicationContext()
  }
}