import { RandomService } from '../random/RandomService';
import { WheelGeometry } from '../wheel/WheelGeometry';

export class WheelSpin {
  resultIndex: number;
  result: string;
  targetAngle: number;

  constructor(resultIndex: number, result: string, targetAngle: number) {
    this.resultIndex = resultIndex;
    this.result = result;
    this.targetAngle = targetAngle;
  }
}

export class WheelSession {
  running: boolean = false;
  completed: boolean = false;
  result: string = '';
  resultIndex: number = -1;
  targetAngle: number = 0;

  start(options: readonly string[]): WheelSpin | null {
    if (this.running || options.length === 0) {
      return null;
    }
    const index: number = RandomService.randomInteger(0, options.length - 1);
    const fullTurns: number = RandomService.randomInteger(5, 8);
    const angle: number =
      fullTurns * 360 + WheelGeometry.stopAngle(options.length, index);
    this.running = true;
    this.completed = false;
    this.result = options[index];
    this.resultIndex = index;
    this.targetAngle = angle;
    return new WheelSpin(index, options[index], angle);
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
    if (!this.running) {
      return;
    }
    this.running = false;
    this.completed = false;
    this.result = '';
    this.resultIndex = -1;
    this.targetAngle = 0;
  }

  reset(): void {
    this.running = false;
    this.completed = false;
    this.result = '';
    this.resultIndex = -1;
    this.targetAngle = 0;
  }
}
