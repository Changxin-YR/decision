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
import { DecisionTiming } from '../domain/feedback/DecisionTiming';
import { DraftChangeDetector } from '../domain/validation/DraftChangeDetector';
import { OptionValidator } from '../domain/validation/OptionValidator';
import {
  WheelSession,
  WheelSpin
} from '../domain/state/WheelSession';
import {
  DecisionOption,
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
  @State private wheelOptions: string[] = ['待填写', '待填写'];
  @State private editorOptions: DecisionOption[] = [];
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
    this.refreshEditorOptions();
    this.refreshWheelOptions();
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

  private refreshWheelOptions(): void {
    this.wheelOptions = this.optionTexts().map((value: string): string => {
      return value.trim().length > 0 ? value.trim() : '待填写';
    });
    this.optionsVersion++;
  }

  private refreshEditorOptions(): void {
    this.editorOptions = decisionDraftStore.decisionOptions();
  }

  private updateOption(id: string, text: string): void {
    if (this.running) {
      return;
    }
    decisionDraftStore.updateOption(id, text);
    this.refreshEditorOptions();
    this.refreshWheelOptions();
    this.error = '';
  }

  private removeOption(id: string): void {
    decisionDraftStore.removeOption(id);
    this.refreshEditorOptions();
    this.refreshWheelOptions();
    this.error = '';
  }

  private moveOption(from: number, to: number): void {
    decisionDraftStore.moveOption(from, to);
    this.refreshEditorOptions();
    this.refreshWheelOptions();
  }

  private addOption(): void {
    decisionDraftStore.addOption();
    this.refreshEditorOptions();
    this.refreshWheelOptions();
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
    soundService.stop();
  }

  private async spin(): Promise<void> {
    const validation = OptionValidator.validate(this.optionTexts());
    if (!validation.valid) {
      this.error = validation.message;
      return;
    }
    const values: string[] =
      this.optionTexts().map((value: string): string => value.trim());
    this.running = true;
    decisionDraftStore.updateOptions(values);
    this.refreshWheelOptions();
    const spin: WheelSpin | null = this.session.start(values);
    if (spin === null) {
      this.running = false;
      return;
    }
    this.error = '';
    this.result = '';
    this.saved = false;
    this.record = null;
    await soundService.play(SoundEffect.WHEEL);
    if (!this.running) {
      return;
    }
    const duration: number = DecisionTiming.WHEEL_RESULT_AT;
    const base: number = Math.ceil(this.rotation / 360) * 360;
    this.getUIContext().animateTo({
      duration: duration,
      curve: Curve.EaseOut
    }, (): void => {
      this.rotation = base + spin.targetAngle;
    });
    this.timerId = setTimeout(async (): Promise<void> => {
      this.timerId = -1;
      await soundService.play(SoundEffect.RESULT);
      if (!this.session.complete()) {
        return;
      }
      decisionDraftStore.updateOptions(values);
      this.refreshEditorOptions();
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
        Column({ space: 12 }) {
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
            options: this.wheelOptions,
            refreshVersion: this.optionsVersion,
            rotation: this.rotation,
            colors: this.colors
          })

          AppButton({
            colors: this.colors,
            label: this.running ? AppStrings.WHEEL_RUNNING : AppStrings.START_WHEEL,
            isEnabled: !this.running,
            onPress: (): void => {
              this.spin();
            }
          })

          Text(AppStrings.OPTIONS)
            .width('100%')
            .fontSize(AppFontSizes.HEADING)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.text)

          if (this.running || this.result.length > 0) {
            Column({ space: 8 }) {
              ForEach(this.wheelOptions, (value: string, index: number): void => {
                Row({ space: 8 }) {
                  Text('⠿')
                    .width(24)
                    .fontSize(18)
                    .fontColor(this.colors.subtext)
                    .textAlign(TextAlign.Center)
                  Text(value)
                    .layoutWeight(1)
                    .height(44)
                    .padding({ left: 12, right: 12 })
                    .fontSize(AppFontSizes.BODY)
                    .fontColor(this.colors.text)
                    .backgroundColor(this.colors.card)
                    .borderRadius(8)
                    .border({ width: 1, color: this.colors.border })
                  Text('删除')
                    .fontSize(AppFontSizes.CAPTION)
                    .fontColor(this.colors.error)
                    .opacity(0.35)
                }
                .width('100%')
                .padding({ left: 8, right: 12, top: 4, bottom: 4 })
                .backgroundColor(this.colors.card)
                .borderRadius(12)
                .border({ width: 1, color: this.colors.border })
              }, (_value: string, index: number): string => `${index}`)
            }
            .width('100%')
          } else {
            OptionsEditor({
              options: this.editorOptions,
              isEnabled: true,
              colors: this.colors,
              onUpdate: (id: string, text: string): void => this.updateOption(id, text),
              onRemove: (id: string): void => this.removeOption(id),
              onMove: (from: number, to: number): void => this.moveOption(from, to),
              onAdd: (): void => this.addOption()
            })
          }

          if (this.error.length > 0) {
            Text(this.error)
              .width('100%')
              .fontSize(AppFontSizes.CAPTION)
              .fontColor(this.colors.error)
          }

          AppButton({
            colors: this.colors,
            label: AppStrings.SAVE_TEMPLATE,
            variant: AppButtonVariant.SECONDARY,
            isEnabled: !this.running,
            onPress: (): void => this.openTemplateDialog()
          })
          if (this.result.length > 0) {
            AppButton({
              colors: this.colors,
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
        .padding({ left: 16, right: 16, top: 14, bottom: 28 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .backgroundColor(this.colors.background)

      ResultSheet({
        visible: this.result.length > 0,
        result: this.result,
        colors: this.colors,
        showRetry: true,
        onRetry: (): void => {
          decisionDraftStore.updateOptions(this.wheelOptions);
          this.refreshEditorOptions();
          this.result = '';
          this.spin();
        },
        onClose: (): void => {
          decisionDraftStore.updateOptions(this.wheelOptions);
          this.refreshEditorOptions();
          this.result = '';
        }
      })
    }
    .width('100%')
    .height('100%')
    .constraintSize({ maxWidth: 720 })
  }
}
