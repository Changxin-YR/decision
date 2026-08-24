import { AppButton } from '../components/common/AppButton';
import { AppInput } from '../components/common/AppInput';
import { PageHeader } from '../components/common/PageHeader';
import { ResultSheet } from '../components/common/ResultSheet';
import { AppFontSizes, AppSpacing, ThemeTokens } from '../constants/DesignTokens';
import { RandomService } from '../domain/random/RandomService';
import { SimpleDecisionState } from '../domain/state/SimpleDecisionState';
import { HistoryRecord, ToolType } from '../models/AppModels';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { feedbackService } from '../services/FeedbackService';
import { SoundEffect, soundService } from '../services/SoundService';
import { appStore } from '../stores/AppStore';

@Component
export struct YesNoPage {
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };
  @State private question: string = '';
  @State private result: string = '';
  @State private running: boolean = false;
  @State private saved: boolean = false;
  private state: SimpleDecisionState = new SimpleDecisionState();
  private timerId: number = -1;
  private unsubscribe: (() => void) | null = null;
  private record: HistoryRecord | null = null;

  aboutToAppear(): void {
    this.unsubscribe = appLifecycleBus.subscribe((background: boolean): void => {
      if (background) {
        this.cancel();
      }
    });
  }

  aboutToDisappear(): void {
    this.cancel();
    if (this.unsubscribe !== null) {
      this.unsubscribe();
    }
  }

  private cancel(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
    this.state.cancel();
    this.running = false;
  }

  private decide(): void {
    if (!this.state.begin()) {
      return;
    }
    const choice: string = RandomService.randomBoolean() ? '是' : '否';
    this.running = true;
    this.result = '';
    this.saved = false;
    soundService.play(SoundEffect.TAP);
    this.timerId = setTimeout((): void => {
      if (!this.state.complete()) {
        return;
      }
      this.running = false;
      this.result = choice;
      this.record = {
        id: `${Date.now()}`,
        toolType: ToolType.YES_NO,
        title: this.question.trim().length > 0 ? this.question.trim() : '是或否',
        options: ['是', '否'],
        result: choice,
        createdAt: new Date().toISOString()
      };
      feedbackService.impact();
      soundService.play(SoundEffect.RESULT);
      if (appStore.settings.autoSaveHistory) {
        this.save();
      }
    }, 400);
  }

  private async save(): Promise<void> {
    if (this.record === null || this.saved) {
      return;
    }
    this.saved = await appStore.saveHistoryRecord(this.record);
  }

  build() {
    Stack() {
      Column({ space: 18 }) {
        PageHeader({
          title: '是或否',
          subtitle: '',
          colors: this.colors,
          onBack: (): void => this.onBack()
        })
        Text('心里有个问题？')
          .fontSize(AppFontSizes.HEADING)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colors.text)
        Text('写下你的问题，让直觉帮你决定')
          .fontSize(AppFontSizes.CAPTION)
          .fontColor(this.colors.subtext)
        AppInput({
          value: $question,
          placeholder: '可以写下你的问题（选填）',
          isEnabled: !this.running,
          colors: this.colors
        })
        Blank()
        Row({ space: 24 }) {
          Button(this.running ? '…' : '是', { type: ButtonType.Circle })
            .width(112)
            .height(112)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.accent)
            .backgroundColor(this.colors.isDark ? '#10234B' : '#F1F8FE')
            .border({ width: 2, color: this.colors.isDark ? this.colors.accent : '#D4EBFC' })
            .shadow({ radius: 18, color: this.colors.isDark ? this.colors.glow : '#182D94F4', offsetX: 0, offsetY: 4 })
            .enabled(!this.running)
            .onClick((): void => this.decide())
          Button(this.running ? '…' : '否', { type: ButtonType.Circle })
            .width(112)
            .height(112)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.subtext)
            .backgroundColor(this.colors.card)
            .border({ width: 2, color: this.colors.border })
            .shadow({ radius: 14, color: '#1427496B', offsetX: 0, offsetY: 4 })
            .enabled(!this.running)
            .onClick((): void => this.decide())
        }
        Blank()
        AppButton({
          colors: this.colors,
          label: '交给直觉',
          isEnabled: !this.running,
          onPress: (): void => this.decide()
        })
        if (this.result.length > 0) {
          AppButton({
            colors: this.colors,
            label: this.saved ? '已保存' : '保存结果',
            isEnabled: !this.saved,
            onPress: (): void => {
              this.save();
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 22 })
      .backgroundColor(this.colors.background)

      ResultSheet({
        visible: this.result.length > 0,
        result: this.result,
        colors: this.colors,
        onClose: (): void => {
          this.result = '';
        }
      })
    }
  }
}
