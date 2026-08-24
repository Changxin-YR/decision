import { ThemeMode } from '../models/AppModels';

export class AppColors {
  static readonly PRIMARY: string = '#2D94F4';
  static readonly PRIMARY_LIGHT: string = '#64B9F7';
  static readonly LIGHT_BACKGROUND: string = '#F7F9FC';
  static readonly LIGHT_CARD: string = '#FFFFFF';
  static readonly LIGHT_TEXT: string = '#0B1F3A';
  static readonly LIGHT_SUBTEXT: string = '#8B97AB';
  static readonly LIGHT_BORDER: string = '#E6EBF2';
  static readonly DARK_BACKGROUND: string = '#071426';
  static readonly DARK_CARD: string = '#101E35';
  static readonly DARK_TEXT: string = '#F5F7FB';
  static readonly DARK_SUBTEXT: string = '#9AA5B5';
  static readonly DARK_BORDER: string = '#294361';
  static readonly ERROR: string = '#F05B63';
  static readonly SUCCESS: string = '#27AE60';
}

export interface ThemeTokens {
  background: string;
  card: string;
  input: string;
  text: string;
  subtext: string;
  border: string;
  accent: string;
  primaryStart: string;
  primaryEnd: string;
  glow: string;
  shadow: string;
  isDark: boolean;
  error: string;
  success: string;
}

export class ThemeResolver {
  static resolve(mode: ThemeMode, systemDark: boolean): ThemeTokens {
    const dark: boolean = mode === ThemeMode.DARK ||
      (mode === ThemeMode.SYSTEM && systemDark);
    if (dark) {
      return {
        background: AppColors.DARK_BACKGROUND,
        card: AppColors.DARK_CARD,
        input: '#0C1930',
        text: AppColors.DARK_TEXT,
        subtext: AppColors.DARK_SUBTEXT,
        border: AppColors.DARK_BORDER,
        accent: AppColors.PRIMARY,
        primaryStart: '#2E83FF',
        primaryEnd: '#1748D4',
        glow: '#663C8CFF',
        shadow: '#80010818',
        isDark: true,
        error: AppColors.ERROR,
        success: AppColors.SUCCESS
      };
    }
    return {
      background: AppColors.LIGHT_BACKGROUND,
      card: AppColors.LIGHT_CARD,
      input: AppColors.LIGHT_CARD,
      text: AppColors.LIGHT_TEXT,
      subtext: AppColors.LIGHT_SUBTEXT,
      border: AppColors.LIGHT_BORDER,
      accent: AppColors.PRIMARY,
      primaryStart: AppColors.PRIMARY,
      primaryEnd: AppColors.PRIMARY,
      glow: '#00000000',
      shadow: '#0D27496B',
      isDark: false,
      error: AppColors.ERROR,
      success: AppColors.SUCCESS
    };
  }
}

export class AppSpacing {
  static readonly XS: number = 4;
  static readonly SM: number = 8;
  static readonly MD: number = 16;
  static readonly LG: number = 24;
  static readonly XL: number = 32;
  static readonly PAGE_HORIZONTAL: number = 16;
  static readonly SECTION: number = 18;
  static readonly ROW: number = 12;
}

export class AppRadii {
  static readonly INPUT: number = 8;
  static readonly CARD: number = 12;
  static readonly DIALOG: number = 20;
  static readonly PRIMARY_BUTTON: number = 10;
  static readonly ICON_BUTTON: number = 10;
}

export class AppFontSizes {
  static readonly PAGE_TITLE: number = 22;
  static readonly TITLE: number = 24;
  static readonly HEADING: number = 18;
  static readonly BODY: number = 15;
  static readonly CAPTION: number = 12;
}

export class AppLimits {
  static readonly MIN_OPTIONS: number = 2;
  static readonly MAX_OPTIONS: number = 12;
  static readonly MAX_OPTION_LENGTH: number = 15;
  static readonly MAX_TEMPLATE_NAME_LENGTH: number = 15;
  static readonly MIN_RANDOM_NUMBER: number = -999999;
  static readonly MAX_RANDOM_NUMBER: number = 999999;
  static readonly MAX_RANDOM_COUNT: number = 100;
  static readonly MAX_HISTORY_COUNT: number = 200;
}

export const WHEEL_COLORS: string[] = [
  '#F7DDE2',
  '#F7E8B7',
  '#D9F0DF',
  '#D8EAF8',
  '#F8DDC8',
  '#E8D8F5',
  '#F4DCEB',
  '#D6EFED',
  '#F0E1B8',
  '#D6E8F7',
  '#E2DCF3',
  '#F2D8C8'
];
