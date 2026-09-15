import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { PageHeader } from '../components/common/PageHeader';
import {
  AppFontSizes,
  AppRadii,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import { AppStrings } from '../constants/AppStrings';
import { ThemeMode } from '../models/AppModels';
import {
  feedbackSettingsController,
  FeedbackUpdateResult
} from '../services/FeedbackSettingsController';
import { systemBarService } from '../services/SystemBarService';
import { appStore, AppStore } from '../stores/AppStore';

@Component
export struct SettingsPage {
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };
  onPrivacy: () => void = (): void => {
  };
  @State private store: AppStore = appStore;
  private clearHistoryDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '清除历史记录',
      message: '仅删除历史记录，自定义模板和设置会保留。',
      confirmLabel: '清除历史',
      colors: this.colors,
      onConfirm: (): void => {
        this.clearHistory();
      }
    }),
    autoCancel: true
  });
  private clearTemplatesDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '清除自定义模板',
      message: '仅删除你创建的模板，内置模板和历史记录会保留。',
      confirmLabel: '清除模板',
      colors: this.colors,
      onConfirm: (): void => {
        this.clearTemplates();
      }
    }),
    autoCancel: true
  });
  private clearAllDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '清除全部数据',
      message: '历史、自定义模板和设置都会被清除，设置恢复默认值。',
      confirmLabel: '全部清除',
      colors: this.colors,
      onConfirm: (): void => {
        this.clearAll();
      }
    }),
    autoCancel: true
  });

  private toast(success: boolean, successMessage: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: success ? successMessage : '操作失败，请重试'
      });
    } catch (_error) {
    }
  }

  private async clearHistory(): Promise<void> {
    this.toast(await this.store.clearHistory(), '历史记录已清除');
  }

  private async clearTemplates(): Promise<void> {
    this.toast(await this.store.clearTemplates(), '自定义模板已清除');
  }

  private async clearAll(): Promise<void> {
    const cleared: boolean = await this.store.clearAll();
    if (cleared) {
      systemBarService.setThemeMode(this.store.settings.themeMode);
    }
    this.toast(cleared, '全部数据已清除');
  }

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message });
    } catch (_error) {
    }
  }

  private async updateVibrationEnabled(value: boolean): Promise<void> {
    const result: FeedbackUpdateResult =
      await feedbackSettingsController.setVibrationEnabled(value);
    if (!result.saved) {
      this.showMessage('振动设置保存失败，请重试');
    } else if (value && !result.previewed) {
      this.showMessage('振动反馈暂不可用，请检查系统振动设置');
    }
  }

  private async updateSoundEnabled(value: boolean): Promise<void> {
    const result: FeedbackUpdateResult =
      await feedbackSettingsController.setSoundEnabled(value);
    if (!result.saved) {
      this.showMessage('音效设置保存失败，请重试');
    } else if (value && !result.previewed) {
      this.showMessage('音效暂不可用，请检查系统音量');
    }
  }

  private async updateThemeMode(mode: ThemeMode): Promise<void> {
    if (await this.store.updateSettings({ themeMode: mode })) {
      systemBarService.setThemeMode(mode);
    }
  }

  @Builder
  private settingSwitch(
    label: string,
    value: boolean,
    change: (value: boolean) => void
  ) {
    Row() {
      Text(label)
        .fontSize(AppFontSizes.BODY)
        .fontColor(this.colors.text)
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: value })
        .onChange(change)
    }
    .width('100%')
    .height(46)
    .padding({ left: 14, right: 12 })
    .backgroundColor(this.colors.card)
    .borderRadius(AppRadii.CARD)
  }

  @Builder
  private actionRow(label: string, danger: boolean, action: () => void) {
    Button(label, { type: ButtonType.Normal })
      .width('100%')
      .height(46)
      .fontSize(14)
      .fontColor(danger ? this.colors.error : this.colors.text)
      .backgroundColor(this.colors.card)
      .borderRadius(AppRadii.CARD)
      .onClick(action)
  }

  @Builder
  private infoRow(label: string) {
    Text(label)
      .width('100%')
      .height(46)
      .padding({ left: 16, right: 16 })
      .fontSize(AppFontSizes.BODY)
      .fontColor(this.colors.subtext)
      .backgroundColor(this.colors.card)
      .borderRadius(AppRadii.CARD)
      .textAlign(TextAlign.Start)
  }

  build() {
    Column({ space: 10 }) {
      PageHeader({
        title: AppStrings.SETTINGS,
        subtitle: AppStrings.LOCAL_SETTINGS,
        colors: this.colors,
        onBack: (): void => this.onBack()
      })
      Scroll() {
        Column({ space: 10 }) {
          Text(AppStrings.FEEDBACK)
            .width('100%')
            .fontSize(AppFontSizes.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.text)
          Column({ space: 1 }) {
            this.settingSwitch(
              AppStrings.VIBRATION,
              this.store.settings.vibrationEnabled,
              (value: boolean): void => {
                this.updateVibrationEnabled(value);
              }
            )
            this.settingSwitch(
              AppStrings.SOUND,
              this.store.settings.soundEnabled,
              (value: boolean): void => {
                this.updateSoundEnabled(value);
              }
            )
          }
          .width('100%')
          .borderRadius(12)
          .clip(true)
          .shadow({ radius: 8, color: '#0D27496B', offsetX: 0, offsetY: 3 })

          Text(AppStrings.THEME)
            .width('100%')
            .fontSize(AppFontSizes.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.text)
          Row({ space: 8 }) {
            ForEach([
              ThemeMode.SYSTEM,
              ThemeMode.LIGHT,
              ThemeMode.DARK
            ], (mode: ThemeMode): void => {
              Button(mode === ThemeMode.SYSTEM ? '跟随系统' :
                (mode === ThemeMode.LIGHT ? '浅色' : '深色'), {
                type: ButtonType.Normal
              })
                .layoutWeight(1)
                .height(44)
                .fontSize(AppFontSizes.CAPTION)
                .fontColor(this.store.settings.themeMode === mode ?
                  '#FFFFFF' : this.colors.text)
                .backgroundColor(this.store.settings.themeMode === mode ?
                  this.colors.accent : this.colors.card)
                .borderRadius(AppRadii.CARD)
                .onClick((): void => {
                  this.updateThemeMode(mode);
                })
            })
          }
          .width('100%')

          Text(AppStrings.DATA)
            .width('100%')
            .fontSize(AppFontSizes.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.text)
          Column({ space: 1 }) {
            this.settingSwitch(
              AppStrings.AUTO_SAVE,
              this.store.settings.autoSaveHistory,
              (value: boolean): void => {
                this.store.updateSettings({ autoSaveHistory: value });
              }
            )
            this.actionRow('清除历史记录', false, (): void => this.clearHistoryDialog.open())
            this.actionRow('清除自定义模板', false, (): void => this.clearTemplatesDialog.open())
            this.actionRow('清除全部数据', true, (): void => this.clearAllDialog.open())
          }
          .width('100%')
          .borderRadius(12)
          .clip(true)
          .shadow({ radius: 8, color: '#0D27496B', offsetX: 0, offsetY: 3 })

          Text(AppStrings.ABOUT)
            .width('100%')
            .fontSize(AppFontSizes.CAPTION)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.text)
          Column({ space: 1 }) {
            this.infoRow(AppStrings.APP_VERSION)
            this.actionRow(AppStrings.PRIVACY_DESCRIPTION, false, (): void => this.onPrivacy())
          }
          .width('100%')
          .borderRadius(12)
          .clip(true)
          .shadow({ radius: 8, color: '#0D27496B', offsetX: 0, offsetY: 3 })
          Text(AppStrings.USER_GUIDE)
            .width('100%')
            .fontSize(AppFontSizes.CAPTION)
            .fontColor(this.colors.subtext)
            .padding({ bottom: 30 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .height('100%')
    .constraintSize({ maxWidth: 720 })
    .padding({ left: 16, right: 16, top: 14 })
    .backgroundColor(this.colors.background)
  }
}
