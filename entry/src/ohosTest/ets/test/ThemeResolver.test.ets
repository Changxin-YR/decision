import { describe, expect, it } from '@ohos/hypium';
import {
  AppColors,
  ThemeResolver,
  ThemeTokens
} from '../../../main/ets/constants/DesignTokens';
import { ThemeMode } from '../../../main/ets/models/AppModels';

export default function themeResolverTest(): void {
  describe('ThemeResolver', () => {
    it('returnsLightTokens', 0, () => {
      const tokens: ThemeTokens = ThemeResolver.resolve(ThemeMode.LIGHT, true);

      expect(tokens.background).assertEqual(AppColors.LIGHT_BACKGROUND);
      expect(tokens.card).assertEqual(AppColors.LIGHT_CARD);
      expect(tokens.text).assertEqual(AppColors.LIGHT_TEXT);
      expect(tokens.border).assertEqual(AppColors.LIGHT_BORDER);
      expect(tokens.accent).assertEqual(AppColors.PRIMARY);
    });

    it('returnsDarkTokens', 0, () => {
      const tokens: ThemeTokens = ThemeResolver.resolve(ThemeMode.DARK, false);

      expect(tokens.background).assertEqual(AppColors.DARK_BACKGROUND);
      expect(tokens.card).assertEqual(AppColors.DARK_CARD);
      expect(tokens.text).assertEqual(AppColors.DARK_TEXT);
      expect(tokens.border).assertEqual(AppColors.DARK_BORDER);
      expect(tokens.accent).assertEqual(AppColors.PRIMARY);
    });

    it('followsSystemMode', 0, () => {
      const dark: ThemeTokens = ThemeResolver.resolve(ThemeMode.SYSTEM, true);
      const light: ThemeTokens = ThemeResolver.resolve(ThemeMode.SYSTEM, false);

      expect(dark.background).assertEqual(AppColors.DARK_BACKGROUND);
      expect(light.background).assertEqual(AppColors.LIGHT_BACKGROUND);
    });
  });
}
