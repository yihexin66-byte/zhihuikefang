/**
 * 快捷服务（子组件）：请勿打扰 / 清理房间 两张圆角金色卡片 + 晚安模式通栏横幅
 * 视觉：三处卡片均为鎏金渐变常亮，不再区分选中态
 * 交互：每次点击弹出开启 / 关闭轻提示（不做真实设备控制）
 */
import { BusinessError } from '@kit.BasicServicesKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { HomeViewModel } from '../viewModel/HomeViewModel'

/**
 * 服务卡：鎏金渐变常亮底 + 图标 + 文案
 */
@ComponentV2
struct QuickServiceCard {
  @Require @Param icon: Resource
  @Require @Param label: string
  /** 点击回调：仅转发，状态与轻提示文案由上层处理 */
  @Event onToggle: () => void = () => {}

  build() {
    Stack() {
      // 鎏金渐变常亮底
      Image($r('app.media.home_layer_scenemode'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Row({ space: CommonConstants.SPACE_XS }) {
        Image(this.icon)
          .width(CommonConstants.ICON_QUICK)
          .height(CommonConstants.ICON_QUICK)
          .objectFit(ImageFit.Contain)
          .borderRadius(12)

        Text(this.label)
          .fontSize(CommonConstants.FONT_TINY)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_GOLD_TEXT)
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1)
    .height(CommonConstants.QUICK_CARD_HEIGHT)
    .borderRadius(CommonConstants.FIELD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_GOLD_CARD_RIM })
    .clip(true)
    .onClick(() => {
      this.onToggle()
    })
  }
}

@ComponentV2
export struct QuickServiceSection {
  @Require @Param viewModel: HomeViewModel

  /**
   * 分区标题：金色竖条 + 标题文字（与场景模式分区样式统一）
   */
  @Builder
  sectionHeader() {
    Row() {
      Column()
        .width(3)
        .height(12)
        .backgroundColor(CommonConstants.COLOR_GOLD)
        .borderRadius(2)

      Text(this.viewModel.quickServiceTitle)
        .fontSize(CommonConstants.FONT_SECTION_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .letterSpacing(1)
        .margin({ left: CommonConstants.SPACE_XS })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 轻提示：属增强反馈，展示失败不阻断交互
   */
  private showTip(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 })
    } catch (err) {
      const error = err as BusinessError
      this.viewModel.logTipFailure(`${error.code} ${error.message}`)
    }
  }

  /**
   * 晚安模式：通栏鎏金横幅，左「晚安模式 · 一键关闭所有灯光」，右侧月亮图标
   * 点击切换开 / 关并弹出对应轻提示
   */
  @Builder
  nightBanner() {
    Stack() {
      Image($r('app.media.home_layer_night'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)

      Row() {
        Text(this.viewModel.nightModeLabel)
          .fontSize(CommonConstants.FONT_BANNER_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_GOLD_TEXT)
          .letterSpacing(1)

        Text(this.viewModel.nightBannerText)
          .fontSize(CommonConstants.FONT_TINY)
          .fontColor(CommonConstants.COLOR_GOLD_TEXT)
          .opacity(0.75)
          .margin({ left: CommonConstants.SPACE_S })

        Blank()

        Image($r('app.media.home_icon_night_right'))
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
      }
      .width('100%')
      .height('100%')
      .padding({ left: CommonConstants.SPACE_M, right: CommonConstants.SPACE_M })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(CommonConstants.NIGHT_BANNER_HEIGHT)
    .borderRadius(CommonConstants.FIELD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_GOLD_CARD_RIM })
    .clip(true)
    .onClick(() => {
      this.showTip(this.viewModel.toggleNightMode())
    })
  }

  build() {
    Column({ space: CommonConstants.SPACE_XS }) {
      this.sectionHeader()

      // 两张服务卡：请勿打扰（月亮） / 清理房间（扫帚）
      Row({ space: CommonConstants.SPACE_XS }) {
        QuickServiceCard({
          icon: $r('app.media.home_icon_night_right'),
          label: this.viewModel.dndLabel,
          onToggle: () => {
            this.showTip(this.viewModel.toggleDnd())
          }
        })

        QuickServiceCard({
          icon: $r('app.media.home_icon_clear'),
          label: this.viewModel.cleanLabel,
          onToggle: () => {
            this.showTip(this.viewModel.toggleClean())
          }
        })
      }
      .width('100%')

      // 晚安模式通栏横幅
      this.nightBanner()
    }
    .width('100%')
  }
}