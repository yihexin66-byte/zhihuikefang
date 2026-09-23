/**
 * 智慧客房首页 ViewModel 单元测试
 * 覆盖：路由参数与房号保底、空调电源与温度步进边界、场景模式单选互斥、快捷服务与晚安模式轻提示文案、底部导航切换
 */
import { describe, it, expect } from '@ohos/hypium'
import { HomeRouteParams, HomeDefaults } from '../main/ets/features/home/model/HomeModel'
import { HomeViewModel } from '../main/ets/features/home/viewModel/HomeViewModel'

/**
 * 非路由参数类型的占位对象：用于验证「参数类型不符时走保底房号」
 */
class UnexpectedParam {
  roomNo: string = '9999'
}

export default function homeViewModelTest() {
  describe('HomeViewModelTest', () => {
    // ==================== 路由参数与房号 ====================

    it('applyRouteParam_有效参数_展示传入房号', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.applyRouteParam(HomeRouteParams.of('2006'))

      expect(viewModel.roomNo).assertEqual('2006')
      expect(viewModel.roomText).assertEqual('房号 2006')
    })

    it('applyRouteParam_未接收参数_保底房号2002', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.applyRouteParam(undefined)

      expect(viewModel.roomNo).assertEqual('2002')
      expect(viewModel.roomText).assertEqual('房号 2002')
    })

    it('applyRouteParam_房号为空串_保底房号2002', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.applyRouteParam(HomeRouteParams.of(''))

      expect(viewModel.roomNo).assertEqual('2002')
    })

    it('applyRouteParam_房号仅空白_保底房号2002', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.applyRouteParam(HomeRouteParams.of('   '))

      expect(viewModel.roomNo).assertEqual('2002')
    })

    it('applyRouteParam_参数类型不符_保底房号2002', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.applyRouteParam(new UnexpectedParam())

      expect(viewModel.roomNo).assertEqual('2002')
    })

    it('默认房号_未调用初始化_为保底值2002', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.roomNo).assertEqual(HomeDefaults.FALLBACK_ROOM_NO)
    })

    // ==================== 默认状态 ====================

    it('默认状态_空调开机_房间20度_设定22度', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.powerOn).assertTrue()
      expect(viewModel.powerStatusText).assertEqual('运行中')
      expect(viewModel.currentTemp).assertEqual(20)
      expect(viewModel.setTemp).assertEqual(22)
      expect(viewModel.tempAreaActive).assertTrue()
    })

    it('默认状态_场景未选_快捷服务与晚安模式关闭_导航在首页', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.selectedSceneId).assertEqual('')
      expect(viewModel.dndOn).assertFalse()
      expect(viewModel.cleanOn).assertFalse()
      expect(viewModel.nightOn).assertFalse()
      expect(viewModel.currentTab).assertEqual(0)
    })

    // ==================== 空调电源 ====================

    it('电源关闭_状态文案为已关机_温度区不可用', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.setPower(false)

      expect(viewModel.powerOn).assertFalse()
      expect(viewModel.powerStatusText).assertEqual('已关机')
      expect(viewModel.tempAreaActive).assertFalse()
      expect(viewModel.canIncrease).assertFalse()
      expect(viewModel.canDecrease).assertFalse()
    })

    it('电源关闭_加减号不响应温度不变', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.setPower(false)
      viewModel.stepTemp(1)
      viewModel.stepTemp(-1)

      expect(viewModel.setTemp).assertEqual(22)
    })

    it('电源关闭后再开机_状态文案回到运行中', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.setPower(false)
      viewModel.setPower(true)

      expect(viewModel.powerStatusText).assertEqual('运行中')
      expect(viewModel.tempAreaActive).assertTrue()
    })

    it('电源状态重复设置_保持目标状态', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.setPower(true)

      expect(viewModel.powerOn).assertTrue()
    })

    // ==================== 温度步进与边界 ====================

    it('温度步进_升温一次为23度_降温一次回22度', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.stepTemp(1)
      expect(viewModel.setTemp).assertEqual(23)

      viewModel.stepTemp(-1)
      expect(viewModel.setTemp).assertEqual(22)
    })

    it('温度上限_30度时升温不响应', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      for (let i: number = 0; i < 20; i++) {
        viewModel.stepTemp(1)
      }

      expect(viewModel.setTemp).assertEqual(HomeDefaults.TEMP_MAX)
      expect(viewModel.setTemp).assertEqual(30)
      expect(viewModel.canIncrease).assertFalse()

      viewModel.stepTemp(1)
      expect(viewModel.setTemp).assertEqual(30)
    })

    it('温度下限_16度时降温不响应', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      for (let i: number = 0; i < 20; i++) {
        viewModel.stepTemp(-1)
      }

      expect(viewModel.setTemp).assertEqual(HomeDefaults.TEMP_MIN)
      expect(viewModel.setTemp).assertEqual(16)
      expect(viewModel.canDecrease).assertFalse()

      viewModel.stepTemp(-1)
      expect(viewModel.setTemp).assertEqual(16)
    })

    it('温度边界_29度可升温_17度可降温', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      for (let i: number = 0; i < 7; i++) {
        viewModel.stepTemp(1)
      }
      expect(viewModel.setTemp).assertEqual(29)
      expect(viewModel.canIncrease).assertTrue()
      viewModel.stepTemp(1)
      expect(viewModel.setTemp).assertEqual(30)

      for (let i: number = 0; i < 13; i++) {
        viewModel.stepTemp(-1)
      }
      expect(viewModel.setTemp).assertEqual(17)
      expect(viewModel.canDecrease).assertTrue()
      viewModel.stepTemp(-1)
      expect(viewModel.setTemp).assertEqual(16)
    })

    it('当前温度_恒为只读20度', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.stepTemp(1)

      expect(viewModel.currentTemp).assertEqual(20)
    })

    // ==================== 场景模式：单选互斥 + 轻提示 ====================

    it('场景模式_四张卡文案固定', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.sceneModes.length).assertEqual(4)
      expect(viewModel.sceneModes[0].label).assertEqual('明亮模式')
      expect(viewModel.sceneModes[1].label).assertEqual('柔和模式')
      expect(viewModel.sceneModes[2].label).assertEqual('阅读模式')
      expect(viewModel.sceneModes[3].label).assertEqual('温馨模式')
    })

    it('场景模式_点击未开启卡_返回已开启文案', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      const tip: string = viewModel.toggleScene('bright')

      expect(tip).assertEqual('明亮模式已开启')
      expect(viewModel.selectedSceneId).assertEqual('bright')
    })

    it('场景模式_再次点击已开启卡_返回已关闭文案', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.toggleScene('bright')
      const tip: string = viewModel.toggleScene('bright')

      expect(tip).assertEqual('明亮模式已关闭')
      expect(viewModel.selectedSceneId).assertEqual('')
    })

    it('场景模式_单选互斥_切换到另一张卡', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.toggleScene('bright')
      const tip: string = viewModel.toggleScene('warm')

      expect(tip).assertEqual('温馨模式已开启')
      expect(viewModel.selectedSceneId).assertEqual('warm')
    })

    it('场景模式_四张卡开启文案均正确', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.toggleScene('bright')).assertEqual('明亮模式已开启')
      expect(viewModel.toggleScene('soft')).assertEqual('柔和模式已开启')
      expect(viewModel.toggleScene('read')).assertEqual('阅读模式已开启')
      expect(viewModel.toggleScene('warm')).assertEqual('温馨模式已开启')
    })

    // ==================== 快捷服务：轻提示文案 ====================

    it('请勿打扰_开关文案交替', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.toggleDnd()).assertEqual('请勿打扰已开启')
      expect(viewModel.dndOn).assertTrue()
      expect(viewModel.toggleDnd()).assertEqual('请勿打扰已关闭')
      expect(viewModel.dndOn).assertFalse()
    })

    it('清理房间_开关文案交替', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.toggleClean()).assertEqual('清理房间已开启')
      expect(viewModel.cleanOn).assertTrue()
      expect(viewModel.toggleClean()).assertEqual('清理房间已关闭')
      expect(viewModel.cleanOn).assertFalse()
    })

    it('快捷服务_两项互不影响', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.toggleDnd()

      expect(viewModel.dndOn).assertTrue()
      expect(viewModel.cleanOn).assertFalse()
    })

    it('晚安模式_开启与关闭文案固定', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.toggleNightMode()).assertEqual('晚安模式已开启，已关闭所有灯光')
      expect(viewModel.nightOn).assertTrue()
      expect(viewModel.toggleNightMode()).assertEqual('晚安模式已关闭')
      expect(viewModel.nightOn).assertFalse()
    })

    // ==================== 底部导航 ====================

    it('底部导航_四项文案固定', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()

      expect(viewModel.navTabs.length).assertEqual(4)
      expect(viewModel.navTabs[0].label).assertEqual('首页')
      expect(viewModel.navTabs[1].label).assertEqual('灯光')
      expect(viewModel.navTabs[2].label).assertEqual('窗帘')
      expect(viewModel.navTabs[3].label).assertEqual('服务')
    })

    it('底部导航_切换选中项', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.switchTab(2)

      expect(viewModel.currentTab).assertEqual(2)
    })

    it('底部导航_重复切换当前项_保持选中', 0, () => {
      const viewModel: HomeViewModel = new HomeViewModel()
      viewModel.switchTab(3)
      viewModel.switchTab(3)

      expect(viewModel.currentTab).assertEqual(3)
    })
  })
}