import { ClientGlobalPrefKeys } from './ClientGlobalPrefKeys';
import { AppInfo } from './AppInfo';
import { PreferencesControl } from './PreferencesManager';
import { ColorsCommon } from './ColorsCommon';
import { UIAbilityContext } from './UIAbilityContext';
import { AppStorageV2 } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { type preferences } from '@kit.ArkData';
import { ConfigurationConstant } from '@kit.AbilityKit';


export class Initialize extends UIAbilityContext {
  // 新建AppStorageV2————应用全局UI状态存储
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.uiContext))!;

  public async Init() {
    const useColorsCommon: ColorsCommon = new ColorsCommon(this.uiContext);
    const usePreferencesControl: PreferencesControl = new PreferencesControl(this.uiContext);
    // 获取系统颜色
    const colorModeSys: resourceManager.ColorMode = await useColorsCommon.getColorMode();
    this.useAppInfo.colorModeLocalInSys = colorModeSys;
    // 获取存储的应用级颜色模式首选项
    const colorModeAppPref: Promise<preferences.ValueType | null> = usePreferencesControl.prefGet(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_APP, -1);
    const colorModeLocalInColorsPagePref: Promise<preferences.ValueType | null> = usePreferencesControl.prefGet(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_COLORS_PAGE, -1);
    const prefResult = await Promise.all([colorModeAppPref, colorModeLocalInColorsPagePref]);
    // 判断
    if (typeof prefResult[0] === 'number' && ConfigurationConstant.ColorMode[prefResult[0]]) {
      this.useAppInfo.colorModeLocalInApp = prefResult[0];
    } else {
      console.error(`[Initialize] 获取存储的应用级颜色模式首选项失败`);
    }
    if (typeof prefResult[1] === 'number') {
      this.useAppInfo.colorModeLocalInColorsPage = prefResult[1];
    } else {
      console.error(`[Initialize] 获取存储的 Colors 页列表的局部颜色模式首选项失败`);
    }
  }
}