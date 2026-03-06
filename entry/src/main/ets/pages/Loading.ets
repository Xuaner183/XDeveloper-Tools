import { AppInfo, ColorsPageInit } from '../common/Index';
import { NavHomeParm } from './Home';
import { AppStorageV2 } from '@kit.ArkUI';

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
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(AppInfo.getContext(this)))!;
  @Local private tipText: string = '加载中';
  // private mainNavPathInfo?: NavPathInfo;
  private isColors: boolean = false;
  private isPush: boolean = true;

  private async Init() {
    // 清除已有计时器
    if (this.useAppInfo.pushColorsPageTimeId) {
      clearTimeout(this.useAppInfo.pushColorsPageTimeId);
      this.isPush = true;
    }
    const param: NavLoadingParm = {
      isLoadDown: true,
      // systemTransition: NavigationSystemTransitionType.DEFAULT
    }
    if (!this.useAppInfo.isLoadDown) {
      const useColorsPageInit = new ColorsPageInit(ColorsPageInit.getContext(this));
      const isSucceed = await useColorsPageInit.init();
      if (isSucceed) {
        this.useAppInfo.pushColorsPageTimeId = setTimeout(() => {
          if (this.isPush) {
            console.info(`[Loading] 加载成功, ${param.isLoadDown}`)
            this.mainNavPathStack.replacePath({
              name: 'Colors',
              param: param
            }, false);
          }
        }, 1000)
        this.useAppInfo.isLoadDown = true;
        console.info(`[Loading] isLoadDown = ${this.useAppInfo.isLoadDown}`)
      } else {
        this.tipText = '加载失败';
        console.info('[Loading] 加载失败')
      }
    } else {
      this.mainNavPathStack.replacePath({
        name: 'Colors',
        param: param
      }, true);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          LoadingProgress()
            .enableLoading(true)
            .color('#fff')
        }
        .width(100).height(100)

        Column() {
          Text(this.tipText)
            .fontColor('#ffefefef')
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      // .linearGradient(this.jianBianStyleColorsPage)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#ff343434')
    }
    .onReady((ctx) => {
      this.mainNavPathStack = ctx.pathStack;
      if (this.useAppInfo.isLoadDown) {
        this.mainNavPathStack.replacePath({
          name: 'Colors',
        }, true);
      }
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
      this.isColors && this.Init();
    })
    .systemTransition(NavigationSystemTransitionType.FADE)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM])
    // .mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      this.mainNavPathStack.clear(true);
      // 打断跳转Colors页计时器
      this.isPush = false;
      clearTimeout(this.useAppInfo.pushColorsPageTimeId);
      return true;
    })
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}