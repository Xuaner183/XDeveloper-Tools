import { AppStorageV2, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI';
import { AppInfo } from '../common/Index';

@Builder export function SettingBuilder() {
  Setting();
}

/**
 * 列表组卡片样式
 */
@Extend(ListItemGroup)
function listItemGroupCard() {
  .margin({
    left: 0,
    right: 0,
    top: 0,
    bottom: 12
  })
  .padding(4)
  .divider({
    strokeWidth: 1,
    color: $r('sys.color.ohos_id_color_subheading_separator'),
    startMargin: 12,
    endMargin: 12
  })
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

@Builder
function ListItemTitle1(title: string | Resource) {
  ListItemGroup({ style: ListItemGroupStyle.CARD }) {
    ListItem({ style: ListItemStyle.CARD }) {
      Column() {
        Text(title)
          .fontSize($r('sys.float.ohos_id_text_size_over_line'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
      .width('100%')
      .margin({
        left: 4,
        right: 4,
        top: 18,
        bottom: 18
      })
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor(Color.Transparent)
    .selected(false)
    .enabled(false)
  }
  .backgroundColor(Color.Transparent)
  .margin({ bottom: 0, top: 0 })
  .padding({ bottom: 0, top: 0 })
  .enabled(false)
  .offset({ y: 4 })
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

  @Builder Title1(text: string | Resource = '') {
    Row() {
      Text(text)
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .lineHeight(19)
        .width('100%')
    }
    .margin({
      left: 12,
      right: 12,
      top: 19.5,
      bottom: 9.5
    })
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          // 顶部间距
          ListItem()
          .height($r('sys.float.titlebar_default_height'))
          .margin({ top: $r('sys.float.ohos_id_elements_margin_vertical_m') })

          ListItemGroup() {
            ListItem() {
              Column() {
                Text('颜色')
                  .fontSize($r('sys.float.ohos_id_text_size_over_line'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              }
              .width('100%')
              .margin({
                left: 4,
                right: 4,
                top: 18,
                bottom: 18
              })
              .alignItems(HorizontalAlign.Start)
            }
          }

          ListItemGroup({ style: ListItemGroupStyle.CARD }) {
            ListItem({ style: ListItemStyle.CARD }) {
              Row() {
                Column({ space: $r('sys.float.ohos_id_text_margin_vertical') }) {
                  Text('颜色模式')
                    .listItemText1()
                }
                .alignItems(HorizontalAlign.Start)

                Blank()
                this.SwitchColorMode()
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .padding({
              left: 8,
              right: 8,
              top: 16,
              bottom: 16
            })
            .align(Alignment.Start)
            .height('auto')
          }
          .listItemGroupCard

          ListItem().height(120)

        }
        .margin({ left: 14, right: 14 })
        .alignListItem(ListItemAlign.Start)
        .width('auto')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%').height('100%')
    }
    .title('设置', {
      backgroundBlurStyle: BlurStyle.Thin,
      barStyle: BarStyle.STACK
    })
    .onReady((ctx: NavDestinationContext) => {
      this.mainNavPathStack = ctx.pathStack
    })
  }
}
