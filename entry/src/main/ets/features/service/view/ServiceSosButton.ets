/**
 * SOS 紧急呼叫按钮（子组件）：金色渐变大圆角卡片，居中展示
 * 图元：设计稿整幅 SOS 卡（金色圆角底 + 红色铃铛 + 深色加粗 SOS 文字）
 * 交互：点击弹出轻提示（不跳转、不对接真实报警系统）；Button 自带按压反馈
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'

@ComponentV2
export struct ServiceSosButton {
  /** 无障碍文案：图元内已含 SOS 字样，此处供读屏使用 */
  @Require @Param label: string
  /** 点击回调：仅转发，轻提示文案由 ViewModel 提供 */
  @Event onTrigger: () => void = () => {}

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Image($r('app.media.service_btn_sos_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    // 高度由宽度等比推导（设计稿 1210:451）
    .aspectRatio(CommonConstants.SERVICE_SOS_RATIO)
    .backgroundColor(Color.Transparent)
    .padding(0)
    .borderRadius(0)
    .accessibilityText(this.label)
    .onClick(() => {
      this.onTrigger()
    })
  }
}
