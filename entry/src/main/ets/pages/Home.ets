import { Initialize } from '../common/Index';
import { common } from '@kit.AbilityKit';


@ComponentV2
export struct Home {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private useInitialize: Initialize = new Initialize(Initialize.getContext(this));

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  aboutToAppear(): void {
    try {
      this.useInitialize.Init();
    } catch (_) {
      console.error('[Home] 初始化失败！')
    }
  }

  build() {
    Navigation(this.mainNavPathStack){
      Column() {
        Button('Color', { type: ButtonType.Normal })
          .onClick(() => {
            this.mainNavPathStack.pushPath({
              name: 'Colors'
            })
          })
      }
      .width('100%')
      .height('100%')
    }
    .title('主页')
  }
}