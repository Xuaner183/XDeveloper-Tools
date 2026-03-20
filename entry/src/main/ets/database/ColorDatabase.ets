import { relationalStore } from '@kit.ArkData';
import { ColorArray, ColorType } from '../common/Index';
import { common } from '@kit.AbilityKit';

enum ThemeMode {
  Light,
  Dark
}

// 数据库表结构接口
interface ColorTable {
  id: number; // 主键
  theme: ThemeMode; // 0-Light, 1-Dark
  colorName: string; // 颜色资源名称
  rgba: ColorType.RGBA;
  rrggbbaa: ColorType.RRGGBBAA;
  aarrggbb: ColorType.AARRGGBB;
  hex: ColorType.HEX;
  cmyk: ColorType.CMYK;
  hsl: ColorType.HSL;
  hsv: ColorType.HSV;
}

export interface ColorTypeObj {
  RGBA: ColorType.RGBA;
  RRGGBBAA: ColorType.RRGGBBAA;
  AARRGGBB: ColorType.AARRGGBB;
  HEX: ColorType.HEX;
  CMYK: ColorType.CMYK;
  HSL: ColorType.HSL;
  HSV: ColorType.HSV;
}

export interface JsonObj {
  Light: Record<string, ColorTypeObj>,
  Dark: Record<string, ColorTypeObj>
}

/**
 * 颜色值数据管理器
 */
export class ColorDatabaseManager {

  private ctx: common.BaseContext;

  constructor(ctx: common.BaseContext) {
    this.ctx = ctx;
  }

  // 数据库常量
  private static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'ColorDataStore.db', // 数据库名称
    securityLevel: relationalStore.SecurityLevel.S1 // 安全级别
  };

  private static readonly TABLE_NAME: string = 'color_table'; // 表名

  // 表结构定义
  private static readonly CREATE_TABLE_SQL: string = `
    CREATE TABLE IF NOT EXISTS ${ColorDatabaseManager.TABLE_NAME} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      theme INTEGER NOT NULL,
      colorName TEXT NOT NULL,
      rgba TEXT NOT NULL,
      rrggbbaa TEXT NOT NULL,
      aarrggbb TEXT NOT NULL,
      hex TEXT NOT NULL,
      cmyk TEXT NOT NULL,
      hsl TEXT NOT NULL,
      hsv TEXT NOT NULL,
      UNIQUE(theme, colorName) ON CONFLICT REPLACE
    )`;

  private rdbStore: relationalStore.RdbStore | null = null;
  private isInitialized: boolean = false;

  /**
   * 初始化数据库
   * @throws BusinessError
   */
  async initDatabase(): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(this.ctx, ColorDatabaseManager.STORE_CONFIG);
      await this.rdbStore.executeSql(ColorDatabaseManager.CREATE_TABLE_SQL);
      this.isInitialized = true;
      console.log('[ColorDatabase] 颜色数据库初始化成功');
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`[ColorDatabase] 颜色数据库初始化失败: ${err.code} ${err.message}`);
      throw new Error(error);
    }
  }

  /**
   * 存储颜色数据
   * @param colorSysStringArrOriginal
   * @param colorValue
   * @returns
   */
  async storeColorData(
    colorSysStringArrOriginal: string[],
    colorValue: [ColorType.RGBA[][], ColorType.RGBA[][]]
  ): Promise<void> {
    if (!this.isInitialized || !this.rdbStore) {
      throw new Error('颜色数据库未初始化');
    }

    const LIGHT = colorValue[ThemeMode.Light];
    const DARK  = colorValue[ThemeMode.Dark];
    // 记录事务ID
    let affairId: number | undefined = undefined;

    try {
      // 开始事务
      affairId = await this.rdbStore.beginTrans();

      // 清空现有数据
      await this.rdbStore.executeSql(`DELETE FROM ${ColorDatabaseManager.TABLE_NAME}`);

      // 插入Light主题数据
      for (let i = 0; i < colorSysStringArrOriginal.length; i++) {
        const colorName = colorSysStringArrOriginal[i];
        await this.insertColorData(0, colorName, LIGHT, i);
      }

      // 插入Dark主题数据
      for (let i = 0; i < colorSysStringArrOriginal.length; i++) {
        const colorName = colorSysStringArrOriginal[i];
        await this.insertColorData(1, colorName, DARK, i);
      }

      // 提交事务
      await this.rdbStore.commit(affairId);
      console.log('Color data stored successfully');

    } catch (error) {
      // 回滚事务
      if (this.rdbStore && affairId) {
        await this.rdbStore.rollback(affairId);
      }
      const err: BusinessError = error as BusinessError;
      console.error(`[ColorDatabase] 存储颜色数据失败: ${JSON.stringify(err)}`);
      return Promise.reject(err);
    }
  }

  /**
   * 插入单条颜色数据
   * @param theme
   * @param colorName
   * @param colorArray
   * @param index
   * @returns
   * @throws Error: RdbStore 是空的
   */
  private async insertColorData(
    theme: ThemeMode,
    colorName: string,
    colorArray: ColorType.RGBA[][],
    index: number
  ): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('RdbStore 是空的');
    }

    const valueBucket: relationalStore.ValuesBucket = {
      theme: theme,
      colorName: colorName,
      rgba: colorArray[ColorArray.RgbaArray][index],
      rrggbbaa: colorArray[ColorArray.RrggbbaaArray][index],
      aarrggbb: colorArray[ColorArray.AarrggbbArray][index],
      hex: colorArray[ColorArray.HexArray][index],
      cmyk: colorArray[ColorArray.CmykArray][index],
      hsl: colorArray[ColorArray.HslArray][index],
      hsv: colorArray[ColorArray.HsvArray][index]
    };

    await this.rdbStore.insert(ColorDatabaseManager.TABLE_NAME, valueBucket);
  }

  /**
   * 查询颜色数据
   * @param theme
   * @param colorName
   * @throws Error
   * @returns
   */
  async queryColorData(theme: ThemeMode, colorName: string): Promise<ColorTable | null> {
    if (!this.isInitialized || !this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(ColorDatabaseManager.TABLE_NAME);
    predicates.equalTo('theme', theme).and().equalTo('colorName', colorName);

    const resultSet: relationalStore.ResultSet = await this.rdbStore.query(predicates, ['*'])
      .catch((e: BusinessError) => {
        console.error(`[ColorDatabase] query失败: ${JSON.stringify(e)}`);
         return Promise.reject(e);
      });

    try {
      if (resultSet.rowCount === 0) {
        return null;
      }

      const colorData: ColorTable = {
        id: 0,
        theme: 0,
        colorName: '',
        rgba: '',
        rrggbbaa: '',
        aarrggbb: '',
        hex: '',
        cmyk: '',
        hsl: '',
        hsv: ''
      };

      if (resultSet.goToFirstRow()) {
        colorData.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
        colorData.theme = resultSet.getDouble(resultSet.getColumnIndex('theme'));
        colorData.colorName = resultSet.getString(resultSet.getColumnIndex('colorName'));
        colorData.rgba = resultSet.getString(resultSet.getColumnIndex('rgba'));
        colorData.rrggbbaa = resultSet.getString(resultSet.getColumnIndex('rrggbbaa'));
        colorData.aarrggbb = resultSet.getString(resultSet.getColumnIndex('aarrggbb'));
        colorData.hex = resultSet.getString(resultSet.getColumnIndex('hex'));
        colorData.cmyk = resultSet.getString(resultSet.getColumnIndex('cmyk'));
        colorData.hsl = resultSet.getString(resultSet.getColumnIndex('hsl'));
        colorData.hsv = resultSet.getString(resultSet.getColumnIndex('hsv'));
      }

      return colorData;

    } catch (e){
      throw new Error(e);
    } finally {
      resultSet.close();
    }
  }

  // 查询所有主题的颜色数据
  async queryAllColors(): Promise<Map<string, Map<string, ColorTable>>> {
    if (!this.isInitialized || !this.rdbStore) {
      throw new Error('数据库未初始化');
    }

    const result: Map<string, Map<string, ColorTable>> = new Map();
    result.set('Light', new Map());
    result.set('Dark', new Map());

    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(ColorDatabaseManager.TABLE_NAME);
    const resultSet: relationalStore.ResultSet = await this.rdbStore.query(predicates, ['*'])
      .catch((e: BusinessError) => {
        console.error(`[ColorDatabase] queryAllColors的query失败: ${JSON.stringify(e)}`);
        return Promise.reject(e);
      });

    try {
      while (resultSet.goToNextRow()) {
        const colorData: ColorTable = {
          id: resultSet.getDouble(resultSet.getColumnIndex('id')),
          theme: resultSet.getDouble(resultSet.getColumnIndex('theme')),
          colorName: resultSet.getString(resultSet.getColumnIndex('colorName')),
          rgba: resultSet.getString(resultSet.getColumnIndex('rgba')),
          rrggbbaa: resultSet.getString(resultSet.getColumnIndex('rrggbbaa')),
          aarrggbb: resultSet.getString(resultSet.getColumnIndex('aarrggbb')),
          hex: resultSet.getString(resultSet.getColumnIndex('hex')),
          cmyk: resultSet.getString(resultSet.getColumnIndex('cmyk')),
          hsl: resultSet.getString(resultSet.getColumnIndex('hsl')),
          hsv: resultSet.getString(resultSet.getColumnIndex('hsv'))
        };

        const themeName: string = colorData.theme === 0 ? 'Light' : 'Dark';
        const colorMap: Map<string, ColorTable> | undefined = result.get(themeName);
        if (colorMap) {
          colorMap.set(colorData.colorName, colorData);
        }
      }

      return result;

    } catch (e) {
      throw new Error(e);
    } finally {
      resultSet.close();
    }
  }

  // 导出为JSON格式
  async exportToJson(): Promise<string> {
    const allColors: Map<string, Map<string, ColorTable>> = await this.queryAllColors();

    const jsonObj: JsonObj = {
      Light: {},
      Dark: {}
    };

    const lightMap: Map<string, ColorTable> | undefined = allColors.get('Light');
    if (lightMap) {
      lightMap.forEach((colorData: ColorTable, colorName: string) => {
        jsonObj.Light[colorName] = {
          RGBA: colorData.rgba,
          RRGGBBAA: colorData.rrggbbaa,
          AARRGGBB: colorData.aarrggbb,
          HEX: colorData.hex,
          CMYK: colorData.cmyk,
          HSL: colorData.hsl,
          HSV: colorData.hsv
        };
      });
    }

    const darkMap: Map<string, ColorTable> | undefined = allColors.get('Dark');
    if (darkMap) {
      darkMap.forEach((colorData: ColorTable, colorName: string) => {
        jsonObj.Dark[colorName] = {
          RGBA: colorData.rgba,
          RRGGBBAA: colorData.rrggbbaa,
          AARRGGBB: colorData.aarrggbb,
          HEX: colorData.hex,
          CMYK: colorData.cmyk,
          HSL: colorData.hsl,
          HSV: colorData.hsv
        };
      });
    }

    return JSON.stringify(jsonObj, null, 2);
  }

  // 删除数据库
  async deleteDatabase(): Promise<void> {
    if (this.rdbStore) {
      await relationalStore.deleteRdbStore(this.ctx, ColorDatabaseManager.STORE_CONFIG.name)
        .catch((e: BusinessError) => {
          return Promise.reject(e);
        });
      this.rdbStore = null;
      this.isInitialized = false;
      console.log('[ColorDatabase] 颜色数据库删除成功');
    }
  }
}