export class WheelGeometry {
  static stopAngle(optionCount: number, resultIndex: number): number {
    WheelGeometry.assertValid(optionCount, resultIndex);
    const sectorAngle: number = 360 / optionCount;
    return WheelGeometry.normalize(360 - (resultIndex * sectorAngle + sectorAngle / 2));
  }

  static resultIndexAtPointer(optionCount: number, rotation: number): number {
    if (!Number.isInteger(optionCount) || optionCount <= 0 || !Number.isFinite(rotation)) {
      throw new Error('转盘参数无效');
    }
    const sectorAngle: number = 360 / optionCount;
    const pointerAngle: number = WheelGeometry.normalize(360 - rotation);
    return Math.floor(pointerAngle / sectorAngle) % optionCount;
  }

  private static assertValid(optionCount: number, resultIndex: number): void {
    if (!Number.isInteger(optionCount) || optionCount <= 0 ||
      !Number.isInteger(resultIndex) || resultIndex < 0 || resultIndex >= optionCount) {
      throw new Error('转盘参数无效');
    }
  }

  private static normalize(angle: number): number {
    return ((angle % 360) + 360) % 360;
  }
}
