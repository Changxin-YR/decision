import { describe, expect, it } from '@ohos/hypium';
import { PreferencesStore } from '../../../main/ets/data/PreferencesStore';
import { HistoryRepository } from '../../../main/ets/data/repositories/HistoryRepository';
import { SettingsRepository } from '../../../main/ets/data/repositories/SettingsRepository';
import { TemplateRepository } from '../../../main/ets/data/repositories/TemplateRepository';
import {
  ThemeMode,
  ToolType
} from '../../../main/ets/models/AppModels';
import { AppStore } from '../../../main/ets/stores/AppStore';

class MemoryPreferencesStore extends PreferencesStore {
  private values: Map<string, string> = new Map<string, string>();

  async getString(key: string, fallback: string): Promise<string> {
    return this.values.get(key) ?? fallback;
  }

  async putString(key: string, value: string): Promise<void> {
    this.values.set(key, value);
  }

  async remove(key: string): Promise<void> {
    this.values.delete(key);
  }
}

function createStore(): AppStore {
  const persistence: MemoryPreferencesStore = new MemoryPreferencesStore();
  return new AppStore(
    new SettingsRepository(persistence),
    new TemplateRepository(persistence),
    new HistoryRepository(persistence)
  );
}

export default function appStoreTest(): void {
  describe('AppStore', () => {
    it('initializesWithDefaultSettings', 0, async () => {
      const store: AppStore = createStore();

      await store.initialize();

      expect(store.initialized).assertTrue();
      expect(store.settings.soundEnabled).assertTrue();
      expect(store.settings.themeMode).assertEqual(ThemeMode.SYSTEM);
    });

    it('updatesOneSettingWithoutOverwritingOthers', 0, async () => {
      const store: AppStore = createStore();
      await store.initialize();

      const saved: boolean = await store.updateSettings({ soundEnabled: false });

      expect(saved).assertTrue();
      expect(store.settings.soundEnabled).assertFalse();
      expect(store.settings.vibrationEnabled).assertTrue();
      expect(store.settings.themeMode).assertEqual(ThemeMode.SYSTEM);
      expect(store.settings.autoSaveHistory).assertFalse();
    });

    it('clearAllRestoresDefaultSettings', 0, async () => {
      const store: AppStore = createStore();
      await store.initialize();
      await store.updateSettings({
        soundEnabled: false,
        vibrationEnabled: false,
        themeMode: ThemeMode.DARK,
        autoSaveHistory: true
      });

      const cleared: boolean = await store.clearAll();

      expect(cleared).assertTrue();
      expect(store.settings.soundEnabled).assertTrue();
      expect(store.settings.vibrationEnabled).assertTrue();
      expect(store.settings.themeMode).assertEqual(ThemeMode.SYSTEM);
      expect(store.settings.autoSaveHistory).assertFalse();
      expect(store.templates.length).assertEqual(0);
      expect(store.history.length).assertEqual(0);
    });

    it('createsTrimmedWheelTemplateAndPersistsIt', 0, async () => {
      const store: AppStore = createStore();
      await store.initialize();

      const saved: boolean =
        await store.createCustomTemplate('  午饭  ', ToolType.WHEEL, ['面', '饭']);

      expect(saved).assertTrue();
      expect(store.templates.length).assertEqual(1);
      expect(store.templates[0].name).assertEqual('午饭');
      expect(store.templates[0].options.length).assertEqual(2);
      expect(store.templates[0].builtIn).assertFalse();
    });

    it('rejectsTemplateForUnsupportedTool', 0, async () => {
      const store: AppStore = createStore();
      await store.initialize();

      const saved: boolean =
        await store.createCustomTemplate('硬币', ToolType.COIN, ['正面', '反面']);

      expect(saved).assertFalse();
      expect(store.templates.length).assertEqual(0);
    });

    it('deletesOnlyMatchingCustomTemplate', 0, async () => {
      const store: AppStore = createStore();
      await store.initialize();
      await store.createCustomTemplate('一', ToolType.DRAW, ['甲', '乙']);
      await store.createCustomTemplate('二', ToolType.WHEEL, ['丙', '丁']);
      const firstId: string = store.templates[0].id;

      const deleted: boolean = await store.deleteCustomTemplate(firstId);

      expect(deleted).assertTrue();
      expect(store.templates.length).assertEqual(1);
      expect(store.templates[0].name).assertEqual('二');
    });
  });
}
