/**
 * 窗帘控制页 ViewModel：页面文案、布帘 / 窗纱状态、开合动画进度与交互入口，零 UI
 *
 * 分层职责：
 *  1. 文案与默认值全部收敛在这里，View 只渲染、只转发点击；
 *  2. 每台设备的指令状态、动画进度、运行动态由 View 层直接读取并渲染；
 *  3. 开合动画的「进度推进」也由本层持有：页面在 aboutToAppear 注入动画驱动器
 *     （内部用 UIContext.createAnimator 创建真实动画对象），驱动器逐帧回调 applyFrame、
 *     结束时回调 finishMotion —— 因此暂停只需停止推进进度，天然「保持当前状态」。
 *
 * 顶部胶囊的选中态取「指令状态」而非动画进度：点击即刻选中，动画只负责视觉过渡；
 * 布帘与窗纱均下达打开指令则「全部打开」选中，均下达关闭指令则「全部关闭」选中，
 * 一开一关的混合状态两个胶囊都不选中。
 */
import { AnimatorOptions, AnimatorResult } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { Logger } from '../../../common/log/Logger'
import { CurtainDefaults, CurtainDevice, CurtainMotionState } from '../model/CurtainModel'

/**
 * 动画驱动器工厂：把 UIContext 的动画能力移交给 ViewModel
 * 单测不注入时，指令直接落到目标进度，状态机仍可完整验证
 */
export type CurtainAnimatorFactory = (options: AnimatorOptions) => AnimatorResult

@ObservedV2
export class CurtainViewModel {
  // ==================== 页面文案（固定，一字不改）====================
  /** 页面标题 */
  readonly pageTitle: string = '窗帘控制'
  /** 顶部两个胶囊 */
  readonly modeOpenLabel: string = '全部打开'
  readonly modeCloseLabel: string = '全部关闭'
  /** 卡片内三个圆形按钮 */
  readonly btnOpenLabel: string = '打开'
  readonly btnPauseLabel: string = '暂停'
  readonly btnCloseLabel: string = '关闭'

  // ==================== 固定数据（需求锁定）====================
  /** 布帘：默认关闭 */
  readonly curtain: CurtainDevice = CurtainDefaults.createCurtain()
  /** 窗纱：默认关闭 */
  readonly sheer: CurtainDevice = CurtainDefaults.createSheer()

  /** 动画驱动器：由页面注入；未注入时（单测）指令直接落到目标进度 */
  private animatorFactory: CurtainAnimatorFactory | undefined = undefined
  /** 每台设备当前在跑的动画对象，暂停与重新下达指令时按 id 取用 */
  private readonly animators: Map<string, AnimatorResult> = new Map<string, AnimatorResult>()

  private logger: Logger = new Logger('[CurtainViewModel]')

  // ==================== 顶部胶囊选中态（综合两台设备的指令状态）====================

  /** 「全部打开」选中态：布帘与窗纱均已下达打开指令 */
  get allOpenSelected(): boolean {
    return this.curtain.open && this.sheer.open
  }

  /** 「全部关闭」选中态：布帘与窗纱均已下达关闭指令（默认态） */
  get allClosedSelected(): boolean {
    return !this.curtain.open && !this.sheer.open
  }

  // ==================== 初始化 ====================

  /**
   * 注入动画驱动器：由页面在 aboutToAppear 中传入
   * 延迟到点击时才创建动画对象，确保此时页面已经挂载、UIContext 可用
   */
  bindAnimatorFactory(factory: CurtainAnimatorFactory): void {
    this.animatorFactory = factory
  }

  // ==================== 顶部胶囊：同时控制布帘与窗纱 ====================

  /**
   * 全部打开：布帘与窗纱同时执行打开动画，胶囊切换为「全部打开」选中态
   */
  openAll(): void {
    this.moveTo(CurtainDefaults.FULLY_OPEN, true)
  }

  /**
   * 全部关闭：布帘与窗纱同时执行关闭动画，胶囊切换为「全部关闭」选中态
   */
  closeAll(): void {
    this.moveTo(CurtainDefaults.FULLY_CLOSED, false)
  }

  // ==================== 卡片内：单台设备的打开 / 暂停 / 关闭 ====================

  /**
   * 打开：下达打开指令并驱动开合动画
   * 已完全打开且无动画在跑时重复点击不再执行，避免无谓刷新
   */
  open(id: string): void {
    const device: CurtainDevice | undefined = this.findDevice(id)
    if (device === undefined) {
      this.logger.warn(`未找到窗帘设备：${id}`)
      return
    }
    if (device.open && device.motion === CurtainMotionState.IDLE
      && device.progress >= CurtainDefaults.FULLY_OPEN) {
      return
    }
    this.moveToDevice(device, CurtainDefaults.FULLY_OPEN, true)
  }

  /**
   * 关闭：下达关闭指令并驱动开合动画
   * 已完全关闭且无动画在跑时重复点击不再执行
   */
  close(id: string): void {
    const device: CurtainDevice | undefined = this.findDevice(id)
    if (device === undefined) {
      this.logger.warn(`未找到窗帘设备：${id}`)
      return
    }
    if (!device.open && device.motion === CurtainMotionState.IDLE
      && device.progress <= CurtainDefaults.FULLY_CLOSED) {
      return
    }
    this.moveToDevice(device, CurtainDefaults.FULLY_CLOSED, false)
  }

  /**
   * 暂停：立即停止正在进行的打开或关闭动画，并保持当前开合进度
   * 已静止时不做任何改变（当前状态本就被保持），指令状态也不回退
   * @returns true 表示确实暂停了一个进行中的动画
   */
  pause(id: string): boolean {
    const device: CurtainDevice | undefined = this.findDevice(id)
    if (device === undefined) {
      this.logger.warn(`未找到窗帘设备：${id}`)
      return false
    }
    if (device.motion !== CurtainMotionState.OPENING
      && device.motion !== CurtainMotionState.CLOSING) {
      this.logger.info(`${device.label}当前无进行中的开合动作，保持当前状态`)
      return false
    }
    const animator: AnimatorResult | undefined = this.animators.get(device.id)
    if (animator !== undefined) {
      // 停止推进进度：后续不再有帧回调，帘体停在当前位置
      animator.pause()
    }
    device.motion = CurtainMotionState.PAUSED
    this.logger.info(`${device.label}已暂停，保持当前开合进度`)
    return true
  }

  // ==================== 动画驱动器回调（帧推进 / 结束）====================

  /**
   * 动画帧回调：由驱动器逐帧上报进度，驱动帘体位置与不透明度实时刷新
   * 只在打开中 / 关闭中生效，暂停后与结束后的迟到帧一律忽略，保证进度不被改写
   */
  applyFrame(id: string, progress: number): void {
    const device: CurtainDevice | undefined = this.findDevice(id)
    if (device === undefined) {
      return
    }
    if (device.motion !== CurtainMotionState.OPENING
      && device.motion !== CurtainMotionState.CLOSING) {
      return
    }
    device.progress = this.clampProgress(progress)
  }

  /**
   * 动画结束回调：落到目标进度并回到静止，圆形按钮选中态随之定格
   */
  finishMotion(id: string): void {
    const device: CurtainDevice | undefined = this.findDevice(id)
    if (device === undefined) {
      return
    }
    if (device.motion !== CurtainMotionState.OPENING
      && device.motion !== CurtainMotionState.CLOSING) {
      return
    }
    device.progress = device.motion === CurtainMotionState.OPENING
      ? CurtainDefaults.FULLY_OPEN
      : CurtainDefaults.FULLY_CLOSED
    device.motion = CurtainMotionState.IDLE
    this.animators.delete(id)
    this.logger.info(`${device.label}开合完成`)
  }

  /**
   * 释放全部动画：页面卸载时调用，避免动画继续推进已卸载的视图
   * 按「暂停」语义收尾：停在当前进度，且此后的迟到帧一律被忽略
   */
  releaseAnimators(): void {
    this.cancelAnimator(this.curtain)
    this.cancelAnimator(this.sheer)
  }

  // ==================== 内部实现 ====================

  /** 顶部胶囊：对布帘与窗纱同时下达同一条指令 */
  private moveTo(target: number, open: boolean): void {
    this.moveToDevice(this.curtain, target, open)
    this.moveToDevice(this.sheer, target, open)
  }

  /** 对单台设备下达指令并驱动开合动画 */
  private moveToDevice(device: CurtainDevice, target: number, open: boolean): void {
    device.open = open
    this.startMotion(device, target)
    this.logger.info(`${device.label}${open ? '打开' : '关闭'}，目标进度 ${target}`)
  }

  /**
   * 驱动开合动画：从当前进度缓缓过渡到目标进度
   * 暂停后再次下达指令时，会从暂停处的进度续跑，而不是从两端重新开始
   */
  private startMotion(device: CurtainDevice, target: number): void {
    // 同一台设备上仍在跑的动画先收尾，避免两条动画同时改写进度
    this.cancelAnimator(device)
    const from: number = this.clampProgress(device.progress)
    device.progress = from
    if (from === target) {
      device.motion = CurtainMotionState.IDLE
      return
    }
    device.motion = target > from ? CurtainMotionState.OPENING : CurtainMotionState.CLOSING

    const factory: CurtainAnimatorFactory | undefined = this.animatorFactory
    if (factory === undefined) {
      // 无驱动器（单测环境）：直接落到目标进度，状态机行为保持一致
      device.progress = target
      device.motion = CurtainMotionState.IDLE
      return
    }

    const options: AnimatorOptions = {
      duration: CommonConstants.CURTAIN_MOTION_DURATION,
      easing: 'ease-in-out',
      delay: 0,
      fill: 'forwards',
      direction: 'normal',
      iterations: 1,
      begin: from,
      end: target
    }
    try {
      const animator: AnimatorResult = factory(options)
      animator.onFrame = (value: number) => {
        this.applyFrame(device.id, value)
      }
      animator.onFinish = () => {
        this.finishMotion(device.id)
      }
      this.animators.set(device.id, animator)
      animator.play()
    } catch (err) {
      // 动画属视觉增强：不可用时直接落到目标进度，保证打开 / 关闭功能本身可用
      const error = err as BusinessError
      this.logger.warn(`开合动画启动失败，直接落到目标进度：${error.code} ${error.message}`)
      device.progress = target
      device.motion = CurtainMotionState.IDLE
    }
  }

  /** 取消并丢弃指定设备上的动画对象 */
  private cancelAnimator(device: CurtainDevice): void {
    const animator: AnimatorResult | undefined = this.animators.get(device.id)
    if (animator === undefined) {
      return
    }
    animator.cancel()
    this.animators.delete(device.id)
    // 动画被打断即按暂停处理：保持当前进度，且不再接受后续帧
    if (device.motion === CurtainMotionState.OPENING
      || device.motion === CurtainMotionState.CLOSING) {
      device.motion = CurtainMotionState.PAUSED
    }
  }

  /** 进度收敛到 [0, 1]：缓动函数可能产生极小的越界值 */
  private clampProgress(progress: number): number {
    if (progress < CurtainDefaults.FULLY_CLOSED) {
      return CurtainDefaults.FULLY_CLOSED
    }
    if (progress > CurtainDefaults.FULLY_OPEN) {
      return CurtainDefaults.FULLY_OPEN
    }
    return progress
  }

  /** 按 id 取设备：未命中返回 undefined，由调用方窄化 */
  private findDevice(id: string): CurtainDevice | undefined {
    if (id === this.curtain.id) {
      return this.curtain
    }
    if (id === this.sheer.id) {
      return this.sheer
    }
    return undefined
  }
}
