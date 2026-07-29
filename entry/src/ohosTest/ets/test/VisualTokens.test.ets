import { describe, expect, it } from '@ohos/hypium';
import {
  AppFontSizes,
  AppRadii,
  AppSpacing
} from '../../../main/ets/constants/DesignTokens';

export default function visualTokensTest(): void {
  describe('VisualTokens', (): void => {
    it('matches approved compact phone metrics', 0, (): void => {
      expect(AppSpacing.PAGE_HORIZONTAL).assertEqual(16);
      expect(AppRadii.CARD).assertEqual(12);
      expect(AppRadii.PRIMARY_BUTTON).assertEqual(10);
      expect(AppFontSizes.PAGE_TITLE).assertEqual(22);
    });
  });
}
