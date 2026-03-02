import { ColorSysResourse, ColorSysString, AppInfo, OnListen, ColorsPageInit } from '../common/Index';
import { TabSegmentButtonV2, SegmentButtonV2Items } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { NavLoadingParm } from './Loading';
import { NavHomeParm } from './Home';
import { ColorsDetailBuilder } from './ColorsDetail';
import { emitter } from '@kit.BasicServicesKit';
import { CurrentModeData } from './Index';

export interface ColorsDetailRouterParam {
  chunkColor: ResourceColor;
  resourceIndexString: string | Resource;
  resourceColorName: string;
  resourceIndexNumber: number;
  DetailColorMode: ThemeColorMode;
  colorHex?: string;
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

@Builder
export function ColorsBuilder() {
  Colors();
}


@Preview
@ComponentV2
struct Colors {
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.getContext()))!;
  private useOnListen = AppStorageV2.connect<OnListen>(OnListen, () => new OnListen())!;
  // private usePreferencesControl: PreferencesControl = new PreferencesControl(this.getContext());
  // private useColorModeSwitch: ColorModeSwitch = new ColorModeSwitch(this.getContext());
  @Local symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { icon: $r('app.media.routine') },
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);
  // @Local symbolSelectedIndex: number = this.useAppInfo.colorModeLocalInColorsPage === ThemeColorMode.DARK ? 1 : 0;
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private mainScroller: Scroller = new Scroller();
  // @Local colorModeLocal: ThemeColorMode = this.useAppInfo.colorModeLocalInColorsPage;
  private isLoadDown: boolean = false;
  @Local private onTotalCount: number = 50;
  private isOnReachEnd: boolean = true;
  @Local private isListLoading: boolean = true;
  private isDataReady: boolean = false;

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private init() {
    // 启动监听
    // this.useAppInfo.listenAppColorModeChange();
  }


  aboutToAppear(): void {
    // this.init();
  }

  @Builder
  TextOverlay(
    resourceIndexString: string | Resource | undefined = undefined,
    resourceName: string | undefined = undefined,
    index: number
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
    }
    .padding(4)
    .width('100%').height('100%')
  }

  @Builder IsLoading() {
    ListItem() {
      Row() {
        Text('正在加载...')
        LoadingProgress()
          .width(30)
          .height(30)
      }
      .width('100%')
      .height(100)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('auto')
    .padding({ right: 16, left: 16 })
  }
  @Builder IsEnd() {
    ListItem() {
      Row() {
        Text('到底了')
      }
      .width('100%')
      .height(100)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('auto')
    .padding({ right: 16, left: 16 })
  }

  /**
   * 标题栏右上角切换局部深浅色开关
   */
  @Builder
  SwitchColorMode() {
    Flex({ direction: FlexDirection.RowReverse }) {
      TabSegmentButtonV2({
        items: this.symbolItems,
        selectedIndex: this.useAppInfo.switchColorModeIndex!!,
        onItemClicked: (index: number) => {
          this.useAppInfo.switchColorModeIndexManager(index);
        }
      })
        .width(200)
    }
    .padding({ top: 8, bottom: 8, left: 16, right: 16 })
    .width('auto')
    // .margin({ left: 16, right: 16 })
  }

  @LocalBuilder
  ListItemColorChunk(
    height: Length,
    width: Length,
    chunkColor: ResourceColor,
    resourceIndexString: string | Resource = '-1',
    resourceColorName: string | undefined = undefined,
    zIndex: number = 1,
    index: number
  ) {
    ListItem() {
      // WithTheme({ colorMode: this.useAppInfo.colorModeLocalInColorsPage === darkModeIndex ? ThemeColorMode.DARK : ThemeColorMode.LIGHT }) {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.SpaceEvenly,
          alignItems: ItemAlign.Center
        }) {
          Rect({ width: '100%', height: '100%' })
            .fill(chunkColor)
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
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
        .overlay(this.TextOverlay(resourceIndexString, resourceColorName, index))
      // }
    }
    .width('100%')
    .height('auto')
    .clickEffect({ level: ClickEffectLevel.LIGHT })
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      this.useAppInfo.modalOpen[index] = true;
      // console.info(`[Colors] 点击了 ${index}: ${this.useAppInfo.modalOpen[index]}`)
    })
    .bindSheet(
      this.useAppInfo.modalOpen[index]!!,
      ColorsDetailBuilder(
        chunkColor,
        resourceIndexString,
        resourceColorName ? resourceColorName : '' ,
        index
      ),
      {
        dragBar: true,
        // onWillDisappear: () => {
        //   this.useAppInfo.modalOpen[index] = false;
        //   console.info(`[Colors] 关闭 ${index}: ${this.useAppInfo.modalOpen[index]}`)
        // }
      }
    )

  }


  build() {

    NavDestination() {
      Column() {
        Scroll(this.mainScroller) {
          Column() {
            List() {
              ListItemGroup() {
                // 批量加载 ListItem
                Repeat(ColorSysResourse)
                  .virtualScroll({
                    onTotalCount: () => this.onTotalCount
                  })
                  .each((obj) => {
                    this.ListItemColorChunk(100, '100%', obj.item, String(obj.index + 1), ColorSysString[obj.index],
                      obj.index, obj.index)
                  })
                // 加载时显示无进度动画，加载完显示到底了
                if (this.isListLoading) {
                  this.IsLoading();
                } else {
                  this.IsEnd();
                }
              }
              .padding({
                right: 16,
                left: 16,
                top: 120,
                bottom: 120
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
            .onReachEnd(async () => {
              if (this.isOnReachEnd && this.onTotalCount < ColorSysResourse.length) {
                this.isOnReachEnd = false;
                console.info(`[Colors] 开始加载 isListLoading = ${this.isOnReachEnd}`)
                this.onTotalCount += 4;
                const promise: Promise<void>[] = [];
                for (let i = 0; i < 40; i++) {
                  promise.push(
                    new Promise(resolve => {
                      setTimeout(() => {
                        this.onTotalCount += 4;
                        resolve();
                      }, i * 150);
                    })
                  );
                }
                await Promise.all([promise]);
                this.isOnReachEnd = true;
                console.info(`[Colors] 结束加载 isListLoading = ${this.isOnReachEnd}`)
              } else {
                this.isListLoading = false;
              }
            })
            .cachedCount(4)
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
    .onShown(() => {
    })
    .bindToScrollable([this.mainScroller])
    .title('颜色', {
      backgroundBlurStyle: BlurStyle.Thin,
      barStyle: BarStyle.STACK
    })
    .menus(this.SwitchColorMode())
    .systemTransition(NavigationSystemTransitionType.SLIDE_RIGHT)
  }

}