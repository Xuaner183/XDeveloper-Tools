import { common } from "@kit.AbilityKit";
import { AppStorageV2, LengthUnit } from '@kit.ArkUI';
import { AppInfo, ClientGlobalPrefKeys, PreferencesControl } from "../common/Index";

@Builder export function PrivacyPolicyDialogBuilder() {
  PrivacyPolicyDialog();
}

@Preview
@CustomDialog
export struct PrivacyPolicyDialog {
  public controller: CustomDialogController;
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(this.getContext()))!;
  public onAgree: () => void = () => {};
  public onCancel: () => void = () => {};

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  build() {
    Column() {
      List() {
        // ListItem() {
        //   Column().height(40)
        // }

        ListItem() {
          Column() {
            SymbolGlyph($r('sys.symbol.person_shield_fill'))
              .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
              .fontColor([$r('sys.color.icon_emphasize')])
              .fontSize(38)
              .padding({ bottom: 16 })
            Text('隐私政策')
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Bold)
              .fontSize(24)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }

        ListItem()
          .height(16)

        ListItem() {
          Column() {
            Text() {
              Span('欢迎使用 XDeveloper Tools。本应用为纯本地离线工具，不会收集、存储或上传任何个人信息，也不会连接任何服务器。\n为保障您的知情权，请您阅读我们的')
              Span('《隐私政策》')
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .onClick(() => {
                  this.getContext().openLink(this.useAppInfo.privacyPolicyUrl)!
                })
              Span('。\n继续使用本应用即表示您已阅读并同意该政策。')
            }
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            // .textAlign(TextAlign.JUSTIFY)
            .lineSpacing({ value: 4, unit: LengthUnit.VP })
          }
          .width('100%')
        }

        ListItem()
          .height(24)

        ListItem() {
          Row({ space: 8 }) {
            Button('取消', { buttonStyle: ButtonStyleMode.NORMAL })
              .width('auto')
              .flexGrow(2)
              .onClick(async () => {
                this.onCancel();
                this.controller.close();
              })
            Button('同意', { buttonStyle: ButtonStyleMode.EMPHASIZED })
              .width('auto')
              .flexGrow(2)
              .onClick(async () => {
                this.onAgree();
                this.controller.close();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      // .padding({ left: 14, right: 14 })
      .width('100%')
      .height('auto')
      .flexGrow(2)
    }
    .width('100%')
    .height('auto')
    .backgroundColor($r('sys.color.comp_background_model_sheet'))
    .padding(24)
  }
}