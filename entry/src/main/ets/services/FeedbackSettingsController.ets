import { feedbackService } from './FeedbackService';
import { SoundEffect, soundService } from './SoundService';
import { AppStore, appStore } from '../stores/AppStore';

export interface VibrationPreviewPort {
  impact(duration?: number): Promise<boolean>;
}

export interface SoundPreviewPort {
  play(effect: SoundEffect): Promise<boolean>;
}

export interface FeedbackUpdateResult {
  saved: boolean;
  previewed: boolean;
}

export class FeedbackSettingsController {
  private readonly store: AppStore;
  private readonly vibration: VibrationPreviewPort;
  private readonly sound: SoundPreviewPort;

  constructor(
    store: AppStore,
    vibration: VibrationPreviewPort,
    sound: SoundPreviewPort
  ) {
    this.store = store;
    this.vibration = vibration;
    this.sound = sound;
  }

  async setVibrationEnabled(value: boolean): Promise<FeedbackUpdateResult> {
    const saved: boolean = await this.store.updateSettings({ vibrationEnabled: value });
    const previewed: boolean = saved && value ? await this.vibration.impact(60) : false;
    return { saved, previewed };
  }

  async setSoundEnabled(value: boolean): Promise<FeedbackUpdateResult> {
    const saved: boolean = await this.store.updateSettings({ soundEnabled: value });
    const previewed: boolean = saved && value ? await this.sound.play(SoundEffect.TAP) : false;
    return { saved, previewed };
  }
}

class DefaultVibrationPreview implements VibrationPreviewPort {
  async impact(duration?: number): Promise<boolean> {
    return feedbackService.impact(duration);
  }
}

class DefaultSoundPreview implements SoundPreviewPort {
  async play(effect: SoundEffect): Promise<boolean> {
    return soundService.play(effect);
  }
}

export const feedbackSettingsController: FeedbackSettingsController =
  new FeedbackSettingsController(
    appStore,
    new DefaultVibrationPreview(),
    new DefaultSoundPreview()
  );
