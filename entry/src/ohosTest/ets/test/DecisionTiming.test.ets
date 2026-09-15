import { describe, expect, it } from '@ohos/hypium';
import { DecisionTiming } from '../../../main/ets/domain/feedback/DecisionTiming';

export default function decisionTimingTest(): void {
  describe('DecisionTiming', (): void => {
    it('keepsShortDecisionsVisibleLongEnoughForProcessFeedback', 0, (): void => {
      expect(DecisionTiming.YES_NO_RESULT_AT).assertEqual(1400);
      expect(DecisionTiming.COIN_RESULT_AT).assertEqual(2500);
      expect(DecisionTiming.COIN_ANIMATION_DURATION).assertEqual(2300);
      expect(DecisionTiming.DRAW_RESULT_AT).assertEqual(3000);
      expect(DecisionTiming.WHEEL_RESULT_AT).assertEqual(3600);
      expect(DecisionTiming.FINGER_RESULT_AT).assertEqual(3000);
    });
  });
}
