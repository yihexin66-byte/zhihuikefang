/**
 * 智慧客房首页 ViewModel：状态与基础交互逻辑，零 UI
 * 页面文案、默认值、选中/开关状态全部收敛在这里，View 只负责渲染与转发事件
 */
import { Logger } from '../../../common/log/Logger'
import { HomeDefaults, HomeRouteParams, NavTabItem, SceneModeItem } from '../model/HomeModel'

@ObservedV2
export class HomeViewModel {
  // ==================== 页面文案（固定，一字不改）====================
  /** 标题「智慧客房」字号标识（图形资源，此处保留无障碍/占位文案） */
  readonly brandLabel: string = '智慧客房'
  /** 右上角标签 */
  readonly testTag: string = '开始测试'
  /** 问候语前缀：与房号组合为「欢迎回家，房号 XXXX」 */
  readonly greetingPrefix: string = '欢迎回家，'
  /** 房号前缀：与 @Trace roomNo 组合为「房号 XXXX」 */
  readonly roomPrefix: string = '房号'
  /** 空调卡片 */
  readonly airConditionerName: string = '空调'
  readonly powerOnText: string = '运行中'
  readonly powerOffText: string = '已关机'
  readonly currentTempLabel: string = '当前温度'
  readonly setTempLabel: string = '设定温度'
  /** 分区标题 */
  readonly sceneSectionTitle: string = '场景模式'
  readonly quickServiceTitle: string = '快捷服务'
  /** 快捷服务项 */
  readonly dndLabel: string = '请勿打扰'
  readonly cleanLabel: string = '清理房间'
  /** 晚安模式通栏横幅 */
  readonly nightModeLabel: string = '晚安模式'
  readonly nightBannerText: string = '一键关闭所有灯光'
  /** 轻提示后缀：场景模式 / 快捷服务 通用（卡片常亮，开启与关闭仅由轻提示反馈） */
  readonly tipOpened: string = '已开启'
  readonly tipClosed: string = '已关闭'
  /** 晚安模式轻提示（固定文案，开启与关闭各一条） */
  readonly nightModeOnTip: string = '晚安模式已开启，已关闭所有灯光'
  readonly nightModeOffTip: string = '晚安模式已关闭'
  /** 占位页文案：后续三个页面接入前的过渡态 */
  readonly underDevelopment: string = '页面开发中'

  // ==================== 固定数据（需求锁定）====================
  /** 场景模式四张卡：明亮 / 柔和 / 阅读 / 温馨 */
  readonly sceneModes: SceneModeItem[] = [
    SceneModeItem.of('bright', '明亮模式', $r('app.media.home_icon_bright')),
    SceneModeItem.of('soft', '柔和模式', $r('app.media.home_icon_soft')),
    SceneModeItem.of('read', '阅读模式', $r('app.media.home_icon_read')),
    SceneModeItem.of('warm', '温馨模式', $r('app.media.home_icon_warm'))
  ]

  /** 底部导航四项（图标暂复用已有图元，后续替换专用图标即可） */
  readonly navTabs: NavTabItem[] = [
    NavTabItem.of('首页', $r('app.media.home_icon_airconditioner')),
    NavTabItem.of('灯光', $r('app.media.home_icon_bright')),
    NavTabItem.of('窗帘', $r('app.media.home_icon_night_left')),
    NavTabItem.of('服务', $r('app.media.home_icon_clear'))
  ]

  // ==================== 页面状态（@Trace：变更实时联动 UI）====================
  /** 当前房号：来自登录页路由参数，未接收到时用保底值 */
  @Trace roomNo: string = HomeDefaults.FALLBACK_ROOM_NO
  /** 空调电源开关 */
  @Trace powerOn: boolean = HomeDefaults.POWER_ON
  /** 设定温度 */
  @Trace setTemp: number = HomeDefaults.SET_TEMP
  /** 当前选中的场景模式 id：空串表示四张卡全部未选中 */
  @Trace selectedSceneId: string = HomeDefaults.NO_SCENE
  /** 请勿打扰 */
  @Trace dndOn: boolean = HomeDefaults.QUICK_SERVICE_OFF
  /** 清理房间 */
  @Trace cleanOn: boolean = HomeDefaults.QUICK_SERVICE_OFF
  /** 晚安模式开关 */
  @Trace nightOn: boolean = HomeDefaults.QUICK_SERVICE_OFF
  /** 底部导航当前项：默认首页 */
  @Trace currentTab: number = 0

  private logger: Logger = new Logger('[HomeViewModel]')

  // ==================== 派生展示文案（读取 @Trace，变更即联动）====================

  /** 房号展示：房号 XXXX */
  get roomText(): string {
    return `${this.roomPrefix} ${this.roomNo}`
  }

  /** 空调运行状态文案：随电源开关在 运行中 / 已关机 之间联动 */
  get powerStatusText(): string {
    return this.powerOn ? this.powerOnText : this.powerOffText
  }

  /** 当前温度：只读展示，固定值不可调 */
  get currentTemp(): number {
    return HomeDefaults.CURRENT_TEMP
  }

  /** 温度区是否可用：电源关闭后整区联动置灰 */
  get tempAreaActive(): boolean {
    return this.powerOn
  }

  /** 加号可用性：关机或已到上限（30°C）即置灰不响应 */
  get canIncrease(): boolean {
    return this.powerOn && this.setTemp < HomeDefaults.TEMP_MAX
  }

  /** 减号可用性：关机或已到下限（16°C）即置灰不响应 */
  get canDecrease(): boolean {
    return this.powerOn && this.setTemp > HomeDefaults.TEMP_MIN
  }

  // ==================== 初始化 ====================

  /**
   * 读取路由参数并落地房号
   * 未接收到参数（直接启动本页调试）或参数为空时，保底展示房号 2002
   */
  applyRouteParam(param: Object | undefined): void {
    if (param instanceof HomeRouteParams) {
      const routeParams: HomeRouteParams = param as HomeRouteParams
      const passed: string = routeParams.roomNo.trim()
      if (passed !== '') {
        this.roomNo = passed
        this.logger.info(`接收路由参数：房号 ${this.roomNo}`)
        return
      }
    }
    this.roomNo = HomeDefaults.FALLBACK_ROOM_NO
    this.logger.info(`未接收到房号参数，使用保底房号 ${this.roomNo}`)
  }

  // ==================== 空调控制 ====================

  /**
   * 空调电源开关：由 Toggle 直接回传目标状态，避免快速连点造成状态与 UI 不一致
   * 状态文案与温度区可用性随状态自动联动
   */
  setPower(on: boolean): void {
    if (this.powerOn === on) {
      return
    }
    this.powerOn = on
    this.logger.info(`空调电源切换：${this.powerStatusText}`)
  }

  /**
   * 设定温度步进 ±1°C
   * 关机后不可调；步进结果越界（16°C~30°C 之外）同样不响应
   */
  stepTemp(delta: number): void {
    if (!this.powerOn) {
      this.logger.warn('空调已关机，温度不可调')
      return
    }
    const next: number = this.setTemp + delta
    if (next < HomeDefaults.TEMP_MIN || next > HomeDefaults.TEMP_MAX) {
      this.logger.warn(
        `温度已到边界（${HomeDefaults.TEMP_MIN}~${HomeDefaults.TEMP_MAX}°C），本次不响应`
      )
      return
    }
    this.setTemp = next
    this.logger.info(`设定温度调至 ${this.setTemp}°C`)
  }

  // ==================== 场景模式 / 快捷服务 / 晚安模式 ====================
  // 三处卡片均为鎏金渐变常亮、不再区分选中态，开关状态一律由轻提示文案反馈

  /**
   * 场景模式单选互斥：点击未开启的卡即开启；再次点击已开启的卡则关闭
   * @returns 本次操作的轻提示文案
   */
  toggleScene(id: string): string {
    const opening: boolean = this.selectedSceneId !== id
    this.selectedSceneId = opening ? id : HomeDefaults.NO_SCENE
    const message: string = `${this.sceneLabelOf(id)}${opening ? this.tipOpened : this.tipClosed}`
    this.logger.info(message)
    return message
  }

  /**
   * 按 id 取场景文案：用于拼接轻提示
   */
  private sceneLabelOf(id: string): string {
    for (const item of this.sceneModes) {
      if (item.id === id) {
        return item.label
      }
    }
    return ''
  }

  /**
   * 请勿打扰开关
   * @returns 本次操作的轻提示文案
   */
  toggleDnd(): string {
    this.dndOn = !this.dndOn
    const message: string = `${this.dndLabel}${this.dndOn ? this.tipOpened : this.tipClosed}`
    this.logger.info(message)
    return message
  }

  /**
   * 清理房间开关
   * @returns 本次操作的轻提示文案
   */
  toggleClean(): string {
    this.cleanOn = !this.cleanOn
    const message: string = `${this.cleanLabel}${this.cleanOn ? this.tipOpened : this.tipClosed}`
    this.logger.info(message)
    return message
  }

  /**
   * 晚安模式开关（点击后弹出轻提示，不做真实控灯）
   * @returns 本次操作的轻提示文案
   */
  toggleNightMode(): string {
    this.nightOn = !this.nightOn
    const message: string = this.nightOn ? this.nightModeOnTip : this.nightModeOffTip
    this.logger.info(message)
    return message
  }

  /**
   * 记录轻提示异常：提示属增强反馈，失败不影响主流程
   */
  logTipFailure(reason: string): void {
    this.logger.warn(`轻提示展示失败：${reason}`)
  }

  // ==================== 底部导航 ====================

  /** 切换底部导航项：重复点击当前项不做处理，避免无谓刷新 */
  switchTab(index: number): void {
    if (this.currentTab === index) {
      return
    }
    this.currentTab = index
    this.logger.info(`底部导航切换至：${index}`)
  }
}