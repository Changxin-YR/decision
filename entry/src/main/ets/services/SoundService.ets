import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import audio from '@ohos.multimedia.audio';
import { AppStore, appStore } from '../stores/AppStore';

const DOMAIN: number = 0x4443;
const TAG: string = 'Decision';

export enum SoundEffect {
  TAP = 'tap.wav',
  COIN = 'coin.wav',
  WHEEL = 'wheel.wav',
  DRAW = 'draw.wav',
  RESULT = 'result.wav'
}

const SOUND_EFFECTS: SoundEffect[] = [
  SoundEffect.TAP,
  SoundEffect.COIN,
  SoundEffect.WHEEL,
  SoundEffect.DRAW,
  SoundEffect.RESULT
];

export interface SoundBackend {
  initialize(context: common.Context | null): Promise<boolean>;
  waitUntilReady(): Promise<boolean>;
  play(effect: SoundEffect): Promise<boolean>;
  stop(): Promise<void>;
  release(): Promise<void>;
}

export class SoundPoolBackend implements SoundBackend {
  private pool: media.SoundPool | null = null;
  private soundIds: Map<SoundEffect, number> = new Map<SoundEffect, number>();
  private expectedSoundIds: Set<number> = new Set<number>();
  private loadedSoundIds: Set<number> = new Set<number>();
  private streamIds: Set<number> = new Set<number>();
  private loadCompletion: Promise<boolean> | null = null;
  private loadResolver: ((ready: boolean) => void) | null = null;
  private playbackGeneration: number = 0;

  private finishLoading(ready: boolean): void {
    const resolver: ((ready: boolean) => void) | null = this.loadResolver;
    this.loadResolver = null;
    if (resolver !== null) {
      resolver(ready);
    }
  }

  private resolveLoadingIfComplete(): void {
    if (this.expectedSoundIds.size !== SOUND_EFFECTS.length) {
      return;
    }
    let complete: boolean = true;
    this.expectedSoundIds.forEach((soundId: number): void => {
      if (!this.loadedSoundIds.has(soundId)) {
        complete = false;
      }
    });
    if (complete) {
      this.finishLoading(true);
    }
  }

  async initialize(context: common.Context | null): Promise<boolean> {
    if (this.pool !== null) {
      return true;
    }
    if (context === null) {
      return false;
    }

    try {
      const rendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_GAME,
        rendererFlags: 0
      };
      const pool: media.SoundPool = await media.createSoundPool(4, rendererInfo);
      pool.on('error', (): void => {
        hilog.warn(DOMAIN, TAG, 'Short sound playback reported an error');
        this.finishLoading(false);
      });
      pool.on('loadComplete', (soundId: number): void => {
        this.loadedSoundIds.add(soundId);
        this.resolveLoadingIfComplete();
      });
      pool.on('playFinishedWithStreamId', (streamId: number): void => {
        this.streamIds.delete(streamId);
      });
      this.pool = pool;
      this.expectedSoundIds.clear();
      this.loadedSoundIds.clear();
      this.streamIds.clear();
      this.loadCompletion = new Promise<boolean>((resolve): void => {
        this.loadResolver = resolve;
      });

      for (let index: number = 0; index < SOUND_EFFECTS.length; index += 1) {
        const effect: SoundEffect = SOUND_EFFECTS[index];
        const path: string = `sounds/${effect}`;
        const descriptor = await context.resourceManager.getRawFd(path);
        try {
          const soundId: number =
            await pool.load(descriptor.fd, descriptor.offset, descriptor.length);
          this.soundIds.set(effect, soundId);
          this.expectedSoundIds.add(soundId);
          this.resolveLoadingIfComplete();
        } finally {
          await context.resourceManager.closeRawFd(path);
        }
      }
      return this.soundIds.size === SOUND_EFFECTS.length;
    } catch (_error) {
      hilog.warn(DOMAIN, TAG, 'Short sound initialization failed');
      await this.release();
      return false;
    }
  }

  async waitUntilReady(): Promise<boolean> {
    const completion: Promise<boolean> | null = this.loadCompletion;
    if (this.pool === null || completion === null) {
      return false;
    }
    return completion;
  }

  async play(effect: SoundEffect): Promise<boolean> {
    const pool: media.SoundPool | null = this.pool;
    const soundId: number | undefined = this.soundIds.get(effect);
    if (pool === null || soundId === undefined) {
      return false;
    }
    try {
      const generation: number = this.playbackGeneration;
      const streamId: number = await pool.play(soundId, {
        loop: 0,
        leftVolume: 1,
        rightVolume: 1,
        priority: 1
      });
      if (streamId <= 0) {
        return false;
      }
      if (this.pool !== pool) {
        try {
          await pool.stop(streamId);
        } catch (_error) {
        }
        return false;
      }
      this.streamIds.add(streamId);
      if (generation !== this.playbackGeneration) {
        this.streamIds.delete(streamId);
        try {
          await pool.stop(streamId);
        } catch (_error) {
        }
        return false;
      }
      return true;
    } catch (_error) {
      hilog.warn(DOMAIN, TAG, 'Short sound playback failed');
      return false;
    }
  }

  async stop(): Promise<void> {
    this.playbackGeneration += 1;
    const pool: media.SoundPool | null = this.pool;
    const streamIds: number[] = Array.from(this.streamIds);
    this.streamIds.clear();
    if (pool === null) {
      return;
    }
    for (let index: number = 0; index < streamIds.length; index += 1) {
      try {
        await pool.stop(streamIds[index]);
      } catch (_error) {
        hilog.warn(DOMAIN, TAG, 'Short sound stop failed');
      }
    }
  }

  async release(): Promise<void> {
    const pool: media.SoundPool | null = this.pool;
    this.playbackGeneration += 1;
    this.pool = null;
    this.finishLoading(false);
    this.loadCompletion = null;
    this.soundIds.clear();
    this.expectedSoundIds.clear();
    this.loadedSoundIds.clear();
    this.streamIds.clear();
    if (pool === null) {
      return;
    }
    try {
      pool.off('loadComplete');
      pool.off('playFinishedWithStreamId');
      pool.off('error');
      await pool.release();
    } catch (_error) {
      hilog.warn(DOMAIN, TAG, 'Short sound release failed');
    }
  }
}

export class SoundService {
  private readonly store: AppStore;
  private readonly backend: SoundBackend;
  private ready: boolean = false;
  private initialization: Promise<boolean> | null = null;
  private playbackRequest: number = 0;
  private lifecycleRequest: number = 0;

  constructor(store: AppStore, backend: SoundBackend) {
    this.store = store;
    this.backend = backend;
  }

  async initialize(context: common.Context | null): Promise<boolean> {
    this.lifecycleRequest += 1;
    if (this.ready) {
      return true;
    }
    if (this.initialization !== null) {
      return this.initialization;
    }
    this.initialization = this.initializeBackend(context);
    this.ready = await this.initialization;
    this.initialization = null;
    return this.ready;
  }

  private async initializeBackend(context: common.Context | null): Promise<boolean> {
    if (!await this.backend.initialize(context)) {
      return false;
    }
    return this.backend.waitUntilReady();
  }

  async play(effect: SoundEffect): Promise<boolean> {
    if (!this.store.settings.soundEnabled || !this.ready) {
      return false;
    }
    const request: number = ++this.playbackRequest;
    await this.backend.stop();
    if (request !== this.playbackRequest ||
      !this.store.settings.soundEnabled || !this.ready) {
      return false;
    }
    return this.backend.play(effect);
  }

  async stop(): Promise<void> {
    this.playbackRequest += 1;
    await this.backend.stop();
  }

  async release(): Promise<void> {
    const request: number = ++this.lifecycleRequest;
    this.playbackRequest += 1;
    if (this.initialization !== null) {
      await this.initialization;
      this.initialization = null;
    }
    if (request !== this.lifecycleRequest) {
      return;
    }
    this.ready = false;
    await this.backend.release();
  }
}

export const soundService: SoundService =
  new SoundService(appStore, new SoundPoolBackend());
