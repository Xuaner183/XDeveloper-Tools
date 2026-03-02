import { TabSegmentButtonV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import { HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { ResourceManager as RS,
  AppInfo, OnListen, ColorsPageInit, ColorArray, RGBA, ColorType } from '../common/Index';

const errorText: string = '您当前系统不存在';

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
  private useOnListen = AppStorageV2.connect<OnListen>(OnListen, () => new OnListen())!;
  // 色块预览的颜色
  @Require @Param public chunkColor: ResourceColor = '#fff';
  // 资源数组的Index+1过的字符串
  @Require @Param public resourceIndexString: string | Resource = '-1';
  // 资源名称
  @Require @Param public resourceColorName: string = 'null';
  // 资源数组的Index
  @Param public resourceIndexNumber: number = -1;
  // @Local private isDarkOrLight: boolean = false;

  @Local private symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { icon: $r('app.media.routine') },
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);

  // TODO: HSL和HSV第一位会返回NaN bug
  private outDarkOrLightString(isDark: boolean, colorType: ColorArray): string {
    const darkColor = this.useAppInfo.COLOR_VALUE[1];
    const lightColor = this.useAppInfo.COLOR_VALUE[0];
    const darkOrLight: (colorType: ColorArray) => ColorType.RGBA | string= (colorType: ColorArray) => {
      return isDark ? darkColor[colorType][this.resourceIndexNumber] : lightColor[colorType][this.resourceIndexNumber];
    }
    switch (colorType) {
      case ColorArray.RgbaTuple:
        const rgbaDarkOrLight: ColorType.RGBA = darkOrLight(ColorArray.RgbaTuple) as ColorType.RGBA;
        const r: RGBA = rgbaDarkOrLight[RGBA.red] || 0;
        const g: RGBA = rgbaDarkOrLight[RGBA.green] || 0;
        const b: RGBA = rgbaDarkOrLight[RGBA.blue] || 0;
        const a: RGBA = rgbaDarkOrLight[RGBA.alpha] || 0;
        return `rgba(${r}, ${g}, ${b}, ${a}%)`;
      case ColorArray.HexArray:
        return darkOrLight(ColorArray.HexArray) as string;
      case ColorArray.readableHexArray:
        return darkOrLight(ColorArray.readableHexArray) as string;
      case ColorArray.CmykArray:
        return darkOrLight(ColorArray.CmykArray) as string;
      case ColorArray.HslArray:
        return darkOrLight(ColorArray.HslArray) as string;
      case ColorArray.HsvArray:
        return darkOrLight(ColorArray.HsvArray) as string;
      default:
        return '未知';
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
        Row() {
          Button(resourceIndexString, { type: ButtonType.Capsule, stateEffect: false, controlSize: ControlSize.SMALL })
            .backgroundColor('#fffd2872')
            .constraintSize({ minWidth: 30, minHeight: 30 })
            .fontWeight(FontWeight.Bold)
            .shadow(ShadowStyle.OUTER_DEFAULT_XS)
        }
        .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
        .alignSelf(ItemAlign.Start)
        Blank()
          .flexGrow(1)
          .flexShrink(8)
      }
      .width('100%')
      Column() {
        Text(resourceName)
          .TextStyle()
          .zIndex(8)
      }
      .width('100%')
      Column()
        .width('100%').height(4)
    }
    .padding(4)
    .width('100%').height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    // .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SwitchColorMode() {
    Flex({ direction: FlexDirection.RowReverse }) {
      TabSegmentButtonV2({
        items: this.symbolItems,
        selectedIndex: this.useAppInfo.switchColorModeIndex!!,
        onItemClicked: async (index: number) => {
          this.useAppInfo.switchColorModeIndexManager(index);
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
            .height(200)
          Column().height(24)
          Column() {
            this.SwitchColorMode()
            Column().height(16)
            Column() {
              Row() {
                Text('RGBA:')
                Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.RgbaTuple))
              }.justifyContent(FlexAlign.Start)
              Row() {
                Text('可读HEX: ')
                Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.readableHexArray))
              }.justifyContent(FlexAlign.Start)
              Row() {
                Text('HEX: ')
                Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HexArray))
              }.justifyContent(FlexAlign.Start)
              Row() {
                Text('CMYK: ')
                Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.CmykArray))
              }.justifyContent(FlexAlign.Start)
              Row() {
                Text('HSL: ')
                Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HslArray))
              }.justifyContent(FlexAlign.Start)
              Row() {
                Text('HSV: ')
                Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HsvArray))
              }.justifyContent(FlexAlign.Start)
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
        title: { mainTitle: '颜色详细' }
      }
    })
  }

}