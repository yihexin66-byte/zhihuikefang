/**
 * 窗帘控制页 ViewModel 单元测试
 * 覆盖：默认状态与固定文案、打开 / 关闭动画的指令与进度推进、暂停保持当前进度且可续跑、
 *       顶部胶囊 «全部打开 / 全部关闭» 对布帘与窗纱的同时控制、单台设备操作后的胶囊联动、
 *       动画结束 / 释放 / 进度收敛等边界。
 *
 * 动画驱动器在测试里替换为 FakeAnimator：由用例手动推帧与结束动画，
 * 从而验证「进度由 ViewModel 持有、暂停即停止推进」这一核心行为。
 */
import { describe, it, expect } from '@ohos/hypium'
import { AnimatorOptions, AnimatorResult, SimpleAnimatorOptions } from '@kit.ArkUI'
import { CommonConstants } from '../main/ets/common/constants/CommonConstants'
import { CurtainDefaults, CurtainDevice, CurtainMotionState } from '../main/ets/features/curtain/model/CurtainModel'
import { CurtainAnimatorFactory, CurtainViewModel } from '../main/ets/features/curtain/viewModel/CurtainViewModel'

/**
 * 统计一台设备上处于选中态的圆形按钮数量
 * 打开 / 暂停 / 关闭三态互斥，任何时刻都应恰好为 1
 */
function activeCount(openActive: boolean, pauseActive: boolean, closeActive: boolean): number {
  let count: number = 0
  if (openActive) {
    count++
  }
  if (pauseActive) {
    count++
  }
  if (closeActive) {
    count++
  }
  return count
}

/**
 * 假动画对象：实现 AnimatorResult，但不自行推进进度
 * 用例通过 emitFrame / emitFinish 手动驱动，等价于真实动画的帧回调与结束回调
 */
class FakeAnimator implements AnimatorResult {
  /** 最近一次收到的播放配置（起始 / 目标进度、时长） */
  lastOptions: AnimatorOptions | undefined = undefined
  playCount: number = 0
  pauseCount: number = 0
  cancelCount: number = 0

  update(options: AnimatorOptions): void {
    this.lastOptions = options
  }

  reset(options: AnimatorOptions | SimpleAnimatorOptions): void {
  }

  play(): void {
    this.playCount++
  }

  finish(): void {
  }

  pause(): void {
    this.pauseCount++
  }

  cancel(): void {
    this.cancelCount++
  }

  reverse(): void {
  }

  setExpectedFrameRateRange(rateRange: ExpectedFrameRateRange): void {
  }

  onframe: (progress: number) => void = () => {}
  onFrame: (progress: number) => void = () => {}
  onfinish: () => void = () => {}
  onFinish: () => void = () => {}
  oncancel: () => void = () => {}
  onCancel: () => void = () => {}
  onrepeat: () => void = () => {}
  onRepeat: () => void = () => {}

  /** 推一帧 */
  emitFrame(progress: number): void {
    this.onFrame(progress)
  }

  /** 结束动画 */
  emitFinish(): void {
    this.onFinish()
  }
}

/**
 * 动画驱动器夹具：记录最近一次创建的动画对象，供用例推帧
 */
class AnimatorFixture {
  last: FakeAnimator | undefined = undefined
  /** 本次用例创建过的全部动画对象（顶部胶囊会同时驱动两台设备） */
  readonly all: FakeAnimator[] = []
  created: number = 0
  readonly factory: CurtainAnimatorFactory

  constructor() {
    this.factory = (options: AnimatorOptions) => {
      const animator: FakeAnimator = new FakeAnimator()
      animator.lastOptions = options
      this.last = animator
      this.all.push(animator)
      this.created = this.created + 1
      return animator
    }
  }

  /** 推一帧到最近创建的动画 */
  frame(progress: number): void {
    const animator: FakeAnimator | undefined = this.last
    if (animator !== undefined) {
      animator.emitFrame(progress)
    }
  }

  /** 结束最近创建的动画 */
  finish(): void {
    const animator: FakeAnimator | undefined = this.last
    if (animator !== undefined) {
      animator.emitFinish()
    }
  }

  /** 推一帧到全部动画：两台设备同时开合时使用 */
  frameAll(progress: number): void {
    for (const animator of this.all) {
      animator.emitFrame(progress)
    }
  }

  /** 结束全部动画 */
  finishAll(): void {
    for (const animator of this.all) {
      animator.emitFinish()
    }
  }

  /** 最近一次动画的起始进度：无动画时返回 -1 */
  begin(): number {
    const animator: FakeAnimator | undefined = this.last
    if (animator === undefined || animator.lastOptions === undefined) {
      return -1
    }
    return animator.lastOptions.begin
  }

  /** 最近一次动画的目标进度：无动画时返回 -1 */
  end(): number {
    const animator: FakeAnimator | undefined = this.last
    if (animator === undefined || animator.lastOptions === undefined) {
      return -1
    }
    return animator.lastOptions.end
  }

  /** 最近一次动画的完整配置：无动画时返回 undefined */
  options(): AnimatorOptions | undefined {
    const animator: FakeAnimator | undefined = this.last
    if (animator === undefined) {
      return undefined
    }
    return animator.lastOptions
  }
}

export default function curtainViewModelTest() {
  describe('CurtainViewModelTest', () => {
    // ==================== 默认状态与固定文案 ====================

    it('默认状态_顶部胶囊均未选中_布帘与窗纱均关闭', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      expect(viewModel.allOpenSelected).assertFalse()
      expect(viewModel.allClosedSelected).assertTrue()

      expect(viewModel.curtain.open).assertFalse()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.IDLE)

      expect(viewModel.sheer.open).assertFalse()
      expect(viewModel.sheer.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(viewModel.sheer.motion).assertEqual(CurtainMotionState.IDLE)
    })

    it('默认状态_圆形按钮选中态为关闭', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      expect(viewModel.curtain.openActive).assertFalse()
      expect(viewModel.curtain.pauseActive).assertFalse()
      expect(viewModel.curtain.closeActive).assertTrue()
      expect(viewModel.curtain.closedOpacity).assertEqual(1)
      expect(viewModel.curtain.openOpacity).assertEqual(0)
    })

    it('页面文案固定', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      expect(viewModel.pageTitle).assertEqual('窗帘控制')
      expect(viewModel.modeOpenLabel).assertEqual('全部打开')
      expect(viewModel.modeCloseLabel).assertEqual('全部关闭')
      expect(viewModel.btnOpenLabel).assertEqual('打开')
      expect(viewModel.btnPauseLabel).assertEqual('暂停')
      expect(viewModel.btnCloseLabel).assertEqual('关闭')
    })

    it('卡片标题与设备标识固定', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      expect(viewModel.curtain.label).assertEqual('布帘')
      expect(viewModel.curtain.id).assertEqual(CurtainDefaults.CURTAIN_ID)
      expect(viewModel.sheer.label).assertEqual('窗纱')
      expect(viewModel.sheer.id).assertEqual(CurtainDefaults.SHEER_ID)
    })

    it('异常_未知设备id_不响应也不改变任何状态', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      viewModel.open('unknown')
      viewModel.close('unknown')
      const paused: boolean = viewModel.pause('unknown')

      expect(paused).assertFalse()
      expect(viewModel.allClosedSelected).assertTrue()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
    })

    // ==================== 打开 / 关闭动画 ====================

    it('打开_下达指令即选中打开按钮_动画从完全关闭到完全打开', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)

      expect(viewModel.curtain.open).assertTrue()
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.OPENING)
      expect(viewModel.curtain.openActive).assertTrue()
      expect(viewModel.curtain.closeActive).assertFalse()
      expect(fixture.created).assertEqual(1)
      expect(fixture.begin()).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(fixture.end()).assertEqual(CurtainDefaults.FULLY_OPEN)
      expect(fixture.last?.playCount).assertEqual(1)
      // 只影响被点的那一路，窗纱不受牵连
      expect(viewModel.sheer.open).assertFalse()
    })

    it('打开_逐帧推进_进度跟随帧回调', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.25)
      expect(viewModel.curtain.progress).assertEqual(0.25)
      expect(viewModel.curtain.openOpacity).assertEqual(0.25)
      expect(viewModel.curtain.closedOpacity).assertEqual(0.75)

      fixture.frame(0.8)
      expect(viewModel.curtain.progress).assertEqual(0.8)
    })

    it('打开_动画结束_落到完全打开并回到静止', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.6)
      fixture.finish()

      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_OPEN)
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.IDLE)
      expect(viewModel.curtain.openActive).assertTrue()
      expect(viewModel.curtain.closeActive).assertFalse()
    })

    it('关闭_从完全打开收起_动画从完全打开到完全关闭', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(1)
      fixture.finish()

      viewModel.close(CurtainDefaults.CURTAIN_ID)

      expect(viewModel.curtain.open).assertFalse()
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.CLOSING)
      expect(viewModel.curtain.closeActive).assertTrue()
      expect(viewModel.curtain.openActive).assertFalse()
      expect(fixture.begin()).assertEqual(CurtainDefaults.FULLY_OPEN)
      expect(fixture.end()).assertEqual(CurtainDefaults.FULLY_CLOSED)

      fixture.frame(0.3)
      expect(viewModel.curtain.progress).assertEqual(0.3)
      fixture.finish()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.IDLE)
    })

    it('打开_已完全打开时重复点击_不再新建动画', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(1)
      fixture.finish()
      viewModel.open(CurtainDefaults.CURTAIN_ID)

      expect(fixture.created).assertEqual(1)
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_OPEN)
    })

    it('关闭_已完全关闭时重复点击_不再新建动画', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.close(CurtainDefaults.CURTAIN_ID)

      expect(fixture.created).assertEqual(0)
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
    })

    it('无动画驱动器_指令直接落到目标进度_状态机行为一致', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      viewModel.open(CurtainDefaults.SHEER_ID)

      expect(viewModel.sheer.open).assertTrue()
      expect(viewModel.sheer.progress).assertEqual(CurtainDefaults.FULLY_OPEN)
      expect(viewModel.sheer.motion).assertEqual(CurtainMotionState.IDLE)
      expect(viewModel.sheer.openActive).assertTrue()
    })

    // ==================== 暂停：停止推进并保持当前进度 ====================

    it('暂停_打开进行中_停在当前进度且暂停按钮选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.4)
      const paused: boolean = viewModel.pause(CurtainDefaults.CURTAIN_ID)

      expect(paused).assertTrue()
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.PAUSED)
      expect(viewModel.curtain.progress).assertEqual(0.4)
      expect(viewModel.curtain.pauseActive).assertTrue()
      // 暂停不是静止：打开与关闭按钮都不再选中，选中态始终唯一
      expect(viewModel.curtain.openActive).assertFalse()
      expect(viewModel.curtain.closeActive).assertFalse()
      expect(fixture.last?.pauseCount).assertEqual(1)
    })

    it('暂停_后续迟到帧_进度不被改写', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.4)
      viewModel.pause(CurtainDefaults.CURTAIN_ID)

      fixture.frame(0.9)
      expect(viewModel.curtain.progress).assertEqual(0.4)
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.PAUSED)
    })

    it('暂停_关闭进行中_同样停在当前进度', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(1)
      fixture.finish()

      viewModel.close(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.7)
      viewModel.pause(CurtainDefaults.CURTAIN_ID)

      expect(viewModel.curtain.progress).assertEqual(0.7)
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.PAUSED)
      expect(viewModel.curtain.pauseActive).assertTrue()
    })

    it('暂停_再次打开_从暂停处续跑而非从两端重启', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.4)
      viewModel.pause(CurtainDefaults.CURTAIN_ID)

      viewModel.open(CurtainDefaults.CURTAIN_ID)

      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.OPENING)
      expect(viewModel.curtain.progress).assertEqual(0.4)
      expect(fixture.begin()).assertEqual(0.4)
      expect(fixture.end()).assertEqual(CurtainDefaults.FULLY_OPEN)
      expect(fixture.created).assertEqual(2)

      fixture.frame(1)
      fixture.finish()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_OPEN)
    })

    it('暂停_无进行中的动作_保持当前状态且返回false', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      const paused: boolean = viewModel.pause(CurtainDefaults.CURTAIN_ID)

      expect(paused).assertFalse()
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.IDLE)
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(viewModel.curtain.closeActive).assertTrue()
    })

    it('静止状态_动画帧回调_进度不被改写', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      viewModel.applyFrame(CurtainDefaults.CURTAIN_ID, 0.5)

      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
    })

    it('动画帧_越界进度_收敛到0到1之间', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(-0.2)
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)

      fixture.frame(1.3)
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_OPEN)
    })

    it('释放动画_取消在跑的动画对象且后续帧不生效', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.3)
      viewModel.releaseAnimators()

      expect(fixture.last?.cancelCount).assertEqual(1)
      // 释放按暂停语义收尾：保留当前进度，不再接受后续帧
      expect(viewModel.curtain.progress).assertEqual(0.3)
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.PAUSED)

      fixture.frame(0.9)
      expect(viewModel.curtain.progress).assertEqual(0.3)
    })

    // ==================== 顶部胶囊：同时控制布帘与窗纱 ====================

    it('全部打开_布帘与窗纱同时打开_胶囊切换为全部打开选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.openAll()

      expect(viewModel.allOpenSelected).assertTrue()
      expect(viewModel.allClosedSelected).assertFalse()
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.OPENING)
      expect(viewModel.sheer.motion).assertEqual(CurtainMotionState.OPENING)

      fixture.frameAll(1)
      fixture.finishAll()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_OPEN)
      expect(viewModel.sheer.progress).assertEqual(CurtainDefaults.FULLY_OPEN)
    })

    it('全部关闭_布帘与窗纱同时关闭_胶囊切换为全部关闭选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.openAll()
      fixture.frameAll(1)
      fixture.finishAll()

      viewModel.closeAll()

      expect(viewModel.allClosedSelected).assertTrue()
      expect(viewModel.allOpenSelected).assertFalse()
      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.CLOSING)
      expect(viewModel.sheer.motion).assertEqual(CurtainMotionState.CLOSING)

      fixture.frameAll(0)
      fixture.finishAll()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(viewModel.sheer.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
    })

    it('全部关闭_默认态下点击_两台设备均无动画可跑且胶囊保持选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.closeAll()

      expect(fixture.created).assertEqual(0)
      expect(viewModel.allClosedSelected).assertTrue()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
    })

    // ==================== 单独操作后的胶囊联动 ====================

    it('单独打开布帘_混合状态_两个胶囊均不选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      viewModel.open(CurtainDefaults.CURTAIN_ID)

      expect(viewModel.curtain.open).assertTrue()
      expect(viewModel.sheer.open).assertFalse()
      expect(viewModel.allOpenSelected).assertFalse()
      expect(viewModel.allClosedSelected).assertFalse()
    })

    it('先开布帘再开窗纱_两者齐开_胶囊联动为全部打开', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      expect(viewModel.allOpenSelected).assertFalse()

      viewModel.open(CurtainDefaults.SHEER_ID)

      expect(viewModel.allOpenSelected).assertTrue()
      expect(viewModel.allClosedSelected).assertFalse()
    })

    it('全部打开后单独关闭窗纱_混合状态_两个胶囊均不选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      viewModel.openAll()
      expect(viewModel.allOpenSelected).assertTrue()

      viewModel.close(CurtainDefaults.SHEER_ID)

      expect(viewModel.curtain.open).assertTrue()
      expect(viewModel.sheer.open).assertFalse()
      expect(viewModel.allOpenSelected).assertFalse()
      expect(viewModel.allClosedSelected).assertFalse()
    })

    it('两者全开后逐个关闭_只在全部关闭时才联动为全部关闭', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      viewModel.openAll()
      viewModel.close(CurtainDefaults.CURTAIN_ID)
      expect(viewModel.allClosedSelected).assertFalse()
      expect(viewModel.allOpenSelected).assertFalse()

      viewModel.close(CurtainDefaults.SHEER_ID)
      expect(viewModel.allClosedSelected).assertTrue()
    })

    it('暂停不改变指令状态_两台设备均暂停后胶囊仍反映最后一次指令', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.openAll()
      fixture.frameAll(0.35)

      expect(viewModel.pause(CurtainDefaults.CURTAIN_ID)).assertTrue()
      expect(viewModel.pause(CurtainDefaults.SHEER_ID)).assertTrue()

      expect(viewModel.allOpenSelected).assertTrue()
      expect(viewModel.curtain.progress).assertEqual(0.35)
      expect(viewModel.sheer.progress).assertEqual(0.35)
      expect(viewModel.curtain.pauseActive).assertTrue()
      expect(viewModel.sheer.pauseActive).assertTrue()
    })

    // ==================== 布帘与窗纱相互独立 ====================

    it('两台设备互不干扰_仅操作布帘时窗纱保持关闭', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.5)

      expect(viewModel.curtain.progress).assertEqual(0.5)
      expect(viewModel.sheer.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(viewModel.sheer.motion).assertEqual(CurtainMotionState.IDLE)
    })

    it('两台设备各自独立推进进度', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      viewModel.open(CurtainDefaults.SHEER_ID)
      viewModel.applyFrame(CurtainDefaults.CURTAIN_ID, 0.3)
      viewModel.applyFrame(CurtainDefaults.SHEER_ID, 0.9)

      expect(viewModel.curtain.progress).assertEqual(0.3)
      expect(viewModel.sheer.progress).assertEqual(0.9)
    })

    // ==================== 动画配置与状态不变式 ====================

    it('动画配置_时长与缓动取自固定参数_缓缓过渡', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      const options: AnimatorOptions | undefined = fixture.options()

      expect(options?.duration).assertEqual(CommonConstants.CURTAIN_MOTION_DURATION)
      expect(options?.easing).assertEqual('ease-in-out')
      expect(options?.iterations).assertEqual(1)
      // 单程动画：打开到完全打开即结束，不来回摆动
      expect(options?.direction).assertEqual('normal')
    })

    it('状态不变式_打开暂停关闭三态互斥_任何时刻恰好一个选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)
      const device: CurtainDevice = viewModel.curtain

      // 默认关闭
      expect(activeCount(device.openActive, device.pauseActive, device.closeActive)).assertEqual(1)
      expect(device.closeActive).assertTrue()

      // 打开进行中
      viewModel.open(CurtainDefaults.CURTAIN_ID)
      expect(activeCount(device.openActive, device.pauseActive, device.closeActive)).assertEqual(1)
      expect(device.openActive).assertTrue()

      // 暂停在中间进度
      fixture.frame(0.5)
      viewModel.pause(CurtainDefaults.CURTAIN_ID)
      expect(activeCount(device.openActive, device.pauseActive, device.closeActive)).assertEqual(1)
      expect(device.pauseActive).assertTrue()

      // 完全打开
      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(1)
      fixture.finish()
      expect(activeCount(device.openActive, device.pauseActive, device.closeActive)).assertEqual(1)
      expect(device.openActive).assertTrue()

      // 关闭进行中
      viewModel.close(CurtainDefaults.CURTAIN_ID)
      expect(activeCount(device.openActive, device.pauseActive, device.closeActive)).assertEqual(1)
      expect(device.closeActive).assertTrue()

      // 回到完全关闭
      fixture.frame(0)
      fixture.finish()
      expect(activeCount(device.openActive, device.pauseActive, device.closeActive)).assertEqual(1)
      expect(device.closeActive).assertTrue()
    })

    it('状态不变式_顶部两个胶囊互斥_不可能同时选中', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()

      // 默认：仅全部关闭选中
      expect(viewModel.allOpenSelected && viewModel.allClosedSelected).assertFalse()
      expect(viewModel.allClosedSelected).assertTrue()

      // 混合：两个都不选中
      viewModel.open(CurtainDefaults.CURTAIN_ID)
      expect(viewModel.allOpenSelected && viewModel.allClosedSelected).assertFalse()
      expect(viewModel.allOpenSelected).assertFalse()
      expect(viewModel.allClosedSelected).assertFalse()

      // 全开：仅全部打开选中
      viewModel.open(CurtainDefaults.SHEER_ID)
      expect(viewModel.allOpenSelected && viewModel.allClosedSelected).assertFalse()
      expect(viewModel.allOpenSelected).assertTrue()

      // 全部关闭：仅全部关闭选中
      viewModel.closeAll()
      expect(viewModel.allOpenSelected && viewModel.allClosedSelected).assertFalse()
      expect(viewModel.allClosedSelected).assertTrue()
    })

    it('暂停_再次关闭_从暂停处向关闭续跑', 0, () => {
      const viewModel: CurtainViewModel = new CurtainViewModel()
      const fixture: AnimatorFixture = new AnimatorFixture()
      viewModel.bindAnimatorFactory(fixture.factory)

      viewModel.open(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.6)
      fixture.finish()

      // 从完全打开收起，到中途暂停
      viewModel.close(CurtainDefaults.CURTAIN_ID)
      fixture.frame(0.45)
      viewModel.pause(CurtainDefaults.CURTAIN_ID)
      expect(viewModel.curtain.progress).assertEqual(0.45)

      // 从暂停处向关闭续跑，而不是从完全打开重新收起
      viewModel.close(CurtainDefaults.CURTAIN_ID)

      expect(viewModel.curtain.motion).assertEqual(CurtainMotionState.CLOSING)
      expect(viewModel.curtain.progress).assertEqual(0.45)
      expect(fixture.begin()).assertEqual(0.45)
      expect(fixture.end()).assertEqual(CurtainDefaults.FULLY_CLOSED)

      fixture.frame(0)
      fixture.finish()
      expect(viewModel.curtain.progress).assertEqual(CurtainDefaults.FULLY_CLOSED)
      expect(viewModel.curtain.closeActive).assertTrue()
    })
  })
}
