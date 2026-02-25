import { ColorSysResourse, ColorSysString, AppInfo, PreferencesControl, ClientGlobalPrefKeys, ColorsPageInit } from '../common/Index';
import { TabSegmentButtonV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';

const lightModeIndex: number = 0;
const darkModeIndex: number = 1;


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

@Builder
export function ColorsBuilder() {
  Colors();
}


@Preview
@ComponentV2
struct Colors {
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.getContext()))!;
  private usePreferencesControl: PreferencesControl = new PreferencesControl(this.getContext());
  @Local symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);
  @Local symbolSelectedIndex: number = this.useAppInfo.colorModeLocalInColorsPage === ThemeColorMode.DARK ? 1 : 0;
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private mainScroller: Scroller = new Scroller();
  @Local colorModeLocal: ThemeColorMode = this.useAppInfo.colorModeLocalInColorsPage;

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  @Builder
  TextOverlay(
    text1: string | Resource | undefined = undefined,
    text2: string | Resource | undefined = undefined
  ) {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
      Text(text1)
        .TextStyle()
        .zIndex(8)
      Text(text2)
        .TextStyle()
        .zIndex(8)
    }
    .padding(8)
  }

  /**
   * 标题栏右上角切换局部深浅色开关
   */
  @Builder
  SwitchColorMode() {
    Flex({ direction: FlexDirection.RowReverse }) {
      TabSegmentButtonV2({
        items: this.symbolItems,
        selectedIndex: this.useAppInfo.colorModeLocalInColorsPage!!,
        onItemClicked: (index: number) => {
          switch (index) {
            case lightModeIndex:
              this.colorModeLocal = ThemeColorMode.LIGHT;
              this.useAppInfo.colorModeLocalInColorsPage = lightModeIndex;
              this.usePreferencesControl.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_COLORS_PAGE, lightModeIndex);
              console.info('[Colors] 点击了浅色模式！')
              break;
            case darkModeIndex:
              this.colorModeLocal = ThemeColorMode.DARK;
              this.useAppInfo.colorModeLocalInColorsPage = darkModeIndex;
              console.info('[Colors] 点击了深色模式！')
              this.usePreferencesControl.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_COLORS_PAGE, darkModeIndex);
              break;
          }
        }
      })
        .width(100)
    }
    .padding({ top: 8, bottom: 8, left: 16, right: 16 })
    // .margin({ left: 16, right: 16 })
  }

  @LocalBuilder
  ListItemColorChunk(
    height: Length,
    width: Length,
    backgroundColor: ResourceColor,
    text1: string | Resource | undefined = undefined,
    text2: string | Resource | undefined = undefined,
    zIndex: number = 1
  ) {
    ListItem() {
      WithTheme({ colorMode: this.useAppInfo.colorModeLocalInColorsPage === darkModeIndex ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.SpaceEvenly,
          alignItems: ItemAlign.Center
        }) {
          Rect({ width: '100%', height: '100%' })
            .fill(backgroundColor)
            .radius(14.4)
        }
        .height(height)
        .width(width)
        .zIndex(zIndex)
        .backgroundImage($r('app.media.mosaic'), {
          repeat: ImageRepeat.XY
        })
        .backgroundImagePosition(Alignment.Center)
        .borderRadius(16)
        .overlay(this.TextOverlay(text1, text2))
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
      }
    }
    .width('100%')
    .height('auto')
    .clickEffect({ level: ClickEffectLevel.LIGHT })
    .padding({ top: 8, bottom: 8 })

  }

  aboutToAppear(): void {
    const useColorsPageInit = new ColorsPageInit(ColorsPageInit.getContext(this), this.useAppInfo);
    useColorsPageInit.init();
  }

  build() {

    NavDestination() {
      Column() {
        Scroll(this.mainScroller) {
          Column() {
            List() {
              ListItemGroup() {
                Repeat(ColorSysResourse)
                  .virtualScroll({
                    totalCount: ColorSysResourse.length
                  })
                  .each((obj) => {
                    this.ListItemColorChunk(100, '100%', obj.item, String(obj.index), ColorSysString[obj.index],
                      obj.index)
                  })
              }
              .padding({
                right: 16,
                left: 16,
                bottom: 120,
                top: 120
              })
            }
            .width('100%')
            .height('auto')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .lanes({ minLength: 200, maxLength: 400 }, 8)
            .alignListItem(ListItemAlign.Start)
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          }
        }
      }
      .linearGradient({
        angle: 180,
        colors: [[$r('app.color.background_linearGradient_color1'), 0.0],
          [$r('app.color.background_linearGradient_color2'), 1]]
      })
    }
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .onReady((ctx) => {
      this.mainNavPathStack = ctx.pathStack;
    })
    .bindToScrollable([this.mainScroller])
    .title('颜色', {
      backgroundBlurStyle: BlurStyle.Thin,
      barStyle: BarStyle.STACK
    })
    .menus(this.SwitchColorMode())
  }

}