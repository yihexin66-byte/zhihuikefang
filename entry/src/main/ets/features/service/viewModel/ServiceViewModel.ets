/**
 * 服务控制页 ViewModel：状态与基础交互逻辑，零 UI
 * 页面文案、服务项数据、开关状态全部收敛在这里，View 只负责渲染与转发事件
 *
 * 同步机制：请勿打扰 / 清理房间的开关状态不落在本层，而是读写全局共享的 RoomServiceStore，
 * 因此本页开关与首页快捷服务对应项天然双向联动（任一页变更，另一页自动刷新）。
 */
import { Logger } from '../../../common/log/Logger'
import { RoomServiceDefaults } from '../../../common/model/RoomServiceModel'
import { RoomServiceStore } from '../../../common/state/RoomServiceStore'
import { ServiceItem } from '../model/ServiceModel'

@ObservedV2
export class ServiceViewModel {
  // ==================== 页面文案（固定，一字不改）====================
  /** 页面标题 */
  readonly pageTitle: string = '服务控制'
  /** SOS 按钮无障碍文案（按钮图元内已含 SOS 字样，此处供读屏使用） */
  readonly sosLabel: string = 'SOS'
  /** SOS 点击轻提示（不做真实报警对接） */
  readonly sosTip: string = 'SOS 紧急呼叫已触发'
  /** 退出登录按钮文案（按钮图元内已含该字样，此处供读屏使用） */
  readonly logoutLabel: string = '退出登录'
  /** 服务开关轻提示后缀（与首页快捷服务同一套固定文案，开启与关闭各一条） */
  readonly tipOpened: string = '已开启'
  readonly tipClosed: string = '已关闭'

  // ==================== 固定数据（需求锁定）====================
  /** 左侧服务卡：请勿打扰（月亮 zZ 图标） */
  readonly dndItem: ServiceItem = ServiceItem.of(
    RoomServiceDefaults.SERVICE_DND,
    '请勿打扰',
    $r('app.media.service_icon_do_not_disturb'),
    $r('app.media.service_do_not_disturb_bg')
  )

  /** 右侧服务卡：清理房间（扫帚图标） */
  readonly cleanItem: ServiceItem = ServiceItem.of(
    RoomServiceDefaults.SERVICE_CLEAN,
    '清理房间',
    $r('app.media.service_icon_clean_room'),
    $r('app.media.service_clean_room_bg')
  )

  // ==================== 共享状态 ====================
  /**
   * 客房服务共享状态：默认自有实例（保证单测隔离）
   * 页面 aboutToAppear 注入全局共享实例后，本页开关与首页快捷服务双向同步
   */
  serviceState: RoomServiceStore = new RoomServiceStore()

  private logger: Logger = new Logger('[ServiceViewModel]')

  // ==================== 派生状态（读取 @Trace，变更即联动 UI）====================

  /** 请勿打扰开关状态：与首页快捷服务共享同一份状态 */
  get dndOn(): boolean {
    return this.serviceState.doNotDisturbOn
  }

  /** 清理房间开关状态：与首页快捷服务共享同一份状态 */
  get cleanOn(): boolean {
    return this.serviceState.cleanRoomOn
  }

  // ==================== 初始化 ====================

  /**
   * 注入客房服务共享状态：由页面传入全局唯一实例，实现与首页快捷服务的双向同步
   */
  attachServiceState(store: RoomServiceStore): void {
    this.serviceState = store
  }

  // ==================== 服务开关 ====================

  /**
   * 请勿打扰开关：由开关直接回传目标状态，避免快速连点造成状态与 UI 不一致
   * 变更写入共享状态：首页「请勿打扰」快捷服务卡同步点亮 / 熄灭
   * @returns 本次操作的轻提示文案（固定文案，开启与关闭各一条；状态未变化时返回空串）
   */
  setDnd(on: boolean): string {
    if (!this.serviceState.setDoNotDisturb(on)) {
      return ''
    }
    const message: string = `${this.dndItem.label}${on ? this.tipOpened : this.tipClosed}`
    this.logger.info(message)
    return message
  }

  /**
   * 清理房间开关：同上，与首页「清理房间」快捷服务卡同步
   * @returns 本次操作的轻提示文案（固定文案，开启与关闭各一条；状态未变化时返回空串）
   */
  setClean(on: boolean): string {
    if (!this.serviceState.setCleanRoom(on)) {
      return ''
    }
    const message: string = `${this.cleanItem.label}${on ? this.tipOpened : this.tipClosed}`
    this.logger.info(message)
    return message
  }

  // ==================== SOS / 退出登录 ====================

  /**
   * SOS 紧急呼叫：仅弹出轻提示（不跳转、不对接真实报警系统）
   * @returns 本次操作的轻提示文案
   */
  requestSos(): string {
    this.logger.warn(this.sosTip)
    return this.sosTip
  }

  /**
   * 退出登录：清除本地登录期间的服务状态（两项服务回到默认关闭），
   * 路由跳转回登录页由 View 层负责（清空根栈即回到首屏登录页）
   */
  logout(): void {
    this.serviceState.reset()
    this.logger.info('退出登录：已清除本地服务状态')
  }

  /**
   * 记录轻提示异常：提示属增强反馈，失败不影响主流程
   */
  logTipFailure(reason: string): void {
    this.logger.warn(`轻提示展示失败：${reason}`)
  }
}
