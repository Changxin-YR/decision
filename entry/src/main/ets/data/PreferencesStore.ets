import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class PreferencesStore {
  private data: preferences.Preferences | null = null;

  async initialize(context: common.Context): Promise<void> {
    try {
      this.data = await preferences.getPreferences(context, 'decision_data');
    } catch {
      this.data = null;
      throw new Error('本地存储初始化失败');
    }
  }

  async getString(key: string, fallback: string): Promise<string> {
    if (this.data === null) {
      return fallback;
    }
    try {
      const value = await this.data.get(key, fallback);
      return typeof value === 'string' ? value : fallback;
    } catch {
      return fallback;
    }
  }

  async putString(key: string, value: string): Promise<void> {
    if (this.data === null) {
      throw new Error('本地存储尚未初始化');
    }
    try {
      await this.data.put(key, value);
      await this.data.flush();
    } catch {
      throw new Error('本地数据写入失败');
    }
  }

  async remove(key: string): Promise<void> {
    if (this.data === null) {
      return;
    }
    try {
      await this.data.delete(key);
      await this.data.flush();
    } catch {
      throw new Error('本地数据删除失败');
    }
  }
}
