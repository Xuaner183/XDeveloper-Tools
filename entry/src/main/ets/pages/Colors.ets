import { ColorSysResourse, ColorSysString } from '../common/Index';

@Builder export function ColorsBuilder() {
  Colors();
}

@Extend(Text) function TextStyle() {
  .fontColor(Color.White)
    .textShadow({
      radius: 8,
    })
}

@ComponentV2
struct Colors {
  private mainNavPathStack: NavPathStack = new NavPathStack();


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
      Column() {
        Text(text1)
          .TextStyle()
        Text(text2)
          .TextStyle()
      }
      .height(height)
      .width(width)
      .backgroundColor(backgroundColor)
      .borderRadius(16)
      .foregroundColor(ColoringStrategy.AVERAGE)
      .justifyContent(FlexAlign.SpaceEvenly)
      .shadow(ShadowStyle.OUTER_DEFAULT_MD)
      .zIndex(zIndex)
    }
    .width('100%')
    .height('auto')
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          ListItemGroup() {
            Repeat(ColorSysResourse)
            // .template('temp', (obj) => {
            //   this.ListItemColorChunk(100, 100, obj.item, `${obj.index}`, `${obj.item}`);
            // })
            // .templateId((_) => {
            //   return 'temp'
            // })
              .virtualScroll({
                totalCount: ColorSysResourse.length
              })
              .each((obj) => {
                this.ListItemColorChunk(100, '90%', obj.item, String(obj.index), ColorSysString[obj.index], obj.index)
              })
          }
        }
        .width('100%')
        .height('auto')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .linearGradient({
        angle: 180,
        colors: [['#ff232428', 0.0], ['#ff454548', 1]]
      })
    }
    .onReady((ctx) => {
      this.mainNavPathStack = ctx.pathStack;
    })
  }
}