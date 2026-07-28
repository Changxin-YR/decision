import { vibrator } from '@kit.SensorServiceKit';
import { AppStore, appStore } from '../stores/AppStore';

export class FeedbackService {
  private readonly store: AppStore;

  constructor(store: AppStore) {
    this.store = store;
  }

  async impact(duration: number = 35): Promise<boolean> {
    if (!this.store.settings.vibrationEnabled) {
      return false;
    }
    try {
      await vibrator.startVibration(
        {
          type: 'time',
          duration: duration
        },
        {
          usage: 'touch'
        }
      );
      return true;
    } catch {
      return false;
    }
  }
}

export const feedbackService: FeedbackService = new FeedbackService(appStore);
