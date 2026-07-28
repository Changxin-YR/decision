import randomServiceTest from './RandomService.test';
import validationTest from './Validation.test';
import wheelGeometryTest from './WheelGeometry.test';

export default function testsuite(): void {
  randomServiceTest();
  validationTest();
  wheelGeometryTest();
}
