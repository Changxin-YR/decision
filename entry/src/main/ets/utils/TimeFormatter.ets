export class TimeFormatter {
  static format(isoTime: string): string {
    const value: Date = new Date(isoTime);
    if (Number.isNaN(value.getTime())) {
      return '时间未知';
    }
    const hours: string = `${value.getHours()}`.padStart(2, '0');
    const minutes: string = `${value.getMinutes()}`.padStart(2, '0');
    return `${value.getMonth() + 1}月${value.getDate()}日 ${hours}:${minutes}`;
  }
}
