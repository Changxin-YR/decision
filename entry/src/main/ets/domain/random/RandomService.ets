export class RandomService {
  static pickOne<T>(values: readonly T[]): T {
    if (values.length === 0) {
      throw new Error('列表不能为空');
    }
    const index: number = Math.floor(Math.random() * values.length);
    return values[index];
  }

  static pickMany<T>(values: readonly T[], count: number, allowRepeat: boolean): T[] {
    if (!Number.isInteger(count) || count <= 0) {
      return [];
    }
    if (!allowRepeat && count > values.length) {
      throw new Error('可选项数量不足');
    }
    if (allowRepeat) {
      const repeated: T[] = [];
      for (let index: number = 0; index < count; index++) {
        repeated.push(RandomService.pickOne<T>(values));
      }
      return repeated;
    }

    const pool: T[] = Array.from(values);
    for (let index: number = 0; index < count; index++) {
      const swapIndex: number = index + Math.floor(Math.random() * (pool.length - index));
      const current: T = pool[index];
      pool[index] = pool[swapIndex];
      pool[swapIndex] = current;
    }
    return pool.slice(0, count);
  }

  static randomBoolean(): boolean {
    return Math.random() < 0.5;
  }

  static randomInteger(min: number, max: number): number {
    if (!Number.isInteger(min) || !Number.isInteger(max) || min > max) {
      throw new Error('随机整数参数无效');
    }
    return min + Math.floor(Math.random() * (max - min + 1));
  }

  static randomIntegers(min: number, max: number, count: number, allowRepeat: boolean): number[] {
    const size: number = max - min + 1;
    if (!Number.isInteger(min) || !Number.isInteger(max) || !Number.isInteger(count) ||
      min > max || count <= 0 || (!allowRepeat && count > size)) {
      throw new Error('随机数字参数无效');
    }

    if (allowRepeat) {
      const repeated: number[] = [];
      for (let index: number = 0; index < count; index++) {
        repeated.push(RandomService.randomInteger(min, max));
      }
      return repeated;
    }

    const selected: Set<number> = new Set<number>();
    while (selected.size < count) {
      selected.add(RandomService.randomInteger(min, max));
    }
    return Array.from(selected);
  }
}
