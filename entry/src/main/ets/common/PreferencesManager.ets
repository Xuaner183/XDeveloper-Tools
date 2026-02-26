import { preferences } from '@kit.ArkData';
import { UIAbilityContext } from './UIAbilityContext';
import type { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit'

export interface Entries {
  prefName: string, key: string, value: preferences.ValueType
}

export type ValueType = preferences.ValueType;

/**
 *
 * 介绍：用户首选项的获取和修改
 *
 * 使用：
 *  - 先调用this.setUIAbilityContext获取上下文再操作
 *
 */
export class PreferencesControl extends UIAbilityContext {

  /**
   * 异步获取用户首选项
   *
   * 输入：首选项文件名，key，默认返回值
   *
   * 返回：对应key的值
   */
  public async prefGet(prefName:string, key: string, defaultValue: preferences.ValueType = ''): Promise<preferences.ValueType | null> {
    const pref = await preferences.getPreferences(this.uiContext, prefName).catch((e: BusinessError) => {
      `[PreferencesControl] 获取用户首选项(${key})实例失败: ${e.message}`
      return null;
      });
    if (pref) {
      const prefGet = await pref.get(key, defaultValue).catch((e: BusinessError) => {
        console.error(`[PreferencesControl] 获取用户首选项(${key})的值失败: ${e.message}`)
        return null;
      })
      if (prefGet) {
        // console.info(`[PreferencesControl] 获取用户首选项(${key})的值为 ${prefGet}`)
        return prefGet;
      } else { return null; }
    } else { return null; }
  }

  /**
   * 同步获取用户首选项
   *
   * 输入：首选项文件名，key，默认返回值
   *
   * 返回：对应key的值
   */
  public prefGetSync(prefName:string, key: string, defaultValue: preferences.ValueType = ''): preferences.ValueType | null {
    try {
      const pref: preferences.Preferences = preferences.getPreferencesSync(this.uiContext, { name: prefName });
      const v: preferences.ValueType = pref.getSync(key, defaultValue);
      return v;
    } catch (e) {
      console.error(`[PreferencesControl] 同步获取用户首选项失败: ${e}`)
      return null;
    }
  }

  /**
   * 异步存储用户首选项
   *
   * 输入：首选项文件名，key，值
   */
  public async prefSet(prefName:string, key: string, value: preferences.ValueType): Promise<void> {
    try {
      const pref: preferences.Preferences = await preferences.getPreferences(this.uiContext, prefName);
      pref.put(key, value).catch((e: BusinessError) => {
          console.error(`[PreferencesControl] 缓存用户首选项 put (${key}) 失败: ${e.message}}(${e.code})`);
        }).then(() => {
          pref.flush().catch((e: BusinessError) => {
              console.error(`[PreferencesControl] 存储用户首选项 flush (${key}) 失败: ${e.message}}(${e.code})`);
            });
        }).then(() => {
          // console.info(`[PreferencesControl] 存储用户首选项成功 key: ${key}, value: ${value}`);
      });
    } catch (e) {
      console.error(`[PreferencesControl] 获取用户首选项 getPreferences (${key}) 失败：${e}`);
    }
  }

  /**
   * 存储多个用户首选项
   *
   * 输入：Array<Entries> [
     {prefName: 'user_prefs', key: 'theme', value: 'dark'},
     {prefName: 'app_settings', key: 'volume', value: 80},
     {prefName: 'user_prefs', key: 'language', value: 'zh_CN'}
     ]
   */
  public async prefSetMulti(entries: Entries[]): Promise<void> {
    try {
      const prefMap = new Map<string, Promise<preferences.Preferences>>();

      // 第一阶段：并行获取所有需要的Preferences实例
      const uniqueNames = Array.from(new Set(entries.map(e => e.prefName)));  // 去重获取所有唯一配置文件名
      await Promise.all(uniqueNames.map(async (prefName: string) => { // 并行初始化所有配置实例，提高初始化效率
        if (!prefMap.has(prefName)) {
          prefMap.set(prefName, preferences.getPreferences(this.uiContext, prefName));
        }
      }));

      // 第二阶段：批量执行put操作
      for (const entry of entries) {  // 遍历所有待存储的配置项
        const p = await prefMap.get(entry.prefName);  // 从缓存Map中获取对应配置实例
        if (p) {
          await p.put(entry.key, entry.value);  // 执行put操作存储键值对，await保证顺序执行
        }
      }

      // 第三阶段：统一执行flush
      for (const pPromise of prefMap.values()) {  // 遍历所有配置实例
        const instance = await pPromise; // 逐个执行flush操作将内存数据持久化到磁盘
        await instance.flush();
      }
    } catch (e) {
      console.warn('[PreferencesControl] 批量存储失败: ', e);
    }
  }

  /**
   * 清除用户首选项
   *
   * 输入： prefName
   */
  public async prefClear(prefName: string): Promise<void> {
    try {
      const pref: preferences.Preferences = await preferences.getPreferences(this.uiContext, prefName);
      await pref.clear();
      await pref.flush();
    } catch (e) {
      console.warn(`[PreferencesControl] 清除用户首选项(${prefName}) 失败：${e}`)
    }
  }

  /**
   * 清除多个用户首选项
   * @param prefName
   */
  public async prefClearMulti(prefName: Array<string>): Promise<void> {
    try {
      for (let i = 0; i < prefName.length; i++) {
        const pref: preferences.Preferences = await preferences.getPreferences(this.uiContext, prefName[i]);
        await pref.clear();
        await pref.flush();
      }
    } catch (e) {
      console.warn('[PreferencesControl] 批量清除用户首选项失败: ', e);
    }
  }

  // 一些别名
  public prefPut = this.prefSet;
  public prefPutMulti = this.prefSetMulti

  constructor(uiContext: common.UIAbilityContext) {
    super(uiContext);
  }
}