import { JsonCodec } from '../JsonCodec';
import { PreferencesStore } from '../PreferencesStore';
import { DecisionTemplate } from '../../models/AppModels';

const TEMPLATES_KEY: string = 'templates';

export class TemplateRepository {
  private readonly store: PreferencesStore;

  constructor(store: PreferencesStore) {
    this.store = store;
  }

  async load(): Promise<DecisionTemplate[]> {
    const snapshot: string = await this.store.getString(TEMPLATES_KEY, '');
    return JsonCodec.decodeTemplates(snapshot);
  }

  async saveAll(templates: readonly DecisionTemplate[]): Promise<boolean> {
    try {
      await this.store.putString(TEMPLATES_KEY, JsonCodec.encodeTemplates(templates));
      return true;
    } catch {
      return false;
    }
  }

  async clear(): Promise<boolean> {
    try {
      await this.store.remove(TEMPLATES_KEY);
      return true;
    } catch {
      return false;
    }
  }
}
