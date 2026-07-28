import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { PageHeader } from '../components/common/PageHeader';
import { ResultSheet } from '../components/common/ResultSheet';
import { CoinView } from '../components/decision/CoinView';
import { AppSpacing, ThemeTokens } from '../constants/DesignTokens';
import { RandomService } from '../domain/random/RandomService';
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
  }

  private toss(): void {
    const next: CoinSide = RandomService.randomBoolean() ? CoinSide.HEADS : CoinSide.TAILS;
    if (!this.session.begin(next)) {
      return;
    }
    this.running = true;
    this.result = '';
    this.saved = false;
    const halfTurns: number = next === CoinSide.HEADS ? 10 : 11;
    this.getUIContext().animateTo({ duration: 1500, curve: Curve.EaseOut }, (): void => {
      this.rotation += halfTurns * 180;
    });
    soundService.play(SoundEffect.COIN);
    this.timerId = setTimeout((): void => {
      if (!this.session.complete()) {
        return;
      }
      this.side = next;
      this.running = false;
      this.result = next === CoinSide.HEADS ? '正面' : '反面';
      this.record = {
        id: `${Date.now()}`,
        toolType: ToolType.COIN,
        title: '抛硬币',
        options: ['正面', '反面'],
        result: next === CoinSide.HEADS ? '正面' : '反面',
        createdAt: new Date().toISOString()
      };
      feedbackService.impact();
      if (appStore.settings.autoSaveHistory) {
        this.save();
      }
    }, 1500);
  }

  private async save(): Promise<void> {
    if (this.record === null || this.saved) {
      return;
    }
    this.saved = await appStore.saveHistoryRecord(this.record);
  }

  build() {
    Stack() {
      Column({ space: AppSpacing.LG }) {
        PageHeader({
          title: '抛硬币',
          subtitle: `正面 ${this.session.headsCount} · 反面 ${this.session.tailsCount}`,
          colors: this.colors,
          onBack: (): void => this.onBack()
        })
        Blank()
        CoinView({ rotation: this.rotation, side: this.side, colors: this.colors })
        Blank()
        AppButton({
          label: this.running ? '翻转中…' : '抛一次',
          isEnabled: !this.running,
          onPress: (): void => this.toss()
        })
        if (this.record !== null && !this.running) {
          AppButton({
            label: this.saved ? '已保存' : '保存结果',
            variant: AppButtonVariant.SECONDARY,
            isEnabled: !this.saved,
            onPress: (): void => {
              this.save();
            }
          })
        }
        AppButton({
          label: '重置统计',
          variant: AppButtonVariant.TEXT,
          isEnabled: !this.running,
          onPress: (): void => {
            this.session.reset();
            this.record = null;
            this.saved = false;
            this.result = '';
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
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
  }
}
