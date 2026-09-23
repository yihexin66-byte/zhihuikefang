/**
 * 总开关区（子组件）：金色墙壁开关图 + 「总开关」名称
 * 视觉：开启金色高亮并带金色光晕，关闭低饱和置灰；默认关闭
 * 交互：点击整块即切换 —— 关闭则全开所有独立灯光，开启则全关所有独立灯光
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { LightViewModel } from '../viewModel/LightViewModel'

@ComponentV2
export struct LightMainSwitch {
  @Require @Param viewModel: LightViewModel

  /** 开启态金色光晕 / 关闭态无光晕：显式类型声明，避免未类型化对象字面量 */
  private glowOn: ShadowOptions = {
    radius: CommonConstants.SWITCH_GLOW_RADIUS,
    color: CommonConstants.COLOR_SWITCH_GLOW
  }
  private glowOff: ShadowOptions = {
    radius: CommonConstants.SWITCH_GLOW_RADIUS_OFF,
    color: CommonConstants.COLOR_SWITCH_GLOW
  }

  build() {
    Column({ space: CommonConstants.SPACE_XS }) {
      // 金色墙壁开关：开启保留金色并叠加光晕，关闭转灰并压暗
      Image($r('app.media.light_btn_main_switch'))
        .width(CommonConstants.LIGHT_MAIN_SWITCH)
        .height(CommonConstants.LIGHT_MAIN_SWITCH)
        .objectFit(ImageFit.Contain)
        .grayscale(this.viewModel.mainSwitchOn ? 0 : 1)
        .opacity(this.viewModel.mainSwitchOn ? 1 : CommonConstants.OPACITY_SWITCH_OFF)
        .shadow(this.viewModel.mainSwitchOn ? this.glowOn : this.glowOff)

      // 名称：总开关
      Text(this.viewModel.mainSwitchLabel)
        .fontSize(CommonConstants.FONT_LIGHT_SWITCH_LABEL)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_SUB)
        .letterSpacing(1)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      // 事件只转发：状态与联动逻辑由 ViewModel → 共享状态承担
      this.viewModel.toggleMainSwitch()
    })
  }
}