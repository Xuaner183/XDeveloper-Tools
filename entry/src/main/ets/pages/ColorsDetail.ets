import { TabSegmentButtonV2, SegmentButtonV2Items, ColorMetrics } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import { HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { ResourceManager, AppInfo, getResourceColorRgb, convertDecimalColorToHex, ColorModeSwitch } from '../common/Index';


const lightModeIndex: number = 0;
const darkModeIndex: number = 1;

const nullString: string = 'null';

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
  DetailColorMode: ThemeColorMode,
  resourceIndexNumber: number
) {
  ColorsDetail({
    chunkColor: chunkColor,
    resourceIndexString: resourceIndexString,
    resourceColorName: resourceColorName,
    // colorHex: colorHex,
    DetailColorMode: DetailColorMode,
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
  @Once @Param DetailColorMode: ThemeColorMode = 0;
  @Param public resourceIndexNumber: number = -1;

  @Local symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);

  @Local colorRgba: string = nullString;
  @Local colorHex: string = nullString;


  @Builder
  TextOverlay(
    resourceIndexString: string | Resource | undefined = undefined,
    resourceName: string | Resource | undefined = undefined
  ) {
    Column() {
      // Column() {
      //   Row() {
      //     Button(resourceIndexString, { type: ButtonType.Capsule, stateEffect: false, controlSize: ControlSize.SMALL })
      //       .backgroundColor('#fffd2872')
      //       .constraintSize({ minWidth: 30, minHeight: 30 })
      //       .fontWeight(FontWeight.Bold)
      //       .shadow(ShadowStyle.OUTER_DEFAULT_XS)
      //   }
      //   // .borderRadius(16)
      //   .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
      //   .alignSelf(ItemAlign.Start)
      //   Blank()
      //     .flexGrow(1)
      //     .flexShrink(8)
      // }
      // .width('100%')
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
        selectedIndex: this.DetailColorMode!!,
        onItemClicked: (index: number) => {
          switch (index) {
            case lightModeIndex:
              this.DetailColorMode = ThemeColorMode.LIGHT;
              this.useAppInfo.colorModeLocalInColorsPage = lightModeIndex;
              this.useColorModeSwitch.setLight();
              this.getColor();
              // this.usePreferencesControl.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_COLORS_PAGE, lightModeIndex);
              console.info('[Colors] 点击了浅色模式！')
              break;
            case darkModeIndex:
              this.DetailColorMode = ThemeColorMode.DARK;
              this.useAppInfo.colorModeLocalInColorsPage = darkModeIndex;
              this.useColorModeSwitch.setLight();
              this.getColor();
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

  private getColor() {
    this.colorRgba = getResourceColorRgb(this.resourceColorName);
  }

  aboutToAppear(): void {
    this.getColor();
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
                Text(this.colorHex !== 'null' ? this.colorHex : '您的系统不存在该值')
              }
              Row() {
                Text('rgba: ')
                Text(this.colorRgba)
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