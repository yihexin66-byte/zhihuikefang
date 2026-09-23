/**
 * 退出登录按钮（子组件）：红色胶囊按钮，居中展示
 * 图元：设计稿整幅红色胶囊（登出图标 + 退出登录文字）
 * 交互：点击清除本地登录状态并路由跳转回登录页；Button 自带按压反馈
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'

@ComponentV2
export struct ServiceLogoutButton {
  /** 无障碍文案：图元内已含「退出登录」字样，此处供读屏使用 */
  @Require @Param label: string
  /** 点击回调：仅转发，退出登录逻辑由 ViewModel 与页面处理 */
  @Event onTrigger: () => void = () => {}

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Image($r('app.media.service_btn_logout'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
    }
    // 宽度按内容区百分比给定、高度等比推导（设计稿 1210:322），不硬编码胶囊尺寸
    .width(`${CommonConstants.SERVICE_LOGOUT_WIDTH_PCT}%`)
    .aspectRatio(CommonConstants.SERVICE_LOGOUT_RATIO)
    .backgroundColor(Color.Transparent)
    .padding(0)
    .borderRadius(0)
    .accessibilityText(this.label)
    .onClick(() => {
      this.onTrigger()
    })
  }
}
