import { Initialize } from '../common/Index';
import { common } from '@kit.AbilityKit';

export interface NavHomeParm {
  isColors?: boolean;
  systemTransition?: NavigationSystemTransitionType;
}

@ComponentV2
export struct Home {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  // private useInitialize: Initialize = new Initialize(Initialize.getContext(this));

  // private getContext(): common.UIAbilityContext {
  //   return this.getUIContext().getHostContext() as common.UIAbilityContext
  // }

  // aboutToAppear(): void {
    // try {
    //   this.useInitialize.Init();
    // } catch (_) {
    //   console.error('[Home] 初始化失败！')
    // }
  // }

  build() {
    Navigation(this.mainNavPathStack){
      Column() {
        Button('Color', { type: ButtonType.Normal })
          .onClick(() => {
            const param: NavHomeParm = {
              isColors: true
            }
            this.mainNavPathStack.pushPath({
              name: 'Loading',
              param: param
            })
          })
      }
      .width('100%')
      .height('100%')
    }
    .title('主页')
  }
}