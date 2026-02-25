import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { UIAbilityContext } from './UIAbilityContext'
import type { resourceManager } from '@kit.LocalizationKit'

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
    const promises = filePaths.map(async (filePath) => {
      const content = await this.getResource(filePath);
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
      // 检查uiContext是否有效
      if (!this.uiContext || !this.uiContext.resourceManager) {
        console.error('[ResourceManager] UIAbilityContext或resourceManager为空');
        return '';
      }
      
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