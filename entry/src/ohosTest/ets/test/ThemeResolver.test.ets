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
      expect(tokens.isDark).assertFalse();
    });

    it('returnsDarkTokens', 0, () => {
      const tokens: ThemeTokens = ThemeResolver.resolve(ThemeMode.DARK, false);

      expect(tokens.background).assertEqual('#071426');
      expect(tokens.card).assertEqual('#101E35');
      expect(tokens.text).assertEqual(AppColors.DARK_TEXT);
      expect(tokens.border).assertEqual('#203654');
      expect(tokens.accent).assertEqual(AppColors.PRIMARY);
      expect(tokens.input).assertEqual('#0C1930');
      expect(tokens.primaryStart).assertEqual('#2E83FF');
      expect(tokens.primaryEnd).assertEqual('#1748D4');
      expect(tokens.isDark).assertTrue();
    });

    it('followsSystemMode', 0, () => {
      const dark: ThemeTokens = ThemeResolver.resolve(ThemeMode.SYSTEM, true);
      const light: ThemeTokens = ThemeResolver.resolve(ThemeMode.SYSTEM, false);

      expect(dark.background).assertEqual(AppColors.DARK_BACKGROUND);
      expect(light.background).assertEqual(AppColors.LIGHT_BACKGROUND);
    });

    it('resolvesSystemBarContentForEveryThemeMode', 0, () => {
      expect(ThemeResolver.systemBarContentColor(ThemeMode.DARK, false)).assertEqual('#FFFFFF');
      expect(ThemeResolver.systemBarContentColor(ThemeMode.LIGHT, true)).assertEqual(AppColors.LIGHT_TEXT);
      expect(ThemeResolver.systemBarContentColor(ThemeMode.SYSTEM, true)).assertEqual('#FFFFFF');
      expect(ThemeResolver.systemBarContentColor(ThemeMode.SYSTEM, false)).assertEqual(AppColors.LIGHT_TEXT);
    });
  });
}
