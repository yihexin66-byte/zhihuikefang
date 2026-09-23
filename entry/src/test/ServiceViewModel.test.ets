/**
 * 服务控制页 ViewModel 单元测试
 * 覆盖：固定文案与默认关闭状态、两项服务开关互不影响、开关轻提示文案（与首页同一套）、
 *       SOS 轻提示、退出登录复位、以及与首页快捷服务的双向同步（两页注入同一个共享状态实例）
 */
import { describe, it, expect } from '@ohos/hypium'
import { RoomServiceStore } from '../main/ets/common/state/RoomServiceStore'
import { HomeViewModel } from '../main/ets/features/home/viewModel/HomeViewModel'
import { ServiceViewModel } from '../main/ets/features/service/viewModel/ServiceViewModel'

export default function serviceViewModelTest() {
  describe('ServiceViewModelTest', () => {
    // ==================== 固定文案与固定数据 ====================

    it('页面文案_固定不变', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.pageTitle).assertEqual('服务控制')
      expect(viewModel.sosLabel).assertEqual('SOS')
      expect(viewModel.sosTip).assertEqual('SOS 紧急呼叫已触发')
      expect(viewModel.logoutLabel).assertEqual('退出登录')
    })

    it('两张服务卡_文案固定', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.dndItem.label).assertEqual('请勿打扰')
      expect(viewModel.cleanItem.label).assertEqual('清理房间')
      expect(viewModel.dndItem.id).assertEqual('doNotDisturb')
      expect(viewModel.cleanItem.id).assertEqual('cleanRoom')
    })

    // ==================== 默认状态（需求锁定）====================

    it('默认状态_两项服务均关闭', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.dndOn).assertFalse()
      expect(viewModel.cleanOn).assertFalse()
    })

    // ==================== 服务开关 ====================

    it('请勿打扰_开启后为开启态_再次关闭', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.setDnd(true)).assertEqual('请勿打扰已开启')
      expect(viewModel.dndOn).assertTrue()

      expect(viewModel.setDnd(false)).assertEqual('请勿打扰已关闭')
      expect(viewModel.dndOn).assertFalse()
    })

    it('清理房间_开启后为开启态_再次关闭', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.setClean(true)).assertEqual('清理房间已开启')
      expect(viewModel.cleanOn).assertTrue()

      expect(viewModel.setClean(false)).assertEqual('清理房间已关闭')
      expect(viewModel.cleanOn).assertFalse()
    })

    it('服务开关_轻提示后缀与首页快捷服务同一套固定文案', 0, () => {
      const service: ServiceViewModel = new ServiceViewModel()
      const home: HomeViewModel = new HomeViewModel()

      expect(service.tipOpened).assertEqual(home.tipOpened)
      expect(service.tipClosed).assertEqual(home.tipClosed)
      expect(service.tipOpened).assertEqual('已开启')
      expect(service.tipClosed).assertEqual('已关闭')
    })

    it('服务开关_状态未变化_不返回轻提示文案', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.setDnd(false)).assertEqual('')
      expect(viewModel.setClean(false)).assertEqual('')
    })

    it('两项服务_互不影响', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      viewModel.setDnd(true)
      expect(viewModel.dndOn).assertTrue()
      expect(viewModel.cleanOn).assertFalse()
    })

    // ==================== SOS ====================

    it('SOS_返回固定轻提示文案', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.requestSos()).assertEqual('SOS 紧急呼叫已触发')
    })

    // ==================== 与首页快捷服务的双向同步 ====================

    it('共享状态_服务页开启请勿打扰_首页同步开启', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)

      serviceViewModel.setDnd(true)
      expect(shared.doNotDisturbOn).assertTrue()
      expect(homeViewModel.dndOn).assertTrue()
    })

    it('共享状态_服务页关闭请勿打扰_首页同步关闭', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)
      serviceViewModel.setDnd(true)

      serviceViewModel.setDnd(false)
      expect(homeViewModel.dndOn).assertFalse()
    })

    it('共享状态_首页开启清理房间_服务页同步开启', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)

      expect(homeViewModel.toggleClean()).assertEqual('清理房间已开启')
      expect(shared.cleanRoomOn).assertTrue()
      expect(serviceViewModel.cleanOn).assertTrue()
    })

    it('共享状态_首页开启请勿打扰_服务页同步开启', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)

      expect(homeViewModel.toggleDnd()).assertEqual('请勿打扰已开启')
      expect(serviceViewModel.dndOn).assertTrue()
    })

    it('共享状态_服务页开启_首页快捷服务卡同状态', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)

      serviceViewModel.setClean(true)
      expect(homeViewModel.cleanOn).assertTrue()
      // 另一项不受影响
      expect(homeViewModel.dndOn).assertFalse()
    })

    it('共享状态_未注入时使用自有实例_不影响全局', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()

      serviceViewModel.setDnd(true)
      expect(serviceViewModel.dndOn).assertTrue()
      expect(homeViewModel.dndOn).assertFalse()
    })

    it('共享状态_往返联动_服务页开_首页关_服务页同步关闭', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)

      // 服务页开启 → 首页同步开启
      serviceViewModel.setDnd(true)
      expect(homeViewModel.dndOn).assertTrue()

      // 首页关闭 → 服务页同步关闭
      expect(homeViewModel.toggleDnd()).assertEqual('请勿打扰已关闭')
      expect(serviceViewModel.dndOn).assertFalse()
      expect(shared.doNotDisturbOn).assertFalse()
    })

    it('共享状态_两项服务同时开启_互不覆盖', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)

      serviceViewModel.setDnd(true)
      serviceViewModel.setClean(true)

      expect(shared.doNotDisturbOn).assertTrue()
      expect(shared.cleanRoomOn).assertTrue()
      expect(homeViewModel.dndOn).assertTrue()
      expect(homeViewModel.cleanOn).assertTrue()
    })

    it('共享状态_重复写入同一状态_不产生变更', 0, () => {
      const shared: RoomServiceStore = new RoomServiceStore()

      expect(shared.setDoNotDisturb(true)).assertTrue()
      expect(shared.setDoNotDisturb(true)).assertFalse()
      expect(shared.setCleanRoom(false)).assertFalse()
      expect(shared.doNotDisturbOn).assertTrue()
      expect(shared.cleanRoomOn).assertFalse()
    })

    it('共享实例_全局取用两次_为同一对象', 0, () => {
      expect(RoomServiceStore.getShared() === RoomServiceStore.getShared()).assertTrue()
    })

    it('SOS_不改变服务开关状态', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()

      expect(viewModel.requestSos()).assertEqual('SOS 紧急呼叫已触发')
      expect(viewModel.dndOn).assertFalse()
      expect(viewModel.cleanOn).assertFalse()
    })

    // ==================== 退出登录 ====================

    it('退出登录_两项服务复位为关闭', 0, () => {
      const viewModel: ServiceViewModel = new ServiceViewModel()
      viewModel.setDnd(true)
      viewModel.setClean(true)

      viewModel.logout()

      expect(viewModel.dndOn).assertFalse()
      expect(viewModel.cleanOn).assertFalse()
    })

    it('退出登录_复位共享状态_首页同步回到关闭', 0, () => {
      const serviceViewModel: ServiceViewModel = new ServiceViewModel()
      const homeViewModel: HomeViewModel = new HomeViewModel()
      const shared: RoomServiceStore = new RoomServiceStore()
      serviceViewModel.attachServiceState(shared)
      homeViewModel.attachServiceState(shared)
      serviceViewModel.setDnd(true)
      serviceViewModel.setClean(true)

      serviceViewModel.logout()

      expect(homeViewModel.dndOn).assertFalse()
      expect(homeViewModel.cleanOn).assertFalse()
    })
  })
}
