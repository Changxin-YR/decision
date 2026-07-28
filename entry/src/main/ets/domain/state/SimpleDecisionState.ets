import { CoinSide } from '../../models/AppModels';

export class SimpleDecisionState {
  running: boolean = false;
  completed: boolean = false;

  begin(): boolean {
    if (this.running) {
      return false;
    }
    this.running = true;
    this.completed = false;
    return true;
  }

  complete(): boolean {
    if (!this.running) {
      return false;
    }
    this.running = false;
    this.completed = true;
    return true;
  }

  cancel(): void {
    this.running = false;
    this.completed = false;
  }

  reset(): void {
    this.cancel();
  }
}

export class CoinSession {
  running: boolean = false;
  completed: boolean = false;
  headsCount: number = 0;
  tailsCount: number = 0;
  pendingSide: CoinSide | null = null;
  lastSide: CoinSide | null = null;

  begin(side: CoinSide): boolean {
    if (this.running) {
      return false;
    }
    this.running = true;
    this.completed = false;
    this.pendingSide = side;
    return true;
  }

  complete(): boolean {
    if (!this.running || this.pendingSide === null) {
      return false;
    }
    const side: CoinSide = this.pendingSide;
    this.running = false;
    this.completed = true;
    this.lastSide = side;
    this.pendingSide = null;
    if (side === CoinSide.HEADS) {
      this.headsCount++;
    } else {
      this.tailsCount++;
    }
    return true;
  }

  cancel(): void {
    this.running = false;
    this.completed = false;
    this.pendingSide = null;
  }

  reset(): void {
    this.cancel();
    this.pendingSide = null;
    this.lastSide = null;
    this.headsCount = 0;
    this.tailsCount = 0;
  }
}
