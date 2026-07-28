import { describe, expect, it } from '@ohos/hypium';
import { TimeFormatter } from '../../../main/ets/utils/TimeFormatter';

export default function timeFormatterTest(): void {
  describe('TimeFormatter', () => {
    it('formatsChineseMonthDayAndTime', 0, () => {
      const value: Date = new Date(2026, 6, 28, 18, 30);
      expect(TimeFormatter.format(value.toISOString())).assertEqual('7月28日 18:30');
    });

    it('returnsFallbackForInvalidTime', 0, () => {
      expect(TimeFormatter.format('invalid')).assertEqual('时间未知');
    });
  });
}
