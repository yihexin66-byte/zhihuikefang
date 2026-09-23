/**
 * 登录入住页 ViewModel 单元测试
 * 覆盖：默认值、输入回填、记住我的信息勾选、立即入住校验与提示文案
 */
import { describe, it, expect } from '@ohos/hypium'
import { LoginDefaults } from '../main/ets/features/login/model/LoginModel'
import { LoginViewModel } from '../main/ets/features/login/viewModel/LoginViewModel'

export default function loginViewModelTest() {
  describe('LoginViewModelTest', () => {
    // ==================== 默认值 ====================

    it('默认值_房号2006_账号yi_默认勾选记住信息', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()

      expect(viewModel.roomNo).assertEqual('2006')
      expect(viewModel.roomNo).assertEqual(LoginDefaults.ROOM_NO)
      expect(viewModel.account).assertEqual('yi')
      expect(viewModel.account).assertEqual(LoginDefaults.ACCOUNT)
      expect(viewModel.rememberMe).assertTrue()
      expect(viewModel.rememberMe).assertEqual(LoginDefaults.REMEMBER_ME)
    })

    it('默认值_文案固定', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()

      expect(viewModel.title).assertEqual('深信·未来酒店')
      expect(viewModel.roomPlaceholder).assertEqual('请输入房号')
      expect(viewModel.accountPlaceholder).assertEqual('请输入用户账号')
      expect(viewModel.rememberLabel).assertEqual('记住我的信息')
      expect(viewModel.checkInLabel).assertEqual('立即入住')
    })

    // ==================== 输入回填 ====================

    it('输入回填_房号写入状态', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.setRoomNo('3008')

      expect(viewModel.roomNo).assertEqual('3008')
    })

    it('输入回填_账号写入状态', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.setAccount('zhangsan')

      expect(viewModel.account).assertEqual('zhangsan')
    })

    // ==================== 记住我的信息 ====================

    it('记住我的信息_点击切换勾选状态', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.toggleRememberMe()
      expect(viewModel.rememberMe).assertFalse()

      viewModel.toggleRememberMe()
      expect(viewModel.rememberMe).assertTrue()
    })

    // ==================== 立即入住校验 ====================

    it('立即入住_房号与账号齐备_校验通过并提示欢迎入住', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      const passed: boolean = viewModel.checkIn()

      expect(passed).assertTrue()
      expect(viewModel.tipMessage).assertEqual('欢迎入住 2006 房')
    })

    it('立即入住_房号为空_校验失败并提示填写房号', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.setRoomNo('')
      const passed: boolean = viewModel.checkIn()

      expect(passed).assertFalse()
      expect(viewModel.tipMessage).assertEqual('请填写房号')
    })

    it('立即入住_房号仅空白_校验失败', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.setRoomNo('   ')
      const passed: boolean = viewModel.checkIn()

      expect(passed).assertFalse()
      expect(viewModel.tipMessage).assertEqual('请填写房号')
    })

    it('立即入住_账号为空_校验失败并提示填写用户账号', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.setAccount('')
      const passed: boolean = viewModel.checkIn()

      expect(passed).assertFalse()
      expect(viewModel.tipMessage).assertEqual('请填写用户账号')
    })

    it('立即入住_房号与账号都为空_优先提示房号', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.setRoomNo('')
      viewModel.setAccount('')
      const passed: boolean = viewModel.checkIn()

      expect(passed).assertFalse()
      expect(viewModel.tipMessage).assertEqual('请填写房号')
    })

    it('立即入住_自定义房号_提示文案随房号变化', 0, () => {
      const viewModel: LoginViewModel = new LoginViewModel()
      viewModel.setRoomNo('2002')
      const passed: boolean = viewModel.checkIn()

      expect(passed).assertTrue()
      expect(viewModel.tipMessage).assertEqual('欢迎入住 2002 房')
    })
  })
}