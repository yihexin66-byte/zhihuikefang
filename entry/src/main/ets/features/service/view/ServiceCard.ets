/**
 * 服务卡（子组件）：一张淡金卡承载一项客房服务 —— 图标 + 文案 + 开关
 * 卡底：设计稿淡金圆角方形底图（service_*_bg），按 579:629 比例铺满，高度随宽度等比自适应
 * 内容：白色图元按 alpha 通道着深色，压在淡金卡底上，沿用「金底深色字」规范保证对比度
 * 交互：开关事件只转发，状态由 ViewModel 的共享状态持有（与首页快捷服务双向同步）
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { ServiceItem } from '../model/ServiceModel'
import { ServiceToggle } from './ServiceToggle'

@ComponentV2
export struct ServiceCard {
  @Require @Param item: ServiceItem
  /** 开关状态：取自共享状态，与首页同名快捷服务一致 */
  @Require @Param isOn: boolean
  /** 开关回调：仅转发目标状态，联动逻辑由 ViewModel 处理 */
  @Event onSwitch: (on: boolean) => void = (on: boolean) => {}

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 淡金卡底：圆角由底图自带
      Image(this.item.cardBg)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)

      Column({ space: CommonConstants.SERVICE_CARD_SPACE }) {
        // 图标：白色图元按 alpha 通道着色，保证在淡金卡底上的对比度
        Image(this.item.icon)
          .width(`${CommonConstants.SERVICE_CARD_ICON_PCT}%`)
          .aspectRatio(1)
          .objectFit(ImageFit.Contain)
          .renderMode(ImageRenderMode.Template)
          .fillColor(CommonConstants.COLOR_SERVICE_CARD_CONTENT)

        Text(this.item.label)
          .fontSize(CommonConstants.FONT_SERVICE_CARD_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_SERVICE_CARD_CONTENT)
          .letterSpacing(1)

        ServiceToggle({
          isOn: this.isOn,
          onChange: (on: boolean) => {
            this.onSwitch(on)
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding(CommonConstants.SERVICE_CARD_PADDING)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .layoutWeight(1)
    // 高度由宽度等比推导：不同机型均按设计稿比例展示，不硬编码卡片高度
    .aspectRatio(CommonConstants.SERVICE_CARD_RATIO)
  }
}
