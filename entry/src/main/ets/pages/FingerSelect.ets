import { AppButton, AppButtonVariant } from '../components/common/AppButton';
import { PageHeader } from '../components/common/PageHeader';
import {
  AppFontSizes,
  AppSpacing,
  ThemeTokens
} from '../constants/DesignTokens';
import { AppStrings } from '../constants/AppStrings';
import { DecisionTiming } from '../domain/feedback/DecisionTiming';
import {
  FingerSelectionMachine,
  FingerState
} from '../domain/state/FingerSelectionMachine';
import { appLifecycleBus } from '../services/AppLifecycleBus';
import { feedbackService } from '../services/FeedbackService';
import { SoundEffect, soundService } from '../services/SoundService';

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
  private countdownRequest: number = 0;
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
    this.countdownRequest += 1;
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

  private async startCountdown(): Promise<void> {
    const request: number = ++this.countdownRequest;
    if (this.countdownTimer >= 0) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
    await soundService.play(SoundEffect.TAP);
    if (request !== this.countdownRequest ||
      this.machine.state !== FingerState.COUNTDOWN) {
      return;
    }
    this.countdownTimer = setInterval(async (): Promise<void> => {
      if (request !== this.countdownRequest) {
        return;
      }
      this.machine.tick();
      if (this.machine.state === FingerState.LOCKED) {
        clearInterval(this.countdownTimer);
        this.countdownTimer = -1;
        await soundService.play(SoundEffect.RESULT);
        if (request !== this.countdownRequest ||
          this.machine.state !== FingerState.LOCKED) {
          return;
        }
        this.syncMachine();
        feedbackService.impact(80);
        this.unlockTimer = setTimeout((): void => {
          this.reset();
        }, 3000);
      } else {
        this.syncMachine();
      }
    }, DecisionTiming.FINGER_RESULT_AT / 3);
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
    } else if (this.machine.state === FingerState.IDLE) {
      this.countdownRequest += 1;
      if (this.countdownTimer >= 0) {
        clearInterval(this.countdownTimer);
        this.countdownTimer = -1;
      }
      soundService.stop();
    }
  }

  private reset(): void {
    this.clearTimers();
    this.machine.reset();
    this.points = [];
    this.syncMachine();
    soundService.stop();
  }

  @Builder
  private touchSurface() {
    Stack() {
      Column({ space: 14 }) {
        Text(this.state === FingerState.LOCKED ? '选中你了！' : '指尖选择')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.colors.text)
          .textAlign(TextAlign.Center)
        Text(this.state === FingerState.IDLE ?
          '请将手指放在屏幕上' :
          (this.state === FingerState.COUNTDOWN ?
            `保持不动，${this.countdown}` : '3 秒后可再次选择'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colors.text)
          .textAlign(TextAlign.Center)
        Text(this.state === FingerState.IDLE ? '至少需要两根手指' : '')
          .fontSize(AppFontSizes.BODY)
          .fontColor(this.colors.subtext)
        if (this.points.length === 0) {
          Image(this.colors.isDark ?
            $r('app.media.ui_finger_guide_dark_v2') : $r('app.media.ui_finger_guide'))
            .width('82%')
            .height(330)
            .objectFit(ImageFit.Contain)
            .borderRadius(this.colors.isDark ? 18 : 0)
            .margin({ top: 10 })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .onTouch((event: TouchEvent): void => {
      this.updateTouches(event.touches);
    })
  }

  build() {
    Stack() {
      Column() {
        PageHeader({
          title: '',
          colors: this.colors,
          backButtonSize: 44,
          backButtonRadius: 13,
          onBack: (): void => this.onBack()
        })

        this.touchSurface()

        Column({ space: 14 }) {
          AppButton({
            colors: this.colors,
            label: '重新开始',
            onPress: (): void => this.reset()
          })
          AppButton({
            colors: this.colors,
            label: '返回首页',
            variant: AppButtonVariant.SECONDARY,
            onPress: (): void => this.onBack()
          })
        }
        .width('100%')
        .padding({ left: 28, right: 28, bottom: 8 })
      }
      .width('100%')
      .height('100%')

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
    }
    .width('100%')
    .height('100%')
    .constraintSize({ maxWidth: 720 })
    .backgroundColor(this.colors.background)
  }
}
