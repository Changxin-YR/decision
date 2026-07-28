import { ToolType } from './AppModels';

export enum AppRoute {
  WHEEL = 'Wheel',
  DRAW = 'Draw',
  FINGER_SELECT = 'FingerSelect',
  COIN = 'Coin',
  YES_NO = 'YesNo',
  RANDOM_NUMBER = 'RandomNumber',
  HISTORY = 'History',
  SETTINGS = 'Settings',
  PRIVACY = 'Privacy'
}

export interface DecisionPageParams {
  title: string;
  toolType: ToolType;
  options: string[];
}

export interface HomeToolItem {
  route: AppRoute;
  toolType: ToolType;
  title: string;
  description: string;
  symbol: string;
  tint: string;
}

export class ResponsiveLayout {
  static columnsForWidth(width: number): number {
    if (width >= 840) {
      return 4;
    }
    if (width >= 600) {
      return 3;
    }
    return 2;
  }
}
