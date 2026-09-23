import curtainViewModelTest from './CurtainViewModel.test';
import homeViewModelTest from './HomeViewModel.test';
import lightViewModelTest from './LightViewModel.test';
import loginViewModelTest from './LoginViewModel.test';
import serviceViewModelTest from './ServiceViewModel.test';

export default function testsuite() {
  curtainViewModelTest();
  homeViewModelTest();
  lightViewModelTest();
  loginViewModelTest();
  serviceViewModelTest();
}
