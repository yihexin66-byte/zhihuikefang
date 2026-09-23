/**
 * 客房服务数据模型（纯数据 + 需求锁定的默认值，零业务逻辑）
 *
 * 放置于 common 的原因：请勿打扰 / 清理房间是「客房服务状态」，
 * 由智慧客房首页（快捷服务卡）与服务控制页共同读写，属于跨页共享数据，
 * 因此标识与默认值收敛到 common，状态本身由 RoomServiceStore 统一持有。
 */

/**
 * 客房服务固定参数（需求锁定，请勿改动）
 */
export class RoomServiceDefaults {
  /** 服务开关默认关闭：本页与首页快捷服务均为关闭态 */
  static readonly SERVICE_OFF: boolean = false

  /** 请勿打扰 id：首页快捷服务与服务控制页同名项双向同步的判定依据 */
  static readonly SERVICE_DND: string = 'doNotDisturb'
  /** 清理房间 id */
  static readonly SERVICE_CLEAN: string = 'cleanRoom'
}
