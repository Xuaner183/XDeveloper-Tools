import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { AppInfo } from '../common/Index';


@Builder export function AboutBuilder() {
  About();
}

@Preview
@ComponentV2
struct About {
  private mainNavPathStack: NavPathStack = new NavPathStack();

  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.getContext()))!;
  private appVersion?: string = this.useAppInfo.appVersion;
  private REPOSITORY_URL:string = '';

  private flexOption: FlexOptions = {
    direction: FlexDirection.Column,
    alignItems: ItemAlign.Center
  }

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private getResource(): string {
    try {
      const repositoryUrl: string = this.getContext().resourceManager.getStringSync($r('app.string.github_url').id);
      return this.REPOSITORY_URL = repositoryUrl;
    } catch (_) {
      return this.REPOSITORY_URL = '';
    }
  }

  aboutToAppear(): void {
    this.getResource();
  }

  build() {
    NavDestination() {
      Column() {
        List() {

          ListItem()
            .margin({ top: $r('sys.float.ohos_id_elements_margin_vertical_m') })

          ListItem() {
            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.Start
            }) {
              Flex(this.flexOption) {
                Image($r('app.media.app_icon'))
                  .height('80')
                  .width('80')
              }
              .width('100%')
              .height('auto')
              .margin({ top: 24, bottom: 16 })

              Flex(this.flexOption) {
                Text($r('app.string.EntryAbility_label'))
                  .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height('auto')
              .margin({ bottom: 24 })
            }
            .width('100%')
            .height('auto')
          }

          ListItemGroup({ style: ListItemGroupStyle.CARD }) {

            ListItem({ style: ListItemStyle.CARD }) {
              Column() {
                Column({ space: $r('sys.float.ohos_id_text_margin_vertical') }) {
                  Text('版本信息')
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontWeight(FontWeight.Medium)
                  Text(this.appVersion)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                }
                .margin({
                  left: 4,
                  right: 4,
                  top: 18,
                  bottom: 18
                })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .align(Alignment.Start)
            .height('auto')
            .backgroundColor($r('app.color.modal_card_background'))

            ListItem({ style: ListItemStyle.CARD }) {
              Row({ space:4 }) {
                Column({ space: $r('sys.float.ohos_id_text_margin_vertical') }) {
                  Text('仓库')
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontWeight(FontWeight.Medium)
                  Text($r('app.string.github_url'))
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  // .enableDataDetector(true) //超链接高亮
                }
                .width('auto')
                .margin({
                  left: 4,
                  right: 4,
                  top: 18,
                  bottom: 18
                })
                .alignItems(HorizontalAlign.Start)
                Blank()
                Row(){
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontColor([$r('sys.color.ohos_id_color_fourth')])
                    .fontSize(24)
                    .margin({right:2})
                }
              }
              .width('100%')
            }
            .align(Alignment.Start)
            .height('auto')
            .backgroundColor($r('app.color.modal_card_background'))
            .onClick(() => {
              this.getContext().openLink(this.REPOSITORY_URL)
            })

          }
          .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
          .backgroundColor($r('app.color.modal_card_background'))
          .margin({ left: 0, right: 0, top: 0 })
          .padding(4)
          .divider({
            strokeWidth: 1,
            color: $r('sys.color.ohos_id_color_subheading_separator'),
            startMargin: 12,
            endMargin: 12
          })

          ListItem()
            .height(100)
        }
        .alignListItem(ListItemAlign.Start)
        .width('100%')
        .height('auto')
        .flexGrow(2)

      }
      .height('100%')
      .width('100%')
      .padding({ left: 14, right: 14 })
    }
    .backgroundColor($r('sys.color.comp_background_model_sheet'))

  }
}