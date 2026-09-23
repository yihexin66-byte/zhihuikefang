/**
 * 窗帘控制页数据模型（纯数据类 + 需求锁定的默认值，零业务逻辑）
 *
 * 布帘与窗纱各持一份 CurtainDevice：一台设备的「指令状态 + 动画进度 + 运行动态」自成一个
 * 可观察单元，卡片预览、圆形按钮与顶部胶囊都直接读它，任一变化实时联动。
 */

/**
 * 一路窗帘的运行动态
 * 静止 / 打开中 / 关闭中 / 已暂停：暂停是「停在中间进度」的独立状态，
 * 与静止（动画结束）区分开，才能让「暂停」按钮在暂停期间保持选中
 */
export class CurtainMotionState {
  /** 静止：未开始动画，或动画已结束 */
  static readonly IDLE: number = 0
  /** 正在打开 */
  static readonly OPENING: number = 1
  /** 正在关闭 */
  static readonly CLOSING: number = 2
  /** 已暂停：动画停在中间进度，保持当前开合程度 */
  static readonly PAUSED: number = 3
}

/**
 * 一路窗帘（布帘 / 窗纱）：需求锁定的标题与四张开合图 + 运行期状态
 *
 * @ObservedV2 + @Trace：open / progress / motion 任一变化即刷新依赖它们的视图，
 * 无需手工通知，也不用 V1 装饰器。
 */
@ObservedV2
export class CurtainDevice {
  /** 唯一标识：卡片与 ViewModel 的指令都以它寻址 */
  readonly id: string
  /** 卡片标题（布帘 / 窗纱，一字不改） */
  readonly label: string
  /** 打开态预览图：左半（316:467 等设计稿图元，收向左侧留出中缝） */
  readonly openLeft: Resource
  /** 打开态预览图：右半 */
  readonly openRight: Resource
  /** 关闭态预览图：左半（两半在中间合拢） */
  readonly closedLeft: Resource
  /** 关闭态预览图：右半 */
  readonly closedRight: Resource

  /**
   * 指令状态：true = 已下达打开指令（含正在打开），false = 已下达关闭指令
   * 顶部胶囊与圆形按钮的选中态取此值 —— 点击即刻联动，开合动画只负责视觉过渡
   */
  @Trace open: boolean = false
  /** 动画进度：0 = 完全关闭，1 = 完全打开；中间值出现在开合动画进行中与暂停之后 */
  @Trace progress: number = 0
  /** 运行动态：静止 / 打开中 / 关闭中 / 已暂停 */
  @Trace motion: number = CurtainMotionState.IDLE

  constructor(id: string, label: string, openLeft: Resource, openRight: Resource,
    closedLeft: Resource, closedRight: Resource) {
    this.id = id
    this.label = label
    this.openLeft = openLeft
    this.openRight = openRight
    this.closedLeft = closedLeft
    this.closedRight = closedRight
  }

  /** 「打开」按钮选中态：正在打开，或已静止在完全打开 */
  get openActive(): boolean {
    return this.motion === CurtainMotionState.OPENING
      || (this.motion === CurtainMotionState.IDLE && this.open)
  }

  /** 「暂停」按钮选中态：动画被暂停在中间进度 */
  get pauseActive(): boolean {
    return this.motion === CurtainMotionState.PAUSED
  }

  /** 「关闭」按钮选中态：正在关闭，或已静止在完全关闭（默认态） */
  get closeActive(): boolean {
    return this.motion === CurtainMotionState.CLOSING
      || (this.motion === CurtainMotionState.IDLE && !this.open)
  }

  /** 关闭态帘体不透明度：进度越大越淡出 */
  get closedOpacity(): number {
    return 1 - this.progress
  }

  /** 打开态帘体不透明度：与关闭态互补，两态交叉过渡不出现空档 */
  get openOpacity(): number {
    return this.progress
  }
}

/**
 * 窗帘控制页固定参数（需求锁定，请勿改动）
 */
export class CurtainDefaults {
  /** 布帘 id */
  static readonly CURTAIN_ID: string = 'curtain'
  /** 窗纱 id */
  static readonly SHEER_ID: string = 'sheer'

  /** 完全关闭（帘体两半在中间合拢） */
  static readonly FULLY_CLOSED: number = 0
  /** 完全打开（帘体两半收向两侧，中间留缝） */
  static readonly FULLY_OPEN: number = 1

  /** 顶部两个胶囊默认均未选中 */
  static readonly MODE_SELECTED_OFF: boolean = false
  /** 布帘与窗纱默认状态：关闭 */
  static readonly DEFAULT_OPEN: boolean = false
  /** 默认动画进度：完全关闭 */
  static readonly DEFAULT_PROGRESS: number = CurtainDefaults.FULLY_CLOSED

  /**
   * 创建布帘：标题与四张开合图取自第 4 屏设计稿
   * 打开态为收拢的褶皱帘（curtain_icon_left/right_part），关闭态为平铺帘（curtain_icon_left/right_closed）
   */
  static createCurtain(): CurtainDevice {
    return new CurtainDevice(CurtainDefaults.CURTAIN_ID, '布帘',
      $r('app.media.curtain_icon_left_part'),
      $r('app.media.curtain_icon_right_part'),
      $r('app.media.curtain_icon_left_closed'),
      $r('app.media.curtain_icon_right_closed'))
  }

  /**
   * 创建窗纱：与布帘同一套开合逻辑，仅图元换成纱帘
   * 打开态为 curtain_icon_window_screening_left/right_part，关闭态为 left/right_part_closed
   */
  static createSheer(): CurtainDevice {
    return new CurtainDevice(CurtainDefaults.SHEER_ID, '窗纱',
      $r('app.media.curtain_icon_window_screening_left_part'),
      $r('app.media.curtain_icon_window_screening_right_part'),
      $r('app.media.curtain_icon_window_screening_left_part_closed'),
      $r('app.media.curtain_icon_window_screening_right_part_closed'))
  }
}
