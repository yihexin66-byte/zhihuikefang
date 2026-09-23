/**
 * 布帘 / 窗纱卡片（子组件）：一张卡片承载一路窗帘 —— 标题 + 帘体预览 + 打开 / 暂停 / 关闭
 * 容器：深色半透明圆角卡片配金色描边（与灯光页、首页同一套材质常量）
 * 预览：窗帘杆 + 左右两半帘体；关闭态两半在中间合拢，打开态两半收向两侧留出中缝
 *
 * 开合动画：两张状态图同位置交叉淡入淡出，同时整组帘体随进度向外滑动 —— 进度由 ViewModel
 * 逐帧推进，暂停即停止推进，帘体停在当前位置（不落到两端）。
 * 尺寸：预览区宽度按卡片内宽的百分比给定，帘体高度吃掉卡片剩余空间，因此不同机型
 * 均无需硬编码像素，也不会溢出。
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { CurtainDevice } from '../model/CurtainModel'
import { CurtainViewModel } from '../viewModel/CurtainViewModel'

/**
 * 单个圆形控制按钮：圆形底图 + 图标 + 文案，选中 / 未选中两套观感
 */
@ComponentV2
struct CurtainControlButton {
  @Require @Param label: string
  @Require @Param icon: Resource
  @Require @Param selected: boolean
  /** 点击回调：仅转发，设备状态与动画由 ViewModel 处理 */
  @Event onTap: () => void = () => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 选中态为设计稿金色圆底，未选中态为圆环描边底图
        Image(this.selected
          ? $r('app.media.curtain_btn_selected_bg')
          : $r('app.media.curtain_btn_unselected_bg'))
          .width(CommonConstants.CURTAIN_BTN_SIZE)
          .height(CommonConstants.CURTAIN_BTN_SIZE)
          .objectFit(ImageFit.Contain)

        // 图元按 alpha 通道着色：金底上用深色，暗底上用浅色，保证两种底色下的对比度
        Image(this.icon)
          .width(CommonConstants.CURTAIN_BTN_ICON)
          .height(CommonConstants.CURTAIN_BTN_ICON)
          .objectFit(ImageFit.Contain)
          .renderMode(ImageRenderMode.Template)
          .fillColor(this.selected
            ? CommonConstants.COLOR_GOLD_TEXT
            : CommonConstants.COLOR_TEXT_SUB)
      }
      .width(CommonConstants.CURTAIN_BTN_SIZE)
      .height(CommonConstants.CURTAIN_BTN_SIZE)

      Text(this.label)
        .fontSize(CommonConstants.FONT_CURTAIN_BTN)
        .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.selected
          ? CommonConstants.COLOR_GOLD_LIGHT
          : CommonConstants.COLOR_TEXT_SUB)
        .maxLines(1)
        .margin({ top: CommonConstants.CURTAIN_BTN_LABEL_GAP })
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onTap()
    })
  }
}

@ComponentV2
export struct CurtainDeviceCard {
  @Require @Param viewModel: CurtainViewModel
  /** 本卡片承载的设备：布帘或窗纱，标题与四张开合图都来自它 */
  @Require @Param device: CurtainDevice

  /**
   * 帘体向外滑动位移（占预览区宽度的百分比）：进度越大越靠外
   * 收拢动作因此带上一段横向位移，比单纯淡入淡出更接近真实帘体
   */
  private slideOffset(): string {
    const percent: number =
      this.device.progress * CommonConstants.CURTAIN_PANEL_SLIDE_PCT
    return `${percent}%`
  }

  /**
   * 单侧帘体：关闭态与打开态两张图放在同一盒内交叉过渡
   * 两张图都用 ImageFit.Fill 铺满同一高度，保证合拢时两半在中间严丝合缝、打开时中缝居中
   * @param sideStart true = 左半（靠左对齐、向左滑出）；false = 右半（靠右对齐、向右滑出）
   */
  @Builder
  panelHalf(sideStart: boolean) {
    Stack({ alignContent: sideStart ? Alignment.TopStart : Alignment.TopEnd }) {
      // 关闭态：平铺帘，合拢时覆盖整扇窗
      Image(sideStart ? this.device.closedLeft : this.device.closedRight)
        .width(`${CommonConstants.CURTAIN_PANEL_CLOSED_PCT}%`)
        .height('100%')
        .objectFit(ImageFit.Fill)
        .opacity(this.device.closedOpacity)

      // 打开态：收拢出褶皱的帘，两半之间留出中缝
      Image(sideStart ? this.device.openLeft : this.device.openRight)
        .width(`${CommonConstants.CURTAIN_PANEL_OPEN_PCT}%`)
        .height('100%')
        .objectFit(ImageFit.Fill)
        .opacity(this.device.openOpacity)
    }
    .width('100%')
    .height('100%')
    // 左半负向、右半正向：两侧同时向外滑动
    .translate({ x: sideStart ? `-${this.slideOffset()}` : this.slideOffset() })
  }

  /**
   * 帘体预览区：窗帘杆（宽度驱动高度）+ 帘体（吃掉卡片剩余高度）
   */
  @Builder
  preview() {
    Column() {
      // 窗帘杆：宽度与帘体同宽，高度按图元比例自适应
      Image($r('app.media.curtain_icon_top_bar'))
        .width(`${CommonConstants.CURTAIN_STAGE_WIDTH_PCT}%`)
        .aspectRatio(CommonConstants.CURTAIN_ROD_RATIO)
        .objectFit(ImageFit.Fill)

      // 帘体区：左右两半各占一半宽度，高度吃满预览区剩余空间
      Stack({ alignContent: Alignment.Center }) {
        this.panelHalf(true)
        this.panelHalf(false)
      }
      .width(`${CommonConstants.CURTAIN_STAGE_WIDTH_PCT}%`)
      .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .margin({ top: CommonConstants.CURTAIN_CARD_TITLE_GAP })
  }

  build() {
    Column() {
      // 卡片标题：布帘 / 窗纱（文案来自模型，一字不改）
      Text(this.device.label)
        .fontSize(CommonConstants.FONT_CURTAIN_CARD_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .letterSpacing(1)

      this.preview()

      // 打开 / 暂停 / 关闭：三个圆形按钮等距排布
      Row() {
        CurtainControlButton({
          label: this.viewModel.btnOpenLabel,
          icon: $r('app.media.curtain_icon_open'),
          selected: this.device.openActive,
          onTap: () => {
            this.viewModel.open(this.device.id)
          }
        })
        CurtainControlButton({
          label: this.viewModel.btnPauseLabel,
          icon: $r('app.media.curtain_icon_pause'),
          selected: this.device.pauseActive,
          onTap: () => {
            this.viewModel.pause(this.device.id)
          }
        })
        CurtainControlButton({
          label: this.viewModel.btnCloseLabel,
          icon: $r('app.media.curtain_icon_close'),
          selected: this.device.closeActive,
          onTap: () => {
            this.viewModel.close(this.device.id)
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: CommonConstants.CURTAIN_BTN_ROW_GAP })
    }
    .width('100%')
    // 两张卡片等分内容区剩余高度，屏幕高低不同都不产生滚动
    .layoutWeight(1)
    .padding(CommonConstants.CURTAIN_CARD_PADDING)
    .backgroundColor(CommonConstants.COLOR_LIGHT_CARD_BG)
    .borderRadius(CommonConstants.CURTAIN_CARD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_LIGHT_CARD_BORDER })
  }
}
