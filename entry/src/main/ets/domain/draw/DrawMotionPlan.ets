import { DecisionTiming } from '../feedback/DecisionTiming';

export enum DrawFeedbackKind {
  START = 'start',
  FINAL_SHAKE = 'final-shake',
  RESULT = 'result'
}

export class DrawShakeStage {
  at: number;
  duration: number;
  angle: number;
  translateY: number;

  constructor(at: number, duration: number, angle: number, translateY: number) {
    this.at = at;
    this.duration = duration;
    this.angle = angle;
    this.translateY = translateY;
  }
}

export class DrawFeedbackCue {
  at: number;
  duration: number;
  kind: DrawFeedbackKind;

  constructor(at: number, duration: number, kind: DrawFeedbackKind) {
    this.at = at;
    this.duration = duration;
    this.kind = kind;
  }
}

export class DrawMotionPlan {
  static readonly SHAKE_END: number = 420;
  static readonly PAUSE_END: number = 560;
  static readonly LIFT_PEAK: number = 1250;
  static readonly LIFT_SETTLE: number = 1450;
  static readonly RESULT_AT: number = DecisionTiming.DRAW_RESULT_AT;
  static readonly SHAKES: DrawShakeStage[] = [
    new DrawShakeStage(0, 70, 9, -3),
    new DrawShakeStage(70, 70, -10, 1),
    new DrawShakeStage(140, 70, 8, -2),
    new DrawShakeStage(210, 70, -6, 1),
    new DrawShakeStage(280, 140, 2, 0)
  ];
  static readonly CUES: DrawFeedbackCue[] = [
    new DrawFeedbackCue(0, 18, DrawFeedbackKind.START),
    new DrawFeedbackCue(350, 28, DrawFeedbackKind.FINAL_SHAKE),
    new DrawFeedbackCue(DecisionTiming.DRAW_RESULT_AT, 70, DrawFeedbackKind.RESULT)
  ];
}
