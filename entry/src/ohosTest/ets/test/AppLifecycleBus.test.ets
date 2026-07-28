import { describe, expect, it } from '@ohos/hypium';
import {
  AppLifecycleBus,
  LifecycleListener
} from '../../../main/ets/services/AppLifecycleBus';

export default function appLifecycleBusTest(): void {
  describe('AppLifecycleBus', () => {
    it('notifiesSubscribedListenersAndSupportsUnsubscribe', 0, () => {
      const bus: AppLifecycleBus = new AppLifecycleBus();
      const values: boolean[] = [];
      const listener: LifecycleListener = (inBackground: boolean): void => {
        values.push(inBackground);
      };
      const unsubscribe: () => void = bus.subscribe(listener);

      bus.notify(true);
      unsubscribe();
      bus.notify(false);

      expect(values.length).assertEqual(1);
      expect(values[0]).assertTrue();
    });
  });
}
