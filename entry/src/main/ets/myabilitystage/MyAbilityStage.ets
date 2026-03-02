import { AbilityStage, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { OnListen } from '../common/OnListen'

const TAG: string = '[MyAbilityStage]';
const DOMAIN_NUMBER: number = 0xFF00;

export interface CurrentModeData {
  themeMode: ConfigurationConstant.ColorMode | undefined
}


export default class EnvAbilityStage extends AbilityStage {
  onCreate(): void {
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    hilog.info(DOMAIN_NUMBER, TAG, `onConfigurationUpdate回调, 颜色模式: ${newConfig.colorMode}`);

    // 判断是否是深色模式
    const useOnListen = AppStorageV2.connect<OnListen>(OnListen, () => new OnListen())!;
    if (newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      useOnListen.isDarkMode = true;
    } else {
      useOnListen.isDarkMode = false;
    }

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