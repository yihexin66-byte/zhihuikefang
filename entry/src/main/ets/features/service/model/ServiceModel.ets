/**
 * 服务控制页界面模型（纯数据类，零业务逻辑）
 * 请勿打扰 / 清理房间的开关状态属于跨页共享的客房服务数据，已收敛到 common（RoomServiceStore）
 */

/**
 * 服务卡数据（淡金卡底图 + 图标 + 文案）
 * 图标与卡底均在模型层以资源引用声明，View 只负责渲染，后续可由服务端下发替换
 */
export class ServiceItem {
  /** 唯一标识：共享状态据此与首页快捷服务同名项双向同步 */
  id: string = ''
  /** 卡片文案（固定） */
  label: string = ''
  /** 卡片图标（白色图元，View 层按 alpha 着色后压在淡金卡底上） */
  icon: Resource = $r('app.media.service_icon_do_not_disturb')
  /** 卡片底色图元（淡金圆角方形，按设计稿宽高比铺满卡片） */
  cardBg: Resource = $r('app.media.service_do_not_disturb_bg')

  static of(id: string, label: string, icon: Resource, cardBg: Resource): ServiceItem {
    const item: ServiceItem = new ServiceItem()
    item.id = id
    item.label = label
    item.icon = icon
    item.cardBg = cardBg
    return item
  }
}
