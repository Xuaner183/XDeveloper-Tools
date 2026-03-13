import { HdsNavDestination, HdsNavigationTitleBarOptions, TextStyleMode } from '@kit.UIDesignKit';
import { TabSegmentButtonV2, SegmentButtonV2Items, AppStorageV2 } from '@kit.ArkUI';
import { AppInfo } from '../common/Index';

@Builder export function SearchItemBuilder() {
  SearchItem();
}


@ComponentV2
export struct SearchItem {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(AppInfo.getContext(this)))!;
  @Local text: string = '';
  private readonly symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { icon: $r('app.media.routine') },
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);
  // @Consumer('isSearchItemShow') private isSearchItemShow: boolean = false;

  private readonly hdsNavigationTitleBarOptions: HdsNavigationTitleBarOptions = {
    content: {
      title: { mainTitle: '搜索' },
      stackBuilder: this.SearchBox(),
      bottomBuilder: {
        builder: () => this.SwitchColorMode2()
      }
    }
  }

  @Builder SearchBox() {
    Row() {
      Search({
        value: this.text!!,
        placeholder: '搜索资源的名称和值'
      })
        .width('100%')
    }
    .width(LayoutPolicy.matchParent)
    .height(LayoutPolicy.matchParent)
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
    .padding({ left: 16, right: 16 })
    .constraintSize({ maxWidth: 450 })
    .flexGrow(8)
  }

  // aboutToDisappear(): void {
  //   console.info(`[SearchItem] 触发aboutToDisappear`);
  //   // this.isSearchItemShow = false;
  // }
  //
  // aboutToAppear(): void {
  //   console.info(`[SearchItem] 触发aboutToAppear`);
  // }

  build() {
    // HdsNavDestination() {
      Column() {
        Column(){
          Text('测试1')
        }
        .backgroundColor(Color.Orange)
        List() {

            ListItem() {
              Column() {
                Button('点击')
                Text('测试2')
                  .fontColor(Color.Red)
                  .fontSize(30)
              }
              .backgroundColor(Color.Yellow)
            }
            .backgroundColor(Color.Blue)
            .width('100%')
            .height(50)

          // .padding({
          //   right: 16,
          //   left: 16,
          //   // top: 56*3,
          //   bottom: 120
          // })
        }
        .width('100%')
        .height(100)
        .backgroundColor(Color.Pink)
        // .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        // .lanes({ minLength: 200, maxLength: 400 }, 8)
        // .alignListItem(ListItemAlign.Start)
        // .nestedScroll({
        //   scrollForward: NestedScrollMode.PARENT_FIRST,
        //   scrollBackward: NestedScrollMode.SELF_FIRST
        // })

      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Brown)
      // .linearGradient({
      //   angle: 180,
      //   colors: [[$r('app.color.background_linearGradient_color1'), 0.0],
      //     [$r('app.color.background_linearGradient_color2'), 1]]
      // })
    // }
    // .titleBar(this.hdsNavigationTitleBarOptions)
    // .onBackPressed(() => {
    //   console.info(`[SearchItem] 触发onBackPressed`);
    //   this.isSearchItemShow = false;
    //   return true;
    // })
  }
}