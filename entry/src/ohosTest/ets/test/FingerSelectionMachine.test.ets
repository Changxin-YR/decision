import { describe, expect, it } from '@ohos/hypium';
import {
  FingerSelectionMachine,
  FingerState
} from '../../../main/ets/domain/state/FingerSelectionMachine';

export default function fingerSelectionMachineTest(): void {
  describe('FingerSelectionMachine', () => {
    it('startsCountdownOnlyWithAtLeastTwoTouches', 0, () => {
      const machine: FingerSelectionMachine = new FingerSelectionMachine();
      machine.updateTouches([1]);
      expect(machine.state).assertEqual(FingerState.IDLE);
      machine.updateTouches([1, 2]);
      expect(machine.state).assertEqual(FingerState.COUNTDOWN);
      expect(machine.countdown).assertEqual(3);
    });

    it('restartsCountdownWhenTouchesChange', 0, () => {
      const machine: FingerSelectionMachine = new FingerSelectionMachine();
      machine.updateTouches([1, 2]);
      machine.tick();
      machine.updateTouches([1, 2, 3]);
      expect(machine.countdown).assertEqual(3);
      machine.updateTouches([1, 3]);
      expect(machine.countdown).assertEqual(3);
    });

    it('locksASelectedActiveTouchAfterThreeTicks', 0, () => {
      const machine: FingerSelectionMachine = new FingerSelectionMachine();
      machine.updateTouches([4, 8]);
      machine.tick();
      machine.tick();
      machine.tick();
      expect(machine.state).assertEqual(FingerState.LOCKED);
      expect(machine.activeIds.includes(machine.selectedId)).assertTrue();
    });

    it('ignoresTouchesWhileLockedAndCanReset', 0, () => {
      const machine: FingerSelectionMachine = new FingerSelectionMachine();
      machine.updateTouches([1, 2]);
      machine.tick();
      machine.tick();
      machine.tick();
      machine.updateTouches([7, 9]);
      expect(machine.activeIds.includes(7)).assertFalse();
      machine.reset();
      expect(machine.state).assertEqual(FingerState.IDLE);
      expect(machine.activeIds.length).assertEqual(0);
    });
  });
}
