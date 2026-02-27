import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, AppStorageV2 } from '@kit.ArkUI';
import { PreferencesControl as PC, ClientGlobalPrefKeys } from '../common/Index';
import { AppInfo, SwitchColorModeIndex } from '../common/Index';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.context))!;
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

    const setLightData = () => {
      setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      useAppInfo.switchColorModeIndex = SwitchColorModeIndex.Light;
      useAppInfo.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      console.info(`[EntryAbility] 根据首选项设置颜色模式：浅色模式`);
    }

    const setDarkData = () => {
      setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      useAppInfo.switchColorModeIndex = SwitchColorModeIndex.Dark;
      useAppInfo.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      console.info(`[EntryAbility] 根据首选项设置颜色模式：深色模式`);
    }

    const setAutoData = () => {
      // 设置应用颜色
      setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      // 在AppInfo记录颜色切换滑块的索引值
      useAppInfo.switchColorModeIndex = SwitchColorModeIndex.Auto;
      // 在AppInfo记录当前颜色值
      useAppInfo.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
      console.info(`[EntryAbility] 根据首选项设置颜色模式：跟随系统`);
    }

    // 如果首选项没有存储，或是跟随系统模式
    if (!appColorMode || appColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
      setAutoData();
    } else {
      switch (appColorMode) {
        // 设置应用颜色
        // 在AppInfo记录颜色切换滑块的索引值
        // 在AppInfo记录当前颜色值
        case ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT:
          setLightData();
          break;
        case ConfigurationConstant.ColorMode.COLOR_MODE_DARK:
          setDarkData();
          break;
        default:
          setAutoData();
          console.warn(`[EntryAbility] 错误的首选项，兜底设置颜色模式：跟随系统`);
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