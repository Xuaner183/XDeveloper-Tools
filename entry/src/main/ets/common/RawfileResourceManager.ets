import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { UIAbilityContext } from './UIAbilityContext'
import { resourceManager } from '@kit.LocalizationKit';

/**
 * 获取rawfile工具
 * 用于统一管理项目中需要从rawfile目录加载的JS等文本资源文件
 * 支持批量和单个获取资源内容
 */
export class RawfileResourceManager extends UIAbilityContext {
  private resourceCache: Map<string, string> = new Map();
  private loadingPromises: Map<string, Promise<string>> = new Map();

  /**
   * 获取单个资源文件内容
   * @param filePath 资源文件路径（相对于rawfile目录）
   * @returns Promise<string> 资源文件内容
   */
  public async getResource(filePath: string): Promise<string> {
    // 检查缓存
    if (this.resourceCache.has(filePath)) {
      return this.resourceCache.get(filePath)!;
    }

    // 检查是否正在加载
    if (this.loadingPromises.has(filePath)) {
      return this.loadingPromises.get(filePath)!;
    }

    // 创建新的加载Promise
    const loadPromise = this.loadResourceFile(filePath);
    this.loadingPromises.set(filePath, loadPromise);

    const content = await loadPromise;
    if (content) {
      this.resourceCache.set(filePath, content);
      this.loadingPromises.delete(filePath);
      return content;
    } else {
      this.loadingPromises.delete(filePath);
      console.error(`[RawfileResourceManager] 获取${filePath}失败`);
      return ''; // 返回空字符串而不是void
    }
  }

  /**
   * 批量获取多个资源文件内容
   * @param filePaths 资源文件路径数组
   * @returns Promise<Map<string, string>> 资源文件内容映射
   */
  public async getMultipleResources(filePaths: string[]): Promise<Map<string, string>> {
    const results = new Map<string, string>();
    // 并行加载所有资源
    const promises: Promise<void>[] = filePaths.map(async (filePath) => {
      const content: string = await this.getResource(filePath);
      results.set(filePath, content);
    });
    await Promise.all(promises);
    return results;
  }

  /**
   * 获取资源文件内容（内部实现）
   * @param filePath 资源文件路径
   * @returns Promise<string> 资源文件内容
   */
  private async loadResourceFile(filePath: string): Promise<string> {
    try {
      const rM: resourceManager.ResourceManager = this.uiContext.resourceManager;
      const fileContent = await rM.getRawFileContent(filePath);
      
      if (fileContent !== null && fileContent !== undefined && fileContent instanceof Uint8Array) {
        const decoder = util.TextDecoder.create('utf-8'); // 指定编码格式
        return decoder.decodeToString(fileContent);
      }
      
      return ''; // 文件内容异常时返回空字符串
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`[ResourceManager] getRawFileContent失败 ${filePath}: ${businessError.message} (${businessError.code})`);
      return ''; // 错误时返回空字符串
    }
  }

  /**
   * 获取单个颜色资源的值
   * 返回资源名称对应的颜色值（十进制）
   */
  public async getResourceColorSys(resName: string): Promise<number> {
    try {
      const rM = resourceManager.getSysResourceManager();
      const colorResource = await rM.getColorByName(resName);
      return colorResource;
    } catch (e) {
      console.error(`[ResourceManager] 获取颜色资源失败 ${(e as BusinessError).message}`)
      // 错误则返回白色的十进制
      return 4294967295
    }
  }
  /**
   * 获取多个颜色资源的值
   * 返回资源名称对应的颜色值（十进制）
   */
  public async getMultipleResourceColorSys(resName: Array<string>): Promise<number[]> {
    try {
      let resPromise: Promise<number>[] = [];
      const rM = resourceManager.getSysResourceManager();
      for (let i = 0; i < resName.length; i++) {
        resPromise.push(rM.getColorByName(resName[i]));
      }
      const colorResult: number[] = await Promise.all(resPromise);
      return colorResult;
    } catch (e) {
      console.error(`[ResourceManager] 批量获取颜色资源失败${(e as BusinessError).message}`)
      return new Array(resName.length).fill(4294967295);
    }
  }

  /**
   * 清除指定资源的缓存
   * @param filePath 资源文件路径
   */
  public clearCache(filePath?: string): void {
    if (filePath) {
      this.resourceCache.delete(filePath);
      this.loadingPromises.delete(filePath);
    } else {
      this.resourceCache.clear();
      this.loadingPromises.clear();
    }
  }

  /**
   * 检查资源是否已缓存
   * @param filePath 资源文件路径
   * @returns boolean 是否已缓存
   */
  public isCached(filePath: string): boolean {
    return this.resourceCache.has(filePath);
  }

  /**
   * 获取已缓存的资源列表
   * @returns string[] 已缓存的资源路径数组
   */
  public getCachedResources(): string[] {
    return Array.from(this.resourceCache.keys());
  }
}