export class WheelLabelLayout {
  static fontSize(optionCount: number): number {
    if (optionCount <= 6) return 40;
    if (optionCount <= 8) return 34;
    return 28;
  }

  static maxCharacters(optionCount: number): number {
    return optionCount > 8 ? 6 : 8;
  }

  static maxWidthRatio(optionCount: number): number {
    return optionCount > 8 ? 0.46 : 0.62;
  }
}
