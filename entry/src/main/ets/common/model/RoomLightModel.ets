/**
 * 客房灯光数据模型（纯数据 + 需求锁定的默认值，零业务逻辑）
 *
 * 放置于 common 的原因：9 路灯光开关是「客房设备状态」，由智慧客房首页（场景卡）与
 * 灯光控制页共同读写，属于跨页共享数据，因此模型与状态一起收敛到 common。
 */

/**
 * 独立控制项（图标 + 名称 + 开关）
 * @ObservedV2 + @Trace：9 路开关状态各自独立变化，对应格 UI 实时刷新
 */
@ObservedV2
export class LightControlItem {
  /** 唯一标识：开关状态与总开关联动、场景预设的判定依据 */
  id: string = ''
  /** 项名称（固定文案） */
  label: string = ''
  /** 项图标 */
  icon: Resource = $r('app.media.light_icon_main_lamp')
  /** 开关状态：默认全部关闭 */
  @Trace on: boolean = false

  static of(id: string, label: string, icon: Resource): LightControlItem {
    const item: LightControlItem = new LightControlItem()
    item.id = id
    item.label = label
    item.icon = icon
    return item
  }
}

/**
 * 场景预设：场景模式与独立控制开关的对应关系
 * 选中场景 → 打开 lightIds 对应的开关；取消选中 → 关闭这些开关（未列入的灯不受影响）
 */
export class LightScenePreset {
  /** 场景 id（与首页场景卡同名项一致） */
  sceneId: string = ''
  /** 该场景对应的独立控制项 id 列表 */
  lightIds: string[] = []

  static of(sceneId: string, lightIds: string[]): LightScenePreset {
    const preset: LightScenePreset = new LightScenePreset()
    preset.sceneId = sceneId
    preset.lightIds = lightIds
    return preset
  }
}

/**
 * 客房灯光与场景固定参数（需求锁定，请勿改动）
 */
export class RoomLightDefaults {
  /** 总开关默认关闭 */
  static readonly MAIN_SWITCH_OFF: boolean = false
  /** 独立控制开关默认全部关闭 */
  static readonly CONTROL_OFF: boolean = false
  /** 无选中场景（场景模式默认全部未选中） */
  static readonly NO_SCENE: string = ''
  /** 睡眠模式 id：灯光页独有，选中时首页四张场景卡均不选中 */
  static readonly SCENE_SLEEP: string = 'sleep'

  /** 独立控制九项 id（场景预设定向引用，避免魔法字符串散落） */
  static readonly LIGHT_MAIN: string = 'main'
  static readonly LIGHT_WARDROBE: string = 'wardrobe'
  static readonly LIGHT_FLOOR: string = 'floor'
  static readonly LIGHT_WALL: string = 'wall'
  static readonly LIGHT_DESK: string = 'desk'
  static readonly LIGHT_READ_RIGHT: string = 'readRight'
  static readonly LIGHT_READ_LEFT: string = 'readLeft'
  static readonly LIGHT_FAN: string = 'fan'
  static readonly LIGHT_CORRIDOR: string = 'corridor'

  /**
   * 9 路独立控制项：主灯 / 衣柜灯 / 落地灯 / 壁灯 / 书桌灯 / 右阅读灯 / 左阅读灯 / 排风扇 / 廊灯
   */
  static createControls(): LightControlItem[] {
    return [
      LightControlItem.of(RoomLightDefaults.LIGHT_MAIN, '主灯', $r('app.media.light_icon_main_lamp')),
      LightControlItem.of(RoomLightDefaults.LIGHT_WARDROBE, '衣柜灯', $r('app.media.light_icon_wardrobe')),
      LightControlItem.of(RoomLightDefaults.LIGHT_FLOOR, '落地灯', $r('app.media.light_icon_bar_lamp')),
      LightControlItem.of(RoomLightDefaults.LIGHT_WALL, '壁灯', $r('app.media.light_icon_wall_lamp')),
      LightControlItem.of(RoomLightDefaults.LIGHT_DESK, '书桌灯', $r('app.media.light_icon_right_left_desk_read')),
      LightControlItem.of(RoomLightDefaults.LIGHT_READ_RIGHT, '右阅读灯', $r('app.media.light_icon_read_right')),
      LightControlItem.of(RoomLightDefaults.LIGHT_READ_LEFT, '左阅读灯', $r('app.media.light_icon_read_left')),
      LightControlItem.of(RoomLightDefaults.LIGHT_FAN, '排风扇', $r('app.media.light_icon_exhaust_fan')),
      LightControlItem.of(RoomLightDefaults.LIGHT_CORRIDOR, '廊灯', $r('app.media.light_icon_corrid_lights'))
    ]
  }

  /**
   * 场景预设表：4 个与首页联动的场景各自对应若干盏灯
   * 睡眠模式不在表中：其语义是「关闭全部灯光」，由 RoomStateStore 单独处理
   */
  static readonly SCENE_PRESETS: LightScenePreset[] = [
    // 明亮模式：主照明全开
    LightScenePreset.of('bright', [
      RoomLightDefaults.LIGHT_MAIN,
      RoomLightDefaults.LIGHT_WALL,
      RoomLightDefaults.LIGHT_FLOOR,
      RoomLightDefaults.LIGHT_DESK,
      RoomLightDefaults.LIGHT_CORRIDOR
    ]),
    // 柔和模式：仅氛围灯
    LightScenePreset.of('soft', [
      RoomLightDefaults.LIGHT_WALL,
      RoomLightDefaults.LIGHT_FLOOR,
      RoomLightDefaults.LIGHT_CORRIDOR
    ]),
    // 阅读模式：主照明 + 书桌与两侧阅读灯
    LightScenePreset.of('read', [
      RoomLightDefaults.LIGHT_MAIN,
      RoomLightDefaults.LIGHT_DESK,
      RoomLightDefaults.LIGHT_READ_LEFT,
      RoomLightDefaults.LIGHT_READ_RIGHT
    ]),
    // 温馨模式：氛围灯 + 衣柜灯
    LightScenePreset.of('warm', [
      RoomLightDefaults.LIGHT_WARDROBE,
      RoomLightDefaults.LIGHT_WALL,
      RoomLightDefaults.LIGHT_FLOOR
    ])
  ]
}