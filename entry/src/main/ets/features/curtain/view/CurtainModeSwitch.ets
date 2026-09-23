/**
 * 顶部胶囊切换（子组件）：全部打开 / 全部关闭，两枚等宽胶囊各占一半
 * 视觉：选中态用设计稿金色胶囊底图 + 深色图元与文字；未选中态沿用半透卡片材质 + 弱金描边
 * 交互：默认均未选中；点击后立即切换选中态，同时驱动布帘与窗纱执行打开 / 关闭动画
 * 选中态取 ViewModel 的指令状态，单独操作布帘 / 窗纱时也会按两台设备的综合状态联动
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { CurtainViewModel } from '../viewModel/CurtainViewModel'

/**
 * 单枚胶囊：图标 + 文案，选中 / 未选中两套观感
 */
@ComponentV2
struct CurtainModePill {
  @Require @Param label: string
  /** 胶囊图标：open_all = 帘体向两侧展开，close_all = 帘体在中间合拢 */
  @Require @Param icon: Resource
  @Require @Param selected: boolean
  /** 点击回调：仅转发，指令与动画由 ViewModel 处理 */
  @Event onTap: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 选中态底图：设计稿金色胶囊；未选中态用半透卡片材质承担，保持与灯光页同一套低饱和观感
      if (this.selected) {
        Image($r('app.media.curtain_btn_all_open_or_close_selected_bg'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
      }

      Row({ space: CommonConstants.SPACE_XS }) {
        // 图元按 alpha 通道着色：选中为金字底上的深色，未选中为暗底上的浅金色
        Image(this.icon)
          .width(CommonConstants.CURTAIN_MODE_ICON)
          .height(CommonConstants.CURTAIN_MODE_ICON)
          .objectFit(ImageFit.Contain)
          .renderMode(ImageRenderMode.Template)
          .fillColor(this.selected
            ? CommonConstants.COLOR_GOLD_TEXT
            : CommonConstants.COLOR_GOLD_LIGHT)
          .opacity(this.selected ? 1 : CommonConstants.OPACITY_CURTAIN_MODE_IDLE)

        Text(this.label)
          .fontSize(CommonConstants.FONT_CURTAIN_MODE)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selected
            ? CommonConstants.COLOR_GOLD_TEXT
            : CommonConstants.COLOR_TEXT_MAIN)
          .opacity(this.selected ? 1 : CommonConstants.OPACITY_CURTAIN_MODE_IDLE)
          .maxLines(1)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .layoutWeight(1)
    .height(CommonConstants.CURTAIN_MODE_HEIGHT)
    .borderRadius(CommonConstants.CURTAIN_MODE_HEIGHT / 2)
    .backgroundColor(this.selected ? Color.Transparent : CommonConstants.COLOR_LIGHT_CARD_BG)
    .border({
      width: this.selected ? CommonConstants.CURTAIN_MODE_BORDER_WIDTH_ON : 1,
      color: this.selected
        ? CommonConstants.COLOR_GOLD_LIGHT
        : CommonConstants.COLOR_CURTAIN_MODE_BORDER_OFF
    })
    .clip(true)
    .onClick(() => {
      this.onTap()
    })
  }
}

@ComponentV2
export struct CurtainModeSwitch {
  @Require @Param viewModel: CurtainViewModel

  build() {
    Row({ space: CommonConstants.SPACE_S }) {
      // 全部打开：布帘与窗纱同时打开，两者均下达打开指令时保持选中
      CurtainModePill({
        label: this.viewModel.modeOpenLabel,
        icon: $r('app.media.curtain_icon_open_all'),
        selected: this.viewModel.allOpenSelected,
        onTap: () => {
          this.viewModel.openAll()
        }
      })

      // 全部关闭：布帘与窗纱同时关闭，两者均下达关闭指令时保持选中（默认态）
      CurtainModePill({
        label: this.viewModel.modeCloseLabel,
        icon: $r('app.media.curtain_icon_close_all'),
        selected: this.viewModel.allClosedSelected,
        onTap: () => {
          this.viewModel.closeAll()
        }
      })
    }
    .width('100%')
  }
}
