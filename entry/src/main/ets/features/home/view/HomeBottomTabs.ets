/**
 * 底部导航（子组件）：全 App 统一的四项导航 —— 首页 / 灯光 / 窗帘 / 服务
 * 形态：悬浮在页面最底部，左右不占满的圆角描边胶囊；Tabs 自带导航条高度置 0，由自绘导航条承担选中态
 * 选中态：金色胶囊底 + 白色图标 + 暖白文字（图标与文字同时转白，不做缩放、不加描边）
 * 未选中态：图标与文字同为 55% 白，尺寸不变，仅靠无胶囊底区分
 * 内容：首页 / 灯光 / 窗帘 / 服务 四个 TabContent 分别接入四个主页面
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { CurtainPage } from '../../curtain/view/CurtainPage'
import { LightPage } from '../../light/view/LightPage'
import { ServicePage } from '../../service/view/ServicePage'
import { HomeViewModel } from '../viewModel/HomeViewModel'

/**
 * 单个导航项：图标 + 文字，选中 / 未选中两套配色
 * 图标统一按 alpha 通道着白色（renderMode.Template），因此图标资源本身是什么颜色都不影响观感
 */
@ComponentV2
struct NavTabButton {
  /** 导航图标：undefined 表示该项暂无图标资源，仅展示文字占位 */
  @Param icon: Resource | undefined = undefined
  @Require @Param label: string
  @Require @Param selected: boolean
  /** 点击回调：仅转发，选中态由 ViewModel 持有 */
  @Event onTap: () => void = () => {}

  build() {
    Column() {
      // 图标：模板着色统一转白，未选中降到 55% 白（与文字同透明度）
      if (this.icon !== undefined) {
        Image(this.icon)
          .width(CommonConstants.ICON_TAB)
          .height(CommonConstants.ICON_TAB)
          .objectFit(ImageFit.Contain)
          .renderMode(ImageRenderMode.Template)
          .fillColor(Color.White)
          .opacity(this.selected ? 1 : CommonConstants.OPACITY_TAB_IDLE)
      }

      // 文字：选中暖白加粗，未选中 55% 白常规字重
      Text(this.label)
        .fontSize(CommonConstants.FONT_TAB)
        .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.selected
          ? CommonConstants.COLOR_TAB_TEXT_ACTIVE
          : CommonConstants.COLOR_TAB_TEXT_IDLE)
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .height(CommonConstants.TAB_CAPSULE_HEIGHT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(CommonConstants.TAB_CAPSULE_RADIUS)
    // 选中态金胶囊：未选中态渐变整体透明，等价于无底色
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        [this.selected ? CommonConstants.COLOR_TAB_CAPSULE_TOP : Color.Transparent, 0],
        [this.selected ? CommonConstants.COLOR_TAB_CAPSULE_BOTTOM : Color.Transparent, 1]
      ]
    })
    .onClick(() => {
      this.onTap()
    })
  }
}

@ComponentV2
export struct HomeBottomTabs {
  @Require @Param viewModel: HomeViewModel
  /** 首页 Tab 的内容插槽：由 HomePage 注入（把页面内容与导航壳解耦，便于各页面陆续接入） */
  @BuilderParam homeContent: () => void = this.emptyContent

  private tabsController: TabsController = new TabsController()

  @Builder
  emptyContent() {
    Column() {
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 切换导航项：状态变更交给 ViewModel，同时驱动 Tabs 切换内容
   */
  private select(index: number): void {
    this.viewModel.switchTab(index)
    this.tabsController.changeIndex(index)
  }

  /**
   * 悬浮导航条：左右留白的圆角描边胶囊
   */
  @Builder
  floatingBar() {
    Column() {
      Row() {
        NavTabButton({
          icon: this.viewModel.navTabs[0].icon,
          label: this.viewModel.navTabs[0].label,
          selected: this.viewModel.currentTab === 0,
          onTap: () => {
            this.select(0)
          }
        })
        NavTabButton({
          icon: this.viewModel.navTabs[1].icon,
          label: this.viewModel.navTabs[1].label,
          selected: this.viewModel.currentTab === 1,
          onTap: () => {
            this.select(1)
          }
        })
        NavTabButton({
          icon: this.viewModel.navTabs[2].icon,
          label: this.viewModel.navTabs[2].label,
          selected: this.viewModel.currentTab === 2,
          onTap: () => {
            this.select(2)
          }
        })
        NavTabButton({
          icon: this.viewModel.navTabs[3].icon,
          label: this.viewModel.navTabs[3].label,
          selected: this.viewModel.currentTab === 3,
          onTap: () => {
            this.select(3)
          }
        })
      }
      .width('100%')
      .height(CommonConstants.TABBAR_HEIGHT)
      .padding({ left: 6, right: 6 })
      .backgroundColor(CommonConstants.COLOR_TABBAR_BG)
      .borderRadius(CommonConstants.TABBAR_RADIUS)
      .border({ width: 1, color: CommonConstants.COLOR_TABBAR_BORDER })
      .backdropBlur(20)
    }
    .width('100%')
    // 左右不占满 + 贴合页面最底部
    .padding({
      left: CommonConstants.TABBAR_SIDE_MARGIN,
      right: CommonConstants.TABBAR_SIDE_MARGIN,
      bottom: CommonConstants.TABBAR_BOTTOM_MARGIN
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        // 1. 首页：智慧客房控制页
        TabContent() {
          this.homeContent()
        }

        // 2. 灯光：灯光控制页（本屏）；返回按钮切回首页
        TabContent() {
          LightPage({
            onBack: () => {
              this.select(0)
            }
          })
        }

        // 3. 窗帘：窗帘控制页（本屏）；返回按钮切回首页
        TabContent() {
          CurtainPage({
            onBack: () => {
              this.select(0)
            }
          })
        }

        // 4. 服务：服务控制页（本屏）；返回按钮切回首页
        TabContent() {
          ServicePage({
            onBack: () => {
              this.select(0)
            }
          })
        }
      }
      // 隐藏 Tabs 自带导航条，改由下方自绘悬浮导航条承担
      .barHeight(0)
      .scrollable(false)
      .animationDuration(220)
      .width('100%')
      .height('100%')
      .onChange((index: number) => {
        // 事件只转发：选中态交给 ViewModel
        this.viewModel.switchTab(index)
      })

      this.floatingBar()
    }
    .width('100%')
    .height('100%')
  }
}