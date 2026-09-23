/**
 * 服务开关（子组件）：请勿打扰 / 清理房间 的开关控件
 * 图元：滑块取自设计稿 service_toggle_dots_bg（白色圆点），轨道沿用设计稿的胶囊比例 196:103 等比缩放
 * 视觉：关闭态为暖深色半透明轨道（凹槽感），开启态换成实心青铜轨道（明显点亮），滑块随状态左右滑动
 *       设计稿的 service_toggle_bg 为 28% 白轨道，压在淡金卡底上无法辨识（实测 1.24:1），故轨道改用暖深色
 * 交互：整块开关（52×27）均可点击，事件只转发目标状态，实际状态由共享状态持有
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'

@ComponentV2
export struct ServiceToggle {
  /** 开关状态：取自共享状态，本页与首页快捷服务任一侧变更即联动刷新 */
  @Require @Param isOn: boolean
  /** 切换回调：仅转发目标状态，联动逻辑由 ViewModel 处理 */
  @Event onChange: (on: boolean) => void = (on: boolean) => {}

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 轨道：关闭态半透明暖深色（凹槽感），开启态实心青铜（点亮）
      Column()
        .width('100%')
        .height('100%')
        .borderRadius(CommonConstants.SERVICE_TOGGLE_RADIUS)
        .backgroundColor(this.isOn
          ? CommonConstants.COLOR_SERVICE_TOGGLE_ON
          : CommonConstants.COLOR_SERVICE_TOGGLE_OFF)

      // 滑块：关闭态居左、开启态居右，切换时平滑滑动
      Image($r('app.media.service_toggle_dots_bg'))
        .width(CommonConstants.SERVICE_TOGGLE_KNOB)
        .height(CommonConstants.SERVICE_TOGGLE_KNOB)
        .objectFit(ImageFit.Contain)
        .position({
          x: this.isOn
            ? CommonConstants.SERVICE_TOGGLE_KNOB_ON_X
            : CommonConstants.SERVICE_TOGGLE_KNOB_OFF_X,
          y: CommonConstants.SERVICE_TOGGLE_KNOB_Y
        })
        .animation({
          duration: CommonConstants.SERVICE_TOGGLE_MOTION,
          curve: Curve.FastOutSlowIn
        })
    }
    .width(CommonConstants.SERVICE_TOGGLE_WIDTH)
    .height(CommonConstants.SERVICE_TOGGLE_HEIGHT)
    .onClick(() => {
      this.onChange(!this.isOn)
    })
  }
}
