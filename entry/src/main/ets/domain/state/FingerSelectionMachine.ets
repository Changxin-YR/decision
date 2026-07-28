import { RandomService } from '../random/RandomService';

export enum FingerState {
  IDLE = 'idle',
  COUNTDOWN = 'countdown',
  LOCKED = 'locked'
}

export class FingerSelectionMachine {
  state: FingerState = FingerState.IDLE;
  activeIds: number[] = [];
  selectedId: number = -1;
  countdown: number = 3;

  updateTouches(ids: readonly number[]): void {
    if (this.state === FingerState.LOCKED) {
      return;
    }
    const next: number[] = Array.from(ids).sort((left: number, right: number): number => {
      return left - right;
    });
    const changed: boolean = next.join(',') !== this.activeIds.join(',');
    this.activeIds = next;
    if (next.length < 2) {
      this.resetCountdown();
      return;
    }
    if (changed || this.state === FingerState.IDLE) {
      this.state = FingerState.COUNTDOWN;
      this.countdown = 3;
      this.selectedId = -1;
    }
  }

  tick(): void {
    if (this.state !== FingerState.COUNTDOWN) {
      return;
    }
    this.countdown--;
    if (this.countdown <= 0) {
      this.countdown = 0;
      this.selectedId = RandomService.pickOne<number>(this.activeIds);
      this.state = FingerState.LOCKED;
    }
  }

  reset(): void {
    this.activeIds = [];
    this.selectedId = -1;
    this.resetCountdown();
  }

  private resetCountdown(): void {
    this.state = FingerState.IDLE;
    this.countdown = 3;
    this.selectedId = -1;
  }
}
