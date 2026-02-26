import { ColorsPageInit } from '../common/Index';
import { NavHomeParm } from './Home';

export interface NavLoadingParm {
  isLoadDown: boolean;
  systemTransition?: NavigationSystemTransitionType;
}

@Builder export function LoadingBuilder() {
  Loading();
}

@ComponentV2
export struct Loading {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private jianBianStyleColorsPage: LinearGradientOptions = {
    angle: 180,
    colors: [[$r('app.color.background_linearGradient_color1'), 0.0],
      [$r('app.color.background_linearGradient_color2'), 1]]
  }
  @Local private tipText: string = '加载中';
  private mainNavPathInfo?: NavPathInfo;
  private isColors: boolean = false;

  private async Init() {
    const useColorsPageInit = new ColorsPageInit(ColorsPageInit.getContext(this));
    const isSucceed = await useColorsPageInit.init();
    if (isSucceed) {
      const param: NavLoadingParm = {
        isLoadDown: true,
        // systemTransition: NavigationSystemTransitionType.DEFAULT
      }
      this.mainNavPathStack.pop(param);
    } else {
      this.tipText = '加载失败';
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          LoadingProgress()
            .enableLoading(true)
        }
        .width(100).height(100)
        Column(){
          Text(this.tipText)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      // .linearGradient(this.jianBianStyleColorsPage)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .onReady((ctx) => {
      this.mainNavPathStack = ctx.pathStack;
      if (ctx.pathInfo.param) {
        const param = ctx.pathInfo.param as NavHomeParm;
        if (param.isColors) {
          this.isColors = true;
        } else {
          this.tipText = '路由失败'
        }
      }
    })
    .onShown(() => {
      this.isColors && setTimeout(() => {
        this.Init()
      }, 1000);
    })
    .systemTransition(NavigationSystemTransitionType.NONE)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    .mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      this.mainNavPathStack.popToIndex(0);
      return true;
    })
  }
}