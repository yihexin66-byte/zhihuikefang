/**
 * 智慧客房首页数据模型（纯数据类：零业务逻辑）
 */

/**
 * 首页路由参数：登录页「立即入住」→ 智慧客房首页 传递房号
 * 收（HomePage）发（LoginPage）双方共用同一契约，避免魔法字段名散落
 */
export class HomeRouteParams {
  /** 房号（登录页输入值） */
  roomNo: string = ''

  static of(roomNo: string): HomeRouteParams {
    const params: HomeRouteParams = new HomeRouteParams()
    params.roomNo = roomNo
    return params
  }
}

/**
 * 场景模式卡片数据（图标 + 文案）
 * 图标在模型层以资源引用声明，View 只负责渲染，后续可由服务端下发替换
 */
export class SceneModeItem {
  /** 唯一标识：选中态判定的依据 */
  id: string = ''
  /** 卡片文案 */
  label: string = ''
  /** 卡片图标 */
  icon: Resource = $r('app.media.home_icon_bright')

  static of(id: string, label: string, icon: Resource): SceneModeItem {
    const item: SceneModeItem = new SceneModeItem()
    item.id = id
    item.label = label
    item.icon = icon
    return item
  }
}

/**
 * 智慧客房首页固定参数（需求锁定，请勿改动）
 */
export class HomeDefaults {
  /** 房号保底值：直接启动本页调试、未接收到路由参数时展示 */
  static readonly FALLBACK_ROOM_NO: string = '2002'
  /** 当前温度：只读展示，固定 20°C */
  static readonly CURRENT_TEMP: number = 20
  /** 设定温度默认值 */
  static readonly SET_TEMP: number = 22
  /** 设定温度下限（16°C） */
  static readonly TEMP_MIN: number = 16
  /** 设定温度上限（30°C） */
  static readonly TEMP_MAX: number = 30
  /** 空调电源默认开启 */
  static readonly POWER_ON: boolean = true
  /** 快捷服务开关默认关闭 */
  static readonly QUICK_SERVICE_OFF: boolean = false
  /** 无选中场景（默认四张卡全部未选中） */
  static readonly NO_SCENE: string = ''
}

/**
 * 底部导航项数据（四项文案固定）
 * 图标当前复用已有图元：灯光→明亮、窗帘→窗帘图元、服务→清理图元，后续有专用图标直接替换即可
 */
export class NavTabItem {
  /** 导航文案 */
  label: string = ''
  /** 导航图标 */
  icon: Resource = $r('app.media.home_icon_airconditioner')

  static of(label: string, icon: Resource): NavTabItem {
    const item: NavTabItem = new NavTabItem()
    item.label = label
    item.icon = icon
    return item
  }
}