/**
 * 第五屏：服务控制页（View 层 / 页面装配）
 * 分层：背景层（暖金实景 + 压暗遮罩）→ 顶部栏（返回 + 居中标题）→ 两张服务卡
 *       → SOS 紧急呼叫大按钮 → 退出登录胶囊 → 悬浮底部导航（由导航壳统一承载）
 * 排布：整屏固定高度铺满，不产生滚动；卡片高度、SOS 与胶囊尺寸均由宽度等比推导，适配不同机型
 * 零业务逻辑：文案、默认值、开关状态全部取自 ServiceViewModel，各分区独立封装为子组件
 */
import { BusinessError } from '@kit.BasicServicesKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RoomServiceStore } from '../../../common/state/RoomServiceStore'
import { ServiceViewModel } from '../viewModel/ServiceViewModel'
import { ServiceCard } from './ServiceCard'
import { ServiceLogoutButton } from './ServiceLogoutButton'
import { ServiceSosButton } from './ServiceSosButton'
import { ServiceTopBar } from './ServiceTopBar'

@ComponentV2
export struct ServicePage {
  // 根栈：由 AppNavigation 通过 @Provider 下发，退出登录时清空即可回到首屏登录页
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 页面状态与逻辑的唯一持有者
  @Local viewModel: ServiceViewModel = new ServiceViewModel()

  /** 返回回调：由导航壳注入（切回首页 Tab） */
  @Event onBack: () => void = () => {}

  aboutToAppear(): void {
    // 注入客房服务共享状态：请勿打扰 / 清理房间 与首页快捷服务双向同步
    this.viewModel.attachServiceState(RoomServiceStore.getShared())
  }

  // ==================== 交互事件 ====================

  /**
   * 轻提示：属增强反馈，展示失败不阻断交互
   * 文案为空（状态未变化）时不弹出，避免出现空白提示条
   */
  private showTip(message: string): void {
    if (message === '') {
      return
    }
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 })
    } catch (err) {
      const error = err as BusinessError
      this.viewModel.logTipFailure(`${error.code} ${error.message}`)
    }
  }

  /**
   * SOS 点击：仅弹出轻提示，不跳转（不对接真实报警系统）
   */
  private handleSos(): void {
    this.showTip(this.viewModel.requestSos())
  }

  /**
   * 退出登录：清除本地登录状态（服务开关复位），清空根栈即回到首屏登录页
   */
  private handleLogout(): void {
    this.viewModel.logout()
    this.pageStack.clear()
  }

  // ==================== 背景层 ====================

  /**
   * 暖金实景背景 + 压暗遮罩：与首页 / 灯光页 / 窗帘页同一套处理，中部保留金色光晕，上下压暗保证文字可读
   */
  @Builder
  backgroundLayer() {
    Stack() {
      Image($r('app.media.service_bg'))
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
            [CommonConstants.COLOR_SERVICE_SCRIM_TOP, 0],
            [CommonConstants.COLOR_SERVICE_SCRIM_MID, 0.3],
            [CommonConstants.COLOR_SERVICE_SCRIM_BOTTOM, 1]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 服务卡区 ====================

  /**
   * 两张服务卡并排：请勿打扰（月亮）/ 清理房间（扫帚），宽度弹性等分、高度等比推导
   * 开关状态直接取自共享状态：首页快捷服务开启任一项时此处开关同步开启
   * 每次切换均弹出固定轻提示（与首页快捷服务同一套文案：×已开启 / ×已关闭）
   */
  @Builder
  serviceCardRow() {
    Row({ space: CommonConstants.SERVICE_CARD_GAP }) {
      ServiceCard({
        item: this.viewModel.dndItem,
        isOn: this.viewModel.dndOn,
        onSwitch: (on: boolean) => {
          this.showTip(this.viewModel.setDnd(on))
        }
      })

      ServiceCard({
        item: this.viewModel.cleanItem,
        isOn: this.viewModel.cleanOn,
        onSwitch: (on: boolean) => {
          this.showTip(this.viewModel.setClean(on))
        }
      })
    }
    .width('100%')
  }

  // ==================== 页面装配 ====================

  build() {
    Stack() {
      // 1. 背景层
      this.backgroundLayer()

      // 2. 内容层：标题栏 → 服务卡 →（弹性留白）→ SOS →（弹性留白）→ 退出登录；底部避让悬浮导航
      Column({ space: CommonConstants.SERVICE_BLOCK_GAP }) {
        ServiceTopBar({
          title: this.viewModel.pageTitle,
          onBack: () => {
            this.onBack()
          }
        })

        this.serviceCardRow()

        Blank()

        ServiceSosButton({
          label: this.viewModel.sosLabel,
          onTrigger: () => {
            this.handleSos()
          }
        })

        Blank()

        ServiceLogoutButton({
          label: this.viewModel.logoutLabel,
          onTrigger: () => {
            this.handleLogout()
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: CommonConstants.SERVICE_PAGE_PADDING,
        right: CommonConstants.SERVICE_PAGE_PADDING,
        top: CommonConstants.SPACE_S,
        bottom: CommonConstants.HOME_BOTTOM_CLEARANCE
      })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
