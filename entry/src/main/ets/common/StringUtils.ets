export class StringUtils {
  /**
   * 在xxx_xxx_xxx下划线后添加零宽空格
   * @param text
   * @returns
   */
  static addZeroWidthSpaceToString(text: string): string {
    return text.replace(/_/g, '_\u200B');
  }
}