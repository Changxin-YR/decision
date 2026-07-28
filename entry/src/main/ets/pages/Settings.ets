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
    this.toast(await this.store.clearAll(), '全部数据已清除');
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
    .padding(14)
    .backgroundColor(this.colors.card)
    .borderRadius(AppRadii.CARD)
  }

  @Builder
  private actionRow(label: string, danger: boolean, action: () => void) {
    Button(label, { type: ButtonType.Normal })
      .width('100%')
      .height(52)
      .fontSize(AppFontSizes.BODY)
      .fontColor(danger ? this.colors.error : this.colors.text)
      .backgroundColor(this.colors.card)
      .borderRadius(AppRadii.CARD)
      .onClick(action)
  }

  @Builder
  private infoRow(label: string) {
    Text(label)
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .fontSize(AppFontSizes.BODY)
      .fontColor(this.colors.subtext)
      .backgroundColor(this.colors.card)
      .borderRadius(AppRadii.CARD)
      .textAlign(TextAlign.Start)
  }

  build() {
    Column({ space: AppSpacing.MD }) {
      PageHeader({
        title: '设置',
        subtitle: '所有偏好只保存在本机',
        colors: this.colors,
        onBack: (): void => this.onBack()
      })
      Scroll() {
        Column({ space: AppSpacing.MD }) {
          Text('反馈')
            .width('100%')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
          this.settingSwitch(
            '振动反馈',
            this.store.settings.vibrationEnabled,
            (value: boolean): void => {
              this.store.updateSettings({ vibrationEnabled: value });
            }
          )
          this.settingSwitch(
            '音效',
            this.store.settings.soundEnabled,
            (value: boolean): void => {
              this.store.updateSettings({ soundEnabled: value });
            }
          )

          Text('主题')
            .width('100%')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
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
                  this.store.updateSettings({ themeMode: mode });
                })
            })
          }
          .width('100%')

          Text('历史与数据')
            .width('100%')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
          this.settingSwitch(
            '自动保存历史',
            this.store.settings.autoSaveHistory,
            (value: boolean): void => {
              this.store.updateSettings({ autoSaveHistory: value });
            }
          )
          this.actionRow('清除历史记录', false, (): void => this.clearHistoryDialog.open())
          this.actionRow('清除自定义模板', false, (): void => this.clearTemplatesDialog.open())
          this.actionRow('清除全部数据', true, (): void => this.clearAllDialog.open())

          Text('关于')
            .width('100%')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)
          this.infoRow(AppStrings.APP_VERSION)
          this.actionRow('隐私说明', false, (): void => this.onPrivacy())
          Text('使用说明：选择一种工具，按页面提示输入或触摸，即可得到公平随机结果。')
            .width('100%')
            .fontSize(AppFontSizes.CAPTION)
            .fontColor(this.colors.subtext)
            .padding({ bottom: 30 })
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 18 })
    .backgroundColor(this.colors.background)
  }
}
