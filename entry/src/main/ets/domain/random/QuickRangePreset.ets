export class QuickRangeValue {
  min: string;
  max: string;

  constructor(min: string, max: string) {
    this.min = min;
    this.max = max;
  }
}

export class QuickRangePreset {
  static resolve(label: string): QuickRangeValue {
    if (label === '1–10') return new QuickRangeValue('1', '10');
    if (label === '1–1000') return new QuickRangeValue('1', '1000');
    return new QuickRangeValue('1', '100');
  }

  static match(min: string, max: string): string {
    if (min !== '1') return '自定义';
    if (max === '10') return '1–10';
    if (max === '100') return '1–100';
    if (max === '1000') return '1–1000';
    return '自定义';
  }
}
