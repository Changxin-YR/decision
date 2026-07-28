import {
  AppSettings,
  createDefaultSettings,
  DecisionTemplate,
  HistoryRecord,
  ThemeMode,
  ToolType
} from '../models/AppModels';

export class JsonCodec {
  static encodeSettings(settings: AppSettings): string {
    return JSON.stringify(settings);
  }

  static decodeSettings(snapshot: string): AppSettings {
    if (snapshot.length === 0) {
      return createDefaultSettings();
    }
    try {
      const parsed: AppSettings = JSON.parse(snapshot) as AppSettings;
      if (parsed === null || typeof parsed !== 'object') {
        return createDefaultSettings();
      }
      const defaults: AppSettings = createDefaultSettings();
      return {
        soundEnabled: typeof parsed.soundEnabled === 'boolean' ?
          parsed.soundEnabled : defaults.soundEnabled,
        vibrationEnabled: typeof parsed.vibrationEnabled === 'boolean' ?
          parsed.vibrationEnabled : defaults.vibrationEnabled,
        themeMode: JsonCodec.isThemeMode(parsed.themeMode) ?
          parsed.themeMode : defaults.themeMode,
        autoSaveHistory: typeof parsed.autoSaveHistory === 'boolean' ?
          parsed.autoSaveHistory : defaults.autoSaveHistory
      };
    } catch {
      return createDefaultSettings();
    }
  }

  static encodeTemplates(templates: readonly DecisionTemplate[]): string {
    return JSON.stringify(templates);
  }

  static decodeTemplates(snapshot: string): DecisionTemplate[] {
    if (snapshot.length === 0) {
      return [];
    }
    try {
      const parsed: DecisionTemplate[] = JSON.parse(snapshot) as DecisionTemplate[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      return parsed.filter((template: DecisionTemplate): boolean =>
        JsonCodec.isValidTemplate(template));
    } catch {
      return [];
    }
  }

  static encodeHistory(records: readonly HistoryRecord[]): string {
    return JSON.stringify(records);
  }

  static decodeHistory(snapshot: string): HistoryRecord[] {
    if (snapshot.length === 0) {
      return [];
    }
    try {
      const parsed: HistoryRecord[] = JSON.parse(snapshot) as HistoryRecord[];
      if (!Array.isArray(parsed)) {
        return [];
      }
      return parsed.filter((record: HistoryRecord): boolean =>
        JsonCodec.isValidHistoryRecord(record));
    } catch {
      return [];
    }
  }

  private static isThemeMode(value: ThemeMode): boolean {
    return value === ThemeMode.SYSTEM || value === ThemeMode.LIGHT || value === ThemeMode.DARK;
  }

  private static isToolType(value: ToolType): boolean {
    return value === ToolType.WHEEL ||
      value === ToolType.DRAW ||
      value === ToolType.FINGER ||
      value === ToolType.COIN ||
      value === ToolType.YES_NO ||
      value === ToolType.NUMBER;
  }

  private static isStringArray(values: string[]): boolean {
    return Array.isArray(values) &&
      values.every((value: string): boolean => typeof value === 'string');
  }

  private static isValidTemplate(template: DecisionTemplate): boolean {
    return template !== null && typeof template === 'object' &&
      typeof template.id === 'string' && template.id.length > 0 &&
      typeof template.name === 'string' && template.name.length > 0 &&
      JsonCodec.isToolType(template.toolType) &&
      (template.toolType === ToolType.WHEEL || template.toolType === ToolType.DRAW) &&
      JsonCodec.isStringArray(template.options) &&
      typeof template.createdAt === 'string' && template.createdAt.length > 0 &&
      typeof template.builtIn === 'boolean';
  }

  private static isValidHistoryRecord(record: HistoryRecord): boolean {
    return record !== null && typeof record === 'object' &&
      typeof record.id === 'string' && record.id.length > 0 &&
      JsonCodec.isToolType(record.toolType) &&
      typeof record.title === 'string' &&
      JsonCodec.isStringArray(record.options) &&
      typeof record.result === 'string' && record.result.length > 0 &&
      typeof record.createdAt === 'string' && record.createdAt.length > 0;
  }
}
