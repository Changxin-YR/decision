import { JsonCodec } from '../JsonCodec';
import { PreferencesStore } from '../PreferencesStore';
import { AppSettings } from '../../models/AppModels';

const SETTINGS_KEY: string = 'settings';

export class SettingsRepository {
  private readonly store: PreferencesStore;

  constructor(store: PreferencesStore) {
    this.store = store;
  }

  async load(): Promise<AppSettings> {
    const snapshot: string = await this.store.getString(SETTINGS_KEY, '');
    return JsonCodec.decodeSettings(snapshot);
  }

  async save(settings: AppSettings): Promise<boolean> {
    try {
      await this.store.putString(SETTINGS_KEY, JsonCodec.encodeSettings(settings));
      return true;
    } catch {
      return false;
    }
  }

  async clear(): Promise<boolean> {
    try {
      await this.store.remove(SETTINGS_KEY);
      return true;
    } catch {
      return false;
    }
  }
}
