import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { PageHeader } from '../components/common/PageHeader';
import { ResultSheet } from '../components/common/ResultSheet';
import { DrawTube } from '../components/decision/DrawTube';
import { OptionsEditor } from '../components/decision/OptionsEditor';
import { TemplateSaveDialog } from '../components/decision/TemplateSaveDialog';
import {
  AppFontSizes,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import { DrawSession } from '../domain/state/DrawSession';
import { OptionValidator } from '../domain/validation/OptionValidator';
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
export struct DrawPage {
  @Prop colors: ThemeTokens;
  @Prop initialTitle: string = '';
  @Prop initialOptions: string[] = [];
  onBack: () => void = (): void => {
  };
  @State private optionsVersion: number = 0;
  @State private allowRepeat: boolean = false;
  @State private error: string = '';
  @State private running: boolean = false;
  @State private result: string = '';
  @State private saved: boolean = false;
  @State private remainingCount: number = 0;
  @State private shakeAngle: number = 0;
  @State private stickOffset: number = 0;
  @State private liftedLabel: string = '';
  private timerIds: number[] = [];
  private unsubscribe: (() => void) | null = null;
  private record: HistoryRecord | null = null;
  private templateDialog: CustomDialogController = new CustomDialogController({
    builder: TemplateSaveDialog({
      colors: this.colors,
      onSave: async (name: string): Promise<boolean> => {
        return appStore.createCustomTemplate(
          name,
          ToolType.DRAW,
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
        ToolType.DRAW,
        this.initialOptions.length >= 2 ? this.initialOptions : ['', '']
      );
    }
    this.optionsVersion++;
    const activeSession: DrawSession | null = decisionDraftStore.currentDrawSession();
    this.remainingCount = activeSession === null ?
      decisionDraftStore.options.length : activeSession.remaining.length;
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

  private syncDraft(): void {
    decisionDraftStore.updateOptions(this.optionTexts());
  }

  private invalidateSession(): void {
    this.syncDraft();
    this.result = '';
    this.remainingCount = decisionDraftStore.options.length;
  }

  private updateOption(id: string, text: string): void {
    decisionDraftStore.updateOption(id, text);
    this.optionsVersion++;
    this.error = '';
    this.invalidateSession();
  }

  private removeOption(id: string): void {
    decisionDraftStore.removeOption(id);
    this.optionsVersion++;
    this.error = '';
    this.invalidateSession();
  }

  private moveOption(from: number, to: number): void {
    decisionDraftStore.moveOption(from, to);
    this.optionsVersion++;
    this.invalidateSession();
  }

  private addOption(): void {
    decisionDraftStore.addOption();
    this.optionsVersion++;
    this.invalidateSession();
  }

  private clearTimers(): void {
    this.timerIds.forEach((timerId: number): void => clearTimeout(timerId));
    this.timerIds = [];
  }

  private cancel(): void {
    this.syncDraft();
    this.clearTimers();
    const session: DrawSession | null = decisionDraftStore.currentDrawSession();
    if (session !== null) {
      session.cancel();
    }
    this.running = false;
    this.shakeAngle = 0;
    this.stickOffset = 0;
    this.liftedLabel = '';
  }

  private ensureSession(values: string[]): DrawSession {
    const session: DrawSession =
      decisionDraftStore.getDrawSession(values, this.allowRepeat);
    this.remainingCount = session.remaining.length;
    return session;
  }

  private draw(): void {
    const validation = OptionValidator.validate(this.optionTexts());
    if (!validation.valid) {
      this.error = validation.message;
      return;
    }
    const values: string[] =
      this.optionTexts().map((value: string): string => value.trim());
    decisionDraftStore.updateOptions(values);
    const session: DrawSession = this.ensureSession(values);
    const pending: string | null = session.start();
    if (pending === null) {
      this.error = session.remaining.length === 0 ?
        '所有选项已经抽取完成' : '';
      return;
    }
    this.error = '';
    this.running = true;
    this.result = '';
    this.saved = false;
    this.record = null;
    this.liftedLabel = pending;
    this.stickOffset = 0;
    soundService.play(SoundEffect.DRAW);
    this.getUIContext().animateTo({ duration: 240, curve: Curve.EaseInOut }, (): void => {
      this.shakeAngle = 7;
    });
    this.timerIds.push(setTimeout((): void => {
      this.getUIContext().animateTo({ duration: 260, curve: Curve.EaseInOut }, (): void => {
        this.shakeAngle = -7;
      });
    }, 240));
    this.timerIds.push(setTimeout((): void => {
      this.getUIContext().animateTo({ duration: 650, curve: Curve.EaseOut }, (): void => {
        this.shakeAngle = 0;
        this.stickOffset = -96;
      });
    }, 500));
    this.timerIds.push(setTimeout((): void => {
      this.clearTimers();
      if (!session.complete()) {
        return;
      }
      this.running = false;
      this.result = pending;
      this.remainingCount = session.remaining.length;
      this.record = {
        id: `${Date.now()}`,
        toolType: ToolType.DRAW,
        title: this.initialTitle.trim().length > 0 ?
          this.initialTitle.trim() : '抽签',
        options: values,
        result: pending,
        createdAt: new Date().toISOString()
      };
      feedbackService.impact();
      soundService.play(SoundEffect.RESULT);
      if (appStore.settings.autoSaveHistory) {
        this.save();
      }
    }, 1200));
  }

  private resetDraws(): void {
    const session: DrawSession | null = decisionDraftStore.currentDrawSession();
    if (session !== null) {
      session.reset();
      this.remainingCount = session.remaining.length;
    }
    this.result = '';
    this.error = '';
    this.liftedLabel = '';
    this.stickOffset = 0;
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
            title: this.initialTitle.length > 0 ? this.initialTitle : '抽签',
            subtitle: this.running ? '正在抽取，请稍候' :
              (this.allowRepeat ? '允许重复抽取' : `剩余 ${this.remainingCount} 个选项`),
            colors: this.colors,
            onBack: (): void => {
              if (!this.running) {
                this.onBack();
              }
            }
          })

          Row() {
            Text('允许重复')
              .fontSize(AppFontSizes.BODY)
              .fontColor(this.colors.text)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.allowRepeat })
              .enabled(!this.running)
              .onChange((value: boolean): void => {
                this.allowRepeat = value;
                this.invalidateSession();
              })
          }
          .width('100%')

          DrawTube({
            colors: this.colors,
            shakeAngle: this.shakeAngle,
            stickOffset: this.stickOffset,
            liftedLabel: this.liftedLabel
          })

          if (!this.allowRepeat && this.remainingCount === 0) {
            Text('所有选项已经抽取完成')
              .width('100%')
              .fontSize(AppFontSizes.HEADING)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.colors.text)
              .textAlign(TextAlign.Center)
            AppButton({
              label: '重新开始',
              onPress: (): void => this.resetDraws()
            })
          } else {
            AppButton({
              label: this.running ? '抽取中…' : '开始抽签',
              isEnabled: !this.running,
              onPress: (): void => this.draw()
            })
          }

          Text('选项')
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
            label: '保存为模板',
            variant: AppButtonVariant.SECONDARY,
            isEnabled: !this.running,
            onPress: (): void => this.openTemplateDialog()
          })
          if (this.result.length > 0) {
            AppButton({
              label: this.saved ? '结果已保存' : '保存结果',
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
        onClose: (): void => {
          this.result = '';
          this.liftedLabel = '';
          this.stickOffset = 0;
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
