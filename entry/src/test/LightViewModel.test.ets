/**
 * 灯光控制页 ViewModel 单元测试
 * 覆盖：默认状态、总开关全开/全关、9 路开关与总开关双向联动、
 *       场景胶囊单选互斥与取消、场景与独立开关的对应联动（含睡眠模式）、
 *       以及与首页同名场景 / 灯光开关的双向同步
 */
import { describe, it, expect } from '@ohos/hypium'
import { LightControlItem, RoomLightDefaults } from '../main/ets/common/model/RoomLightModel'
import { RoomStateStore } from '../main/ets/common/state/RoomStateStore'
import { HomeViewModel } from '../main/ets/features/home/viewModel/HomeViewModel'
import { LightViewModel } from '../main/ets/features/light/viewModel/LightViewModel'

/** 取指定 id 的开关状态（未命中返回 false，便于直接断言） */
function isOn(controls: LightControlItem[], id: string): boolean {
  for (const item of controls) {
    if (item.id === id) {
      return item.on
    }
  }
  return false
}

/** 统计已开启的灯数 */
function countOn(controls: LightControlItem[]): number {
  let count: number = 0
  for (const item of controls) {
    if (item.on) {
      count++
    }
  }
  return count
}

/** 指定 id 是否为已声明的开关（用于校验场景预设表没有写错的灯 id） */
function hasControl(controls: LightControlItem[], id: string): boolean {
  for (const item of controls) {
    if (item.id === id) {
      return true
    }
  }
  return false
}

export default function lightViewModelTest() {
  describe('LightViewModelTest', () => {
    // ==================== 默认状态 ====================

    it('默认状态_总开关关闭_九路开关全关_场景全未选中', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()

      expect(viewModel.mainSwitchOn).assertFalse()
      expect(viewModel.mainSwitchStateText).assertEqual('全关')
      expect(viewModel.roomState.controls.length).assertEqual(9)
      expect(countOn(viewModel.roomState.controls)).assertEqual(0)
      expect(viewModel.scenes.length).assertEqual(5)
      expect(viewModel.roomState.selectedSceneId).assertEqual('')
    })

    it('页面文案固定', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()

      expect(viewModel.pageTitle).assertEqual('灯光控制')
      expect(viewModel.mainSwitchLabel).assertEqual('总开关')
      expect(viewModel.mainSwitchOnText).assertEqual('全开')
      expect(viewModel.mainSwitchOffText).assertEqual('全关')
      expect(viewModel.sceneSectionTitle).assertEqual('场景模式')
      expect(viewModel.controlSectionTitle).assertEqual('独立控制')
    })

    it('独立控制_九项名称与顺序固定', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      const controls: LightControlItem[] = viewModel.roomState.controls

      expect(controls[0].label).assertEqual('主灯')
      expect(controls[1].label).assertEqual('衣柜灯')
      expect(controls[2].label).assertEqual('落地灯')
      expect(controls[3].label).assertEqual('壁灯')
      expect(controls[4].label).assertEqual('书桌灯')
      expect(controls[5].label).assertEqual('右阅读灯')
      expect(controls[6].label).assertEqual('左阅读灯')
      expect(controls[7].label).assertEqual('排风扇')
      expect(controls[8].label).assertEqual('廊灯')
    })

    it('场景模式_五项名称与顺序固定_睡眠模式为第五项', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()

      expect(viewModel.scenes[0].label).assertEqual('明亮模式')
      expect(viewModel.scenes[1].label).assertEqual('柔和模式')
      expect(viewModel.scenes[2].label).assertEqual('阅读模式')
      expect(viewModel.scenes[3].label).assertEqual('温馨模式')
      expect(viewModel.scenes[4].label).assertEqual('睡眠模式')
      expect(viewModel.scenes[4].id).assertEqual(RoomLightDefaults.SCENE_SLEEP)
    })

    // ==================== 总开关：全开 / 全关 ====================

    it('总开关_关闭时点击_九路全开且状态为全开', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleMainSwitch()

      expect(viewModel.mainSwitchOn).assertTrue()
      expect(viewModel.mainSwitchStateText).assertEqual('全开')
      expect(countOn(viewModel.roomState.controls)).assertEqual(9)
    })

    it('总开关_开启时点击_九路全关且状态为全关', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleMainSwitch()
      viewModel.toggleMainSwitch()

      expect(viewModel.mainSwitchOn).assertFalse()
      expect(viewModel.mainSwitchStateText).assertEqual('全关')
      expect(countOn(viewModel.roomState.controls)).assertEqual(0)
    })

    it('总开关_连续切换两轮_状态与九路开关保持一致', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()

      viewModel.toggleMainSwitch()
      viewModel.toggleMainSwitch()
      viewModel.toggleMainSwitch()

      expect(viewModel.mainSwitchOn).assertTrue()
      expect(countOn(viewModel.roomState.controls)).assertEqual(9)
    })

    // ==================== 独立开关与总开关联动 ====================

    it('独立开关_单路开启_总开关联动为开', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.setControl(RoomLightDefaults.LIGHT_DESK, true)

      expect(isOn(viewModel.roomState.controls, RoomLightDefaults.LIGHT_DESK)).assertTrue()
      expect(viewModel.mainSwitchOn).assertTrue()
      expect(viewModel.mainSwitchStateText).assertEqual('全开')
    })

    it('独立开关_唯二开启后关其一_总开关仍为开', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.setControl(RoomLightDefaults.LIGHT_MAIN, true)
      viewModel.setControl(RoomLightDefaults.LIGHT_FAN, true)
      viewModel.setControl(RoomLightDefaults.LIGHT_MAIN, false)

      expect(isOn(viewModel.roomState.controls, RoomLightDefaults.LIGHT_MAIN)).assertFalse()
      expect(isOn(viewModel.roomState.controls, RoomLightDefaults.LIGHT_FAN)).assertTrue()
      expect(viewModel.mainSwitchOn).assertTrue()
    })

    it('独立开关_最后一盏关闭_总开关联动为关', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.setControl(RoomLightDefaults.LIGHT_MAIN, true)
      viewModel.setControl(RoomLightDefaults.LIGHT_MAIN, false)

      expect(viewModel.mainSwitchOn).assertFalse()
      expect(viewModel.mainSwitchStateText).assertEqual('全关')
    })

    it('独立开关_全开时逐路关闭_总开关在最后一盏关闭时才为关', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleMainSwitch()

      viewModel.setControl(RoomLightDefaults.LIGHT_WARDROBE, false)
      expect(viewModel.mainSwitchOn).assertTrue()

      viewModel.setControl(RoomLightDefaults.LIGHT_FAN, false)
      expect(viewModel.mainSwitchOn).assertTrue()

      for (const item of viewModel.roomState.controls) {
        viewModel.setControl(item.id, false)
      }
      expect(viewModel.mainSwitchOn).assertFalse()
    })

    it('独立开关_状态重复设置_保持目标状态', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.setControl(RoomLightDefaults.LIGHT_FLOOR, true)
      viewModel.setControl(RoomLightDefaults.LIGHT_FLOOR, true)

      expect(isOn(viewModel.roomState.controls, RoomLightDefaults.LIGHT_FLOOR)).assertTrue()
      expect(viewModel.mainSwitchOn).assertTrue()
    })

    it('独立开关_未知 id_不响应且不影响总开关', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.setControl('unknown', true)

      expect(viewModel.mainSwitchOn).assertFalse()
      expect(countOn(viewModel.roomState.controls)).assertEqual(0)
    })

    // ==================== 场景模式：单选互斥与取消 ====================

    it('场景模式_点击未选中胶囊_选中并返回已开启文案', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      const tip: string = viewModel.toggleScene('bright')

      expect(tip).assertEqual('明亮模式已开启')
      expect(viewModel.roomState.selectedSceneId).assertEqual('bright')
    })

    it('场景模式_再次点击已选中胶囊_取消选中', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleScene('bright')
      const tip: string = viewModel.toggleScene('bright')

      expect(tip).assertEqual('明亮模式已关闭')
      expect(viewModel.roomState.selectedSceneId).assertEqual('')
    })

    it('场景模式_单选互斥_切换到另一胶囊', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleScene('bright')
      const tip: string = viewModel.toggleScene('warm')

      expect(tip).assertEqual('温馨模式已开启')
      expect(viewModel.roomState.selectedSceneId).assertEqual('warm')
    })

    it('场景模式_五个胶囊开启文案均正确', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()

      expect(viewModel.toggleScene('bright')).assertEqual('明亮模式已开启')
      expect(viewModel.toggleScene('soft')).assertEqual('柔和模式已开启')
      expect(viewModel.toggleScene('read')).assertEqual('阅读模式已开启')
      expect(viewModel.toggleScene('warm')).assertEqual('温馨模式已开启')
      expect(viewModel.toggleScene(RoomLightDefaults.SCENE_SLEEP)).assertEqual('睡眠模式已开启')
    })

    // ==================== 场景模式与独立开关的对应联动 ====================

    it('明亮模式_选中时打开对应开关_其余保持关闭', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleScene('bright')
      const controls: LightControlItem[] = viewModel.roomState.controls

      expect(isOn(controls, RoomLightDefaults.LIGHT_MAIN)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_WALL)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_FLOOR)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_DESK)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_CORRIDOR)).assertTrue()

      expect(isOn(controls, RoomLightDefaults.LIGHT_WARDROBE)).assertFalse()
      expect(isOn(controls, RoomLightDefaults.LIGHT_READ_LEFT)).assertFalse()
      expect(isOn(controls, RoomLightDefaults.LIGHT_READ_RIGHT)).assertFalse()
      expect(isOn(controls, RoomLightDefaults.LIGHT_FAN)).assertFalse()

      expect(viewModel.mainSwitchOn).assertTrue()
    })

    it('明亮模式_取消时关闭对应开关', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleScene('bright')
      viewModel.toggleScene('bright')

      expect(countOn(viewModel.roomState.controls)).assertEqual(0)
      expect(viewModel.mainSwitchOn).assertFalse()
    })

    it('柔和模式_仅点亮氛围灯', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleScene('soft')
      const controls: LightControlItem[] = viewModel.roomState.controls

      expect(isOn(controls, RoomLightDefaults.LIGHT_WALL)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_FLOOR)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_CORRIDOR)).assertTrue()
      expect(countOn(controls)).assertEqual(3)
    })

    it('阅读模式_点亮主照明与书桌及两侧阅读灯', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleScene('read')
      const controls: LightControlItem[] = viewModel.roomState.controls

      expect(isOn(controls, RoomLightDefaults.LIGHT_MAIN)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_DESK)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_READ_LEFT)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_READ_RIGHT)).assertTrue()
      expect(countOn(controls)).assertEqual(4)
    })

    it('温馨模式_点亮氛围灯与衣柜灯', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleScene('warm')
      const controls: LightControlItem[] = viewModel.roomState.controls

      expect(isOn(controls, RoomLightDefaults.LIGHT_WARDROBE)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_WALL)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_FLOOR)).assertTrue()
      expect(countOn(controls)).assertEqual(3)
    })

    it('场景联动_未列入该场景的灯不受影响', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.setControl(RoomLightDefaults.LIGHT_FAN, true)

      viewModel.toggleScene('bright')

      expect(isOn(viewModel.roomState.controls, RoomLightDefaults.LIGHT_FAN)).assertTrue()
    })

    // ==================== 睡眠模式：关闭所有灯光 ====================

    it('睡眠模式_选中时联动关闭所有灯光与总开关', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleMainSwitch()
      expect(viewModel.mainSwitchOn).assertTrue()

      viewModel.toggleScene(RoomLightDefaults.SCENE_SLEEP)

      expect(viewModel.roomState.selectedSceneId).assertEqual(RoomLightDefaults.SCENE_SLEEP)
      expect(viewModel.mainSwitchOn).assertFalse()
      expect(countOn(viewModel.roomState.controls)).assertEqual(0)
    })

    it('睡眠模式_取消选中_不再改变灯光状态', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.setControl(RoomLightDefaults.LIGHT_CORRIDOR, true)
      viewModel.toggleScene(RoomLightDefaults.SCENE_SLEEP)
      expect(viewModel.mainSwitchOn).assertFalse()

      viewModel.toggleScene(RoomLightDefaults.SCENE_SLEEP)

      expect(viewModel.roomState.selectedSceneId).assertEqual('')
      expect(viewModel.mainSwitchOn).assertFalse()
    })

    // ==================== 场景预设表：数据完整性 ====================

    it('场景预设_共四项且每项引用的灯 id 均已声明', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      const controls: LightControlItem[] = viewModel.roomState.controls

      expect(RoomLightDefaults.SCENE_PRESETS.length).assertEqual(4)
      for (const preset of RoomLightDefaults.SCENE_PRESETS) {
        // 每个预设至少对应一盏灯，且 id 必须能在九项开关中找到（防止映射表写错导致联动静默失效）
        expect(preset.lightIds.length > 0).assertTrue()
        for (const lightId of preset.lightIds) {
          expect(hasControl(controls, lightId)).assertTrue()
        }
      }
    })

    it('场景预设_与首页四张场景卡 id 一一对应', 0, () => {
      const home: HomeViewModel = new HomeViewModel()

      expect(RoomLightDefaults.SCENE_PRESETS.length).assertEqual(home.sceneModes.length)
      for (const mode of home.sceneModes) {
        let matched: boolean = false
        for (const preset of RoomLightDefaults.SCENE_PRESETS) {
          if (preset.sceneId === mode.id) {
            matched = true
          }
        }
        expect(matched).assertTrue()
      }
    })

    it('场景取消_总开关全开时仅关闭对应灯_其余保持开启', 0, () => {
      const viewModel: LightViewModel = new LightViewModel()
      viewModel.toggleMainSwitch()
      expect(countOn(viewModel.roomState.controls)).assertEqual(9)

      viewModel.toggleScene('soft')
      viewModel.toggleScene('soft')
      const controls: LightControlItem[] = viewModel.roomState.controls

      expect(isOn(controls, RoomLightDefaults.LIGHT_WALL)).assertFalse()
      expect(isOn(controls, RoomLightDefaults.LIGHT_FLOOR)).assertFalse()
      expect(isOn(controls, RoomLightDefaults.LIGHT_CORRIDOR)).assertFalse()
      expect(countOn(controls)).assertEqual(6)
      expect(viewModel.mainSwitchOn).assertTrue()
    })

    // ==================== 与首页同名场景 / 灯光开关的双向同步 ====================

    it('共享状态_两页注入同一实例_首页选中后灯光页同步', 0, () => {
      const store: RoomStateStore = new RoomStateStore()
      const home: HomeViewModel = new HomeViewModel()
      const light: LightViewModel = new LightViewModel()
      home.attachRoomState(store)
      light.attachRoomState(store)

      home.toggleScene('soft')

      expect(light.roomState.selectedSceneId).assertEqual('soft')
      expect(light.roomState.isSceneSelected('soft')).assertTrue()
      expect(light.roomState.isSceneSelected('bright')).assertFalse()
    })

    it('共享状态_首页选中场景_灯光页对应开关同步打开', 0, () => {
      const store: RoomStateStore = new RoomStateStore()
      const home: HomeViewModel = new HomeViewModel()
      const light: LightViewModel = new LightViewModel()
      home.attachRoomState(store)
      light.attachRoomState(store)

      home.toggleScene('soft')
      const controls: LightControlItem[] = light.roomState.controls

      expect(isOn(controls, RoomLightDefaults.LIGHT_WALL)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_FLOOR)).assertTrue()
      expect(isOn(controls, RoomLightDefaults.LIGHT_CORRIDOR)).assertTrue()
      expect(light.mainSwitchOn).assertTrue()
    })

    it('共享状态_首页取消场景_灯光页对应开关同步关闭', 0, () => {
      const store: RoomStateStore = new RoomStateStore()
      const home: HomeViewModel = new HomeViewModel()
      const light: LightViewModel = new LightViewModel()
      home.attachRoomState(store)
      light.attachRoomState(store)

      home.toggleScene('read')
      expect(countOn(light.roomState.controls)).assertEqual(4)

      home.toggleScene('read')

      expect(countOn(light.roomState.controls)).assertEqual(0)
      expect(light.mainSwitchOn).assertFalse()
    })

    it('共享状态_灯光页选中后首页同步', 0, () => {
      const store: RoomStateStore = new RoomStateStore()
      const home: HomeViewModel = new HomeViewModel()
      const light: LightViewModel = new LightViewModel()
      home.attachRoomState(store)
      light.attachRoomState(store)

      light.toggleScene('read')

      expect(home.selectedSceneId).assertEqual('read')
    })

    it('共享状态_灯光页取消选中_首页同步取消', 0, () => {
      const store: RoomStateStore = new RoomStateStore()
      const home: HomeViewModel = new HomeViewModel()
      const light: LightViewModel = new LightViewModel()
      home.attachRoomState(store)
      light.attachRoomState(store)

      home.toggleScene('warm')
      expect(light.roomState.isSceneSelected('warm')).assertTrue()

      home.toggleScene('warm')

      expect(light.roomState.selectedSceneId).assertEqual('')
      expect(light.roomState.isSceneSelected('warm')).assertFalse()
    })

    it('共享状态_灯光页选中睡眠模式_首页四张卡均不选中且灯光全关', 0, () => {
      const store: RoomStateStore = new RoomStateStore()
      const home: HomeViewModel = new HomeViewModel()
      const light: LightViewModel = new LightViewModel()
      home.attachRoomState(store)
      light.attachRoomState(store)
      home.toggleScene('bright')

      light.toggleScene(RoomLightDefaults.SCENE_SLEEP)

      expect(home.selectedSceneId).assertEqual(RoomLightDefaults.SCENE_SLEEP)
      // 睡眠模式不在首页四张卡 id 之内，四张卡自然全部未选中
      expect(home.sceneModes.length).assertEqual(4)
      for (const item of home.sceneModes) {
        expect(home.selectedSceneId === item.id).assertFalse()
      }
      expect(countOn(light.roomState.controls)).assertEqual(0)
    })

    it('共享状态_未注入共享实例_两页互不影响', 0, () => {
      const home: HomeViewModel = new HomeViewModel()
      const light: LightViewModel = new LightViewModel()

      home.toggleScene('bright')
      light.toggleScene('soft')

      expect(home.selectedSceneId).assertEqual('bright')
      expect(light.roomState.selectedSceneId).assertEqual('soft')
      expect(countOn(home.roomState.controls)).assertEqual(5)
      expect(countOn(light.roomState.controls)).assertEqual(3)
    })

    it('共享实例_getShared_多次获取为同一对象', 0, () => {
      const first: RoomStateStore = RoomStateStore.getShared()
      const second: RoomStateStore = RoomStateStore.getShared()

      expect(first === second).assertTrue()
      first.clearScene()
      first.turnOffAllLights()
    })
  })
}