export enum ToolType {
  WHEEL = 'wheel',
  DRAW = 'draw',
  FINGER = 'finger',
  COIN = 'coin',
  YES_NO = 'yesno',
  NUMBER = 'number'
}

export enum ThemeMode {
  SYSTEM = 'system',
  LIGHT = 'light',
  DARK = 'dark'
}

export enum CoinSide {
  HEADS = 'heads',
  TAILS = 'tails'
}

export interface AppSettings {
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  themeMode: ThemeMode;
  autoSaveHistory: boolean;
}

export interface DecisionTemplate {
  id: string;
  name: string;
  toolType: ToolType;
  options: string[];
  createdAt: string;
  builtIn: boolean;
}

export interface HistoryRecord {
  id: string;
  toolType: ToolType;
  title: string;
  options: string[];
  result: string;
  createdAt: string;
}

export interface DecisionOption {
  id: string;
  text: string;
}

export function createDefaultSettings(): AppSettings {
  return {
    soundEnabled: false,
    vibrationEnabled: true,
    themeMode: ThemeMode.SYSTEM,
    autoSaveHistory: false
  };
}
