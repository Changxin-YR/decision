import { AppLimits } from '../../constants/DesignTokens';

export class ValidationResult {
  valid: boolean;
  message: string;

  constructor(valid: boolean, message: string = '') {
    this.valid = valid;
    this.message = message;
  }
}

export class OptionValidator {
  static validate(options: readonly string[]): ValidationResult {
    if (options.length < AppLimits.MIN_OPTIONS) {
      return new ValidationResult(false, '请至少添加两个选项');
    }
    if (options.length > AppLimits.MAX_OPTIONS) {
      return new ValidationResult(false, '最多添加十二个选项');
    }

    const normalized: string[] = [];
    for (const option of options) {
      const text: string = option.trim();
      if (text.length === 0) {
        return new ValidationResult(false, '选项不能为空');
      }
      if (text.length > AppLimits.MAX_OPTION_LENGTH) {
        return new ValidationResult(false, '每个选项最多十五个字符');
      }
      if (normalized.includes(text)) {
        return new ValidationResult(false, '选项不能重复');
      }
      normalized.push(text);
    }
    return new ValidationResult(true);
  }

  static validateTemplateName(name: string): ValidationResult {
    const normalized: string = name.trim();
    if (normalized.length === 0) {
      return new ValidationResult(false, '请输入模板名称');
    }
    if (normalized.length > AppLimits.MAX_TEMPLATE_NAME_LENGTH) {
      return new ValidationResult(false, '模板名称最多十五个字符');
    }
    return new ValidationResult(true);
  }
}
