/**
 * ArkTS 颜色转换工具 - rgba -> hex(0x), hex(#), cmyk, hsl, hsv
 *
 * 说明：
 * - 输入 rgba：r/g/b 为 0-255，a 为 0-1（假定可能有很多小数位）
 * - 按要求：先将 alpha 四舍五入到小数点后两位（例如 0.1234 -> 0.12，0.125 -> 0.13），
 *   再用于后续转换（比如转换为十六进制时先用该四舍五入后的 a）
 * - 所有输出数值（除 hex 字符串）保留到小数点后两位
 *
 */

/* ---------------------------
   类型声明（interface）
   --------------------------- */
export interface RgbaObj {
  r: number; // 0-255
  g: number; // 0-255
  b: number; // 0-255
  a: number; // 0-1
}

export interface CmykObj {
  c: number; // 0-100 (百分比)
  m: number; // 0-100
  y: number; // 0-100
  k: number; // 0-100
}

export interface HslObj {
  h: number; // 0-360 (度)
  s: number; // 0-100 (百分比)
  l: number; // 0-100 (百分比)
}

export interface HsvObj {
  h: number; // 0-360 (度)
  s: number; // 0-100 (百分比)
  v: number; // 0-100 (百分比)
}

/* ---------------------------
   静态类实现（修改说明）
   ---------------------------

   - 将 rgbaToCmyk 改为仅输出百分比整数（无小数点），并以字符串形式返回：
     格式: "cmyk(C%, M%, Y%, K%)"，C/M/Y/K 为整数百分比（0-100）
   - 将所有输出颜色相关的方法（CmykObj/HslObj/HsvObj）改为返回字符串：
     - rgbaToHsl 返回 "hsl(H, S%, L%)"，H/S/L 保留两位小数（字符串形式）
     - rgbaToHsv 返回 "hsv(H, S%, V%)"，H/S/V 保留两位小数（字符串形式）
   - hex 方法本来就返回字符串，保持不变。
   - 保留原有注释与 alpha 四舍五入规则。
*/

/* ---------------------------
   静态类主体
   --------------------------- */
export class ColorUtils {
  /* ---------------------------
     私有工具函数（静态）
     --------------------------- */

  /** 将数字限制在 min-max 区间 */
  private static clamp(n: number, min: number, max: number): number {
    if (isNaN(n)) return min;
    if (n < min) return min;
    if (n > max) return max;
    return n;
  }

  /** 四舍五入到指定小数位，并返回 number（避免字符串） */
  private static roundTo(n: number, decimals: number): number {
    const factor = Math.pow(10, decimals);
    return Math.round(n * factor) / factor;
  }

  /** 将 0-255 的整数转为 2 位十六进制（大写），并保证两位 */
  private static toHex2(n: number): string {
    const v = ColorUtils.clamp(Math.round(n), 0, 255);
    const s = v.toString(16).toUpperCase();
    return s.length === 1 ? "0" + s : s;
  }

  /* ---------------------------
     主转换静态方法
     --------------------------- */

  public static alpha255To01(a: number): string {
    if (typeof a !== 'number' || isNaN(a)) return '0';
    const clamped = Math.min(255, Math.max(0, a));
    const normalized = clamped / 255;
    // 四舍五入到小数点后两位并返回 number
    return (Math.round(normalized * 100) / 100).toString();
  }

  /**
   * rgba -> 0xRRGGBBAA 格式字符串（始终包含 alpha，两位）
   * - alpha 先四舍五入到小数点后两位，再乘 255 并四舍五入为整数用于 hex
   */
  public static rgbaToHex0x(input: RgbaObj): string {
    const r = ColorUtils.clamp(Math.round(input.r), 0, 255);
    const g = ColorUtils.clamp(Math.round(input.g), 0, 255);
    const b = ColorUtils.clamp(Math.round(input.b), 0, 255);

    // 先四舍五入到小数后两位
    const aRounded = ColorUtils.clamp(ColorUtils.roundTo(input.a, 2), 0, 1);
    const aInt = Math.round(aRounded * 255);

    const rHex = ColorUtils.toHex2(r);
    const gHex = ColorUtils.toHex2(g);
    const bHex = ColorUtils.toHex2(b);
    const aHex = ColorUtils.toHex2(aInt);

    return "0x" + rHex + gHex + bHex + aHex;
  }

  /**
   * rgba -> #RRGGBBAA 格式字符串（始终包含 alpha，两位）
   * - alpha 先四舍五入到小数点后两位，再乘 255 并四舍五入为整数用于 hex
   */
  public static rgbaToHexHash(input: RgbaObj): string {
    const r = ColorUtils.clamp(Math.round(input.r), 0, 255);
    const g = ColorUtils.clamp(Math.round(input.g), 0, 255);
    const b = ColorUtils.clamp(Math.round(input.b), 0, 255);

    const aRounded = ColorUtils.clamp(ColorUtils.roundTo(input.a, 2), 0, 1);
    const aInt = Math.round(aRounded * 255);

    const rHex = ColorUtils.toHex2(r);
    const gHex = ColorUtils.toHex2(g);
    const bHex = ColorUtils.toHex2(b);
    const aHex = ColorUtils.toHex2(aInt);

    return "#" + rHex + gHex + bHex + aHex;
  }

  /**
   * rgba -> CmykObj（结果为百分比 0-100，返回字符串）
   * - 要求：只要百分比不要小数点，返回形式为 "cmyk(C%, M%, Y%, K%)"
   */
  public static rgbaToCmyk(input: RgbaObj): string {
    const r = ColorUtils.clamp(input.r, 0, 255) / 255;
    const g = ColorUtils.clamp(input.g, 0, 255) / 255;
    const b = ColorUtils.clamp(input.b, 0, 255) / 255;

    const k = 1 - Math.max(r, g, b);

    let c = 0;
    let m = 0;
    let y = 0;

    if (k < 1) {
      c = (1 - r - k) / (1 - k);
      m = (1 - g - k) / (1 - k);
      y = (1 - b - k) / (1 - k);
    } else {
      c = m = y = 0;
    }

    // 转换为百分比并去除小数（整数）
    const cPctInt = Math.round(c * 100);
    const mPctInt = Math.round(m * 100);
    const yPctInt = Math.round(y * 100);
    const kPctInt = Math.round(k * 100);

    return (
      "cmyk(" +
      cPctInt.toString() +
        "%, " +
      mPctInt.toString() +
        "%, " +
      yPctInt.toString() +
        "%, " +
      kPctInt.toString() +
        "%)"
    );
  }

  /**
   * rgba -> HslObj（h: 0-360, s/l: 0-100 百分比），返回字符串并保留两位小数
   * 返回格式: "hsl(H, S%, L%)"（H/S/L 保留两位小数）
   * 常规算法，忽略 alpha（仅使用 r/g/b）
   */
  public static rgbaToHsl(input: RgbaObj): string {
    const r = ColorUtils.clamp(input.r, 0, 255) / 255;
    const g = ColorUtils.clamp(input.g, 0, 255) / 255;
    const b = ColorUtils.clamp(input.b, 0, 255) / 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    const delta = max - min;

    let h = 0;
    let s = 0;
    const l = (max + min) / 2;

    if (delta !== 0) {
      if (max === r) {
        h = ((g - b) / delta) % 6;
      } else if (max === g) {
        h = (b - r) / delta + 2;
      } else {
        h = (r - g) / delta + 4;
      }
      h = h * 60;
      if (h < 0) h += 360;

      s = delta / (1 - Math.abs(2 * l - 1));
    } else {
      h = 0;
      s = 0;
    }

    const hStr = ColorUtils.roundTo(h, 2).toFixed(2);
    const sStr = ColorUtils.roundTo(s * 100, 2).toFixed(2);
    const lStr = ColorUtils.roundTo(l * 100, 2).toFixed(2);

    return "hsl(" + hStr + ", " + sStr + "%, " + lStr + "%)";
  }

  /**
   * rgba -> HsvObj（h: 0-360, s/v: 0-100 百分比），返回字符串并保留两位小数
   * 返回格式: "hsv(H, S%, V%)"（H/S/V 保留两位小数）
   * 常规算法，忽略 alpha（仅使用 r/g/b）
   */
  public static rgbaToHsv(input: RgbaObj): string {
    const r = ColorUtils.clamp(input.r, 0, 255) / 255;
    const g = ColorUtils.clamp(input.g, 0, 255) / 255;
    const b = ColorUtils.clamp(input.b, 0, 255) / 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    const delta = max - min;

    let h = 0;
    let s = 0;
    const v = max;

    if (delta !== 0) {
      if (max === r) {
        h = ((g - b) / delta) % 6;
      } else if (max === g) {
        h = (b - r) / delta + 2;
      } else {
        h = (r - g) / delta + 4;
      }
      h = h * 60;
      if (h < 0) h += 360;

      s = max === 0 ? 0 : delta / max;
    } else {
      h = 0;
      s = 0;
    }

    const hStr = ColorUtils.roundTo(h, 2).toFixed(2);
    const sStr = ColorUtils.roundTo(s * 100, 2).toFixed(2);
    const vStr = ColorUtils.roundTo(v * 100, 2).toFixed(2);

    return "hsv(" + hStr + ", " + sStr + "%, " + vStr + "%)";
  }
}

/* ---------------------------
   示例（注释掉或参考）
   --------------------------- */

/*
const sample: RgbaObj = { r: 34, g: 12, b: 64, a: 0.12345 };

console.log(ColorUtils.rgbaToHex0x(sample));   // -> "0x220C40??" (AA 根据四舍五入后 alpha 计算)
console.log(ColorUtils.rgbaToHexHash(sample)); // -> "#220C40AA"
console.log(ColorUtils.rgbaToCmyk(sample));    // -> "cmyk(??%, ??%, ??%, ??%)" (整数百分比，无小数)
console.log(ColorUtils.rgbaToHsl(sample));     // -> "hsl(HH.HH, SS.SS%, LL.LL%)"
console.log(ColorUtils.rgbaToHsv(sample));     // -> "hsv(HH.HH, SS.SS%, VV.VV%)"
*/