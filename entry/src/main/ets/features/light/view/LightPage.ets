/**
 * 第三屏：灯光控制页（View 层 / 页面装配）
 * 分层：背景层（暖金实景 + 压暗遮罩）→ 顶部栏（返回 + 居中标题）→ 总开关区 → 场景模式卡片 → 独立控制卡片
 * 排布：整屏固定高度铺满，不产生滚动；独立控制卡片弹性占满剩余高度，5 行等分，不同机型均完整显示
 * 零业务逻辑：文案、默认值、交互状态全部取自 LightViewModel 与跨页共享的 RoomStateStore，各分区独立封装为子组件
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RoomStateStore } from '../../../common/state/RoomStateStore'
import { LightViewModel } from '../viewModel/LightViewModel'
import { LightControlList } from './LightControlList'
import { LightMainSwitch } from './LightMainSwitch'
import { LightSceneSection } from './LightSceneSection'

@ComponentV2
export struct LightPage {
  // 页面状态与逻辑的唯一持有者
  @Local viewModel: LightViewModel = new LightViewModel()

  /** 返回回调：由导航壳注入（返回首页 Tab） */
  @Event onBack: () => void = () => {}

  aboutToAppear(): void {
    // 注入客房共享状态：与首页场景卡、9 路独立开关双向同步
    this.viewModel.attachRoomState(RoomStateStore.getShared())
  }

  // ==================== 背景层 ====================

  /**
   * 暖金实景背景 + 压暗遮罩：与首页同一套视觉基调，中部保留金色光晕，上下压暗保证白/金文字可读
   */
  @Builder
  backgroundLayer() {
    Stack() {
      Image($r('app.media.home_background'))
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
            [CommonConstants.COLOR_LIGHT_SCRIM_TOP, 0],
            [CommonConstants.COLOR_LIGHT_SCRIM_MID, 0.3],
            [CommonConstants.COLOR_LIGHT_SCRIM_BOTTOM, 1]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 顶部栏 ====================

  /**
   * 顶部栏：左上角返回按钮（仅箭头图元，按钮背景透明）+ 居中标题「灯光控制」
   */
  @Builder
  topBar() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        Image($r('app.media.light_icon_back'))
          // 触摸区 32×32、图元内缩后约 20×20；按钮背景保持透明，仅箭头压在页面背景上
          .width(CommonConstants.LIGHT_BACK_BOX)
          .height(CommonConstants.LIGHT_BACK_BOX)
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
        .fontSize(CommonConstants.FONT_LIGHT_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .letterSpacing(CommonConstants.LETTER_SPACING_TITLE)
    }
    .width('100%')
    .height(CommonConstants.LIGHT_TOPBAR_HEIGHT)
  }

  // ==================== 页面装配 ====================

  build() {
    Stack() {
      // 1. 背景层
      this.backgroundLayer()

      // 2. 内容层：顶部栏 → 总开关 → 场景模式卡片 → 独立控制卡片（整屏铺满，底部避让悬浮导航）
      Column({ space: CommonConstants.SPACE_M }) {
        this.topBar()

        // ① 总开关区：点击控制全部灯光
        LightMainSwitch({ viewModel: this.viewModel })

        // ② 场景模式区：五选一胶囊，与首页同名场景双向同步并联动对应开关
        LightSceneSection({ viewModel: this.viewModel })

        // ③ 独立控制区：9 项两列网格，弹性占满剩余高度
        LightControlList({ viewModel: this.viewModel })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: CommonConstants.LIGHT_PAGE_PADDING,
        right: CommonConstants.LIGHT_PAGE_PADDING,
        top: CommonConstants.SPACE_S,
        bottom: CommonConstants.HOME_BOTTOM_CLEARANCE
      })
    }
    .width('100%')
    .height('100%')
  }
}