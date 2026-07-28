import { describe, expect, it } from '@ohos/hypium';
import { ResponsiveLayout } from '../../../main/ets/models/NavigationModels';

export default function responsiveLayoutTest(): void {
  describe('ResponsiveLayout', () => {
    it('usesTwoColumnsOnSmallPhones', 0, () => {
      expect(ResponsiveLayout.columnsForWidth(320)).assertEqual(2);
      expect(ResponsiveLayout.columnsForWidth(599)).assertEqual(2);
    });

    it('addsColumnsForWideAndFoldableWindows', 0, () => {
      expect(ResponsiveLayout.columnsForWidth(600)).assertEqual(3);
      expect(ResponsiveLayout.columnsForWidth(839)).assertEqual(3);
      expect(ResponsiveLayout.columnsForWidth(840)).assertEqual(4);
    });
  });
}
