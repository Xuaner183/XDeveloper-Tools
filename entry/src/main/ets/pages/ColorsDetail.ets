import { TabSegmentButtonV2, SegmentButtonV2Items, ColorMetrics } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import { HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { ResourceManager, AppInfo, getResourceColorRgb, convertDecimalColorToHex, ColorModeSwitch, getColor } from '../common/Index';
import colorsea from 'colorsea';


const lightModeIndex: number = 0;
const darkModeIndex: number = 1;

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
  colorHex: string,
  detailColorMode: ThemeColorMode,
  resourceIndexNumber: number
) {
  ColorsDetail({
    chunkColor: chunkColor,
    resourceIndexString: resourceIndexString,
    resourceColorName: resourceColorName,
    // colorHex: colorHex,
    detailColorMode: detailColorMode,
    resourceIndexNumber: resourceIndexNumber
  });
}
@ComponentV2
struct ColorsDetail {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(AppInfo.getContext(this)))!;
  private useColorModeSwitch: ColorModeSwitch = new ColorModeSwitch(ColorModeSwitch.getContext(this));
  @Require @Param public chunkColor: ResourceColor = '#fff';
  @Require @Param public resourceIndexString: string | Resource = '-1';
  @Require @Param public resourceColorName: string = 'null';
  // @Require @Param public colorHex?: string = undefined;
  @Once @Param detailColorMode: ThemeColorMode = 0;
  @Param public resourceIndexNumber: number = -1;

  @Local symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);

  @Local colorRgba: string = '';
  @Local colorHex: string = '';
  @Local isColorError: boolean = false;
  private colorLightModeValue?: ColorValue;
  private colorDarkModeValue?: ColorValue;

  private init() {
    const colorObj: ColorMetrics | null = getColor(this.resourceColorName);
    if (colorObj) {
      const colorAlpha = Math.round((colorObj.alpha / 255) * 100 * 10) / 10;
      const colorManager = colorsea([colorObj.red, colorObj.green, colorObj.red], colorAlpha , {
        thowParseError: true
      })
      const colorHex = colorManager.hex();
      const colorValue: ColorValue = {
        colorRgba: [colorObj.red, colorObj.green, colorObj.red, colorAlpha],
        colorHex: colorHex
      }

      if (this.detailColorMode === ThemeColorMode.LIGHT) {
        this.colorLightModeValue = colorValue;
      } else if (this.detailColorMode === ThemeColorMode.DARK) {
        this.colorDarkModeValue = colorValue;
      }

      return this.isColorError = false;
    } else {
      return this.isColorError = true;
    }
  }

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
      case  ColorType.hex:
        return this.colorDarkModeValue.colorHex
    }
  }

  private colorModeTextManager(type: ColorType): string {
    if (this.detailColorMode === ThemeColorMode.DARK) {
      return this.darkModeTextManager(type);
    } else {
      return this.lightModeTextManager(type);
    }
  }

  aboutToReuse(): void {
    this.init();
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
        selectedIndex: this.detailColorMode!!,
        onItemClicked: (index: number) => {
          switch (index) {
            case lightModeIndex:
              this.detailColorMode = ThemeColorMode.LIGHT;
              this.useAppInfo.colorModeLocalInColorsPage = lightModeIndex;
              this.useColorModeSwitch.setLight();
              this.init();
              // this.usePreferencesControl.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_COLORS_PAGE, lightModeIndex);
              console.info('[Colors] 点击了浅色模式！')
              break;
            case darkModeIndex:
              this.detailColorMode = ThemeColorMode.DARK;
              this.useAppInfo.colorModeLocalInColorsPage = darkModeIndex;
              this.useColorModeSwitch.setLight();
              this.init();
              console.info('[Colors] 点击了深色模式！')
              // this.usePreferencesControl.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_COLORS_PAGE, darkModeIndex);
              break;
          }
        }
      })
        .width(100)
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
                Text(this.colorModeTextManager(ColorType.hex))
              }
              Row() {
                Text('rgba: ')
                Text(this.colorModeTextManager(ColorType.rgba))
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