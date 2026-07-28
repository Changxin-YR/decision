import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import {
  AppFontSizes,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import { AppStrings } from '../constants/AppStrings';
import {
  FingerSelectionMachine,
  FingerState
} from '../domain/state/FingerSelectionMachine';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { feedbackService } from '../services/FeedbackService';

interface FingerPoint {
  id: number;
  x: number;
  y: number;
}

const FINGER_COLORS: string[] = [
  '#E97878', '#E2BD55', '#70B983', '#6897D2', '#B783C5',
  '#58B7B0', '#EE8A55', '#8C82D9', '#D96B9B', '#6FB5E8'
];

@Component
export struct FingerSelectPage {
  @Prop colors: ThemeTokens;
  onBack: () => void = (): void => {
  };
  @State private points: FingerPoint[] = [];
  @State private state: FingerState = FingerState.IDLE;
  @State private countdown: number = 3;
  @State private selectedId: number = -1;
  private machine: FingerSelectionMachine = new FingerSelectionMachine();
  private countdownTimer: number = -1;
  private unlockTimer: number = -1;
  private unsubscribe: (() => void) | null = null;

  aboutToAppear(): void {
    this.unsubscribe = appLifecycleBus.subscribe((background: boolean): void => {
      if (background) {
        this.reset();
      }
    });
  }

  aboutToDisappear(): void {
    this.reset();
    if (this.unsubscribe !== null) {
      this.unsubscribe();
      this.unsubscribe = null;
    }
  }

  private clearTimers(): void {
    if (this.countdownTimer >= 0) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
    if (this.unlockTimer >= 0) {
      clearTimeout(this.unlockTimer);
      this.unlockTimer = -1;
    }
  }

  private syncMachine(): void {
    this.state = this.machine.state;
    this.countdown = this.machine.countdown;
    this.selectedId = this.machine.selectedId;
  }

  private startCountdown(): void {
    if (this.countdownTimer >= 0) {
      clearInterval(this.countdownTimer);
    }
    this.countdownTimer = setInterval((): void => {
      this.machine.tick();
      this.syncMachine();
      if (this.machine.state === FingerState.LOCKED) {
        clearInterval(this.countdownTimer);
        this.countdownTimer = -1;
        feedbackService.impact(80);
        this.unlockTimer = setTimeout((): void => {
          this.reset();
        }, 3000);
      }
    }, 1000);
  }

  private updateTouches(touches: TouchObject[]): void {
    if (this.machine.state === FingerState.LOCKED) {
      return;
    }
    const next: FingerPoint[] = touches.map((touch: TouchObject): FingerPoint => {
      return {
        id: touch.id,
        x: touch.x,
        y: touch.y
      };
    });
    const before: string = this.machine.activeIds.join(',');
    this.machine.updateTouches(next.map((point: FingerPoint): number => point.id));
    this.points = next;
    this.syncMachine();
    const after: string = this.machine.activeIds.join(',');
    if (this.machine.state === FingerState.COUNTDOWN && before !== after) {
      this.startCountdown();
    } else if (this.machine.state === FingerState.IDLE && this.countdownTimer >= 0) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
  }

  private reset(): void {
    this.clearTimers();
    this.machine.reset();
    this.points = [];
    this.syncMachine();
  }

  build() {
    Stack() {
      Column({ space: AppSpacing.SM }) {
        Text(this.state === FingerState.LOCKED ?
          '选中你了！' : AppStrings.FINGER_GUIDE)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.colors.text)
          .textAlign(TextAlign.Center)
        Text(this.state === FingerState.IDLE ?
          '至少需要两根手指' :
          (this.state === FingerState.COUNTDOWN ?
            `保持不动，${this.countdown}` : '3 秒后可再次选择'))
          .fontSize(AppFontSizes.BODY)
          .fontColor(this.colors.subtext)
          .textAlign(TextAlign.Center)
      }
      .position({ x: 20, y: 36 })
      .width('calc(100% - 40vp)')

      ForEach(this.points, (point: FingerPoint, index: number): void => {
        Stack() {
          Circle()
            .width(point.id === this.selectedId ? 112 : 82)
            .height(point.id === this.selectedId ? 112 : 82)
            .fill(FINGER_COLORS[index % FINGER_COLORS.length])
            .stroke('#FFFFFF')
            .strokeWidth(4)
          if (this.state === FingerState.COUNTDOWN) {
            Text(`${this.countdown}`)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
        }
        .width(116)
        .height(116)
        .position({ x: point.x - 58, y: point.y - 58 })
      }, (point: FingerPoint): string => `${point.id}`)

      Column({ space: AppSpacing.SM }) {
        AppButton({
          label: '再来一次',
          variant: AppButtonVariant.SECONDARY,
          onPress: (): void => this.reset()
        })
        AppButton({
          label: '返回首页',
          variant: AppButtonVariant.SECONDARY,
          onPress: (): void => this.onBack()
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
      .align(Alignment.Bottom)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.colors.background)
    .onTouch((event: TouchEvent): void => {
      this.updateTouches(event.touches);
    })
  }
}
