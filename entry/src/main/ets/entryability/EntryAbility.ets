import {
  AbilityConstant,
  Configuration,
  ConfigurationConstant,
  UIAbility,
  Want
} from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { soundService } from '../services/SoundService';
import { systemBarService } from '../services/SystemBarService';
import { appStore, preferencesStore } from '../stores/AppStore';

const DOMAIN: number = 0x4443;
const TAG: string = 'Decision';

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | undefined;
  private systemBottomSafeAreaPx: number = 0;
  private navigationBottomSafeAreaPx: number = 0;

  private isSystemDark(configuration: Configuration = this.context.config): boolean {
    return configuration.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  private publishSafeArea(topSafeAreaPx: number): void {
    AppStorage.setOrCreate('topSafeAreaPx', Math.max(0, topSafeAreaPx));
    AppStorage.setOrCreate(
      'bottomSafeAreaPx',
      Math.max(0, this.systemBottomSafeAreaPx, this.navigationBottomSafeAreaPx)
    );
  }

  private refreshAvoidAreas(mainWindow: window.Window): void {
    let topSafeAreaPx: number = 0;
    try {
      const systemArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      topSafeAreaPx = systemArea.topRect.height;
      this.systemBottomSafeAreaPx = systemArea.bottomRect.height;
    } catch {
      hilog.warn(DOMAIN, TAG, 'System avoid area is temporarily unavailable');
    }

    try {
      const navigationArea: window.AvoidArea = mainWindow.getWindowAvoidArea(
        window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR
      );
      this.navigationBottomSafeAreaPx = navigationArea.bottomRect.height;
    } catch {
      hilog.warn(DOMAIN, TAG, 'Navigation avoid area is temporarily unavailable');
    }
    this.publishSafeArea(topSafeAreaPx);
  }

  private handleAvoidAreaChange(data: window.AvoidAreaOptions): void {
    let topSafeAreaPx: number = AppStorage.get<number>('topSafeAreaPx') ?? 0;
    if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
      topSafeAreaPx = data.area.topRect.height;
      this.systemBottomSafeAreaPx = data.area.bottomRect.height;
    } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.navigationBottomSafeAreaPx = data.area.bottomRect.height;
    }
    this.publishSafeArea(topSafeAreaPx);
  }

  private async configureWindow(windowStage: window.WindowStage): Promise<void> {
    let mainWindow: window.Window;
    try {
      mainWindow = windowStage.getMainWindowSync();
    } catch {
      hilog.warn(DOMAIN, TAG, 'Main window is temporarily unavailable');
      return;
    }
    this.mainWindow = mainWindow;
    try {
      await mainWindow.setWindowLayoutFullScreen(true);
      await systemBarService.initialize(mainWindow, appStore.settings.themeMode, this.isSystemDark());
    } catch {
      hilog.warn(DOMAIN, TAG, 'Immersive window configuration failed; system defaults will be used');
    }

    this.refreshAvoidAreas(mainWindow);
    try {
      mainWindow.on('avoidAreaChange', (data: window.AvoidAreaOptions): void => {
        this.handleAvoidAreaChange(data);
      });
    } catch {
      hilog.warn(DOMAIN, TAG, 'Avoid-area listener registration failed');
    }
  }

  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'EntryAbility created');
    AppStorage.setOrCreate('topSafeAreaPx', 0);
    AppStorage.setOrCreate('bottomSafeAreaPx', 0);
    AppStorage.setOrCreate('systemDark', this.isSystemDark());
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    const systemDark: boolean = this.isSystemDark(newConfig);
    AppStorage.setOrCreate('systemDark', systemDark);
    systemBarService.setSystemDark(systemDark);
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    try {
      await preferencesStore.initialize(this.context);
      await appStore.initialize();
    } catch {
      hilog.warn(DOMAIN, TAG, 'Local state initialization failed; defaults will be used');
    }
    if (!await soundService.initialize(this.context)) {
      hilog.warn(DOMAIN, TAG, 'Short sound service is unavailable');
    }
    await this.configureWindow(windowStage);
    windowStage.loadContent('pages/Index', (error): void => {
      if (error.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load pages/Index: %{public}s', JSON.stringify(error));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Loaded pages/Index');
    });
  }

  onWindowStageDestroy(): void {
    if (this.mainWindow) {
      try {
        this.mainWindow.off('avoidAreaChange');
      } catch {
        hilog.warn(DOMAIN, TAG, 'Avoid-area listener cleanup failed');
      }
      this.mainWindow = undefined;
    }
    systemBarService.release();
  }

  onBackground(): void {
    appLifecycleBus.notify(true);
    soundService.release();
  }

  onForeground(): void {
    appLifecycleBus.notify(false);
    soundService.initialize(this.context);
  }
}
