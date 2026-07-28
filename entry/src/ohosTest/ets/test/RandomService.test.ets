import { describe, expect, it } from '@ohos/hypium';
import { RandomService } from '../../../main/ets/domain/random/RandomService';

export default function randomServiceTest(): void {
  describe('RandomService', () => {
    it('throwsForEmptyList', 0, () => {
      let message: string = '';
      try {
        RandomService.pickOne<string>([]);
      } catch (error) {
        message = (error as Error).message;
      }

      expect(message).assertEqual('列表不能为空');
    });

    it('returnsUniqueValuesWithoutReplacement', 0, () => {
      const values: number[] = RandomService.pickMany<number>([1, 2, 3, 4], 4, false);

      expect(new Set<number>(values).size).assertEqual(4);
    });

    it('keepsIntegersInsideInclusiveRange', 0, () => {
      const values: number[] = RandomService.randomIntegers(-2, 2, 100, true);

      expect(values.every((value: number): boolean => value >= -2 && value <= 2)).assertTrue();
    });

    it('rejectsImpossibleUniqueIntegerDraw', 0, () => {
      let message: string = '';
      try {
        RandomService.randomIntegers(1, 3, 4, false);
      } catch (error) {
        message = (error as Error).message;
      }

      expect(message).assertEqual('随机数字参数无效');
    });
  });
}
