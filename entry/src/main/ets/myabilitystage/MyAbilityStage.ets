import { AbilityStage, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';

const TAG: string = '[MyAbilityStage]';
const DOMAIN_NUMBER: number = 0xFF00;

export interface CurrentModeData {
  themeMode: ConfigurationConstant.ColorMode | undefined
}


export default class EnvAbilityStage extends AbilityStage {
  onCreate(): void {

  }

  onConfigurationUpdate(newConfig: Configuration): void {
    hilog.info(DOMAIN_NUMBER, TAG, `系统环境初始化, 颜色模式: ${newConfig.colorMode}`);

    super.onConfigurationUpdate(newConfig);
    // 获取当前主题模式
    const currentMode: ConfigurationConstant.ColorMode | undefined = newConfig.colorMode;
    // 通过事件总线通知所有页面
    const event: emitter.InnerEvent = {
      eventId: 1001, // 自定义事件ID
    };
    const currentModeData: CurrentModeData = {
      themeMode: currentMode
    }
    emitter.emit(event, { data: currentModeData });

  }

}