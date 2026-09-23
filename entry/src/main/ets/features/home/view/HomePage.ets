/**
 * 第二屏：智慧客房控制首页（View 层 / 页面装配）
 * 分层：背景层（暖金实景 + 压暗遮罩）→ 顶部标题区 → 空调卡片 / 场景模式 / 快捷服务 + 晚安横幅 → 悬浮底部导航
 * 排布：按整屏高度紧凑排布，常规手机一屏可完整展示（内容略短于视口，无需滚动）
 * 零业务逻辑：文案、默认值、交互状态全部取自 HomeViewModel，子组件各自独立封装
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { HomeViewModel } from '../viewModel/HomeViewModel'
import { AirConditionerCard } from './AirConditionerCard'
import { HomeBottomTabs } from './HomeBottomTabs'
import { QuickServiceSection } from './QuickServiceSection'
import { SceneModeSection } from './SceneModeSection'

@ComponentV2
export struct HomePage {
  // 根栈：由 AppNavigation 通过 @Provider 下发
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  /** 路由参数：登录页「立即入住」携带的房号（HomeRouteParams）；未传时为 undefined/null */
  @Param routeParam: Object | undefined = undefined

  // 页面状态与逻辑的唯一持有者
  @Local viewModel: HomeViewModel = new HomeViewModel()

  aboutToAppear(): void {
    // 读取登录页跳转参数并落地房号；未接收到参数（直接启动本页调试）时展示保底房号 2002
    this.viewModel.applyRouteParam(this.routeParam)
  }

  // ==================== 背景层 ====================

  /**
   * 暖金实景背景 + 压暗遮罩：中部保留金色光晕，上下压暗保证白/金文字可读
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
            [CommonConstants.COLOR_HOME_SCRIM_TOP, 0],
            [CommonConstants.COLOR_HOME_SCRIM_MID, 0.3],
            [CommonConstants.COLOR_HOME_SCRIM_BOTTOM, 1]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 顶部标题区 ====================

  /**
   * 标题「智慧客房」+ 右上角「开始测试」标签 + 一行问候语「欢迎回家，房号 XXXX」
   */
  @Builder
  headerBlock() {
    Column() {
      Row() {
        // 标题：金色「智慧客房」字标（资源本身即金字图形，不再叠加文字）
        Image($r('app.media.home_text_smart_guest_room'))
          .width(132)
          .height(33)
          .objectFit(ImageFit.Contain)

        Blank()

        // 右上角标签
        Text(this.viewModel.testTag)
          .fontSize(CommonConstants.FONT_TAG)
          .fontColor(CommonConstants.COLOR_GOLD_LIGHT)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(CommonConstants.COLOR_TAG_BG)
          .borderRadius(12)
          .border({ width: 1, color: CommonConstants.COLOR_TAG_BORDER })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 问候语：一行展示
      Row() {
        Text(this.viewModel.greetingPrefix)
          .fontSize(CommonConstants.FONT_GREETING)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)
          .letterSpacing(1)

        Text(this.viewModel.roomText)
          .fontSize(CommonConstants.FONT_GREETING)
          .fontColor(CommonConstants.COLOR_GOLD_LIGHT)
          .letterSpacing(1)
      }
      .width('100%')
      .margin({ top: CommonConstants.SPACE_XS })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 首页 Tab 内容 ====================

  /**
   * 首页内容：标题区置顶，控制卡片区紧凑排布；底部避让悬浮导航
   * 常规手机一屏即可完整展示（内容短于视口，不产生滚动）；更矮的屏幕退化时可滚动而非被裁切
   */
  @Builder
  homeTabContent() {
    Scroll() {
      Column() {
        this.headerBlock()

        Column({ space: CommonConstants.HOME_GAP }) {
          // ① 空调控制卡片：页面最醒目的大卡片
          AirConditionerCard({ viewModel: this.viewModel })

          // ② 场景模式：明亮 / 柔和 / 阅读 / 温馨（2×2 金色卡片）
          SceneModeSection({ viewModel: this.viewModel })

          // ③ 快捷服务（两张金色卡片）+ 晚安模式通栏横幅
          QuickServiceSection({ viewModel: this.viewModel })
        }
        .width('100%')
        .margin({ top: CommonConstants.SPACE_M })
      }
      .width('100%')
      .padding({
        left: CommonConstants.PAGE_PADDING,
        right: CommonConstants.PAGE_PADDING,
        top: CommonConstants.SPACE_S,
        bottom: CommonConstants.HOME_BOTTOM_CLEARANCE
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .clip(true)
  }

  // ==================== 页面装配 ====================

  build() {
    NavDestination() {
      Stack() {
        // 1. 背景层
        this.backgroundLayer()

        // 2. 内容层：首页控制页 + 悬浮底部导航（尾随闭包注入首页内容，渲染仍在本页作用域）
        HomeBottomTabs({ viewModel: this.viewModel }) {
          this.homeTabContent()
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}