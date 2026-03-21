import { SegmentButtonV2Items, TabSegmentButtonV2, Binding } from "@kit.ArkUI";
import { ConfigurationConstant } from '@kit.AbilityKit';
import {
  AppInfo,
  ClientGlobalPrefKeys,
  ColorModeSwitch,
  PreferencesControl,
  SwitchColorModeIndex
} from "../common/Index";
import type { common } from '@kit.AbilityKit';

export {
  ISwitchColorMode2ParamOptions,
  SegmentButtonV2Items,
  SwitchColorMode2MaxWidth,
  SwitchColorMode2Param,
  SwitchColorMode2,
  SYMBOL_ITEMS
}

interface ISwitchColorMode2ParamOptions {
  uiContext: common.UIAbilityContext;
  index?: SwitchColorModeIndex;
  onItemClicked?: Callback<number, void>;
  padding?: Length | Padding | LocalizedPadding;
  constraintSize?: ConstraintSizeOptions;
}

const SYMBOL_ITEMS: SegmentButtonV2Items = new SegmentButtonV2Items([
  { symbol: $r('sys.symbol.circle_filled_and_circle') },
  { symbol: $r('sys.symbol.sun_max_fill') },
  { symbol: $r('sys.symbol.moon_fill') }
]);

const SwitchColorMode2MaxWidth: number = 450;
/**
 * 切换颜色模式条的参数
 */
class SwitchColorMode2Param {
  public uiContext: common.UIAbilityContext;
  public index: SwitchColorModeIndex = 0;
  public onItemClicked: Callback<number, void> = () => {};
  public padding: Length | Padding | LocalizedPadding = {
    left: 8, right: 8
  };
  public constraintSize: ConstraintSizeOptions = {
    maxWidth: SwitchColorMode2MaxWidth
  };
  private usePreferencesControl: PreferencesControl;
  private useColorModeSwitch: ColorModeSwitch;

  constructor(param: ISwitchColorMode2ParamOptions) {
    this.uiContext = param.uiContext;
    this.usePreferencesControl  = new PreferencesControl(this.uiContext);
    this.useColorModeSwitch     = new ColorModeSwitch(this.uiContext);
    this.index = param?.index ?? this.index;
    this.onItemClicked = param?.onItemClicked ?? this.onItemClicked;
    this.padding = param?.padding ?? this.padding;
    this.constraintSize = param?.constraintSize ?? this.constraintSize;
  }
  /**
   * 切换颜色模式条的控制器
   */
  public switchColorModeIndexManager(index: number, appInfo: AppInfo) {
    const prefPutManager = (colorMode: ConfigurationConstant.ColorMode) => {
      this.usePreferencesControl.prefPut(
        ClientGlobalPrefKeys.PREF_NAME,
        ClientGlobalPrefKeys.COLOR_MODE_LOCAL_IN_APP,
        colorMode
      );
    }
    switch (index) {
      // 设置浅色
      case SwitchColorModeIndex.Light:
        this.useColorModeSwitch.setLight();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        return appInfo.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      // 设置深色
      case SwitchColorModeIndex.Dark:
        this.useColorModeSwitch.setDark();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        return appInfo.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      // 跟随系统
      default:
        this.useColorModeSwitch.setFollowSystem();
        prefPutManager(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        return appInfo.colorModeLocalInApp = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    }
  }

}




/**
 * 标题栏底部切换局部深浅色开关
 */
@Builder
function SwitchColorMode2(param: Binding<SwitchColorMode2Param>) {
  Column() {
    TabSegmentButtonV2({
      items: SYMBOL_ITEMS,
      selectedIndex: param.value.index!!,
      onItemClicked: param.value.onItemClicked,
    })
  }
  .justifyContent(FlexAlign.Center)
  .height('auto')
  .width('100%')
  .padding(param.value.padding)
  .constraintSize(param.value.constraintSize)
  .flexGrow(8)
}