import { AppInfo, PreferencesControl, ClientGlobalPrefKeys } from '../common/Index'
import { AppStorageV2 } from '@kit.ArkUI';
import { bundleManager } from '@kit.AbilityKit';
import lazy { LikeBuilder } from './Like';
import { PrivacyPolicyDialog } from './PrivacyPolicyDialog';
import { common } from "@kit.AbilityKit";
import { ListTitle1, ListBox } from './Setting';
import { HdsNavigation, HdsNavigationTitleBarOptions } from '@hms.hds.hdsBaseComponent';

export interface NavHomeParm {
  isColors?: boolean;
  systemTransition?: NavigationSystemTransitionType;
}

@Styles function MyListItemStyle2() {
  .margin({ left: 12, right: 12 })
  .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
  .borderRadius(14)
  .padding(4)
}

@ComponentV2
export struct Home {
  private mainNavPathStack: NavPathStack = new NavPathStack();
  private usePM = new PreferencesControl(AppInfo.getContext(this));
  private useAppInfo: AppInfo = AppStorageV2.connect<AppInfo>(AppInfo, () => new AppInfo(AppInfo.getContext(this)))!;
  @Local private isMiniMode: boolean = false;
  @Local private isModalShow: boolean = false;

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  /**获取APP名称**/
  public async getAppName(): Promise<string> {
    const repositoryUrl: Promise<string | void> = AppInfo.getContext(this).resourceManager.getStringValue($r('app.string.app_name').id)
      .catch((e: BusinessError) => { console.error(`[DeviceClientInfo] 获取APP名称失败: ${e.message}`) });
    const appNameValue: string | void = await repositoryUrl;
    return appNameValue || '';
  }

  /**获取版本号**/
  public async getAppVersion(): Promise<string> {
    const bundleFlags: number = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    const bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleFlags);
    return bundleInfo.versionName;
  }

  private PrivacyPolicyDialog = new CustomDialogController({
    builder: PrivacyPolicyDialog({
      onAgree: async () => {
        await this.agreePrivacyPolicyDialog();
      },
      onCancel: async () => {
        await this.cancelPrivacyPolicyDialog();
      }
    }),
    autoCancel: false,
    cancel: async () => {
      await this.cancelPrivacyPolicyDialog();
    },
  })

  private async cancelPrivacyPolicyDialog() {
    await this.usePM.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.PRIVACY_POLICY_AGREE, false);
    console.info(`[Home] 执行了cancelPrivacyPolicyDialog`);
    await this.getContext().terminateSelf()
      .catch((e: BusinessError) => {
        console.error(`[Home] 退出应用失败：${e.message} code: ${e.code}`)
      });
  }

  private async agreePrivacyPolicyDialog() {
    await this.usePM.prefPut(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.PRIVACY_POLICY_AGREE, true);
    console.info(`[Home] 执行了agreePrivacyPolicyDialog`);
  }

  private hdsNavigationTitleBarOptions: HdsNavigationTitleBarOptions = {
    content: {
      title: { mainTitle: '主页' },
      menu: {
        value: [
          {
            content: {
              icon: $r('sys.symbol.hand_thumbsup'),
              label: '支持',
              action: () => { this.isModalShow = !this.isMiniMode }
            }
          },
          {
            content: {
              icon: $r('sys.symbol.gearshape'),
              label: '设置',
              action: () => {
                this.mainNavPathStack.pushPath({
                  name: 'Setting'
                })
              }
            }
          }
        ]
      }
    }
  }


  private async init() {
    // 获取版本号和软件名称
    await Promise.all([this.getAppName(), this.getAppVersion()]).then((result) => {
      this.useAppInfo.appName = result[0];
      this.useAppInfo.appVersion = result[1];
    })
  }

  aboutToAppear(): void {
    this.init();
    this.usePM.prefGet(ClientGlobalPrefKeys.PREF_NAME, ClientGlobalPrefKeys.PRIVACY_POLICY_AGREE, false)
      .then((v) => {
        switch (v) {
          case true:
            break;
          default:
            this.PrivacyPolicyDialog.open();
        }
      })
  }

  build() {
    HdsNavigation(this.mainNavPathStack){
      Column() {
        List() {

          ListItem()
            .height(180)

          ListTitle1('系统变量')
          ListItem() {
            ListBox() {
              Column() {
                Image($r('app.media.color2'))
                  .objectFit(ImageFit.Cover)
                  .draggable(false)
                  .borderRadius(11)
              }
              .height(200)
              .width('100%')
              .margin({ top: 8 })

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
              .padding({
                top: 30,
                bottom: 30
              })
            }
          }
          .MyListItemStyle2()
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
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)

          ListItem() {
            Column() {
              Text('—— 尽请期待 ——')
                .fontSize(14)
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            }
            .width('100%')
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .margin({ top: 24 })

          ListItem()
            .height(200)

        }
        .width('100%')
        .height('auto')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .alignListItem(ListItemAlign.Center)
      }
      .width('100%').height('100%')

    }
    // .backgroundColor($r('sys.color.background_secondary'))
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.background_linearGradient_color1'), 0.0],
        [$r('app.color.background_linearGradient_color2'), 1]]
    })
    .width('100%')
    .height('100%')
    .ignoreLayoutSafeArea()
    .mode(NavigationMode.Stack)
    .titleBar(this.hdsNavigationTitleBarOptions)
    .bindSheet(
      this.isModalShow!!,
      LikeBuilder,
      {
        title: { title: '赞助' },
        onDisappear: () => { this.isModalShow = false },
        dragBar: true,
        height: SheetSize.MEDIUM,
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      }
    )
  }
}