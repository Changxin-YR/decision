import { describe, expect, it } from '@ohos/hypium';
import { JsonCodec } from '../../../main/ets/data/JsonCodec';
import {
  AppSettings,
  DecisionTemplate,
  HistoryRecord,
  ThemeMode,
  ToolType
} from '../../../main/ets/models/AppModels';

export default function jsonCodecTest(): void {
  describe('JsonCodec', () => {
    it('fallsBackForDamagedSettings', 0, () => {
      const settings: AppSettings = JsonCodec.decodeSettings('{broken');

      expect(settings.soundEnabled).assertTrue();
      expect(settings.vibrationEnabled).assertTrue();
      expect(settings.themeMode).assertEqual(ThemeMode.SYSTEM);
      expect(settings.autoSaveHistory).assertFalse();
    });

    it('roundTripsSettings', 0, () => {
      const original: AppSettings = {
        soundEnabled: false,
        vibrationEnabled: true,
        themeMode: ThemeMode.DARK,
        autoSaveHistory: true
      };

      const decoded: AppSettings = JsonCodec.decodeSettings(JsonCodec.encodeSettings(original));
      expect(decoded.soundEnabled).assertFalse();
      expect(decoded.themeMode).assertEqual(ThemeMode.DARK);
      expect(decoded.autoSaveHistory).assertTrue();
    });

    it('usesDefaultsOnlyForMissingSettingsFields', 0, () => {
      const decoded: AppSettings = JsonCodec.decodeSettings('{"soundEnabled":false}');

      expect(decoded.soundEnabled).assertFalse();
      expect(decoded.vibrationEnabled).assertTrue();
      expect(decoded.themeMode).assertEqual(ThemeMode.SYSTEM);
      expect(decoded.autoSaveHistory).assertFalse();
    });

    it('filtersInvalidTemplates', 0, () => {
      const valid: DecisionTemplate = {
        id: 'template-1',
        name: '晚餐',
        toolType: ToolType.WHEEL,
        options: ['火锅', '烧烤'],
        createdAt: '2026-07-28T12:00:00.000Z',
        builtIn: false
      };
      const decoded: DecisionTemplate[] =
        JsonCodec.decodeTemplates(JSON.stringify([valid, { id: '', name: 1 }]));

      expect(decoded.length).assertEqual(1);
      expect(decoded[0].id).assertEqual('template-1');
    });

    it('keepsValidTemplatesWhenAnotherEntryIsNull', 0, () => {
      const valid: DecisionTemplate = {
        id: 'template-2',
        name: '周末',
        toolType: ToolType.DRAW,
        options: ['公园', '书店'],
        createdAt: '2026-07-28T12:00:00.000Z',
        builtIn: false
      };
      const snapshot: string = `[${JsonCodec.encodeTemplates([valid]).slice(1, -1)},null]`;
      const decoded: DecisionTemplate[] = JsonCodec.decodeTemplates(snapshot);

      expect(decoded.length).assertEqual(1);
      expect(decoded[0].id).assertEqual('template-2');
    });

    it('filtersInvalidHistoryRecords', 0, () => {
      const valid: HistoryRecord = {
        id: 'history-1',
        toolType: ToolType.COIN,
        title: '未命名',
        options: ['正面', '反面'],
        result: '正面',
        createdAt: '2026-07-28T12:00:00.000Z'
      };
      const decoded: HistoryRecord[] =
        JsonCodec.decodeHistory(JSON.stringify([valid, { id: '', result: false }]));

      expect(decoded.length).assertEqual(1);
      expect(decoded[0].result).assertEqual('正面');
    });
  });
}
