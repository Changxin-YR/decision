import { describe, expect, it } from '@ohos/hypium';
import { CoinSide } from '../../../main/ets/models/AppModels';
import {
  CoinSession,
  SimpleDecisionState
} from '../../../main/ets/domain/state/SimpleDecisionState';

export default function simpleDecisionStateTest(): void {
  describe('SimpleDecisionState', () => {
    it('ignoresSecondStartWhileRunning', 0, () => {
      const state: SimpleDecisionState = new SimpleDecisionState();
      expect(state.begin()).assertTrue();
      expect(state.begin()).assertFalse();
    });

    it('cancelReturnsToIdle', 0, () => {
      const state: SimpleDecisionState = new SimpleDecisionState();
      state.begin();
      state.cancel();
      expect(state.running).assertFalse();
      expect(state.completed).assertFalse();
    });

    it('countsOnlyCompletedCoinResults', 0, () => {
      const state: CoinSession = new CoinSession();
      state.begin(CoinSide.HEADS);
      state.cancel();
      expect(state.headsCount).assertEqual(0);
      state.begin(CoinSide.HEADS);
      state.complete();
      expect(state.headsCount).assertEqual(1);
      expect(state.tailsCount).assertEqual(0);
    });
  });
}
