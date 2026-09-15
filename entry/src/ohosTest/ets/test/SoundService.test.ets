import { common } from '@kit.AbilityKit';
import { describe, expect, it } from '@ohos/hypium';
import { PreferencesStore } from '../../../main/ets/data/PreferencesStore';
import { HistoryRepository } from '../../../main/ets/data/repositories/HistoryRepository';
import { SettingsRepository } from '../../../main/ets/data/repositories/SettingsRepository';
import { TemplateRepository } from '../../../main/ets/data/repositories/TemplateRepository';
import {
  SoundBackend,
  SoundEffect,
  SoundService
} from '../../../main/ets/services/SoundService';
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

class RecordingSoundBackend implements SoundBackend {
  initializeCalls: number = 0;
  playCalls: number = 0;
  releaseCalls: number = 0;
  ready: boolean = false;
  loadComplete: boolean = true;
  activeEffects: SoundEffect[] = [];

  async initialize(_context: common.Context | null): Promise<boolean> {
    this.initializeCalls += 1;
    this.ready = true;
    return true;
  }

  async waitUntilReady(): Promise<boolean> {
    return this.loadComplete;
  }

  async play(effect: SoundEffect): Promise<boolean> {
    this.playCalls += 1;
    if (!this.ready || !this.loadComplete) {
      return false;
    }
    this.activeEffects.push(effect);
    return true;
  }

  async stop(): Promise<void> {
    this.activeEffects = [];
  }

  async release(): Promise<void> {
    this.releaseCalls += 1;
    this.ready = false;
    this.activeEffects = [];
  }
}

class DeferredSoundBackend extends RecordingSoundBackend {
  private initializeResolver: (() => void) | null = null;
  private initializeCompletion: Promise<void> = new Promise<void>((resolve): void => {
    this.initializeResolver = resolve;
  });

  async initialize(_context: common.Context | null): Promise<boolean> {
    this.initializeCalls += 1;
    await this.initializeCompletion;
    this.ready = true;
    return true;
  }

  completeInitialization(): void {
    const resolver: (() => void) | null = this.initializeResolver;
    this.initializeResolver = null;
    if (resolver !== null) {
      resolver();
    }
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

export default function soundServiceTest(): void {
  describe('SoundService', (): void => {
    it('doesNotPlayWhenSoundSettingIsDisabled', 0, async (): Promise<void> => {
      const store: AppStore = createStore();
      await store.initialize();
      await store.updateSettings({ soundEnabled: false });
      const backend: RecordingSoundBackend = new RecordingSoundBackend();
      const service: SoundService = new SoundService(store, backend);
      await service.initialize(null);

      expect(await service.play(SoundEffect.TAP)).assertFalse();
      expect(backend.playCalls).assertEqual(0);
    });

    it('initializesOnceAndPlaysWhenEnabled', 0, async (): Promise<void> => {
      const store: AppStore = createStore();
      await store.initialize();
      await store.updateSettings({ soundEnabled: true });
      const backend: RecordingSoundBackend = new RecordingSoundBackend();
      const service: SoundService = new SoundService(store, backend);

      expect(await service.initialize(null)).assertTrue();
      expect(await service.initialize(null)).assertTrue();
      expect(await service.play(SoundEffect.RESULT)).assertTrue();
      expect(backend.initializeCalls).assertEqual(1);
      expect(backend.playCalls).assertEqual(1);
    });

    it('doesNotBecomeReadyBeforeBackendLoadingCompletes', 0, async (): Promise<void> => {
      const store: AppStore = createStore();
      await store.initialize();
      const backend: RecordingSoundBackend = new RecordingSoundBackend();
      backend.loadComplete = false;
      const service: SoundService = new SoundService(store, backend);

      expect(await service.initialize(null)).assertFalse();
      expect(await service.play(SoundEffect.RESULT)).assertFalse();
      expect(backend.playCalls).assertEqual(0);
    });

    it('replacesProcessSoundWhenResultSoundStarts', 0, async (): Promise<void> => {
      const store: AppStore = createStore();
      await store.initialize();
      await store.updateSettings({ soundEnabled: true });
      const backend: RecordingSoundBackend = new RecordingSoundBackend();
      const service: SoundService = new SoundService(store, backend);
      await service.initialize(null);

      expect(await service.play(SoundEffect.DRAW)).assertTrue();
      expect(await service.play(SoundEffect.RESULT)).assertTrue();

      expect(backend.activeEffects.length).assertEqual(1);
      expect(backend.activeEffects[0]).assertEqual(SoundEffect.RESULT);
    });

    it('canReinitializeAfterRelease', 0, async (): Promise<void> => {
      const store: AppStore = createStore();
      await store.initialize();
      await store.updateSettings({ soundEnabled: true });
      const backend: RecordingSoundBackend = new RecordingSoundBackend();
      const service: SoundService = new SoundService(store, backend);

      await service.initialize(null);
      await service.release();
      await service.initialize(null);

      expect(backend.initializeCalls).assertEqual(2);
      expect(backend.releaseCalls).assertEqual(1);
      expect(await service.play(SoundEffect.TAP)).assertTrue();
    });

    it('foregroundInitializationSupersedesPendingBackgroundRelease', 0,
      async (): Promise<void> => {
        const store: AppStore = createStore();
        await store.initialize();
        await store.updateSettings({ soundEnabled: true });
        const backend: DeferredSoundBackend = new DeferredSoundBackend();
        const service: SoundService = new SoundService(store, backend);

        const initialInitialize: Promise<boolean> = service.initialize(null);
        const backgroundRelease: Promise<void> = service.release();
        const foregroundInitialize: Promise<boolean> = service.initialize(null);
        backend.completeInitialization();

        expect(await initialInitialize).assertTrue();
        await backgroundRelease;
        expect(await foregroundInitialize).assertTrue();
        expect(backend.releaseCalls).assertEqual(0);
        expect(await service.play(SoundEffect.TAP)).assertTrue();
      });
  });
}
