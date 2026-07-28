import { describe, expect, it } from '@ohos/hypium';
import { WheelGeometry } from '../../../main/ets/domain/wheel/WheelGeometry';

export default function wheelGeometryTest(): void {
  describe('WheelGeometry', () => {
    it('mapsFirstOfFourOptionsToPointer', 0, () => {
      expect(WheelGeometry.stopAngle(4, 0)).assertEqual(315);
      expect(WheelGeometry.resultIndexAtPointer(4, 315)).assertEqual(0);
    });

    it('roundTripsEveryIndex', 0, () => {
      const counts: number[] = [2, 3, 6, 12];
      let allMatch: boolean = true;
      counts.forEach((count: number): void => {
        for (let index: number = 0; index < count; index++) {
          const angle: number = WheelGeometry.stopAngle(count, index);
          allMatch = allMatch && WheelGeometry.resultIndexAtPointer(count, angle) === index;
        }
      });

      expect(allMatch).assertTrue();
    });

    it('rejectsInvalidOptionCount', 0, () => {
      let message: string = '';
      try {
        WheelGeometry.stopAngle(0, 0);
      } catch (error) {
        message = (error as Error).message;
      }

      expect(message).assertEqual('转盘参数无效');
    });
  });
}
