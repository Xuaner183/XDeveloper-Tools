import { StringUtils } from '../common/Index';
import { TextOverlayStyle } from '../attributemodifier/Index';
import { Binding } from '@kit.ArkUI';

export {
  TextOverlayParam,
  TextOverlay
}

interface TextOverlayParam {
  resourceIndexString: string | Resource | undefined;
  resourceName: string;
}

@Builder
function TextOverlay(param: Binding<TextOverlayParam>) {
  Column() {
    Column() {
      Row() {
        Button(
          param.value.resourceIndexString,
          { type: ButtonType.Capsule, stateEffect: false, controlSize: ControlSize.SMALL }
        )
          .backgroundColor('#fffd2872')
          .constraintSize({ minWidth: 30, minHeight: 30 })
          .fontWeight(FontWeight.Bold)
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)
          .maxFontScale(1)
      }
      .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
      .alignSelf(ItemAlign.Start)
      Blank()
        .flexGrow(1)
        .flexShrink(8)
    }
    .width('100%')
    Column() {
      Text(StringUtils.addZeroWidthSpaceToString(param.value.resourceName))
        .attributeModifier(new TextOverlayStyle())
        .width('auto')
        .height(LayoutPolicy.matchParent)
        .baselineOffset(8)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .flexGrow(3)
  }
  .padding(4)
  .width('100%').height('100%')
}