import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { AppInput } from '../components/common/AppInput';
import { PageHeader } from '../components/common/PageHeader';
import { ResultSheet } from '../components/common/ResultSheet';
import { CoinView } from '../components/decision/CoinView';
import { AppFontSizes, AppSpacing, ThemeTokens } from '../constants/DesignTokens';
import { AppStrings } from '../constants/AppStrings';
import { RandomService } from '../domain/random/RandomService';
import { DecisionTiming } from '../domain/feedback/DecisionTiming';
import { CoinSession } from '../domain/state/SimpleDecisionState';
import { CoinSide, HistoryRecord, ToolType } from '../models/AppModels';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { feedbackService } from '../services/FeedbackService';
import { SoundEffect, soundService } from '../services/SoundService';
import { appStore } from '../stores/AppStore';

@Component
export struct CoinPage {
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };
  @State private rotation: number = 0;
  @State private side: CoinSide = CoinSide.HEADS;
  @State private running: boolean = false;
  @State private saved: boolean = false;
  @State private result: string = '';
  @State private revealed: boolean = false;
  @State private question: string = '';
  private session: CoinSession = new CoinSession();
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
    this.session.cancel();
    this.running = false;
    soundService.stop();
  }

  private async toss(): Promise<void> {
    const next: CoinSide = RandomService.randomBoolean() ? CoinSide.HEADS : CoinSide.TAILS;
    if (!this.session.begin(next)) {
      return;
    }
    this.running = true;
    this.revealed = false;
    this.result = '';
    this.saved = false;
    const halfTurns: number = next === CoinSide.HEADS ? 10 : 11;
    await soundService.play(SoundEffect.COIN);
    if (!this.running) {
      return;
    }
    this.getUIContext().animateTo({
      duration: DecisionTiming.COIN_ANIMATION_DURATION,
      curve: Curve.EaseOut
    }, (): void => {
      this.rotation += halfTurns * 180;
    });
    this.timerId = setTimeout(async (): Promise<void> => {
      this.timerId = -1;
      await soundService.play(SoundEffect.RESULT);
      if (!this.session.complete()) {
        return;
      }
      this.side = next;
      this.revealed = true;
      this.running = false;
      this.result = next === CoinSide.HEADS ? AppStrings.HEADS : AppStrings.TAILS;
      this.record = {
        id: `${Date.now()}`,
        toolType: ToolType.COIN,
        title: this.question.trim().length > 0 ?
          this.question.trim() : AppStrings.COIN,
        options: [AppStrings.HEADS, AppStrings.TAILS],
        result: this.result,
        createdAt: new Date().toISOString()
      };
      feedbackService.impact();
      if (appStore.settings.autoSaveHistory) {
        this.save();
      }
    }, DecisionTiming.COIN_RESULT_AT);
  }

  private async save(): Promise<void> {
    if (this.record === null || this.saved) {
      return;
    }
    this.saved = await appStore.saveHistoryRecord(this.record);
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 16 }) {
          PageHeader({
            title: AppStrings.COIN,
            subtitle: '让概率替你做决定',
            colors: this.colors,
            onBack: (): void => this.onBack()
          })
          Row() {
            Text(`♧  正面  ${this.session.headsCount}`)
              .layoutWeight(1)
              .fontSize(AppFontSizes.BODY)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.colors.text)
              .textAlign(TextAlign.Center)
            Text('·').fontColor(this.colors.subtext)
            Text(`◉  反面  ${this.session.tailsCount}`)
              .layoutWeight(1)
              .fontSize(AppFontSizes.BODY)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.colors.text)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(52)
          .backgroundColor(this.colors.card)
          .borderRadius(12)
          .shadow({ radius: 9, color: this.colors.shadow, offsetX: 0, offsetY: 3 })

          CoinView({
            rotation: this.rotation,
            side: this.side,
            revealed: this.revealed,
            colors: this.colors
          })
          Column({ space: 8 }) {
            Text('心里有个问题？')
              .width('100%')
              .fontSize(AppFontSizes.HEADING)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.colors.text)
            Text('写下你的问题，再让硬币替你决定')
              .width('100%')
              .fontSize(AppFontSizes.CAPTION)
              .fontColor(this.colors.subtext)
            AppInput({
              value: $question,
              placeholder: '可以写下你的问题（选填）',
              isEnabled: !this.running,
              colors: this.colors
            })
          }
          .width('100%')
          .padding(14)
          .backgroundColor(this.colors.card)
          .borderRadius(12)
          .shadow({ radius: 9, color: this.colors.shadow, offsetX: 0, offsetY: 3 })

          AppButton({
            colors: this.colors,
            label: this.running ? AppStrings.FLIPPING : `⟳  ${AppStrings.TOSS}`,
            isEnabled: !this.running,
            onPress: (): void => {
              this.toss();
            }
          })
          AppButton({
            colors: this.colors,
            label: `⟳  ${AppStrings.RESET_STATS}`,
            variant: AppButtonVariant.SECONDARY,
            isEnabled: !this.running,
            onPress: (): void => {
              this.session.reset();
              this.record = null;
              this.saved = false;
              this.result = '';
              this.revealed = false;
            }
            })
          Text('随机公正 · 结果仅供参考')
            .fontSize(AppFontSizes.CAPTION)
            .fontColor(this.colors.subtext)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 22 })
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
          this.result = '';
          this.toss();
        },
        onClose: (): void => {
          this.result = '';
        }
      })
    }
    .width('100%')
    .height('100%')
    .constraintSize({ maxWidth: 720 })
  }
}
