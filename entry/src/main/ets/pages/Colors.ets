import { ColorSysResourse, ColorSysString, AppInfo, OnListen, ColorType } from '../common/Index';
import { TabSegmentButtonV2, SegmentButtonV2Items, SymbolGlyphModifier } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { ColorsDetailBuilder } from './ColorsDetail';
import { picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { DynamicHideParams, HdsNavDestination, HdsNavigationTitleBarOptions, HideMode, TextStyleMode } from '@kit.UIDesignKit';

export interface ColorsDetailRouterParam {
  chunkColor: ResourceColor;
  resourceIndexString: string | Resource;
  resourceColorName: string;
  resourceIndexNumber: number;
  DetailColorMode: ThemeColorMode;
  colorHex?: string;
}

interface ColorTypeObj {
  RGBA: ColorType.RGBA;
  readableHEX: ColorType.readableHEX;
  HEX: ColorType.HEX;
  CMYK: ColorType.CMYK;
  HSL: ColorType.HSL;
  HSV: ColorType.HSV;
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
  @Local symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { icon: $r('app.media.routine') },
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private mainScroller: Scroller = new Scroller();
  private saveIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.save'));

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async outColorJson() {
    const docPicker = new picker.DocumentViewPicker(AppInfo.getContext(this));
    const saveUrl: string[] = await docPicker.save({
      defaultFilePathUri: 'file://docs/storage/Users/currentUser/Documents',
      newFileNames: ['All_Color'],
      fileSuffixChoices: ['.json', '.txt']
    });

    // 输出某颜色模式的各个颜色名字，对应的各个颜色类型，对应值的Obj
    const outColorNameAndColorTypeObj = (isDarkMode: boolean) => {
      // 输出某个颜色名字，对应的各个颜色类型，对应值的Obj
      const outColorTypeArray = (isDarkMode: boolean) => {
        const colorTypeArray: Array<ColorTypeObj> = []
        const darkOrLight = isDarkMode ? this.useAppInfo.COLOR_VALUE[1] : this.useAppInfo.COLOR_VALUE[0];
        for(let i = 0; i < ColorSysString.length; i++) {
          const colorType: ColorTypeObj = {
            RGBA: darkOrLight[0][i],
            HEX: darkOrLight[1][i],
            readableHEX: darkOrLight[2][i],
            CMYK: darkOrLight[3][i],
            HSL: darkOrLight[4][i],
            HSV: darkOrLight[5][i]
          }
          colorTypeArray.push(colorType);
        }
        return colorTypeArray;
      }

      const colorTypeArray: ColorTypeObj[] = outColorTypeArray(isDarkMode);
      const someModeColorObj: Record<string, ColorTypeObj> = {};
      for(let i = 0; i < ColorSysString.length; i++) {
        someModeColorObj[ColorSysString[i]] = colorTypeArray[i];
      }
      return someModeColorObj;
    }

    const outAllModeColorObj = () => {
      const lightModeObj = outColorNameAndColorTypeObj(false);
      const darkModeObj = outColorNameAndColorTypeObj(true);
      const allModeColorObj: Record<string, Record<string, ColorTypeObj>> = {};
      for(let i = 0; i < ColorSysString.length; i++) {
        allModeColorObj['Light'] = lightModeObj;
        allModeColorObj['Dark'] = darkModeObj;
      }
      return allModeColorObj;
    }

    try {
      const openFile = await fs.open(saveUrl[0], 0o1);
      fs.write(openFile.fd, JSON.stringify(outAllModeColorObj(), null, '\t')).then((result) => {
        // console.info(` 写入了 ${result} 字节`);
      });
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({ message: `失败：${(e as BusinessError).message}` })
    }
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
        Text('——到底了——')
      }
      .width('100%')
      .height(100)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('auto')
    .padding({ right: 16, left: 16 })
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
        title: { title: '颜色详细' },
        dragBar: true,
        height: SheetSize.MEDIUM,
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
        enableOutsideInteractive: false
      }
    )

  }

  @Builder MoreMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: this.saveIcon,
        content: '导出为JSON',
      })
        .onClick(() => {
          this.outColorJson();
        })
    }
  }
  // 右下角折叠菜单
  @Builder myOverlay() {
    Row() {
      Button('󰁡', { type: ButtonType.Circle })
        .fontSize(40)
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
        .width(60)
        .height(60)
        .bindMenu(this.MoreMenu())
        .backgroundColor($r('sys.color.icon_emphasize'))
    }
    .height('100%')
    .width('100%')
    .hitTestBehavior(HitTestMode.None)
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Bottom)
    .padding({ right: 24, bottom: 80 })
  }

  /**
   * 标题栏右上角切换局部深浅色开关
   */
  @Builder
  SwitchColorMode2() {
    Column() {
      TabSegmentButtonV2({
        items: this.symbolItems,
        selectedIndex: this.useAppInfo.switchColorModeIndex!!,
        onItemClicked: (index: number) => {
          this.useAppInfo.switchColorModeIndexManager(index);
        },
      })
    }
    .justifyContent(FlexAlign.Center)
    .height('auto')
    .width('100%')
    .padding({ left: 16, right: 16 })
    .constraintSize({ maxWidth: 450 })
    .flexGrow(8)
  }

  private readonly hdsNavigationTitleBarOptions: HdsNavigationTitleBarOptions = {
    content: {
      title: { mainTitle: '颜色' },
      bottomBuilder: {
        builder: () => this.SwitchColorMode2()
      },
      menu: {
        value: [{
          content: {
            icon: $r('sys.symbol.magnifyingglass'),
            label: '󰀩',
            action: () => {},
            type: TextStyleMode.NORMAL
          }
        }]
      }
    }
  }

  private readonly dynamicHideParams: DynamicHideParams = {
    hideTitleArea: true,
    mode: HideMode.SCROLL_UP,
    hideStatusBar: false
  }

  build() {

    HdsNavDestination() {
      Stack() {

          Column() {
            List({ scroller: this.mainScroller }) {
              ListItemGroup({ footer: this.IsEnd() }) {
                // 批量加载 ListItem
                Repeat(ColorSysResourse)
                  // .virtualScroll({
                  //   onTotalCount: () => ColorSysResourse.length
                  // })
                  .each((obj) => {
                    this.ListItemColorChunk(100, '100%', obj.item, String(obj.index + 1), ColorSysString[obj.index],
                      obj.index, obj.index)
                  })
              }
              .padding({
                right: 16,
                left: 16,
                top: 56*3,
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

          }
          .overlay(this.myOverlay())

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
    .titleBar(this.hdsNavigationTitleBarOptions)
    .dynamicHideTitleBar(this.dynamicHideParams)
  }

}