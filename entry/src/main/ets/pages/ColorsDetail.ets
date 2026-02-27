import { TabSegmentButtonV2, SegmentButtonV2Items, ColorMetrics } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import { HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { ResourceManager as RS,
  AppInfo, getColor, SwitchColorModeIndex, OnListen, ColorsPageInit } from '../common/Index';
import colorsea from 'colorsea';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';

const errorText: string = '您当前系统不存在';

interface ColorValue {
  colorRgba: Array<RGBA>;
  colorHex: string
}

enum RGBA {
  red,
  green,
  blue,
  alpha
}

enum ColorType {
  rgba,
  hex
}

@Extend(Text)
function TextStyle() {
  .fontColor(Color.White)
  .textShadow({
    radius: 8,
  })
  .fontWeight(FontWeight.Bold)
  .lineBreakStrategy(LineBreakStrategy.BALANCED)
  .maxFontScale(4)
  .minFontScale(1)
  .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
}

@Builder export function ColorsDetailBuilder(
  chunkColor: ResourceColor,
  resourceIndexString: string | Resource,
  resourceColorName: string,
  resourceIndexNumber: number
) {
  ColorsDetail({
    chunkColor: chunkColor,
    resourceIndexString: resourceIndexString,
    resourceColorName: resourceColorName,
    resourceIndexNumber: resourceIndexNumber
  });
}
@ComponentV2
struct ColorsDetail {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(AppInfo.getContext(this)))!;
  private useRS: RS = new RS(RS.getContext(this));
  private useOnListen = AppStorageV2.connect<OnListen>(OnListen, () => new OnListen())!;
  private useColorsPageInit: ColorsPageInit = new ColorsPageInit(ColorsPageInit.getContext(this));
  // 色块预览的颜色
  @Require @Param public chunkColor: ResourceColor = '#fff';
  // 资源数组的Index+1过的字符串
  @Require @Param public resourceIndexString: string | Resource = '-1';
  // 资源名称
  @Require @Param public resourceColorName: string = 'null';
  // 资源数组的Index
  @Param public resourceIndexNumber: number = -1;
  // @Local private isDarkOrLight: boolean = false;

  @Local symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { icon: $r('app.media.routine') },
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);

  @Local colorRgba: string = '';
  @Local colorHex: string = '';
  @Local isColorError: boolean = false;
  @Local private colorLightModeValue?: ColorValue;
  @Local private colorDarkModeValue?: ColorValue;
  @Local private hexString: string = '';
  @Local private rgbaString: string = '';

  /**
   * 初始化
   * @returns
   */
  // private init() {
  //   // 获取真实颜色值
  //   const colorObj: ColorMetrics | null = getColor(this.resourceColorName);
  //   if (colorObj) {
  //     // 原版Alpha会有很多小数点，这里加工到四舍五入到只有一个小数
  //     const colorAlpha = Math.round((colorObj.alpha / 255) * 100 * 10) / 10;
  //     // 创建颜色转换程序
  //     const colorManager = colorsea([colorObj.red, colorObj.green, colorObj.red], colorAlpha , {
  //       thowParseError: true
  //     })
  //     // 转换成HEX
  //     const colorHex = colorManager.hex();
  //     const colorValue: ColorValue = {
  //       // 直接从原版RGB输出，以及加工过的Alpha
  //       colorRgba: [colorObj.red, colorObj.green, colorObj.red, colorAlpha],
  //       // HEX输出
  //       colorHex: colorHex
  //     }
  //
  //     console.info(`[CorlosDetail] 获取颜色colorValue：${JSON.stringify(colorValue)}`);
  //
  //     switch (this.useAppInfo.switchColorModeIndex) {
  //       // 如果跟随系统时获取真实颜色模式
  //       case SwitchColorModeIndex.Auto:
  //         const colorMode = this.useRS.getResourceColorMode();
  //         if (colorMode === resourceManager.ColorMode.DARK) {
  //           this.colorDarkModeValue = colorValue;
  //           console.info(`[ColorsDetail] 判断颜色是跟随系统的深色模式`)
  //         } else {
  //           this.colorLightModeValue = colorValue;
  //           console.info(`[ColorsDetail] 判断颜色是跟随系统的浅色模式`)
  //         }
  //         break;
  //       // 如果浅色就把颜色传给浅色数组
  //       case SwitchColorModeIndex.Light:
  //         console.info(`[ColorsDetail] 判断颜色是浅色模式`)
  //         this.colorLightModeValue = colorValue;
  //         break;
  //       // 如果深色就把颜色传给深色数组
  //       case SwitchColorModeIndex.Dark:
  //         console.info(`[ColorsDetail] 判断颜色是深色模式`)
  //         this.colorLightModeValue = colorValue;
  //         break;
  //     }
  //
  //     return this.isColorError = false;
  //   } else {
  //     return this.isColorError = true;
  //   }
  // }

  private lightModeTextManager(type: ColorType): string {
    if (this.isColorError) {
      return errorText;
    }
    if (!this.colorLightModeValue) {
      return '失败'
    }
    switch (type) {
      case ColorType.rgba:
        const rgba = this.colorLightModeValue.colorRgba;
        return `rgba (${rgba[RGBA.red]}, ${rgba[RGBA.green]}, ${rgba[RGBA.blue]}, ${rgba[RGBA.alpha]})`;
      case  ColorType.hex:
        return this.colorLightModeValue.colorHex
    }
  }

  private darkModeTextManager(type: ColorType): string {
    if (this.isColorError) {
      return errorText;
    }
    if (!this.colorDarkModeValue) {
      return '失败'
    }
    switch (type) {
      case ColorType.rgba:
        const rgba = this.colorDarkModeValue.colorRgba;
        return `rgba (${rgba[RGBA.red]}, ${rgba[RGBA.green]}, ${rgba[RGBA.blue]}, ${rgba[RGBA.alpha]})`;
      case ColorType.hex:
        return this.colorDarkModeValue.colorHex
    }
  }

  /**
   * 判断Text应显示哪种颜色模式的值；
   * @param type
   * @returns
   */
  private colorModeTextManager(type: ColorType) {
    switch (this.useAppInfo.switchColorModeIndex) {
      // 如果是跟随系统则判断真实颜色模式
      case SwitchColorModeIndex.Auto:
        const colorMode = this.useRS.getResourceColorMode();
        if (colorMode === resourceManager.ColorMode.DARK) {
          return this.darkModeTextManager(type);
        } else {
          return this.lightModeTextManager(type);
        }

      case SwitchColorModeIndex.Light:
        return this.lightModeTextManager(type);

      case SwitchColorModeIndex.Dark:
        return this.darkModeTextManager(type);
    }
  }
  // TODO: 用深色浅色两个占位符去占文本
  private rgbaText(isDark: boolean) {
    if (!this.useAppInfo.isFull(isDark)) { return '正在加载' }
    try {
      const darkColor = this.useAppInfo.DARK_MODE_COLORS_ARRAY[this.resourceIndexNumber];
      const lightColor = this.useAppInfo.LIGHT_MODE_COLORS_ARRAY[this.resourceIndexNumber];
      const DarkOrLight = isDark ? darkColor : lightColor;
      const r: RGBA = DarkOrLight[RGBA.red];
      const g: RGBA = DarkOrLight[RGBA.green];
      const b: RGBA = DarkOrLight[RGBA.blue];
      const a: RGBA = DarkOrLight[RGBA.alpha];
      const rgbaString = `rgba(${r}, ${g}, ${b}, ${a})`;
      return this.rgbaString = rgbaString;
    } catch (e) {
      console.error(`[ColorDetail] rgbaText错谁：${JSON.stringify(e)}}`)
      return '正在加载';
    }
  }

  private rgbaText2(isDark: boolean) {
    if (!this.useAppInfo.isFull(isDark)) { return '正在加载' }
    try {
      const lightColor = this.useAppInfo.LIGHT_MODE_RGBA_ARRAY[this.resourceIndexNumber];
      const darkColor = this.useAppInfo.DARK_MODE_RGBA_ARRAY[this.resourceIndexNumber];
      const DarkOrLight = isDark ? darkColor : lightColor;
      const rgbaString = DarkOrLight[this.resourceIndexNumber];
      return this.hexString = rgbaString.toString();
    } catch (e) {
      console.error(`[ColorDetail] rgbaText2错误：${JSON.stringify(e)}}`)
      return '正在加载';
    }
  }



  aboutToAppear(): void {
    console.info(`[ColorsDetail] 当前APP颜色模式：${String(this.useAppInfo.colorModeLocalInApp)}`);
    console.info(`[ColorsDetail] 当前滑块索引值：${this.useAppInfo.switchColorModeIndex}`)
    // 初始化
    // this.init();
  }

  aboutToDisappear(): void {
    // 向父组件汇报模态窗已关闭
    this.useAppInfo.modalOpen[this.resourceIndexNumber] = false;
  }

  @Builder
  TextOverlay(
    resourceIndexString: string | Resource | undefined = undefined,
    resourceName: string | Resource | undefined = undefined
  ) {
    Column() {
      Column() {
        Text(resourceName)
          .TextStyle()
          .zIndex(8)
      }
    }
    .padding(4)
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SwitchColorMode() {
    Flex({ direction: FlexDirection.RowReverse }) {
      TabSegmentButtonV2({
        items: this.symbolItems,
        selectedIndex: this.useAppInfo.switchColorModeIndex!!,
        onItemClicked: async (index: number) => {
          // this.init();
          this.useAppInfo.switchColorModeIndexManager(index);
          // 如果某数组没满则再循环获取
          if (!this.useAppInfo.isFull(this.useOnListen.isDarkMode)) {
            const useColorsPageInit: ColorsPageInit = new ColorsPageInit(ColorsPageInit.getContext(this));
            await useColorsPageInit.init();
            this.rgbaText(this.useOnListen.isDarkMode);
            this.rgbaText2(this.useOnListen.isDarkMode);
          }
        }
      })
        .width(200)
    }
    .padding({ top: 8, bottom: 8, left: 16, right: 16 })
    .width('auto')
    // .margin({ left: 16, right: 16 })
  }

  build() {
    HdsNavigation(this.mainNavPathStack) {
      Scroll() {

        Column() {
          Column()
            .height(80)
            Column() {
              Rect({ width: '100%', height: '100%' })
                .fill(this.chunkColor)
                .radius(14.4)
            }
            .borderRadius(16)
            .shadow(ShadowStyle.OUTER_DEFAULT_MD)
            .backgroundImage($r('app.media.mosaic'), {
              repeat: ImageRepeat.XY
            })
            .backgroundImagePosition(Alignment.Center)
            .overlay(this.TextOverlay(this.resourceIndexString, this.resourceColorName))
            .width('100%')
            .height(100)

          Column() {
            this.SwitchColorMode()
            Column() {
              Row() {
                Text('HEX:')
                Text(this.rgbaText2(this.useOnListen.isDarkMode))
              }
              Row() {
                Text('rgba: ')
                Text(this.rgbaText(this.useOnListen.isDarkMode))
              }
            }
            .justifyContent(FlexAlign.Start)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')

        }
      }
      .padding({ left: 24, right: 24 })
      .width('100%')
      .height('auto')
    }
    .titleMode(HdsNavigationTitleMode.MODAL)
    .titleBar({
      content: {
        title: { mainTitle: this.resourceIndexString }
      }
    })
  }

}