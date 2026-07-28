import { describe, expect, it } from '@ohos/hypium';
import { OptionValidator, ValidationResult } from '../../../main/ets/domain/validation/OptionValidator';
import { NumberValidator } from '../../../main/ets/domain/validation/NumberValidator';

export default function validationTest(): void {
  describe('OptionValidator', () => {
    it('rejectsTooFewOptions', 0, () => {
      const result: ValidationResult = OptionValidator.validate(['火锅']);

      expect(result.valid).assertFalse();
      expect(result.message).assertEqual('请至少添加两个选项');
    });

    it('rejectsNormalizedDuplicateOptions', 0, () => {
      const result: ValidationResult = OptionValidator.validate(['火锅', ' 火锅 ']);

      expect(result.valid).assertFalse();
      expect(result.message).assertEqual('选项不能重复');
    });

    it('rejectsEmptyOptions', 0, () => {
      const result: ValidationResult = OptionValidator.validate(['火锅', '  ']);

      expect(result.valid).assertFalse();
      expect(result.message).assertEqual('选项不能为空');
    });

    it('acceptsTwoDistinctOptions', 0, () => {
      expect(OptionValidator.validate(['火锅', '烧烤']).valid).assertTrue();
    });
  });

  describe('NumberValidator', () => {
    it('rejectsReversedRange', 0, () => {
      const result: ValidationResult = NumberValidator.validate(10, 1, 1, false);

      expect(result.message).assertEqual('最小值不能大于最大值');
    });

    it('rejectsImpossibleUniqueDraw', 0, () => {
      const result: ValidationResult = NumberValidator.validate(1, 3, 4, false);

      expect(result.message).assertEqual('数字不够抽，请调整范围或允许重复');
    });

    it('rejectsOutOfBoundsValue', 0, () => {
      const result: ValidationResult = NumberValidator.validate(-1000000, 3, 1, false);

      expect(result.message).assertEqual('超出范围');
    });

    it('acceptsValidRequest', 0, () => {
      expect(NumberValidator.validate(-5, 5, 3, false).valid).assertTrue();
    });
  });
}
