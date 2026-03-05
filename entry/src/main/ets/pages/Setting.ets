import { AppStorageV2, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI';
import { AppInfo } from '../common/Index';
import { HdsNavDestination } from '@kit.UIDesignKit';
import lazy { AboutBuilder } from './About';

@Builder export function SettingBuilder() {
  Setting();
}


/**
 * 列表样式
 */
@Extend(Text)
function listItemText1() {
  .fontColor($r('sys.color.ohos_id_color_text_primary'))
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .fontWeight(FontWeight.Medium)
}
@Extend(Text)
function listItemText1Important() {
  .fontColor($r('sys.color.ohos_id_color_warning'))
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .fontWeight(FontWeight.Medium)
}

@Extend(Text)
function listItemText2() {
  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
  .fontSize($r('sys.float.ohos_id_text_size_body2'))
}



@ComponentV2
export struct Setting {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(AppInfo.getContext(this)))!;
  @Local private symbolItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { icon: $r('app.media.routine') },
    { symbol: $r('sys.symbol.sun_max_fill') },
    { symbol: $r('sys.symbol.moon_fill') }
  ]);
  @Local private isModalShow: boolean = false;

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
    .width('auto')
  }

  @Styles ListItemStyle() {
    .padding({ left: 8, right: 8 })
    .align(Alignment.Start)
    .height('auto')
    .width('100%')
    .constraintSize({ maxWidth: 608 })
  }

  @Builder Title1(text: string | Resource) {
    ListItem() {
      Column() {
        Text(text)
          .fontSize($r('sys.float.ohos_id_text_size_over_line'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ left: 10, right: 10 })
    .height('auto')
    .constraintSize({ maxWidth: 608 })
    .margin({ left: 14, right: 14, top: 10, bottom: 10 })
  }



  build() {
    HdsNavDestination() {
      Column() {
        List() {
          // 顶部间距
          ListItem()
          .height(80)

          this.Title1('颜色')
          ListItemGroup({ style: ListItemGroupStyle.CARD }) {
            ListItem({ style: ListItemStyle.CARD }) {
              Row() {
                Column() {
                  Text('颜色模式')
                    .listItemText1()
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ top: 16, bottom: 16 })

                Blank()
                this.SwitchColorMode()
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .ListItemStyle()
          }

          ListItem()
            .height(16)

          this.Title1('应用')
          ListItemGroup({ style: ListItemGroupStyle.CARD }) {
            ListItem({ style: ListItemStyle.CARD }) {
              Row() {
                Column() {
                  Text('关于')
                    .listItemText1()
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ top: 16, bottom: 16 })
                Blank()
                Row() {
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontColor([$r('sys.color.ohos_id_color_fourth')])
                    .fontSize(24)
                    .margin({ left: 4, right: 2 })
                }
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .onClick(() => { this.isModalShow = true })
            .bindSheet(
              this.isModalShow!!,
              AboutBuilder,
              {
                title: { title: '关于' },
                onDisappear: () => { this.isModalShow = false },
                enableOutsideInteractive: false
              }
            )
            .ListItemStyle()
          }


          ListItem().height(120)

        }
        .alignListItem(ListItemAlign.Start)
        .width('100%')
        .height('auto')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .flexGrow(8)
      }
      .width('100%').height('100%')
    }
    // .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
    // .title('设置', {
    //   backgroundBlurStyle: BlurStyle.Thin,
    //   barStyle: BarStyle.STACK
    // })
    .titleBar({
      content: {
        title: { mainTitle: '设置' }
      }
    })
    .onReady((ctx: NavDestinationContext) => {
      this.mainNavPathStack = ctx.pathStack
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
