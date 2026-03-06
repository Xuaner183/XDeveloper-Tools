import { SymbolGlyphModifier } from "@kit.ArkUI";
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from "@kit.AbilityKit";

@Builder export function LikeBuilder() {
  Like();
}

@ComponentV2
export struct Like {
  private saveIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.save'));

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async saveImage(resourceImage: Resource) {

    const outArrayBuffer: () => Promise<Uint8Array> = async () => {
      const photoUint8Array = await this.getContext().resourceManager.getMediaContent(resourceImage.id)
        .catch((e: BusinessError) => {
          console.error(`[Like] 获取photoUint8Array错误：${e.message}`);
          return Promise.reject(e);
        });
      return photoUint8Array;
    }

    try {
      // 将图片写入到沙箱临时文件
      const tempPath: string = this.getContext().filesDir;
      const filePath: string = `${tempPath}/${Date.now}.png`;
      const fileObject = await fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        .catch((e: BusinessError) => {
          console.error(`[Like] open filePath失败: ${e.message}, code: ${e.code}`);
          return Promise.reject(e)
        });
      await fs.write(fileObject.fd, (await outArrayBuffer()).buffer);
      // 弹窗授权获取Uri写入
      const PAH = photoAccessHelper.getPhotoAccessHelper(this.getContext());
      const authorisedPhotoUri = await PAH.showAssetsCreationDialog([filePath], [{
        fileNameExtension: 'png',
        photoType: photoAccessHelper.PhotoType.IMAGE
      }]).catch((e: BusinessError) => {
        console.error(`[Like] showAssetsCreationDialog错误：${e.message}, code: ${e.code}`);
        return Promise.reject(e);
      });
      const authorisedPhotoObject = await fs.open(authorisedPhotoUri[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        .catch((e: BusinessError) => {
          console.error(`[Like] authorisedPhotoObject错误：${e.message}, code: ${e.code}`);
          return Promise.reject(e);
        });
      // 复制沙箱临时文件至授权路径
      await fs.copyFile(fileObject.fd, authorisedPhotoObject.fd);
      // 删除临时文件
      fs.unlinkSync(filePath);
      fs.closeSync(fileObject.fd);
      fs.closeSync(authorisedPhotoObject.fd);

    } catch (e) {
      console.error(`[Like] 错误：${e.message}, code: ${e.code}`);
    }

  }

  @Builder ImageMenu(resourceImage: Resource) {
    Menu() {
      MenuItem({
        symbolStartIcon: this.saveIcon,
        content: '保存图片',
      })
        .onClick(() => { this.saveImage(resourceImage) })
    }
  }


  build() {
    NavDestination() {
      Column() {
        List() {
          ListItem()
            .height($r('sys.float.ohos_id_elements_margin_vertical_m'))

          ListItemGroup() {
            ListItem() {
              Column() {
                Column() {
                  Text('如果这个项目对你有帮助，可以扫码赞助支持开发。')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                }
                .padding({ bottom: 24 })

                Row() {
                  Image($r('app.media.wechatpay_qrcode'))
                    .width('50%')
                    .bindContextMenu(this.ImageMenu($r('app.media.wechatpay_qrcode')),
                      ResponseType.LongPress)
                  Image($r('app.media.alipay_qrcode'))
                    .width('50%')
                    .bindContextMenu(this.ImageMenu($r('app.media.alipay_qrcode')),
                      ResponseType.LongPress)
                }
                .width('100%')
                .height('auto')
              }
              .width('100%')
            }
          }

          ListItem()
            .height(100)
        }
        .padding({ left: 14, right: 14 })
        .height('auto')
        .width('100%')
        .flexGrow(2)
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor($r('sys.color.comp_background_model_sheet'))
  }
}