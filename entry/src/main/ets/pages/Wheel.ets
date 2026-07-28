import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
import { PageHeader } from '../components/common/PageHeader';
import { ResultSheet } from '../components/common/ResultSheet';
import { OptionsEditor } from '../components/decision/OptionsEditor';
import { TemplateSaveDialog } from '../components/decision/TemplateSaveDialog';
import { WheelCanvas } from '../components/decision/WheelCanvas';
import {
  AppFontSizes,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import { AppStrings } from '../constants/AppStrings';
import { RandomService } from '../domain/random/RandomService';
import { DraftChangeDetector } from '../domain/validation/DraftChangeDetector';
import { OptionValidator } from '../domain/validation/OptionValidator';
import {
  WheelSession,
  WheelSpin
} from '../domain/state/WheelSession';
import {
  HistoryRecord,
  ToolType
} from '../models/AppModels';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { feedbackService } from '../services/FeedbackService';
import { SoundEffect, soundService } from '../services/SoundService';
import { appStore } from '../stores/AppStore';
import { decisionDraftStore } from '../stores/DecisionDraftStore';

@Component
export struct WheelPage {
  @Prop colors: ThemeTokens;
  @Prop initialTitle: string = '';
  @Prop initialOptions: string[] = [];
  onBack: () => void = (): void => {
  };
  @State private optionsVersion: number = 0;
  @State private error: string = '';
  @State private rotation: number = 0;
  @State private running: boolean = false;
  @State private result: string = '';
  @State private saved: boolean = false;
  private session: WheelSession = new WheelSession();
  private timerId: number = -1;
  private unsubscribe: (() => void) | null = null;
  private record: HistoryRecord | null = null;
  private initialDraftOptions: string[] = [];
  private discardDialog: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: AppStrings.DISCARD_TITLE,
      message: AppStrings.DISCARD_MESSAGE,
      confirmLabel: AppStrings.DISCARD_CONFIRM,
      colors: this.colors,
      onConfirm: (): void => this.discardAndBack()
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });
  private templateDialog: CustomDialogController = new CustomDialogController({
    builder: TemplateSaveDialog({
      colors: this.colors,
      onSave: async (name: string): Promise<boolean> => {
        return appStore.createCustomTemplate(
          name,
          ToolType.WHEEL,
          this.optionTexts()
        );
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear(): void {
    if (decisionDraftStore.options.length < 2) {
      decisionDraftStore.set(
        this.initialTitle,
        ToolType.WHEEL,
        this.initialOptions.length >= 2 ? this.initialOptions : ['', '']
      );
    }
    this.initialDraftOptions = this.optionTexts();
    this.optionsVersion++;
    if (this.unsubscribe === null) {
      this.unsubscribe = appLifecycleBus.subscribe((background: boolean): void => {
        if (background) {
          this.cancel();
        }
      });
    }
  }

  aboutToDisappear(): void {
    this.cancel();
    if (this.unsubscribe !== null) {
      this.unsubscribe();
      this.unsubscribe = null;
    }
  }

  private optionTexts(): string[] {
    return Array.from(decisionDraftStore.options);
  }

  private updateOption(id: string, text: string): void {
    decisionDraftStore.updateOption(id, text);
    this.optionsVersion++;
    this.error = '';
  }

  private removeOption(id: string): void {
    decisionDraftStore.removeOption(id);
    this.optionsVersion++;
    this.error = '';
  }

  private moveOption(from: number, to: number): void {
    decisionDraftStore.moveOption(from, to);
    this.optionsVersion++;
  }

  private addOption(): void {
    decisionDraftStore.addOption();
    this.optionsVersion++;
  }

  private requestBack(): void {
    if (DraftChangeDetector.hasChanges(this.initialDraftOptions, this.optionTexts())) {
      this.discardDialog.open();
      return;
    }
    this.onBack();
  }

  private discardAndBack(): void {
    decisionDraftStore.updateOptions(this.initialDraftOptions);
    this.onBack();
  }

  private cancel(): void {
    decisionDraftStore.updateOptions(this.optionTexts());
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
    this.session.cancel();
    this.running = false;
  }

  private spin(): void {
    const validation = OptionValidator.validate(this.optionTexts());
    if (!validation.valid) {
      this.error = validation.message;
      return;
    }
    const values: string[] =
      this.optionTexts().map((value: string): string => value.trim());
    decisionDraftStore.updateOptions(values);
    const spin: WheelSpin | null = this.session.start(values);
    if (spin === null) {
      return;
    }
    this.error = '';
    this.running = true;
    this.result = '';
    this.saved = false;
    this.record = null;
    soundService.play(SoundEffect.WHEEL);
    const duration: number = RandomService.randomInteger(3000, 5000);
    const base: number = Math.ceil(this.rotation / 360) * 360;
    this.getUIContext().animateTo({
      duration: duration,
      curve: Curve.EaseOut
    }, (): void => {
      this.rotation = base + spin.targetAngle;
    });
    this.timerId = setTimeout((): void => {
      this.timerId = -1;
      if (!this.session.complete()) {
        return;
      }
      this.running = false;
      this.result = spin.result;
      this.record = {
        id: `${Date.now()}`,
        toolType: ToolType.WHEEL,
        title: this.initialTitle.trim().length > 0 ?
          this.initialTitle.trim() : '幸运转盘',
        options: values,
        result: spin.result,
        createdAt: new Date().toISOString()
      };
      feedbackService.impact();
      soundService.play(SoundEffect.RESULT);
      if (appStore.settings.autoSaveHistory) {
        this.save();
      }
    }, duration);
  }

  private async save(): Promise<void> {
    if (this.record === null || this.saved) {
      return;
    }
    this.saved = await appStore.saveHistoryRecord(this.record);
  }

  private openTemplateDialog(): void {
    const validation = OptionValidator.validate(this.optionTexts());
    if (!validation.valid) {
      this.error = validation.message;
      return;
    }
    this.templateDialog.open();
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: AppSpacing.LG }) {
          PageHeader({
            title: this.initialTitle.length > 0 ? this.initialTitle : AppStrings.WHEEL,
            subtitle: this.running ? AppStrings.WHEEL_WAIT : AppStrings.WHEEL_FAIR,
            colors: this.colors,
            onBack: (): void => {
              if (!this.running) {
                this.requestBack();
              }
            }
          })

          WheelCanvas({
            options: this.optionTexts().map((value: string): string => {
              return value.trim().length > 0 ? value.trim() : '待填写';
            }),
            rotation: this.rotation,
            colors: this.colors
          })

          AppButton({
            label: this.running ? AppStrings.WHEEL_RUNNING : AppStrings.START_WHEEL,
            isEnabled: !this.running,
            onPress: (): void => this.spin()
          })

          Text(AppStrings.OPTIONS)
            .width('100%')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)

          OptionsEditor({
            options: decisionDraftStore.decisionOptions(),
            isEnabled: !this.running && this.optionsVersion >= 0,
            colors: this.colors,
            onUpdate: (id: string, text: string): void => this.updateOption(id, text),
            onRemove: (id: string): void => this.removeOption(id),
            onMove: (from: number, to: number): void => this.moveOption(from, to),
            onAdd: (): void => this.addOption()
          })

          if (this.error.length > 0) {
            Text(this.error)
              .width('100%')
              .fontSize(AppFontSizes.CAPTION)
              .fontColor(this.colors.error)
          }

          AppButton({
            label: AppStrings.SAVE_TEMPLATE,
            variant: AppButtonVariant.SECONDARY,
            isEnabled: !this.running,
            onPress: (): void => this.openTemplateDialog()
          })
          if (this.result.length > 0) {
            AppButton({
              label: this.saved ? AppStrings.RESULT_SAVED : AppStrings.SAVE_RESULT,
              variant: AppButtonVariant.SECONDARY,
              isEnabled: !this.saved,
              onPress: (): void => {
                this.save();
              }
            })
          }
        }
        .width('100%')
        .constraintSize({ maxWidth: 720 })
        .padding({ left: 20, right: 20, top: 20, bottom: 36 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.colors.background)

      ResultSheet({
        visible: this.result.length > 0,
        result: this.result,
        colors: this.colors,
        showRetry: true,
        onRetry: (): void => {
          this.result = '';
          this.spin();
        },
        onClose: (): void => {
          this.result = '';
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
