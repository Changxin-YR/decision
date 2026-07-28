import historyRepositoryTest from './HistoryRepository.test';
import jsonCodecTest from './JsonCodec.test';
import randomServiceTest from './RandomService.test';
import validationTest from './Validation.test';
import wheelGeometryTest from './WheelGeometry.test';

export default function testsuite(): void {
  jsonCodecTest();
  historyRepositoryTest();
  randomServiceTest();
  validationTest();
  wheelGeometryTest();
}
