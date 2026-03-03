import { pasteboard } from '@kit.BasicServicesKit';
import { UIContext } from '@kit.ArkUI';

export class PasteboardUtil {
  static async copy(text: string, context: UIContext) {
    const pa = context.getPromptAction()
    if (!text) {
      try {
        pa.showToast({ message: `复制失败：内容为空` });
      } catch (_) {
        console.error('[PasteboardUtil] showToast失败')
      }
      return;
    }

    // 1. 创建剪贴板数据对象
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    // 2. 获取系统剪贴板实例
    const systemPasteboard = pasteboard.getSystemPasteboard();

    try {
      // 3. 写入剪贴板
      await systemPasteboard.setData(pasteData);
      pa.showToast({ message: `已复制至剪贴板: ${text}` });
    } catch (err) {
      pa.showToast({ message: '复制失败：' + err.message });
    }
  }
}