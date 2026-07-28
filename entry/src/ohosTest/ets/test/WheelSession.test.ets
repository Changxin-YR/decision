import { describe, expect, it } from '@ohos/hypium';
import {
  WheelSession,
  WheelSpin
} from '../../../main/ets/domain/state/WheelSession';
import { WheelGeometry } from '../../../main/ets/domain/wheel/WheelGeometry';

export default function wheelSessionTest(): void {
  describe('WheelSession', () => {
    it('preselectsResultAndMatchingTargetAngle', 0, () => {
      const session: WheelSession = new WheelSession();
      const spin: WheelSpin | null = session.start(['甲', '乙', '丙', '丁']);

      expect(spin === null).assertFalse();
      if (spin === null) {
        return;
      }
      expect(spin.resultIndex >= 0 && spin.resultIndex < 4).assertTrue();
      expect(spin.targetAngle >= 5 * 360).assertTrue();
      expect(
        WheelGeometry.resultIndexAtPointer(4, spin.targetAngle)
      ).assertEqual(spin.resultIndex);
    });

    it('rejectsSecondStartWhileRunning', 0, () => {
      const session: WheelSession = new WheelSession();
      expect(session.start(['甲', '乙']) === null).assertFalse();
      expect(session.start(['甲', '乙'])).assertNull();
    });

    it('cancelPreventsCompletion', 0, () => {
      const session: WheelSession = new WheelSession();
      session.start(['甲', '乙']);
      session.cancel();

      expect(session.complete()).assertFalse();
      expect(session.completed).assertFalse();
      expect(session.result).assertEqual('');
    });
  });
}
