import { ColorSysResourse, ColorSysString, AppInfo, OnListen, ColorType, ColorArray } from '../common/Index';
import { TabSegmentButtonV2, SegmentButtonV2Items, SymbolGlyphModifier, LengthMetrics } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { AppStorageV2, LengthUnit } from '@kit.ArkUI';
import lazy { ColorsDetailBuilder } from './ColorsDetail';
import { picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import {
  DynamicHideParams,
  HdsNavDestination,
  HdsNavigationTitleBarOptions,
  HideMode
} from '@kit.UIDesignKit';

// 标题栏根据页面宽度设置左右间距
// 单位vp
enum TitlePadding {
  Less = 16,
  Greater = 32,
  Default = 24
}

enum MatchingMode {
  ResourceName,
  Rgba,
  Rrggbbaa,
  Aarrggbb,
  Hex,
  Cmyk,
  Hsl,
  Hsv
}


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
  RRGGBBAA: ColorType.RRGGBBAA;
  AARRGGBB: ColorType.AARRGGBB;
  HEX: ColorType.HEX;
  CMYK: ColorType.CMYK;
  HSL: ColorType.HSL;
  HSV: ColorType.HSV;
}

interface PlaceholderObj {
  default: ResourceStr,
  rgba: ResourceStr,
  rrggbbaa: ResourceStr,
  aarrggbb: ResourceStr,
  hex: ResourceStr,
  cmyk: ResourceStr,
  hsl: ResourceStr,
  hsv: ResourceStr,
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


@ComponentV2
struct Colors {
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.getContext()))!;
  // private useOnListen = AppStorageV2.connect<OnListen>(OnListen, () => new OnListen())!;
  private readonly symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { icon: $r('app.media.routine') },
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private mainScroller: Scroller = new Scroller();
  private readonly saveIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.save'));
  @Local private isSearchPageShow: boolean = false;
  // 搜索框内容
  @Local private searchText: string = '';
  // 标题栏间距
  @Local private titleBarPadding: number = TitlePadding.Default;
  // 搜索结果
  @Local private searchResultIndex: number[] | undefined = undefined;
  // 窗口宽度检测
  @Local private windowWith: number = 320;
  // 是否需要拦截返回操作
  private isStopBackPress: boolean = false;
  // search组件控制器
  private searchController: SearchController = new SearchController();
  // 搜索筛选模式
  @Local private matchingMode: MatchingMode = MatchingMode.ResourceName;
  // 搜索框占位符文本
  private readonly placeholderObj: PlaceholderObj = {
    default: '按资源名称搜索',
    rgba: '按RGBA搜索',
    rrggbbaa: '按#RRGGBBAA搜索',
    aarrggbb: '按#AARRGGBB搜索',
    hex: '按HEX搜索',
    cmyk: '按CMYK搜索',
    hsl: '按HSL搜索',
    hsv: '按HSV搜索',
  }
  // 搜索筛选按钮名称
  private readonly leiBieString: ResourceStr[] = [
    '资源名称',
    'RGBA',
    '#RRGGBBAA',
    '#AARRGGBB',
    'HEX',
    'CMYK',
    'HSL',
    'HSV'
  ]
  /**
   * 搜索页路由标题栏配置
   */
  private readonly searchTitleOptions: HdsNavigationTitleBarOptions = {
    content: {
      // title: { mainTitle: '搜索' },
      stackBuilder: () => this.SearchBox(),
      bottomBuilder: {
        builder: () => this.SwitchColorMode2()
      },
      backIcon: {
        action: () => {
          this.searchPageBack();
        }
      }
    }
  }

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  /**
   * 导出所有颜色为JSON文件
   */
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
            RGBA: darkOrLight[ColorArray.RgbaArray][i],
            RRGGBBAA: darkOrLight[ColorArray.RrggbbaaArray][i],
            AARRGGBB: darkOrLight[ColorArray.AarrggbbArray][i],
            HEX: darkOrLight[ColorArray.HexArray][i],
            CMYK: darkOrLight[ColorArray.CmykArray][i],
            HSL: darkOrLight[ColorArray.HslArray][i],
            HSV: darkOrLight[ColorArray.HsvArray][i]
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
  /**
   * 判断并输出搜索框占位符
   * @param value
   * @returns
   */
  private outSearchPlaceholder(value: MatchingMode): ResourceStr {
    switch (value) {
      case MatchingMode.ResourceName:
        return this.placeholderObj.default;
      case MatchingMode.Rgba:
        return this.placeholderObj.rgba;
      case MatchingMode.Rrggbbaa:
        return this.placeholderObj.rrggbbaa;
      case MatchingMode.Aarrggbb:
        return this.placeholderObj.aarrggbb;
      case MatchingMode.Hex:
        return this.placeholderObj.hex;
      case MatchingMode.Cmyk:
        return this.placeholderObj.cmyk;
      case MatchingMode.Hsl:
        return this.placeholderObj.hsl;
      case MatchingMode.Hsv:
        return this.placeholderObj.hsv;
    }
  }
  /**
   * 搜索页返回时触发动画
   */
  private searchPageBack() {
    this.getUIContext().animateTo({ duration: 350, curve: Curve.Friction }, () => {
      this.isSearchPageShow = false;
    })
  }

  /**
   * 颜色页标题栏配置
   */
  private readonly hdsNavigationTitleBarOptions: HdsNavigationTitleBarOptions = {
    content: {
      title: { mainTitle: '颜色' },
      bottomBuilder: {
        builder: () => this.SwitchColorMode2()
      },
      stackBuilder: () => this.TitleMenu()
    }
  }
  /**
   * 颜色页标题栏自动隐藏配置
   */
  private readonly dynamicHideParams: DynamicHideParams = {
    hideTitleArea: true,
    mode: HideMode.SCROLL_UP,
    hideStatusBar: false
  }

  /**
   * 搜索页匹配input结果,输出Index
   * @param keyWord
   * @param mode
   * @returns
   */
  private searchItemInIndex(keyWord: string, mode: MatchingMode): number[] | undefined {
    if (!keyWord) { return }
    console.info(`[Search] 匹配模式: ${mode}`);
    console.info(`[Search] 匹配keyWord: ${keyWord}`)
    const COLOR_VALUE = this.useAppInfo.COLOR_VALUE;
    // 将关键词全转小写
    const value: string = keyWord.toLowerCase();
    const resultIndex: number[] = [];
    console.info(`[Search] 小写keyWord: ${value}`)

    const matchingResourceName = (arr: Array<string>) => {
      for (let i = 0; i < arr.length; i++) {
        if (arr[i].toLowerCase().includes(value)) {
          console.info(`[Search] 匹配到 ${arr[i]}`)
          resultIndex.push(i);
        }
      }
    }

    switch (mode) {
      case MatchingMode.ResourceName:
        matchingResourceName(ColorSysString);
        break;
      case MatchingMode.Rgba:
        matchingResourceName(COLOR_VALUE[0][ColorArray.RgbaArray]);
        matchingResourceName(COLOR_VALUE[1][ColorArray.RgbaArray]);
        break;
      case MatchingMode.Hex:
        matchingResourceName(COLOR_VALUE[0][ColorArray.HexArray]);
        matchingResourceName(COLOR_VALUE[1][ColorArray.HexArray]);
        break;
      case MatchingMode.Rrggbbaa:
        matchingResourceName(COLOR_VALUE[0][ColorArray.RrggbbaaArray]);
        matchingResourceName(COLOR_VALUE[1][ColorArray.RrggbbaaArray]);
        break;
      case MatchingMode.Aarrggbb:
        matchingResourceName(COLOR_VALUE[0][ColorArray.AarrggbbArray]);
        matchingResourceName(COLOR_VALUE[0][ColorArray.AarrggbbArray]);
      case MatchingMode.Cmyk:
        matchingResourceName(COLOR_VALUE[0][ColorArray.CmykArray]);
        matchingResourceName(COLOR_VALUE[1][ColorArray.CmykArray]);
        break;
      case MatchingMode.Hsl:
        matchingResourceName(COLOR_VALUE[0][ColorArray.HslArray]);
        matchingResourceName(COLOR_VALUE[1][ColorArray.HslArray]);
        break;
      case MatchingMode.Hsv:
        matchingResourceName(COLOR_VALUE[0][ColorArray.HsvArray]);
        matchingResourceName(COLOR_VALUE[1][ColorArray.HsvArray]);
        break;
    }

    // console.log(`[Colors] 搜索未去重数组: ${resultIndex}`);
    const quChongResultIndex: number[] = Array.from(new Set(resultIndex));
    // console.log(`[Colors] 搜索已去重数组: ${quChongResultIndex}`);
    return quChongResultIndex;
  }

  /**
   * 判断窗口宽度决定列表列数
   * @returns
   */
  private outListLanes(): number {
    console.info('触发列数调整')
    // 第一个区间：宽度 <= 320，返回 1
    if (this.windowWith <= 320) {
      return 1;
    }
    // 后续区间：阈值每次增加 400，返回值每次增加 2
    const step = 400; // 阈值步长
    const baseThreshold = 321;  // 第一个非特殊区间的起始宽度（>320）
    const index = Math.floor((this.windowWith - baseThreshold) / step); // 区间索引，从0开始
    return 2 * (index + 1); // 返回值：2, 4, 6, 8, ...
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
    index: number,
    isSearchPage: boolean = false
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
      isSearchPage ? this.useAppInfo.searchPageModalOpen[index]!! : this.useAppInfo.modalOpen[index]!!,
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
      Button('󰀵', { type: ButtonType.Circle })
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
   * 标题栏底部切换局部深浅色开关
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
    .padding({ left: this.titleBarPadding, right: this.titleBarPadding })
    .constraintSize({ maxWidth: 450 })
    .flexGrow(8)
  }
  /**
   * 颜色页标题栏右上角菜单
   */
  @Builder TitleMenu() {
    Row() {
      Button('󰀩', { buttonStyle: ButtonStyleMode.NORMAL })
        .onClick(() => {
          this.getUIContext().animateTo({ duration: 350, curve: Curve.Friction }, () => {
            this.isSearchPageShow = true;
          })
        })
        .fontSize(18)
        .fontColor($r('sys.color.ohos_id_color_primary'))
        .constraintSize({ minWidth: 22 })
        .geometryTransition('search', { follow: false })
        .transition(TransitionEffect.OPACITY)
    }
    .height('auto')
    .width('100%')
    .justifyContent(FlexAlign.End)
    .flexGrow(5)
    .padding({ left: this.titleBarPadding, right: this.titleBarPadding })
  }




  build() {

    HdsNavDestination() {
      Column() {

        Column() {
          List({ scroller: this.mainScroller }) {
            // 顶部间距
            ListItemGroup()
              .padding({ top: 56 * 3 })
            // 内容
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
            // 底部间距
            ListItemGroup()
              .padding({ bottom: 120 })
          }
          .width('100%')
          .height('auto')
          .padding({ right: this.titleBarPadding, left: this.titleBarPadding })
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .lanes(this.outListLanes(), 8)
          .alignListItem(ListItemAlign.Center)
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
    .bindContentCover(
      this.isSearchPageShow!!,
      this.SearchPage(),
      {
        modalTransition: ModalTransition.NONE,
        enableSafeArea: true,
        onWillDismiss: (_) => {
          if (this.isStopBackPress) {
            this.searchController.stopEditing();
          } else {
            this.searchPageBack();
          }
        },
        // 退出时重置默认筛选和清空文本
        onDisappear: () => {
          this.matchingMode = MatchingMode.ResourceName;
          this.searchText = '';
          this.searchResultIndex = undefined;
          },
        transition: TransitionEffect.OPACITY.animation({ duration: 350 })
      }
    )
    .onAreaChange((_, newValue: Area) => {
      console.info(`[Colors] 触发主组件区域变化`);
      const newWith = Number(newValue.width);
      this.windowWith = newWith;
      console.info(`[Colors] newWith = ${newWith}`);
      // 配置标题栏左右间距
      if (newWith < 600) {
        this.titleBarPadding = TitlePadding.Less;
      } else if (newWith >= 800) {
        this.titleBarPadding = TitlePadding.Greater;
      } else {
        this.titleBarPadding = TitlePadding.Default;
      }
    })
  }




  @Builder SearchBox() {
    Row() {
      Search({
        value: this.searchText!!,
        placeholder: this.outSearchPlaceholder(this.matchingMode),
        controller: this.searchController
      })
        .width('auto')
        .flexGrow(8)
        .margin({
          start: { value: this.titleBarPadding + 60, unit: LengthUnit.VP },
          end: { value: this.titleBarPadding, unit: LengthUnit.VP }
        })
        .geometryTransition('search')
        .transition(TransitionEffect.OPACITY)
        .onChange((value: string, previewText: PreviewText, options: TextChangeOptions) => {
          const indexArr: number[] | undefined = this.searchItemInIndex(value, this.matchingMode);
          this.searchResultIndex = indexArr;
        })
        .onSubmit((text: string) => {
          const indexArr: number[] | undefined = this.searchItemInIndex(text, this.matchingMode);
          this.searchResultIndex = indexArr;
        })
        .keyboardAppearance(KeyboardAppearance.IMMERSIVE)
        .onEditChange((v: boolean) => {
          this.isStopBackPress = v;
          console.info(`[Colors] 搜索框编辑状态：${v}`)
        })
        // 排除汉字
        .inputFilter('[^\u4e00-\u9fff]')
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('auto')
    .flexGrow(5)
  }

  /**
   * 搜索筛选组件
   */
  @LocalBuilder SearchFiltration() {
    Column() {
      Column() {
        Column() {
          Text('按类别搜索')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(18)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 8 })
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.Wrap,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween,
          space: { main: LengthMetrics.vp(6), cross: LengthMetrics.vp(4) }
        }) {
          Repeat(this.leiBieString)
            .each((obj) => {
              Button(obj.item, {
                buttonStyle: ButtonStyleMode.TEXTUAL,
                type: ButtonType.Normal
              })
                .borderRadius(8)
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .onClick(() => {
                  this.matchingMode = obj.index;
                })
            })
        }
        .width('100%')
      }
    }
    .padding({ top: 56})
    .width('100%')
    .height('auto')
  }
  /**
   * 搜索页主组件
   */
  @Builder SearchPage() {
    HdsNavDestination() {
      Column() {
        List() {
          // 顶部间距
          ListItemGroup()
            .padding({ top: 56 * 3 })
          if (!this.searchResultIndex || this.searchResultIndex.length <= 0) {
            ListItemGroup({ header: this.SearchFiltration() })
              .width('100%')
              .height(LayoutPolicy.wrapContent)
          }
          ListItemGroup() {
            // 循环加载搜索结果Index
            if (this.searchResultIndex && this.searchResultIndex.length > 0) {
              Repeat(this.searchResultIndex)
                .each((obj) => {
                  this.ListItemColorChunk(100, '100%', ColorSysResourse[obj.item], String(obj.item + 1),
                    ColorSysString[obj.item],
                    obj.index, obj.item, true);
                })
            }
          }
          // 底部间距
          ListItemGroup()
            .padding({ bottom: 120 })
        }
        .padding({ right: this.titleBarPadding, left: this.titleBarPadding })
        .width('100%')
        .height('auto')
        .flexGrow(3)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .lanes(this.outListLanes(), 8)
        .alignListItem(ListItemAlign.Center)
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
        .sticky(StickyStyle.Header)
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [[$r('app.color.background_linearGradient_color1'), 0.0],
          [$r('app.color.background_linearGradient_color2'), 1]]
      })
    }
    .expandSafeArea()
    .ignoreLayoutSafeArea()
    .titleBar(this.searchTitleOptions)
  }


}