


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

/**
 * ListItem包含标题和1副标题
 */
@ComponentV2
export struct CustomListItemCardWithTitle2AndSub {
  @Require @Param public title: string | Resource;
  @Param public sub?: string | Resource = undefined;
  @Param public onClickList?: () => void = () => {};
  @Param public toggleIsOn?: boolean = undefined;
  @Param public onChangeToggle?: (v: boolean) => void = () => {};
  @Param public isGo?: boolean = false;
  @Param public isWarningText?: boolean = false;

  build() {
    ListItem({ style: ListItemStyle.CARD }) {
      Row() {
        Column({ space: $r('sys.float.ohos_id_text_margin_vertical') }) {
          if (!this.isWarningText) {
            Text(this.title)
              .listItemText1()
          }
          if (this.isWarningText){
            Text(this.title)
              .listItemText1Important()
          }
          if (this.sub) {
            Text(this.sub)
              .listItemText2()
          }
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        if (this.toggleIsOn !== undefined) {
          Row() {
            Toggle({ type: ToggleType.Switch, isOn: this.toggleIsOn })
              .margin({ left: 8, right: 2 })
              .onChange(this.onChangeToggle)
              // .selectedColor($r('app.color.theme_color'))
          }
        }
        // 显示右箭头
        if (this.isGo) {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.ohos_id_color_fourth')])
              .fontSize(24)
              .margin({ left: 4, right: 2 })
          }
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .padding({ left: 8, right: 8, top: 16, bottom: 16 })
    .align(Alignment.Start)
    .height('auto')
    .backgroundColor($r('sys.color.ohos_id_list_background_color'))
    .onClick(this.onClickList)
  }
}