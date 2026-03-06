@Builder export function LikeBuilder() {
  Like();
}

@ComponentV2
export struct Like {
  build() {
    NavDestination() {
      Column() {
        List() {
          ListItem()
            .height($r('sys.float.ohos_id_elements_margin_vertical_m'))

          ListItemGroup() {
            ListItem() {
              Column() {
                Column() {
                  Text('如果这个项目对你有帮助，可以扫码赞助支持开发。')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                }
                .padding({ bottom: 24 })

                Row() {
                  Image($r('app.media.wechatpay_qrcode'))
                    .width('50%')
                  Image($r('app.media.alipay_qrcode'))
                    .width('50%')
                }
                .width('100%')
                .height('auto')
              }
              .width('100%')
            }
          }

          ListItem()
            .height(100)
        }
        .padding({ left: 14, right: 14 })
        .height('auto')
        .width('100%')
        .flexGrow(2)
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor($r('sys.color.comp_background_model_sheet'))
  }
}