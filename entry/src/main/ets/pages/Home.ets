import { AppInfo } from '../common/Index'
import App from '@system.app';
import { AppStorageV2 } from '@kit.ArkUI';

export interface NavHomeParm {
  isColors?: boolean;
  systemTransition?: NavigationSystemTransitionType;
}

@ComponentV2
export struct Home {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(AppInfo.getContext(this)))!;

  build() {
    Navigation(this.mainNavPathStack){
      List() {
        ListItem()
          .height(16)
        ListItemGroup({ style: ListItemGroupStyle.CARD }) {
          ListItem({ style: ListItemStyle.CARD }) {
            Column() {
              Column() {
                Image($r('app.media.color2'))
                  .objectFit(ImageFit.Cover)
                  .draggable(false)
              }
              .height(200)
              .width('100%')

              Row() {
                Text('颜色')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.ohos_id_color_foreground'))
                Blank()
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .padding({ left: 8, right: 8 })
                  .fontSize(20)
                  .fontColor([$r('sys.color.ohos_id_color_secondary')])
              }
              .justifyContent(FlexAlign.Start)
              .height('auto').width('100%')
              .padding({left: 16, right: 16, top: 30, bottom: 30})
            }
            .height('auto').width('100%')
          }
          .onClick(() => {
            const param: NavHomeParm = {
              isColors: true
            }
            if (!this.useAppInfo.isLoadDown) {
              console.info('[Home] 跳转到Loading isLoadDown' + this.useAppInfo.isLoadDown)
              this.mainNavPathStack.pushPath({
                name: 'Loading',
                param: param
              }, true);
            } else {
              console.info('[Home] 跳转到Colors isLoadDown' + this.useAppInfo.isLoadDown)
              this.mainNavPathStack.pushPath({
                name: 'Colors',
                param: param
              }, true);
            }
          })
          .height('auto').width('100%')
          .padding(0)
          .clip(true)
        }
        .height('auto').width('100%')
        .padding(0)

      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .height('100%')
    .title('主页')
    .ignoreLayoutSafeArea()
    .mode(NavigationMode.Stack)
  }
}