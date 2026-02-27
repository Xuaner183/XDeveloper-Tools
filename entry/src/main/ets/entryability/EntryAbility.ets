import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { PreferencesControl as PC, ClientGlobalPrefKeys } from '../common/Index';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const usePC: PC = new PC(this.context);
    const appColorMode = usePC.prefGetSync(
      ClientGlobalPrefKeys.PREF_NAME,
      ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_APP,
      ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    const setColorMode = (codeMode: ConfigurationConstant.ColorMode) => {
      try {
        this.context.getApplicationContext().setColorMode(codeMode);
      } catch (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
      }
    }

    if (!appColorMode || appColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
      setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      console.info(`[EntryAbility] 根据首选项设置颜色模式：跟随系统`);
    } else {
      switch (appColorMode) {
        case ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT:
          setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
          console.info(`[EntryAbility] 根据首选项设置颜色模式：浅色模式`);
          break;
        case ConfigurationConstant.ColorMode.COLOR_MODE_DARK:
          setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
          console.info(`[EntryAbility] 根据首选项设置颜色模式：深色模式`);
          break;
        default:
          setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      }
    }

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}