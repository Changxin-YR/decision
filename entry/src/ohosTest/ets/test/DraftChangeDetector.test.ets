import { describe, expect, it } from '@ohos/hypium';
import { DraftChangeDetector } from '../../../main/ets/domain/validation/DraftChangeDetector';

export default function draftChangeDetectorTest(): void {
  describe('DraftChangeDetector', (): void => {
    it('detects option edits and repeat-mode changes', 0, (): void => {
      expect(DraftChangeDetector.hasChanges(['甲', '乙'], ['甲', '乙'])).assertFalse();
      expect(DraftChangeDetector.hasChanges(['甲', '乙'], ['甲', '丙'])).assertTrue();
      expect(DraftChangeDetector.hasChanges(['甲', '乙'], ['甲', '乙'], false, true)).assertTrue();
    });
  });
}
