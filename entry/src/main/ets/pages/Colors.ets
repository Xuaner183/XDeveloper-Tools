import { ColorSysResourse, ColorSysString } from '../common/Index';


@Extend(Text) function TextStyle() {
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

@Builder export function ColorsBuilder() {
  Colors();
}


@Preview
@ComponentV2
struct Colors {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private mainScroller: Scroller = new Scroller();

  @Builder BackgroundMosaic() {
    Image($r('app.media.mosaic'))
      .height('681px').width('681px')
      .objectRepeat(ImageRepeat.XY)
  }

  @Builder TextOverlay(
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

        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
          Rect({ width: '100%', height: '100%' })
            .fill(backgroundColor)
            .radius(14.4)
        }
        .height(height)
        .width(width)
        .zIndex(zIndex)
        .backgroundImage($r('app.media.mosaic'),{
          repeat: ImageRepeat.XY
        })
        .backgroundImagePosition(Alignment.Center)
        .borderRadius(16)
        .overlay(this.TextOverlay(text1, text2))
        .shadow(ShadowStyle.OUTER_DEFAULT_MD)
        // .clip(true)
    }
    .width('100%')
    .height('auto')
    .clickEffect({ level: ClickEffectLevel.LIGHT })
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    NavDestination() {
      Column() {
        Scroll(this.mainScroller) {
          Column() {
            Column()
              .height(120)
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
              .padding({ right: 16, left: 16, bottom: 120 })
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
        colors: [['#ff232428', 0.0], ['#ff454548', 1]]
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
  }
}