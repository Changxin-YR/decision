import { AppLimits } from '../../constants/DesignTokens';
import { HistoryRecord } from '../../models/AppModels';
import { JsonCodec } from '../JsonCodec';
import { PreferencesStore } from '../PreferencesStore';

const HISTORY_KEY: string = 'history';

export class HistoryRepository {
  private readonly store: PreferencesStore;

  constructor(store: PreferencesStore) {
    this.store = store;
  }

  static prependAndTrim(record: HistoryRecord, existing: readonly HistoryRecord[]): HistoryRecord[] {
    const next: HistoryRecord[] = [record, ...existing];
    return next.slice(0, AppLimits.MAX_HISTORY_COUNT);
  }

  async load(): Promise<HistoryRecord[]> {
    const snapshot: string = await this.store.getString(HISTORY_KEY, '');
    return JsonCodec.decodeHistory(snapshot);
  }

  async saveAll(records: readonly HistoryRecord[]): Promise<boolean> {
    try {
      await this.store.putString(HISTORY_KEY, JsonCodec.encodeHistory(records));
      return true;
    } catch {
      return false;
    }
  }

  async clear(): Promise<boolean> {
    try {
      await this.store.remove(HISTORY_KEY);
      return true;
    } catch {
      return false;
    }
  }
}
