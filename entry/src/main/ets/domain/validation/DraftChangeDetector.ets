export class DraftChangeDetector {
  static hasChanges(
    initialOptions: readonly string[],
    currentOptions: readonly string[],
    initialRepeat: boolean = false,
    currentRepeat: boolean = false
  ): boolean {
    if (initialRepeat !== currentRepeat || initialOptions.length !== currentOptions.length) {
      return true;
    }
    return initialOptions.some((value: string, index: number): boolean => {
      return value !== currentOptions[index];
    });
  }
}
