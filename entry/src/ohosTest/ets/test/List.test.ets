import appLifecycleBusTest from './AppLifecycleBus.test';
import appStoreTest from './AppStore.test';
import historyRepositoryTest from './HistoryRepository.test';
import jsonCodecTest from './JsonCodec.test';
import randomServiceTest from './RandomService.test';
import responsiveLayoutTest from './ResponsiveLayout.test';
import simpleDecisionStateTest from './SimpleDecisionState.test';
import themeResolverTest from './ThemeResolver.test';
import validationTest from './Validation.test';
import wheelGeometryTest from './WheelGeometry.test';

export default function testsuite(): void {
  appStoreTest();
  appLifecycleBusTest();
  jsonCodecTest();
  historyRepositoryTest();
  randomServiceTest();
  responsiveLayoutTest();
  simpleDecisionStateTest();
  themeResolverTest();
  validationTest();
  wheelGeometryTest();
}
