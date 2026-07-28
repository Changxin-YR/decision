import { pasteboard } from '@kit.BasicServicesKit';

export class ClipboardService {
  async copyLines(values: readonly string[]): Promise<boolean> {
    try {
      const data: pasteboard.PasteData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, values.join('\n'));
      await pasteboard.getSystemPasteboard().setData(data);
      return true;
    } catch {
      return false;
    }
  }
}

export const clipboardService: ClipboardService = new ClipboardService();
