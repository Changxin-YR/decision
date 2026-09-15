import { describe, expect, it } from '@ohos/hypium';
import { PreferencesStore } from '../../../main/ets/data/PreferencesStore';
import { HistoryRepository } from '../../../main/ets/data/repositories/HistoryRepository';
import { SettingsRepository } from '../../../main/ets/data/repositories/SettingsRepository';
import { TemplateRepository } from '../../../main/ets/data/repositories/TemplateRepository';
import {
  FeedbackSettingsController,
  FeedbackUpdateResult,
  SoundPreviewPort,
  VibrationPreviewPort
} from '../../../main/ets/services/FeedbackSettingsController';
import { SoundEffect } from '../../../main/ets/services/SoundService';
import { AppStore } from '../../../main/ets/stores/AppStore';

class MemoryPreferencesStore extends PreferencesStore {
  private values: Map<string, string> = new Map<string, string>();
  failWrites: boolean = false;

  async getString(key: string, fallback: string): Promise<string> {
    return this.values.get(key) ?? fallback;
  }

  async putString(key: string, value: string): Promise<void> {
    if (this.failWrites) {
      throw new Error('write failed');
    }
    this.values.set(key, value);
  }

  async remove(key: string): Promise<void> {
    this.values.delete(key);
  }
}

class RecordingVibrationPreview implements VibrationPreviewPort {
  calls: number = 0;

  async impact(_duration?: number): Promise<boolean> {
    this.calls += 1;
    return true;
  }
}

class RecordingSoundPreview implements SoundPreviewPort {
  calls: number = 0;
  lastEffect: SoundEffect | null = null;

  async play(effect: SoundEffect): Promise<boolean> {
    this.calls += 1;
    this.lastEffect = effect;
    return true;
  }
}

function createStore(persistence: MemoryPreferencesStore): AppStore {
  return new AppStore(
    new SettingsRepository(persistence),
    new TemplateRepository(persistence),
    new HistoryRepository(persistence)
  );
}

export default function feedbackSettingsControllerTest(): void {
  describe('FeedbackSettingsController', (): void => {
    it('previewsVibrationAfterEnablingIsPersisted', 0, async (): Promise<void> => {
      const persistence: MemoryPreferencesStore = new MemoryPreferencesStore();
      const store: AppStore = createStore(persistence);
      await store.initialize();
      await store.updateSettings({ vibrationEnabled: false });
      const vibration: RecordingVibrationPreview = new RecordingVibrationPreview();
      const sound: RecordingSoundPreview = new RecordingSoundPreview();
      const controller: FeedbackSettingsController =
        new FeedbackSettingsController(store, vibration, sound);

      const result: FeedbackUpdateResult = await controller.setVibrationEnabled(true);

      expect(result.saved).assertTrue();
      expect(result.previewed).assertTrue();
      expect(vibration.calls).assertEqual(1);
      expect(store.settings.vibrationEnabled).assertTrue();
    });

    it('previewsTapSoundAfterEnablingIsPersisted', 0, async (): Promise<void> => {
      const persistence: MemoryPreferencesStore = new MemoryPreferencesStore();
      const store: AppStore = createStore(persistence);
      await store.initialize();
      await store.updateSettings({ soundEnabled: false });
      const vibration: RecordingVibrationPreview = new RecordingVibrationPreview();
      const sound: RecordingSoundPreview = new RecordingSoundPreview();
      const controller: FeedbackSettingsController =
        new FeedbackSettingsController(store, vibration, sound);

      const result: FeedbackUpdateResult = await controller.setSoundEnabled(true);

      expect(result.saved).assertTrue();
      expect(result.previewed).assertTrue();
      expect(sound.calls).assertEqual(1);
      expect(sound.lastEffect).assertEqual(SoundEffect.TAP);
    });

    it('doesNotPreviewWhenFeedbackIsDisabled', 0, async (): Promise<void> => {
      const persistence: MemoryPreferencesStore = new MemoryPreferencesStore();
      const store: AppStore = createStore(persistence);
      await store.initialize();
      const vibration: RecordingVibrationPreview = new RecordingVibrationPreview();
      const sound: RecordingSoundPreview = new RecordingSoundPreview();
      const controller: FeedbackSettingsController =
        new FeedbackSettingsController(store, vibration, sound);

      const vibrationResult: FeedbackUpdateResult =
        await controller.setVibrationEnabled(false);
      const soundResult: FeedbackUpdateResult = await controller.setSoundEnabled(false);

      expect(vibrationResult.saved).assertTrue();
      expect(vibrationResult.previewed).assertFalse();
      expect(soundResult.saved).assertTrue();
      expect(soundResult.previewed).assertFalse();
      expect(vibration.calls).assertEqual(0);
      expect(sound.calls).assertEqual(0);
    });

    it('doesNotPreviewWhenPersistenceFails', 0, async (): Promise<void> => {
      const persistence: MemoryPreferencesStore = new MemoryPreferencesStore();
      const store: AppStore = createStore(persistence);
      await store.initialize();
      await store.updateSettings({ soundEnabled: false });
      persistence.failWrites = true;
      const vibration: RecordingVibrationPreview = new RecordingVibrationPreview();
      const sound: RecordingSoundPreview = new RecordingSoundPreview();
      const controller: FeedbackSettingsController =
        new FeedbackSettingsController(store, vibration, sound);

      const result: FeedbackUpdateResult = await controller.setSoundEnabled(true);

      expect(result.saved).assertFalse();
      expect(result.previewed).assertFalse();
      expect(sound.calls).assertEqual(0);
      expect(store.settings.soundEnabled).assertFalse();
    });
  });
}
