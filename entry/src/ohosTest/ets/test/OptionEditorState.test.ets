import { describe, expect, it } from '@ohos/hypium';
import { OptionEditorState } from '../../../main/ets/domain/state/OptionEditorState';

export default function optionEditorStateTest(): void {
  describe('OptionEditorState', () => {
    it('startsWithTwoOptionsAndCapsAtTwelve', 0, () => {
      const state: OptionEditorState = new OptionEditorState();
      expect(state.options.length).assertEqual(2);
      for (let index: number = 0; index < 15; index++) {
        state.add();
      }
      expect(state.options.length).assertEqual(12);
    });

    it('doesNotRemoveBelowTwoOptions', 0, () => {
      const state: OptionEditorState = new OptionEditorState();
      expect(state.remove(state.options[0].id)).assertFalse();
      expect(state.options.length).assertEqual(2);
    });

    it('movesOptionsWithoutChangingStableIds', 0, () => {
      const state: OptionEditorState = new OptionEditorState(['甲', '乙', '丙']);
      const lastId: string = state.options[2].id;
      expect(state.move(2, 0)).assertTrue();
      expect(state.options[0].id).assertEqual(lastId);
      expect(state.texts()[0]).assertEqual('丙');
    });

    it('rejectsNormalizedDuplicates', 0, () => {
      const state: OptionEditorState = new OptionEditorState(['火锅', ' 火锅 ']);
      expect(state.validate().valid).assertFalse();
    });
  });
}
