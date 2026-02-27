/**
 import { AppStorageV2 } from '@kit.ArkUI';
 useOnListen = AppStorageV2.connect<OnListen>(OnListen, () => new OnListen())!;

 */

@ObservedV2
export class OnListen {
  // 是否是深色模式
  @Trace public isDarkMode: boolean = false;
}