import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { ConfirmDialog } from '../components/common/ConfirmDialog';
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
import { AppStrings } from '../constants/AppStrings';
import {
  DrawMotionPlan,
  DrawShakeStage
} from '../domain/draw/DrawMotionPlan';
import { DrawSession } from '../domain/state/DrawSession';
import { DraftChangeDetector } from '../domain/validation/DraftChangeDetector';
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
  @State private shakeY: number = 0;
  @State private stickOffset: number = 0;
  @State private stickOpacity: number = 0;
  @State private stickScale: number = 0.96;
  @State private revealGlow: number = 0;
  @State private liftedLabel: string = '';
  private timerIds: number[] = [];
  private unsubscribe: (() => void) | null = null;
  private record: HistoryRecord | null = null;
  private initialDraftOptions: string[] = [];
  private initialAllowRepeat: boolean = false;
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
    this.initialDraftOptions = this.optionTexts();
    this.initialAllowRepeat = this.allowRepeat;
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

  private requestBack(): void {
    if (DraftChangeDetector.hasChanges(
      this.initialDraftOptions,
      this.optionTexts(),
      this.initialAllowRepeat,
      this.allowRepeat
    )) {
      this.discardDialog.open();
      return;
    }
    this.onBack();
  }

  private discardAndBack(): void {
    decisionDraftStore.updateOptions(this.initialDraftOptions);
    this.allowRepeat = this.initialAllowRepeat;
    this.onBack();
  }

  private clearTimers(): void {
    this.timerIds.forEach((timerId: number): void => clearTimeout(timerId));
    this.timerIds = [];
  }

  private resetMotion(): void {
    this.shakeAngle = 0;
    this.shakeY = 0;
    this.stickOffset = 0;
    this.stickOpacity = 0;
    this.stickScale = 0.96;
    this.revealGlow = 0;
    this.liftedLabel = '';
  }

  private cancel(): void {
    this.syncDraft();
    this.clearTimers();
    const session: DrawSession | null = decisionDraftStore.currentDrawSession();
    if (session !== null) {
      session.cancel();
    }
    this.running = false;
    this.resetMotion();
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
        AppStrings.DRAW_FINISHED : '';
      return;
    }
    this.error = '';
    this.running = true;
    this.result = '';
    this.saved = false;
    this.record = null;
    this.clearTimers();
    this.resetMotion();
    this.liftedLabel = pending;
    soundService.play(SoundEffect.DRAW);
    feedbackService.impact(DrawMotionPlan.CUES[0].duration);
    DrawMotionPlan.SHAKES.forEach((stage: DrawShakeStage): void => {
      this.timerIds.push(setTimeout((): void => {
        this.getUIContext().animateTo({
          duration: stage.duration,
          curve: Curve.EaseInOut
        }, (): void => {
          this.shakeAngle = stage.angle;
          this.shakeY = stage.translateY;
        });
      }, stage.at));
    });
    this.timerIds.push(setTimeout((): void => {
      feedbackService.impact(DrawMotionPlan.CUES[1].duration);
    }, DrawMotionPlan.CUES[1].at));
    this.timerIds.push(setTimeout((): void => {
      this.getUIContext().animateTo({
        duration: DrawMotionPlan.PAUSE_END - DrawMotionPlan.SHAKE_END,
        curve: Curve.EaseOut
      }, (): void => {
        this.shakeAngle = 0;
        this.shakeY = 0;
      });
    }, DrawMotionPlan.SHAKE_END));
    this.timerIds.push(setTimeout((): void => {
      this.getUIContext().animateTo({
        duration: DrawMotionPlan.LIFT_PEAK - DrawMotionPlan.PAUSE_END,
        curve: Curve.EaseOut
      }, (): void => {
        this.stickOffset = -128;
        this.stickOpacity = 1;
        this.stickScale = 1.04;
      });
    }, DrawMotionPlan.PAUSE_END));
    this.timerIds.push(setTimeout((): void => {
      this.getUIContext().animateTo({
        duration: DrawMotionPlan.LIFT_SETTLE - DrawMotionPlan.LIFT_PEAK,
        curve: Curve.EaseInOut
      }, (): void => {
        this.stickOffset = -116;
        this.stickScale = 1;
        this.revealGlow = 1;
      });
    }, DrawMotionPlan.LIFT_PEAK));
    this.timerIds.push(setTimeout((): void => {
      this.getUIContext().animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, (): void => {
        this.revealGlow = 0.62;
      });
    }, DrawMotionPlan.LIFT_SETTLE));
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
      feedbackService.impact(DrawMotionPlan.CUES[2].duration);
      soundService.play(SoundEffect.RESULT);
      if (appStore.settings.autoSaveHistory) {
        this.save();
      }
    }, DrawMotionPlan.RESULT_AT));
  }

  private resetDraws(): void {
    this.clearTimers();
    const session: DrawSession | null = decisionDraftStore.currentDrawSession();
    if (session !== null) {
      session.reset();
      this.remainingCount = session.remaining.length;
    }
    this.result = '';
    this.error = '';
    this.resetMotion();
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
            title: this.initialTitle.length > 0 ? this.initialTitle : '抽签',
            subtitle: this.running ? '正在抽取，请稍候' :
              (this.allowRepeat ? '允许重复抽取' : `剩余 ${this.remainingCount} 个选项`),
            colors: this.colors,
            onBack: (): void => {
              if (!this.running) {
                this.requestBack();
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
          .height(48)
          .padding({ left: 14, right: 12 })
          .backgroundColor(this.colors.card)
          .borderRadius(12)
          .shadow({ radius: 8, color: '#0D27496B', offsetX: 0, offsetY: 3 })

          DrawTube({
            colors: this.colors,
            shakeAngle: this.shakeAngle,
            shakeY: this.shakeY,
            stickOffset: this.stickOffset,
            stickOpacity: this.stickOpacity,
            stickScale: this.stickScale,
            revealGlow: this.revealGlow,
            liftedLabel: this.liftedLabel
          })

          if (!this.allowRepeat && this.remainingCount === 0) {
            Text(AppStrings.DRAW_FINISHED)
              .width('100%')
              .fontSize(AppFontSizes.HEADING)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.colors.text)
              .textAlign(TextAlign.Center)
            AppButton({
              colors: this.colors,
              label: '重新开始',
              onPress: (): void => this.resetDraws()
            })
          } else {
            AppButton({
              colors: this.colors,
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
            colors: this.colors,
            label: '保存为模板',
            variant: AppButtonVariant.SECONDARY,
            isEnabled: !this.running,
            onPress: (): void => this.openTemplateDialog()
          })
          if (this.result.length > 0) {
            AppButton({
              colors: this.colors,
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
        .padding({ left: 16, right: 16, top: 14, bottom: 28 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(this.colors.background)

      ResultSheet({
        visible: this.result.length > 0,
        result: this.result,
        colors: this.colors,
        showRetry: true,
        onRetry: (): void => {
          this.result = '';
          this.resetMotion();
          this.draw();
        },
        onClose: (): void => {
          this.result = '';
          this.resetMotion();
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
