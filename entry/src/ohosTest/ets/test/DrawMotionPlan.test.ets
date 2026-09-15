import { describe, expect, it } from '@ohos/hypium';
import {
  DrawFeedbackKind,
  DrawMotionPlan
} from '../../../main/ets/domain/draw/DrawMotionPlan';

export default function drawMotionPlanTest(): void {
  describe('DrawMotionPlan', (): void => {
    it('usesApprovedDramaticTiming', 0, (): void => {
      expect(DrawMotionPlan.SHAKE_END).assertEqual(420);
      expect(DrawMotionPlan.PAUSE_END).assertEqual(560);
      expect(DrawMotionPlan.LIFT_SETTLE).assertEqual(1450);
      expect(DrawMotionPlan.RESULT_AT).assertEqual(3000);
    });

    it('usesFiveDecayingShakeSteps', 0, (): void => {
      expect(DrawMotionPlan.SHAKES.length).assertEqual(5);
      expect(Math.abs(DrawMotionPlan.SHAKES[0].angle))
        .assertLarger(Math.abs(DrawMotionPlan.SHAKES[4].angle));
    });

    it('definesThreeOrderedFeedbackCues', 0, (): void => {
      expect(DrawMotionPlan.CUES.length).assertEqual(3);
      expect(DrawMotionPlan.CUES[0].kind)
        .assertEqual(DrawFeedbackKind.START);
      expect(DrawMotionPlan.CUES[1].kind)
        .assertEqual(DrawFeedbackKind.FINAL_SHAKE);
      expect(DrawMotionPlan.CUES[2].kind)
        .assertEqual(DrawFeedbackKind.RESULT);
      expect(DrawMotionPlan.CUES[0].duration).assertEqual(18);
      expect(DrawMotionPlan.CUES[1].duration).assertEqual(28);
      expect(DrawMotionPlan.CUES[2].duration).assertEqual(70);
    });
  });
}
