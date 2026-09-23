/**
 * 客房服务共享状态（跨页唯一的服务开关数据源）
 *
 * 智慧客房首页「快捷服务」与服务控制页共用同一个实例：
 *  1. 请勿打扰：服务页开关开启 → 首页对应快捷服务卡同步点亮，反之亦然；
 *  2. 清理房间：同上，两页读写同一份状态；
 *  3. 退出登录时统一复位，保证下一个账号入住时两项服务均为关闭态。
 *
 * @ObservedV2 + @Trace：View 直接读取 doNotDisturbOn / cleanRoomOn 即建立依赖，
 * 任一页变更另一页自动刷新，无需手工通知。
 */
import { RoomServiceDefaults } from '../model/RoomServiceModel'

@ObservedV2
export class RoomServiceStore {
  /** 全局共享实例（延迟创建） */
  private static sharedInstance: RoomServiceStore | undefined = undefined

  /** 请勿打扰：默认关闭 */
  @Trace doNotDisturbOn: boolean = RoomServiceDefaults.SERVICE_OFF

  /** 清理房间：默认关闭 */
  @Trace cleanRoomOn: boolean = RoomServiceDefaults.SERVICE_OFF

  /**
   * 取全局共享实例：应用运行期两页拿到的是同一个对象
   */
  static getShared(): RoomServiceStore {
    if (RoomServiceStore.sharedInstance === undefined) {
      RoomServiceStore.sharedInstance = new RoomServiceStore()
    }
    return RoomServiceStore.sharedInstance
  }

  /**
   * 请勿打扰开关：由开关回传目标状态，避免快速连点造成状态与 UI 不一致
   * @returns true 表示本次状态确有变化
   */
  setDoNotDisturb(on: boolean): boolean {
    if (this.doNotDisturbOn === on) {
      return false
    }
    this.doNotDisturbOn = on
    return true
  }

  /**
   * 清理房间开关：同上
   * @returns true 表示本次状态确有变化
   */
  setCleanRoom(on: boolean): boolean {
    if (this.cleanRoomOn === on) {
      return false
    }
    this.cleanRoomOn = on
    return true
  }

  /** 复位两项服务：退出登录时清除本地登录期间的服务状态 */
  reset(): void {
    this.doNotDisturbOn = RoomServiceDefaults.SERVICE_OFF
    this.cleanRoomOn = RoomServiceDefaults.SERVICE_OFF
  }
}
