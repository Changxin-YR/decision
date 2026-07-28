import { AppStore, appStore } from '../stores/AppStore';

export class FeedbackService {
  private readonly store: AppStore;

  constructor(store: AppStore) {
    this.store = store;
  }

  async impact(duration: number = 35): Promise<boolean> {
    if (!this.store.settings.vibrationEnabled || duration <= 0) {
      return false;
    }
    // API 24's vibrator service requires a manifest permission. This project
    // deliberately ships with zero permission declarations, so haptics
    // degrade without affecting the decision result.
    return false;
  }
}

export const feedbackService: FeedbackService = new FeedbackService(appStore);
