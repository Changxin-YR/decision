import { describe, expect, it } from '@ohos/hypium';
import { PRESET_TEMPLATES } from '../../../main/ets/constants/PresetTemplates';
import { QuickRangePreset } from '../../../main/ets/domain/random/QuickRangePreset';
import { WheelLabelLayout } from '../../../main/ets/domain/wheel/WheelLabelLayout';
import {
  DecisionTemplate,
  ToolType
} from '../../../main/ets/models/AppModels';
import { DecisionDraftStore } from '../../../main/ets/stores/DecisionDraftStore';

export default function feedbackRegressionTest(): void {
  describe('FeedbackRegression', (): void => {
    it('appliesEveryQuickNumberRange', 0, (): void => {
      expect(QuickRangePreset.resolve('1–10').max).assertEqual('10');
      expect(QuickRangePreset.resolve('1–100').max).assertEqual('100');
      expect(QuickRangePreset.resolve('1–1000').max).assertEqual('1000');
    });

    it('keepsQuickRangeSelectedAfterItsInputsUpdate', 0, (): void => {
      expect(QuickRangePreset.match('1', '10')).assertEqual('1–10');
      expect(QuickRangePreset.match('1', '100')).assertEqual('1–100');
      expect(QuickRangePreset.match('1', '1000')).assertEqual('1–1000');
      expect(QuickRangePreset.match('2', '100')).assertEqual('自定义');
    });

    it('shipsDrawTemplatesWithUsableDefaults', 0, (): void => {
      const takeout: DecisionTemplate =
        PRESET_TEMPLATES.filter((item: DecisionTemplate): boolean =>
          item.id === 'preset_takeout')[0];
      const first: DecisionTemplate =
        PRESET_TEMPLATES.filter((item: DecisionTemplate): boolean =>
          item.id === 'preset_first')[0];
      expect(takeout.options.length).assertLarger(2);
      expect(first.options.length).assertLarger(1);
    });

    it('keepsWheelLabelsReadableWithManyOptions', 0, (): void => {
      expect(WheelLabelLayout.fontSize(12)).assertLarger(21);
      expect(WheelLabelLayout.maxCharacters(12)).assertLarger(4);
    });

    it('retainsEditedOptionsAfterNormalization', 0, (): void => {
      const store: DecisionDraftStore = new DecisionDraftStore();
      store.set('', store.toolType, ['', '']);
      const firstId: string = store.decisionOptions()[0].id;
      store.updateOption(firstId, '去爬山');
      store.updateOptions(store.options.map((value: string): string => value.trim()));
      expect(store.options[0]).assertEqual('去爬山');
      expect(store.decisionOptions()[0].text).assertEqual('去爬山');
    });

    it('keepsManualWheelOptionsAcrossRepeatedSpinInputs', 0, (): void => {
      const store: DecisionDraftStore = new DecisionDraftStore();
      store.set('', ToolType.WHEEL, ['', '']);
      const firstId: string = store.decisionOptions()[0].id;
      const secondId: string = store.decisionOptions()[1].id;
      store.updateOption(firstId, 'Alpha');
      store.updateOption(secondId, 'Beta');
      const firstSpin: string[] = Array.from(store.options);
      store.updateOptions(firstSpin.map((value: string): string => value.trim()));
      const secondSpin: string[] = Array.from(store.options);
      expect(firstSpin.join('|')).assertEqual('Alpha|Beta');
      expect(secondSpin.join('|')).assertEqual('Alpha|Beta');
      expect(store.decisionOptions()[0].text).assertEqual('Alpha');
      expect(store.decisionOptions()[1].text).assertEqual('Beta');
    });
  });
}
