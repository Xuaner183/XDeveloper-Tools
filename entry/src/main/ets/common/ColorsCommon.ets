import { ConfigurationConstant } from '@kit.AbilityKit';
import { UIAbilityContext, type common } from './UIAbilityContext';
import { resourceManager } from '@kit.LocalizationKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { ResourceManager as RS, ColorModeSwitch, AppInfo, OnListen, ColorSysString, getColor, ColorArray,
  ColorType} from './Index';
// import colorsea from 'colorsea';
import { emitter } from '@kit.BasicServicesKit';
import { ColorUtils , RgbaObj } from './ColorUtils';

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

    const useColorModeSwitch = new ColorModeSwitch(this.uiContext);

    // const colorRGBAs: Array<Array<RGBA>> = [];
    // const colorHex: Array<string> = [];
    // 只记录一次是否是深色模式
    let isOneDark: boolean = false;
    // 定义结果函数不执行
    const forResult = () => {
      // 建立元组
      const colorValue: [ColorType.RGBA[], ColorType.readableHEX[], ColorType.HEX[], ColorType.CMYK[],
        ColorType.HSL[], ColorType.HSV[]] = [[], [], [], [], [], []];
      // 定义循环执行的函数
      const forColor = (resColorName: string) => {
        // 获取 ColorMetrics 对象
        const colorObj: ColorMetrics | null = getColor(resColorName);
        if (colorObj) {
          // 将Alpha的[0-255]转换成[0-1]
          const colorAlpha: string = ColorUtils.alpha255To01(colorObj.alpha);
          // RGBA结果
          const colorRgbaResult: ColorType.RGBA =
            `rgba(${colorObj.red.toString()}, ${colorObj.green.toString()}, ${colorObj.blue.toString()}, ${colorAlpha})`;
          // 将RGBA结果转换成十六进制HEX
          const rgbaObj: RgbaObj = {
            r: colorObj.red,
            g: colorObj.green,
            b: colorObj.blue,
            a: colorObj.alpha
          }
          const colorHEX: ColorType.HEX = ColorUtils.rgbaToHex0x(rgbaObj);
          // 转换可读HEX
          const colorReadableHEXResult: ColorType.readableHEX = ColorUtils.rgbaToHexHash(rgbaObj);
          // 处理CMYK
          const colorCMYK: ColorType.CMYK = ColorUtils.rgbaToCmyk(rgbaObj);
          // 处理HSL
          const colorHSL: ColorType.HSL = ColorUtils.rgbaToHsl(rgbaObj);
          // 处理HSV
          const colorHSV = ColorUtils.rgbaToHsv(rgbaObj);
          // 存储到数组中
          colorValue[ColorArray.RgbaArray].push(colorRgbaResult);
          colorValue[ColorArray.readableHexArray].push(colorReadableHEXResult);
          colorValue[ColorArray.HexArray].push(colorHEX);
          colorValue[ColorArray.CmykArray].push(colorCMYK);
          colorValue[ColorArray.HslArray].push(colorHSL);
          colorValue[ColorArray.HsvArray].push(colorHSV);
          // console.info(`[ColorsInit] 获取成功: color10aResult = ${color10aResult}, colorRgbaResult = ${colorRgbaResult}`)
          return true;
        } else { return false; }

      }

      for (let i = 0; i < ColorSysString.length; i++) {
        if (!forColor(ColorSysString[i])) {
          console.error(`[ColorsInit] 获取失败: index: ${i}, string: ${ColorSysString[i]}`);
        }
      }
      return colorValue;
    }

    const set = () => {
      // 确定颜色模式，并判断数组是否存过了
      if (this.useOnListen.isDarkMode && !this.useAppInfo.isDarkColorFull) {
        // 如果深色模式
        // 防止颜色是跟随系统时中途变化，所以指定固色
        console.info(`[ColorsCommon] isDarkMode = ${this.useOnListen.isDarkMode} 设置深色模式`);
        console.info(`[ColorsCommon] 当前颜色切换条索引值： ${this.useAppInfo.switchColorModeIndex}`);
        useColorModeSwitch.setDark();
        const result = forResult();
        this.useAppInfo.COLOR_VALUE[1] = result;
        isOneDark = true;
        this.useAppInfo.isDarkColorFull = true;
      } else if (!this.useOnListen.isDarkMode && !this.useAppInfo.isLightColorFull) {
        // 如果浅色模式
        // 防止颜色是跟随系统时中途变化，所以指定固色
        console.info(`[ColorsCommon] isDarkMode = ${this.useOnListen.isDarkMode} 设置浅色模式`);
        console.info(`[ColorsCommon] 当前颜色切换条索引值： ${this.useAppInfo.switchColorModeIndex}`);
        useColorModeSwitch.setLight();
        const result = forResult();
        this.useAppInfo.COLOR_VALUE[0] = result;
        isOneDark = false;
        this.useAppInfo.isLightColorFull = true;
      }
    }
    // 记住用户设置的颜色模式
    const colorMode = this.useAppInfo.colorModeLocalInApp
    // 获取第一次数颜色值
    set();

    // 注册颜色变化时的事件回调
    this.useAppInfo.listenAppColorModeChange(() => {
      setTimeout(() => {
        console.info(`[ColorsCommon] 事件回调一次`)
        forResult();
        set();
      }, 300);
      // 取消事件订阅
      emitter.off(1001);
    })

    // 获取第二次颜色值
    // 如果前面是深色模式则临时变浅色模式
    if (isOneDark) {
      useColorModeSwitch.setLight();
    } else {
      useColorModeSwitch.setDark();
    }

    setTimeout(() => {
      // 恢复用户设置颜色
      switch (colorMode) {
        case ConfigurationConstant.ColorMode.COLOR_MODE_DARK:
          useColorModeSwitch.setDark();
          break
        case ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT:
          useColorModeSwitch.setLight();
          break
        default:
          useColorModeSwitch.setFollowSystem();
      }
    }, 500)

    return true;

  }

  constructor(uiContext: common.UIAbilityContext) {
    super(uiContext);
  }
}