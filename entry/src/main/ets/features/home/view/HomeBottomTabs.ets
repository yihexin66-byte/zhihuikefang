/**
 * 底部导航（子组件）：全 App 统一的四项导航 —— 首页 / 灯光 / 窗帘 / 服务
 * 形态：悬浮在页面最底部，左右不占满的圆角描边胶囊；Tabs 自带导航条高度置 0，由自绘导航条承担选中态
 * 选中态：暖白加粗文字 + 暖金图标（圆角描边）+ 微弱高亮底色；未选中态：浅灰白常规字重、无高亮
 * 灯光 / 窗帘 / 服务三个 TabContent 暂为占位页，后续接入真实页面时替换 placeholderPage 即可
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { HomeViewModel } from '../viewModel/HomeViewModel'

/**
 * 单个导航项：图标 + 文字，选中 / 未选中两套配色
 */
@ComponentV2
struct NavTabButton {
  @Require @Param icon: Resource
  @Require @Param label: string
  @Require @Param selected: boolean
  /** 点击回调：仅转发，选中态由 ViewModel 持有 */
  @Event onTap: () => void = () => {}

  build() {
    Column() {
      // 图标：选中暖金（保留原色），未选中转为浅灰白
      Image(this.icon)
        .width(CommonConstants.ICON_TAB)
        .height(CommonConstants.ICON_TAB)
        .objectFit(ImageFit.Contain)
        .padding(2)
        .borderRadius(9)
        .border({
          width: 1,
          color: this.selected
            ? CommonConstants.COLOR_TAB_ICON_BORDER
            : CommonConstants.COLOR_TAB_ICON_BORDER_IDLE
        })
        .grayscale(this.selected ? 0 : 1)
        .brightness(this.selected ? 1 : 1.2)

      // 文字：选中暖白加粗，未选中浅灰白常规
      Text(this.label)
        .fontSize(CommonConstants.FONT_TAB)
        .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.selected
          ? CommonConstants.COLOR_TAB_TEXT_ACTIVE
          : CommonConstants.COLOR_TAB_TEXT_IDLE)
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(18)
    // 微弱高亮底色：仅选中态
    .backgroundColor(this.selected ? CommonConstants.COLOR_TAB_HIGHLIGHT : Color.Transparent)
    .onClick(() => {
      this.onTap()
    })
  }
}

@ComponentV2
export struct HomeBottomTabs {
  @Require @Param viewModel: HomeViewModel
  /** 首页 Tab 的内容插槽：由 HomePage 注入（把页面内容与导航壳解耦，便于三个页面陆续接入） */
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

  /**
   * 占位页：居中展示对应名称 + 页面开发中
   */
  @Builder
  placeholderPage(index: number) {
    Column() {
      Text(this.viewModel.navTabs[index].label)
        .fontSize(CommonConstants.FONT_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .letterSpacing(CommonConstants.LETTER_SPACING_TITLE)

      Divider()
        .width(46)
        .strokeWidth(2)
        .color(CommonConstants.COLOR_GOLD)
        .margin({ top: CommonConstants.SPACE_M, bottom: CommonConstants.SPACE_M })

      Text(this.viewModel.underDevelopment)
        .fontSize(CommonConstants.FONT_SUBTITLE)
        .fontColor(CommonConstants.COLOR_TEXT_HINT)
        .letterSpacing(CommonConstants.LETTER_SPACING_SUBTITLE)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: CommonConstants.HOME_BOTTOM_CLEARANCE })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        // 1. 首页：智慧客房控制页
        TabContent() {
          this.homeContent()
        }

        // 2. 灯光（待接入）
        TabContent() {
          this.placeholderPage(1)
        }

        // 3. 窗帘（待接入）
        TabContent() {
          this.placeholderPage(2)
        }

        // 4. 服务（待接入）
        TabContent() {
          this.placeholderPage(3)
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