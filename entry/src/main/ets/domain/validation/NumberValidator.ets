import { AppLimits } from '../../constants/DesignTokens';
import { ValidationResult } from './OptionValidator';

export class NumberValidator {
  static validate(min: number, max: number, count: number, allowRepeat: boolean): ValidationResult {
    if (!Number.isInteger(min) || !Number.isInteger(max) || !Number.isInteger(count)) {
      return new ValidationResult(false, '请输入有效的整数');
    }
    if (min > max) {
      return new ValidationResult(false, '最小值不能大于最大值');
    }
    if (min < AppLimits.MIN_RANDOM_NUMBER || max > AppLimits.MAX_RANDOM_NUMBER) {
      return new ValidationResult(false, '超出范围');
    }
    if (count <= 0) {
      return new ValidationResult(false, '抽取数量必须大于 0');
    }
    if (count > AppLimits.MAX_RANDOM_COUNT) {
      return new ValidationResult(false, '单次最多抽取 100 个');
    }
    const available: number = max - min + 1;
    if (!allowRepeat && count > available) {
      return new ValidationResult(false, '数字不够抽，请调整范围或允许重复');
    }
    return new ValidationResult(true);
  }
}
