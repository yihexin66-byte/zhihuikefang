/**
 * 灯光控制页界面模型（纯数据类，零业务逻辑）
 * 独立控制项与场景预设属于跨页共享的客房设备数据，已收敛到 common/model/RoomLightModel
 */

/**
 * 场景模式项（胶囊：图标 + 文案）
 * id 与首页四张场景卡同名项保持一致（bright / soft / read / warm），睡眠模式为灯光页独有
 */
export class LightSceneItem {
  /** 唯一标识：共享状态据此与首页同名场景双向同步，并驱动对应独立开关 */
  id: string = ''
  /** 胶囊文案（固定） */
  label: string = ''
  /** 胶囊图标 */
  icon: Resource = $r('app.media.light_icon_bright_mode')

  static of(id: string, label: string, icon: Resource): LightSceneItem {
    const item: LightSceneItem = new LightSceneItem()
    item.id = id
    item.label = label
    item.icon = icon
    return item
  }
}