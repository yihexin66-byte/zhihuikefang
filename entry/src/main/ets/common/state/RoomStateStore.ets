/**
 * 客房共享状态（跨页唯一的灯光与场景数据源）
 *
 * 智慧客房首页与灯光控制页共用同一个实例：
 *  1. 场景模式：任一页选中 / 取消，另一页实时联动；
 *  2. 9 路独立开关与总开关：首页场景卡与灯光页开关读写同一份状态；
 *  3. 场景与开关的对应关系在 toggleScene 内统一落地 —— 无论从首页还是灯光页触发，
 *     选中场景即打开对应开关、取消选中即关闭对应开关。
 *
 * @ObservedV2 + @Trace：View 直接读取 selectedSceneId / mainSwitchOn / controls[i].on
 * 即建立依赖，变更自动刷新，无需手工通知。
 */
import { LightControlItem, LightScenePreset, RoomLightDefaults } from '../model/RoomLightModel'

@ObservedV2
export class RoomStateStore {
  /** 全局共享实例（延迟创建） */
  private static sharedInstance: RoomStateStore | undefined = undefined

  /**
   * 当前选中的场景 id：空串表示全部未选中
   * 睡眠模式（sleep）为灯光页独有，选中时不在首页四张场景卡 id 之内，首页四张卡自然全部未选中
   */
  @Trace selectedSceneId: string = RoomLightDefaults.NO_SCENE

  /** 总开关：默认关闭；任一独立开关开启即为开，全部关闭即为关 */
  @Trace mainSwitchOn: boolean = RoomLightDefaults.MAIN_SWITCH_OFF

  /** 9 路独立控制项：开关状态默认全部关闭 */
  readonly controls: LightControlItem[] = RoomLightDefaults.createControls()

  /**
   * 取全局共享实例：应用运行期两页拿到的是同一个对象
   */
  static getShared(): RoomStateStore {
    if (RoomStateStore.sharedInstance === undefined) {
      RoomStateStore.sharedInstance = new RoomStateStore()
    }
    return RoomStateStore.sharedInstance
  }

  // ==================== 场景模式 ====================

  /** 是否选中指定场景 */
  isSceneSelected(id: string): boolean {
    return this.selectedSceneId === id
  }

  /**
   * 选中 / 取消选中场景，并联动对应独立开关：
   * 选中 → 打开该场景对应的灯；再次点击取消 → 关闭这些灯
   * 睡眠模式语义为「关闭全部灯光」，选中时全部关闭，取消时不再改变灯光
   * @returns true 表示本次为「选中」，false 表示本次为「取消选中」
   */
  toggleScene(id: string): boolean {
    const opening: boolean = this.selectedSceneId !== id
    if (opening) {
      this.selectedSceneId = id
      this.applySceneLights(id)
    } else {
      this.selectedSceneId = RoomLightDefaults.NO_SCENE
      this.clearSceneLights(id)
    }
    return opening
  }

  /** 清空选中场景：全部未选中，不改动灯光状态 */
  clearScene(): void {
    this.selectedSceneId = RoomLightDefaults.NO_SCENE
  }

  /** 打开场景对应的灯光 */
  private applySceneLights(sceneId: string): void {
    if (sceneId === RoomLightDefaults.SCENE_SLEEP) {
      this.turnOffAllLights()
      return
    }
    const preset: LightScenePreset | undefined = this.findPreset(sceneId)
    if (preset === undefined) {
      return
    }
    for (const lightId of preset.lightIds) {
      this.setControl(lightId, true)
    }
  }

  /** 取消场景：关闭该场景对应的灯光（未列入该场景的灯不受影响） */
  private clearSceneLights(sceneId: string): void {
    if (sceneId === RoomLightDefaults.SCENE_SLEEP) {
      return
    }
    const preset: LightScenePreset | undefined = this.findPreset(sceneId)
    if (preset === undefined) {
      return
    }
    for (const lightId of preset.lightIds) {
      this.setControl(lightId, false)
    }
  }

  /** 按 id 取场景预设：未命中返回 undefined，由调用方窄化 */
  private findPreset(sceneId: string): LightScenePreset | undefined {
    for (const preset of RoomLightDefaults.SCENE_PRESETS) {
      if (preset.sceneId === sceneId) {
        return preset
      }
    }
    return undefined
  }

  // ==================== 总开关与独立开关 ====================

  /**
   * 总开关点击：关闭则全开所有独立灯光，开启则全关所有独立灯光
   */
  toggleMainSwitch(): void {
    const target: boolean = !this.mainSwitchOn
    for (const item of this.controls) {
      item.on = target
    }
    this.mainSwitchOn = target
  }

  /**
   * 单路开关：由 Row 内的开关回传目标状态
   * 变更后按「全部关闭 = 关，任一开启 = 开」联动总开关
   */
  setControl(id: string, on: boolean): void {
    const item: LightControlItem | undefined = this.findControl(id)
    if (item === undefined || item.on === on) {
      return
    }
    item.on = on
    this.syncMainSwitch()
  }

  /** 关闭全部独立灯光并同步总开关 */
  turnOffAllLights(): void {
    for (const item of this.controls) {
      item.on = RoomLightDefaults.CONTROL_OFF
    }
    this.mainSwitchOn = RoomLightDefaults.MAIN_SWITCH_OFF
  }

  /** 总开关联动：任一独立开关开启则总开关为开，全部关闭则总开关为关 */
  private syncMainSwitch(): void {
    let anyOn: boolean = false
    for (const item of this.controls) {
      if (item.on) {
        anyOn = true
        break
      }
    }
    this.mainSwitchOn = anyOn
  }

  /** 按 id 查找独立控制项：未命中返回 undefined，由调用方窄化 */
  private findControl(id: string): LightControlItem | undefined {
    for (const item of this.controls) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }
}