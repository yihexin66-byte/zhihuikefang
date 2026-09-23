/**
 * 灯光控制页 ViewModel：页面文案与交互入口，零 UI
 * 灯光与场景的真实状态由跨页共享的 RoomStateStore 持有（首页场景卡读写同一份数据），
 * 本 ViewModel 只做文案拼接与事件转发：场景选中、总开关、9 路开关全部下沉到共享状态。
 */
import { Logger } from '../../../common/log/Logger'
import { RoomLightDefaults } from '../../../common/model/RoomLightModel'
import { RoomStateStore } from '../../../common/state/RoomStateStore'
import { LightSceneItem } from '../model/LightModel'

@ObservedV2
export class LightViewModel {
  // ==================== 页面文案（固定，一字不改）====================
  /** 页面标题 */
  readonly pageTitle: string = '灯光控制'
  /** 总开关名称与状态文案（关闭 → 全开；开启 → 全关） */
  readonly mainSwitchLabel: string = '总开关'
  readonly mainSwitchOnText: string = '全开'
  readonly mainSwitchOffText: string = '全关'
  /** 分区标题 */
  readonly sceneSectionTitle: string = '场景模式'
  readonly controlSectionTitle: string = '独立控制'
  /** 场景轻提示后缀（与首页场景模式同一套反馈文案） */
  readonly tipOpened: string = '已开启'
  readonly tipClosed: string = '已关闭'

  // ==================== 固定数据（需求锁定）====================
  /**
   * 场景模式五项：明亮 / 柔和 / 阅读 / 温馨 与首页同名卡双向同步
   * 睡眠模式为灯光页独有，选中时首页四张卡均不选中
   */
  readonly scenes: LightSceneItem[] = [
    LightSceneItem.of('bright', '明亮模式', $r('app.media.light_icon_bright_mode')),
    LightSceneItem.of('soft', '柔和模式', $r('app.media.light_icon_soft')),
    LightSceneItem.of('read', '阅读模式', $r('app.media.light_icon_read_mode')),
    LightSceneItem.of('warm', '温馨模式', $r('app.media.light_icon_warm_mode')),
    LightSceneItem.of(RoomLightDefaults.SCENE_SLEEP, '睡眠模式', $r('app.media.light_icon_sleep_mode'))
  ]

  /**
   * 客房共享状态：默认自有实例（保证单测隔离）
   * 页面 aboutToAppear 注入全局共享实例后，与首页场景卡、9 路开关双向同步
   */
  roomState: RoomStateStore = new RoomStateStore()

  private logger: Logger = new Logger('[LightViewModel]')

  // ==================== 派生展示文案 ====================

  /** 总开关状态：读取共享状态 */
  get mainSwitchOn(): boolean {
    return this.roomState.mainSwitchOn
  }

  /** 总开关状态文案：全开 / 全关 */
  get mainSwitchStateText(): string {
    return this.roomState.mainSwitchOn ? this.mainSwitchOnText : this.mainSwitchOffText
  }

  // ==================== 初始化 ====================

  /**
   * 注入客房共享状态：由页面传入全局唯一实例，实现与首页的双向同步
   */
  attachRoomState(store: RoomStateStore): void {
    this.roomState = store
  }

  // ==================== 总开关与独立开关（下沉到共享状态）====================

  /**
   * 总开关点击：关闭则全开所有独立灯光，开启则全关所有独立灯光
   */
  toggleMainSwitch(): void {
    this.roomState.toggleMainSwitch()
    this.logger.info(`总开关切换：${this.mainSwitchStateText}`)
  }

  /**
   * 单路开关：由开关回传目标状态，联动逻辑（含总开关）在共享状态内统一处理
   */
  setControl(id: string, on: boolean): void {
    this.roomState.setControl(id, on)
  }

  // ==================== 场景模式 ====================

  /**
   * 场景胶囊单选互斥：点击未选中项即选中，再次点击已选中项则取消
   * 选中 / 取消均联动对应独立开关（睡眠模式为关闭全部灯光）
   * @returns 本次操作的轻提示文案
   */
  toggleScene(id: string): string {
    const opening: boolean = this.roomState.toggleScene(id)
    const message: string = `${this.sceneLabelOf(id)}${opening ? this.tipOpened : this.tipClosed}`
    this.logger.info(message)
    return message
  }

  /** 按 id 取场景文案：用于拼接轻提示 */
  private sceneLabelOf(id: string): string {
    for (const item of this.scenes) {
      if (item.id === id) {
        return item.label
      }
    }
    return ''
  }

  /**
   * 记录轻提示异常：提示属增强反馈，失败不影响主流程
   */
  logTipFailure(reason: string): void {
    this.logger.warn(`轻提示展示失败：${reason}`)
  }
}