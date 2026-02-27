import { ConfigurationConstant } from '@kit.AbilityKit';
import { UIAbilityContext, type common } from './UIAbilityContext';
import { resourceManager } from '@kit.LocalizationKit';
import { AppInfo, SwitchColorModeIndex } from './AppInfo';
import { ResourceManager as RM } from './ResourceManager';
import { ColorSysString, getColor } from './ColorArray';
import { ClientGlobalPrefKeys } from './ClientGlobalPrefKeys';
import { PreferencesControl } from './PreferencesManager';
import { AppStorageV2 } from '@kit.ArkUI';
import {  ResourceManager as RS } from './Index';
import colorsea from 'colorsea';
import { OnListen } from './OnListen';
enum RGBA {
  red,
  green,
  blue,
  alpha
}

interface ColorValue {
  colorRgba: Array<RGBA>;
  colorHex: string
}

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
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.uiContext))!;
  // private useRM: RM = new RM(this.uiContext);
  // private usePreferencesControl: PreferencesControl = new PreferencesControl(this.uiContext);
  private useRS: RS = new RS(this.uiContext);
  private useOnListen = AppStorageV2.connect<OnListen>(OnListen, () => new OnListen())!;

  public async init(isFull: boolean = false): Promise<boolean> {

    if (isFull) { return false }

    const colorRGBAs: Array<Array<RGBA>> = [];
    const color10: Array<string> = [];

    const forResult = () => {
      // 定义循环执行的函数
      const forColor = (resColorName: string) => {
        // 获取 ColorMetrics 对象
        const colorObj: ColorMetrics | null = getColor(resColorName);
        if (colorObj) {
          // 原版Alpha会有很多小数点，这里加工到四舍五入到只有一个小数
          const colorAlpha = Math.round((colorObj.alpha / 255) * 100 * 10) / 10;
          // RGBA结果
          const colorRgbaResult: Array<RGBA> = [colorObj.red, colorObj.green, colorObj.red, colorAlpha];
          // 十进制结果
          const color10aResult: string = colorObj.color;
          // 存储到数组中
          color10.push(color10aResult);
          colorRGBAs.push(colorRgbaResult);
          console.info(`[ColorsInit] 获取成功: color10aResult = ${color10aResult}, colorRgbaResult = ${colorRgbaResult}`)
          return true;
        } else { return false; }
      }

      for (let i = 0; i < ColorSysString.length; i++) {
        if (!forColor(ColorSysString[i])) {
          console.error(`[ColorsInit] 获取失败: index: ${i}, string: ${ColorSysString[i]}`);
        }
      }
    }

    const darkResult = () => {
      console.info(`[ColorsInit] 判断颜色是深色模式，存储到 DARK_MODE_COLORS_ARRAY`);
      this.useAppInfo.DARK_MODE_COLORS_ARRAY = colorRGBAs;
      this.useAppInfo.DARK_MODE_RGBA_ARRAY = color10;
    }

    const lightResult = () => {
      console.info(`[ColorsInit] 判断颜色是浅色模式，存储到 LIGHT_MODE_COLORS_ARRAY`);
      this.useAppInfo.LIGHT_MODE_COLORS_ARRAY = colorRGBAs;
      this.useAppInfo.LIGHT_MODE_RGBA_ARRAY = color10;
    }

    // 确定颜色模式，并防止多余的执行
    if (this.useOnListen.isDarkMode && !this.useAppInfo.isDarkColorFull) {
      // 如果深色模式
      forResult();
      darkResult()
      this.useAppInfo.isDarkColorFull = true;
    } else if (!this.useOnListen.isDarkMode && !this.useAppInfo.isLightColorFull) {
      // 如果浅色模式
      forResult();
      lightResult();
    }

    return true;

  }

  constructor(uiContext: common.UIAbilityContext) {
    super(uiContext);
  }
}