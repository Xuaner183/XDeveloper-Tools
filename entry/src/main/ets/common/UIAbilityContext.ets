import { common } from '@kit.AbilityKit';
export { type common } from '@kit.AbilityKit';

/**
 *  介绍：类需要获取UIAbility组件的上下文
 *
 *  使用：
 *  1. 实例class后在组件struct函数中
    private getContext(): common.UIAbilityContext {
            return this.getUIContext().getHostContext() as common.UIAbilityContext
   }
   2. 调用本 setUIAbilityContext 传入getContext()
 *
 */
export class UIAbilityContext {
  public uiContext: common.UIAbilityContext;

  /**
   * 在实例组件传入this获取上下文
   */
  static getContext(baseCustomComponent: BaseCustomComponent): common.UIAbilityContext {
    return baseCustomComponent.getUIContext().getHostContext() as common.UIAbilityContext
  }

  constructor(uiContext: common.UIAbilityContext) {
    this.uiContext = uiContext
  }
}