import { RandomService } from '../random/RandomService';

export class DrawSession {
  private readonly initialOptions: string[];
  private readonly allowRepeat: boolean;
  remaining: string[];
  running: boolean = false;
  currentResult: string = '';
  completedResults: string[] = [];

  constructor(options: readonly string[], allowRepeat: boolean) {
    this.initialOptions = Array.from(options);
    this.allowRepeat = allowRepeat;
    this.remaining = Array.from(options);
  }

  start(): string | null {
    if (this.running || this.remaining.length === 0) {
      return null;
    }
    this.currentResult = RandomService.pickOne<string>(this.remaining);
    this.running = true;
    return this.currentResult;
  }

  complete(): boolean {
    if (!this.running || this.currentResult.length === 0) {
      return false;
    }
    this.running = false;
    this.completedResults = [...this.completedResults, this.currentResult];
    if (!this.allowRepeat) {
      this.remaining =
        this.remaining.filter((value: string): boolean => value !== this.currentResult);
    }
    return true;
  }

  cancel(): void {
    if (!this.running) {
      return;
    }
    this.running = false;
    this.currentResult = '';
  }

  reset(): void {
    this.remaining = Array.from(this.initialOptions);
    this.running = false;
    this.currentResult = '';
    this.completedResults = [];
  }
}
