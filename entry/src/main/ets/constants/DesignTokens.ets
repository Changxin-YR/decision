import { ThemeMode } from '../models/AppModels';

export class AppColors {
  static readonly PRIMARY: string = '#4A90D9';
  static readonly PRIMARY_LIGHT: string = '#6BA5E7';
  static readonly LIGHT_BACKGROUND: string = '#F5F5F5';
  static readonly LIGHT_CARD: string = '#FFFFFF';
  static readonly LIGHT_TEXT: string = '#1A1A1A';
  static readonly LIGHT_SUBTEXT: string = '#999999';
  static readonly LIGHT_BORDER: string = '#E5E5E5';
  static readonly DARK_BACKGROUND: string = '#2C2C2C';
  static readonly DARK_CARD: string = '#3A3A3A';
  static readonly DARK_TEXT: string = '#F0F0F0';
  static readonly DARK_SUBTEXT: string = '#888888';
  static readonly DARK_BORDER: string = '#4A4A4A';
  static readonly ERROR: string = '#E74C3C';
  static readonly SUCCESS: string = '#27AE60';
}

export interface ThemeTokens {
  background: string;
  card: string;
  text: string;
  subtext: string;
  border: string;
  accent: string;
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
        text: AppColors.DARK_TEXT,
        subtext: AppColors.DARK_SUBTEXT,
        border: AppColors.DARK_BORDER,
        accent: AppColors.PRIMARY,
        error: AppColors.ERROR,
        success: AppColors.SUCCESS
      };
    }
    return {
      background: AppColors.LIGHT_BACKGROUND,
      card: AppColors.LIGHT_CARD,
      text: AppColors.LIGHT_TEXT,
      subtext: AppColors.LIGHT_SUBTEXT,
      border: AppColors.LIGHT_BORDER,
      accent: AppColors.PRIMARY,
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
}

export class AppRadii {
  static readonly INPUT: number = 8;
  static readonly CARD: number = 12;
  static readonly DIALOG: number = 20;
}

export class AppFontSizes {
  static readonly TITLE: number = 24;
  static readonly HEADING: number = 20;
  static readonly BODY: number = 16;
  static readonly CAPTION: number = 13;
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
  '#E97878',
  '#E2BD55',
  '#70B983',
  '#6897D2',
  '#E49661',
  '#B783C5',
  '#DE84A9',
  '#58B7B0',
  '#C9A14C',
  '#75ADDA',
  '#9D86C8',
  '#D98452'
];
