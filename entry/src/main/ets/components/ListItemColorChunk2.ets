import { Binding, UIUtils } from '@kit.ArkUI';
import { ColorSysResource, ColorSysString } from '../common/Index';
import { TextOverlayParam, TextOverlay } from './TextOverlay';

export { bindSheetOpt, ListItemColorChunk2Param, ListItemColorChunk2 }


interface bindSheetOpt {
  isShow: boolean, builder: CustomBuilder, options: SheetOptions | undefined
}

class ListItemColorChunk2Param {
  public height: Length = 100;
  public width: Length = '100%';
  public repeatItem: RepeatItem<number> = {
    item: 0,
    index: -1
  };
  public onClick: (event: ClickEvent) => void = () => {}
  public bindSheet: bindSheetOpt;

  constructor(
    height: Length = 100,
    width: Length = '100%',
    repeatItem: RepeatItem<number>,
    binSheet: bindSheetOpt,
    onClick: (event: ClickEvent) => void = () => {}
  ) {
    this.height = height;
    this.width = width;
    this.repeatItem = repeatItem;
    this.bindSheet = binSheet;
    this.onClick = onClick;
  }
}


@Builder function ListItemColorChunk2(param: Binding<ListItemColorChunk2Param>) {
  ListItem() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceEvenly,
      alignItems: ItemAlign.Center
    }) {
      Rect({ width: '100%', height: '100%' })
        .fill(ColorSysResource()[param.value.repeatItem.item])
        .radius(14.4)
    }
    .height(100)
    .width('100%')
    .zIndex(param.value.repeatItem.index)
    .backgroundImage($r('app.media.mosaic'), {
      repeat: ImageRepeat.XY
    })
    .backgroundImagePosition(Alignment.Center)
    .borderRadius(16)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
    .overlay(TextOverlay(UIUtils.makeBinding<TextOverlayParam>(() => {
      const textOverlayParam: TextOverlayParam = {
        resourceIndexString: String(param.value.repeatItem.item + 1),
        resourceName: ColorSysString[param.value.repeatItem.item]
      }
      return textOverlayParam;
    })))

  }
  .width('100%')
  .height('auto')
  .clickEffect({ level: ClickEffectLevel.LIGHT })
  .padding({ top: 8, bottom: 8 })
  .onClick(param.value.onClick)
  .bindSheet(
    // this.useAppInfo.searchPageModalOpen[param.value.repeatItem.item]!!,
    // ColorsDetailBuilder(
    //   ColorSysResource()[param.value.repeatItem.item],
    //   String(param.value.repeatItem.item + 1),
    //   ColorSysString[param.value.repeatItem.item],
    //   param.value.repeatItem.item
    // ),
    // {
    //   title: { title: '颜色详细' },
    //   dragBar: true,
    //   height: SheetSize.MEDIUM,
    //   detents: [SheetSize.MEDIUM, SheetSize.LARGE],
    //   enableOutsideInteractive: false
    // }
    param.value.bindSheet.isShow ?? undefined,
    param.value.bindSheet.builder ?? undefined,
    param.value.bindSheet.options ?? undefined
  )
}