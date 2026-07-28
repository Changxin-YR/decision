import appLifecycleBusTest from './AppLifecycleBus.test';
import appStoreTest from './AppStore.test';
import historyRepositoryTest from './HistoryRepository.test';
import jsonCodecTest from './JsonCodec.test';
import randomServiceTest from './RandomService.test';
import validationTest from './Validation.test';
import wheelGeometryTest from './WheelGeometry.test';

export default function testsuite(): void {
  appStoreTest();
  appLifecycleBusTest();
  jsonCodecTest();
  historyRepositoryTest();
  randomServiceTest();
  validationTest();
  wheelGeometryTest();
}
