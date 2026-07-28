import { describe, expect, it } from '@ohos/hypium';
import { DrawSession } from '../../../main/ets/domain/state/DrawSession';

export default function drawSessionTest(): void {
  describe('DrawSession', () => {
    it('removesCompletedResultInNoRepeatMode', 0, () => {
      const session: DrawSession = new DrawSession(['甲', '乙'], false);
      const first: string | null = session.start();

      expect(first === null).assertFalse();
      expect(session.complete()).assertTrue();
      if (first !== null) {
        expect(session.remaining.includes(first)).assertFalse();
      }
    });

    it('keepsAllCandidatesInRepeatMode', 0, () => {
      const session: DrawSession = new DrawSession(['甲', '乙'], true);
      session.start();
      session.complete();

      expect(session.remaining.length).assertEqual(2);
    });

    it('cancelDoesNotConsumeThePendingResult', 0, () => {
      const session: DrawSession = new DrawSession(['甲', '乙'], false);
      const pending: string | null = session.start();
      session.cancel();

      expect(session.remaining.length).assertEqual(2);
      if (pending !== null) {
        expect(session.remaining.includes(pending)).assertTrue();
      }
    });

    it('rejectsSecondStartWhileRunning', 0, () => {
      const session: DrawSession = new DrawSession(['甲', '乙'], false);

      expect(session.start() === null).assertFalse();
      expect(session.start()).assertNull();
    });
  });
}
