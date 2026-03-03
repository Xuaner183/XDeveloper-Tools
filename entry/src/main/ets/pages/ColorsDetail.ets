import { TabSegmentButtonV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import {
  AppInfo, OnListen, ColorArray, ColorType, PasteboardUtil } from '../common/Index';
import { CustomListItemCardWithTitle2AndSub } from '../components/CustomListItemCardWithTitle2AndSub';

// const errorText: string = '您当前系统不存在';

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

  private outDarkOrLightString(isDark: boolean, colorType: ColorArray): string {
    const darkColor = this.useAppInfo.COLOR_VALUE[1];
    const lightColor = this.useAppInfo.COLOR_VALUE[0];
    const darkOrLight: (colorType: ColorArray) => ColorType.RGBA | string= (colorType: ColorArray) => {
      return isDark ? darkColor[colorType][this.resourceIndexNumber] : lightColor[colorType][this.resourceIndexNumber];
    }
    switch (colorType) {
      case ColorArray.RgbaArray:
        return darkOrLight(ColorArray.RgbaArray) as string;
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

  private copy(text: string) {
    PasteboardUtil.copy(text, this.getUIContext());
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
    Stack() {
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
      .height('100%')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      Column()
        .width('100%').height(4)
    }
    .padding(4)
    .width('100%').height('100%')
    // .justifyContent(FlexAlign.SpaceBetween)
    // .alignItems(HorizontalAlign.Center)
    .alignContent(Alignment.Start)
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
    Navigation(this.mainNavPathStack) {
      Scroll() {

        Column() {
          Column()
            .height(40)
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
            .height(120)
          Column().height(24)
          Column() {
            this.SwitchColorMode()
            Column().height(16)
            Column() {
              List() {
                CustomListItemCardWithTitle2AndSub({
                  title: this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.RgbaArray),
                  sub: 'RGBA',
                  onClickList: () => { this.copy(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.RgbaArray)) }
                })
                CustomListItemCardWithTitle2AndSub({
                  title: this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.readableHexArray),
                  sub: '可读HEX',
                  onClickList: () => { this.copy(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.readableHexArray)) }
                })
                CustomListItemCardWithTitle2AndSub({
                  title: this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HexArray),
                  sub: 'HEX',
                  onClickList: () => { this.copy(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HexArray)) }
                })
                CustomListItemCardWithTitle2AndSub({
                  title: this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.CmykArray),
                  sub: 'CMYK',
                  onClickList: () => { this.copy(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.CmykArray)) }
                })
                CustomListItemCardWithTitle2AndSub({
                  title: this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HslArray),
                  sub: 'HSL',
                  onClickList: () => { this.copy(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HslArray)) }
                })
                CustomListItemCardWithTitle2AndSub({
                  title: this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HsvArray),
                  sub: 'HSV',
                  onClickList: () => { this.copy(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HsvArray)) }
                })
                ListItem()
                  .height(140)
              }
              .width('100%').height('auto')
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.PARENT_FIRST
              })
              // Row() {
              //   Text('RGBA: ')
              //   Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.RgbaArray))
              // }
              // Row() {
              //   Text('可读HEX: ')
              //   Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.readableHexArray))
              // }
              // Row() {
              //   Text('HEX: ')
              //   Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HexArray))
              // }
              // Row() {
              //   Text('CMYK: ')
              //   Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.CmykArray))
              // }
              // Row() {
              //   Text('HSL: ')
              //   Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HslArray))
              // }
              // Row() {
              //   Text('HSV: ')
              //   Text(this.outDarkOrLightString(this.useOnListen.isDarkMode, ColorArray.HsvArray))
              // }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')

        }
      }
      .padding({ left: 24, right: 24 })
      .width('100%')
      .height('auto')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    // .titleMode(HdsNavigationTitleMode.MODAL)
    // .titleBar({
    //   content: {
    //     title: { mainTitle: '颜色详细' }
    //   }
    // })
    .hideTitleBar(true)
  }

}