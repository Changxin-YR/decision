import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { AppStore, appStore } from '../stores/AppStore';

export enum SoundEffect {
  TAP = 'tap.wav',
  COIN = 'coin.wav',
  WHEEL = 'wheel.wav',
  DRAW = 'draw.wav',
  RESULT = 'result.wav'
}

export class SoundService {
  private readonly store: AppStore;
  private context: common.Context | null = null;
  private player: media.AVPlayer | null = null;
  private rawPath: string = '';

  constructor(store: AppStore) {
    this.store = store;
  }

  initialize(context: common.Context): void {
    this.context = context;
  }

  async play(effect: SoundEffect): Promise<boolean> {
    if (!this.store.settings.soundEnabled || this.context === null) {
      return false;
    }
    await this.release();
    const path: string = `sounds/${effect}`;
    try {
      const descriptor = await this.context.resourceManager.getRawFd(path);
      this.rawPath = path;
      this.player = await media.createAVPlayer();
      this.player.fdSrc = {
        fd: descriptor.fd,
        offset: descriptor.offset,
        length: descriptor.length
      };
      await this.player.prepare();
      await this.player.play();
      return true;
    } catch {
      await this.release();
      return false;
    }
  }

  async release(): Promise<void> {
    const current: media.AVPlayer | null = this.player;
    this.player = null;
    if (current !== null && current.state !== 'released') {
      try {
        await current.release();
      } catch {
      }
    }
    if (this.context !== null && this.rawPath.length > 0) {
      const path: string = this.rawPath;
      this.rawPath = '';
      try {
        await this.context.resourceManager.closeRawFd(path);
      } catch {
      }
    }
  }
}

export const soundService: SoundService = new SoundService(appStore);
