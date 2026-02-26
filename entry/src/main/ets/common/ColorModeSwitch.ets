import { ConfigurationConstant, Ability, Configuration } from '@kit.AbilityKit';
import { UIAbilityContext } from './UIAbilityContext';

// export default class MainAbility extends Ability {
//   onCreate() {
//     this.context.config.on('configChange', (config: Configuration) => {
//       if (config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
//         // 深色模式逻辑
//       } else {
//         // 浅色模式逻辑
//       }
//     });
//   }
// }

export class ColorModeSwitch extends UIAbilityContext {
  /**
   * 切换深色模式
   */
  public setDark() {
    this.uiContext.getApplicationContext().setColorMode(
      ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    );
  }
  /**
   * 切换浅色模式
   */
  public setLight() {
    this.uiContext.getApplicationContext().setColorMode(
      ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
    );
  }
  /**
   * 切换跟随系统
   */
  public setFollowSystem() {
    this.uiContext.getApplicationContext().setColorMode(
      ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
    );
  }
}