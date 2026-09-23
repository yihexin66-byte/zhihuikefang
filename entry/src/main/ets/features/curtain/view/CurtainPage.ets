/**
 * 第四屏：窗帘控制页（View 层 / 页面装配）
 * 分层：背景层（暖金实景 + 压暗遮罩）→ 顶部栏（返回 + 居中标题）
 *       → 顶部胶囊（全部打开 / 全部关闭）→ 布帘卡片 → 窗纱卡片
 * 排布：整屏固定高度铺满，不产生滚动；两张卡片等分剩余高度、帘体高度自适应不同机型
 * 零业务逻辑：文案、默认值、开合状态与动画进度全部取自 CurtainViewModel，各分区独立封装为子组件
 */
import { AnimatorOptions } from '@kit.ArkUI'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { CurtainViewModel } from '../viewModel/CurtainViewModel'
import { CurtainDeviceCard } from './CurtainDeviceCard'
import { CurtainModeSwitch } from './CurtainModeSwitch'

@ComponentV2
export struct CurtainPage {
  // 页面状态与逻辑的唯一持有者
  @Local viewModel: CurtainViewModel = new CurtainViewModel()

  /** 返回回调：由导航壳注入（切回首页 Tab） */
  @Event onBack: () => void = () => {}

  aboutToAppear(): void {
    /**
     * 注入动画驱动器：把 UIContext 的开合动画能力交给 ViewModel
     * 工厂在点击时才创建动画对象，此时页面已挂载、UIContext 可用；
     * 进度推进与状态流转仍全部由 ViewModel 掌管，View 不参与动画逻辑
     */
    this.viewModel.bindAnimatorFactory(
      (options: AnimatorOptions) => this.getUIContext().createAnimator(options)
    )
  }

  aboutToDisappear(): void {
    // 页面卸载时收尾动画，避免动画继续推进已卸载的视图
    this.viewModel.releaseAnimators()
  }

  // ==================== 背景层 ====================

  /**
   * 暖金实景背景 + 压暗遮罩：与首页 / 灯光页同一套处理，中部保留金色光晕，上下压暗保证白/金文字可读
   */
  @Builder
  backgroundLayer() {
    Stack() {
      Image($r('app.media.curtain_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [CommonConstants.COLOR_CURTAIN_SCRIM_TOP, 0],
            [CommonConstants.COLOR_CURTAIN_SCRIM_MID, 0.3],
            [CommonConstants.COLOR_CURTAIN_SCRIM_BOTTOM, 1]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 顶部栏 ====================

  /**
   * 顶部栏：左上角返回按钮（仅箭头图元，按钮背景透明）+ 居中标题「窗帘控制」
   */
  @Builder
  topBar() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        Image($r('app.media.light_icon_back'))
          // 触摸区 32×32、图元内缩后约 20×20；按钮背景保持透明，仅箭头压在页面背景上
          .width(CommonConstants.CURTAIN_BACK_BOX)
          .height(CommonConstants.CURTAIN_BACK_BOX)
          .padding(CommonConstants.SPACE_XS)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.onBack()
          })

        Blank()
      }
      .width('100%')
      .height('100%')

      Text(this.viewModel.pageTitle)
        .fontSize(CommonConstants.FONT_CURTAIN_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .letterSpacing(CommonConstants.LETTER_SPACING_TITLE)
    }
    .width('100%')
    .height(CommonConstants.CURTAIN_TOPBAR_HEIGHT)
  }

  // ==================== 页面装配 ====================

  build() {
    Stack() {
      // 1. 背景层
      this.backgroundLayer()

      // 2. 内容层：顶部栏 → 顶部胶囊 → 布帘卡片 → 窗纱卡片（整屏铺满，底部避让悬浮导航）
      Column({ space: CommonConstants.CURTAIN_BLOCK_GAP }) {
        this.topBar()

        // ① 顶部胶囊：一次控制布帘与窗纱，选中态按两台设备的综合状态联动
        CurtainModeSwitch({ viewModel: this.viewModel })

        // ② 布帘卡片：默认关闭
        CurtainDeviceCard({ viewModel: this.viewModel, device: this.viewModel.curtain })

        // ③ 窗纱卡片：与布帘同一套开合逻辑，默认关闭
        CurtainDeviceCard({ viewModel: this.viewModel, device: this.viewModel.sheer })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: CommonConstants.CURTAIN_PAGE_PADDING,
        right: CommonConstants.CURTAIN_PAGE_PADDING,
        top: CommonConstants.SPACE_S,
        bottom: CommonConstants.HOME_BOTTOM_CLEARANCE
      })
    }
    .width('100%')
    .height('100%')
  }
}
