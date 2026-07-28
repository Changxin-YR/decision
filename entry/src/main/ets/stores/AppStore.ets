import { HistoryRepository } from '../data/repositories/HistoryRepository';
import { SettingsRepository } from '../data/repositories/SettingsRepository';
import { TemplateRepository } from '../data/repositories/TemplateRepository';
import { PreferencesStore } from '../data/PreferencesStore';
import {
  AppSettings,
  createDefaultSettings,
  DecisionTemplate,
  HistoryRecord,
  ThemeMode,
  ToolType
} from '../models/AppModels';
import { OptionValidator } from '../domain/validation/OptionValidator';

export interface AppSettingsPatch {
  soundEnabled?: boolean;
  vibrationEnabled?: boolean;
  themeMode?: ThemeMode;
  autoSaveHistory?: boolean;
}

@Observed
export class AppStore {
  settings: AppSettings = createDefaultSettings();
  templates: DecisionTemplate[] = [];
  history: HistoryRecord[] = [];
  initialized: boolean = false;

  private readonly settingsRepository: SettingsRepository;
  private readonly templateRepository: TemplateRepository;
  private readonly historyRepository: HistoryRepository;

  constructor(
    settingsRepository: SettingsRepository,
    templateRepository: TemplateRepository,
    historyRepository: HistoryRepository
  ) {
    this.settingsRepository = settingsRepository;
    this.templateRepository = templateRepository;
    this.historyRepository = historyRepository;
  }

  async initialize(): Promise<void> {
    this.settings = await this.settingsRepository.load();
    this.templates = await this.templateRepository.load();
    this.history = await this.historyRepository.load();
    this.initialized = true;
  }

  async updateSettings(patch: AppSettingsPatch): Promise<boolean> {
    const next: AppSettings = {
      soundEnabled: patch.soundEnabled ?? this.settings.soundEnabled,
      vibrationEnabled: patch.vibrationEnabled ?? this.settings.vibrationEnabled,
      themeMode: patch.themeMode ?? this.settings.themeMode,
      autoSaveHistory: patch.autoSaveHistory ?? this.settings.autoSaveHistory
    };
    const saved: boolean = await this.settingsRepository.save(next);
    if (saved) {
      this.settings = next;
    }
    return saved;
  }

  async saveTemplates(templates: readonly DecisionTemplate[]): Promise<boolean> {
    const next: DecisionTemplate[] = Array.from(templates);
    const saved: boolean = await this.templateRepository.saveAll(next);
    if (saved) {
      this.templates = next;
    }
    return saved;
  }

  async createCustomTemplate(
    name: string,
    toolType: ToolType,
    options: readonly string[]
  ): Promise<boolean> {
    if (toolType !== ToolType.WHEEL && toolType !== ToolType.DRAW) {
      return false;
    }
    if (!OptionValidator.validateTemplateName(name).valid ||
      !OptionValidator.validate(options).valid) {
      return false;
    }
    const template: DecisionTemplate = {
      id: `template-${Date.now()}-${this.templates.length}`,
      name: name.trim(),
      toolType: toolType,
      options: options.map((option: string): string => option.trim()),
      createdAt: new Date().toISOString(),
      builtIn: false
    };
    return this.saveTemplates(this.templates.concat([template]));
  }

  async deleteCustomTemplate(id: string): Promise<boolean> {
    const target: DecisionTemplate | undefined =
      this.templates.find((template: DecisionTemplate): boolean => template.id === id);
    if (target === undefined || target.builtIn) {
      return false;
    }
    const next: DecisionTemplate[] =
      this.templates.filter((template: DecisionTemplate): boolean => template.id !== id);
    return this.saveTemplates(next);
  }

  async saveHistoryRecord(record: HistoryRecord): Promise<boolean> {
    const next: HistoryRecord[] =
      HistoryRepository.prependAndTrim(record, this.history);
    const saved: boolean = await this.historyRepository.saveAll(next);
    if (saved) {
      this.history = next;
    }
    return saved;
  }

  async deleteHistoryRecord(id: string): Promise<boolean> {
    const next: HistoryRecord[] =
      this.history.filter((record: HistoryRecord): boolean => record.id !== id);
    const saved: boolean = await this.historyRepository.saveAll(next);
    if (saved) {
      this.history = next;
    }
    return saved;
  }

  async clearHistory(): Promise<boolean> {
    const cleared: boolean = await this.historyRepository.clear();
    if (cleared) {
      this.history = [];
    }
    return cleared;
  }

  async clearTemplates(): Promise<boolean> {
    const cleared: boolean = await this.templateRepository.clear();
    if (cleared) {
      this.templates = [];
    }
    return cleared;
  }

  async clearAll(): Promise<boolean> {
    const settingsCleared: boolean = await this.settingsRepository.clear();
    const templatesCleared: boolean = await this.templateRepository.clear();
    const historyCleared: boolean = await this.historyRepository.clear();
    if (!settingsCleared || !templatesCleared || !historyCleared) {
      return false;
    }
    this.settings = createDefaultSettings();
    this.templates = [];
    this.history = [];
    return true;
  }
}

export const preferencesStore: PreferencesStore = new PreferencesStore();
export const appStore: AppStore = new AppStore(
  new SettingsRepository(preferencesStore),
  new TemplateRepository(preferencesStore),
  new HistoryRepository(preferencesStore)
);
