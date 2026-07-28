import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { soundService } from '../services/SoundService';
import { appStore, preferencesStore } from '../stores/AppStore';

const DOMAIN: number = 0x4443;
const TAG: string = 'Decision';

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility created');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      await preferencesStore.initialize(this.context);
      await appStore.initialize();
    } catch {
      hilog.warn(DOMAIN, TAG, 'Local state initialization failed; defaults will be used');
    }
    soundService.initialize(this.context);
    windowStage.loadContent('pages/Index', (error): void => {
      if (error.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load pages/Index: %{public}s', JSON.stringify(error));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Loaded pages/Index');
    });
  }

  onBackground(): void {
    appLifecycleBus.notify(true);
    soundService.release();
  }

  onForeground(): void {
    appLifecycleBus.notify(false);
  }
}
