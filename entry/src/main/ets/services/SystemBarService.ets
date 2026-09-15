import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ThemeResolver } from '../constants/DesignTokens';
import { ThemeMode } from '../models/AppModels';

const DOMAIN: number = 0x4443;
const TAG: string = 'SystemBarService';

export class SystemBarService {
  private mainWindow: window.Window | undefined;
  private themeMode: ThemeMode = ThemeMode.SYSTEM;
  private systemDark: boolean = false;

  async initialize(
    mainWindow: window.Window,
    themeMode: ThemeMode,
    systemDark: boolean
  ): Promise<void> {
    this.mainWindow = mainWindow;
    this.themeMode = themeMode;
    this.systemDark = systemDark;
    await this.apply();
  }

  setThemeMode(themeMode: ThemeMode): void {
    this.themeMode = themeMode;
    this.applyWithoutBlocking();
  }

  setSystemDark(systemDark: boolean): void {
    this.systemDark = systemDark;
    this.applyWithoutBlocking();
  }

  release(): void {
    this.mainWindow = undefined;
  }

  private applyWithoutBlocking(): void {
    this.apply().catch((): void => {
      hilog.warn(DOMAIN, TAG, 'System-bar theme update failed');
    });
  }

  private async apply(): Promise<void> {
    if (!this.mainWindow) {
      return;
    }
    const contentColor: string = ThemeResolver.systemBarContentColor(this.themeMode, this.systemDark);
    try {
      await this.mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        statusBarContentColor: contentColor,
        navigationBarColor: '#00000000',
        navigationBarContentColor: contentColor
      });
    } catch {
      hilog.warn(DOMAIN, TAG, 'System-bar properties are temporarily unavailable');
    }
  }
}

export const systemBarService: SystemBarService = new SystemBarService();
