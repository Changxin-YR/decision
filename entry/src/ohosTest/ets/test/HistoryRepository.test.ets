import { describe, expect, it } from '@ohos/hypium';
import { HistoryRepository } from '../../../main/ets/data/repositories/HistoryRepository';
import { HistoryRecord, ToolType } from '../../../main/ets/models/AppModels';

function createRecords(count: number): HistoryRecord[] {
  const records: HistoryRecord[] = [];
  for (let index: number = 0; index < count; index++) {
    records.push({
      id: `${index}`,
      toolType: ToolType.YES_NO,
      title: `问题${index}`,
      options: ['是', '否'],
      result: '是',
      createdAt: new Date(index).toISOString()
    });
  }
  return records;
}

export default function historyRepositoryTest(): void {
  describe('HistoryRepository', () => {
    it('keepsNewestTwoHundredRecords', 0, () => {
      const records: HistoryRecord[] = createRecords(201);
      const trimmed: HistoryRecord[] = HistoryRepository.prependAndTrim(records[200], records.slice(0, 200));

      expect(trimmed.length).assertEqual(200);
      expect(trimmed[0].id).assertEqual('200');
      expect(trimmed[199].id).assertEqual('198');
    });

    it('doesNotMutateExistingRecords', 0, () => {
      const existing: HistoryRecord[] = createRecords(2);
      const snapshot: string = JSON.stringify(existing);

      HistoryRepository.prependAndTrim(createRecords(3)[2], existing);

      expect(JSON.stringify(existing)).assertEqual(snapshot);
    });
  });
}
