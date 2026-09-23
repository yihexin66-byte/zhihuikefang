/**
 * 空调控制卡片（子组件）
 * 上排：左侧「空调」名称 + 运行状态小标签，右上角金色圆形电源按钮
 * 下排：左侧「当前温度 20°C」（金色大字，只读），右侧「设定温度 22°C」+ 圆形加减按钮
 * 状态全部读取 HomeViewModel 的 @Trace 字段，交互只转发事件
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { HomeViewModel } from '../viewModel/HomeViewModel'

@ComponentV2
export struct AirConditionerCard {
  @Require @Param viewModel: HomeViewModel

  // ==================== 上排：名称 · 状态标签 · 电源按钮 ====================

  /**
   * 运行状态小标签：开机「运行中」（金色），关机「已关机」（置灰）
   */
  @Builder
  statusTag() {
    Text(this.viewModel.powerStatusText)
      .fontSize(CommonConstants.FONT_TAG)
      .fontColor(this.viewModel.powerOn
        ? CommonConstants.COLOR_GOLD_LIGHT
        : CommonConstants.COLOR_TEXT_HINT)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .backgroundColor(this.viewModel.powerOn
        ? CommonConstants.COLOR_TAG_BG
        : CommonConstants.COLOR_TAG_BG_OFF)
      .borderRadius(8)
      .border({
        width: 1,
        color: this.viewModel.powerOn
          ? CommonConstants.COLOR_TAG_BORDER
          : CommonConstants.COLOR_TAG_BORDER_OFF
      })
      .margin({ top: 4 })
  }

  /**
   * 金色圆形电源按钮：关机后整体压暗，点击切换开 / 关机
   */
  @Builder
  powerButton() {
    Image($r('app.media.home_icon_close'))
      .width(CommonConstants.POWER_BTN)
      .height(CommonConstants.POWER_BTN)
      .objectFit(ImageFit.Contain)
      .borderRadius(CommonConstants.POWER_BTN / 2)
      .clip(true)
      .opacity(this.viewModel.powerOn ? 1 : 0.4)
      .grayscale(this.viewModel.powerOn ? 0 : 0.8)
      .onClick(() => {
        // 事件只转发：状态变更交给 ViewModel
        this.viewModel.setPower(!this.viewModel.powerOn)
      })
  }

  @Builder
  nameRow() {
    Row() {
      Column() {
        Text(this.viewModel.airConditionerName)
          .fontSize(CommonConstants.FONT_CARD_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_TEXT_MAIN)

        this.statusTag()
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      this.powerButton()
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  // ==================== 下排：当前温度（金色大字）· 设定温度 ====================

  /**
   * 当前温度：只读展示，金色大字
   */
  @Builder
  currentTempBlock() {
    Column() {
      Text(this.viewModel.currentTempLabel)
        .fontSize(CommonConstants.FONT_TINY)
        .fontColor(CommonConstants.COLOR_TEXT_HINT)

      Row() {
        Text(`${this.viewModel.currentTemp}`)
          .fontSize(CommonConstants.FONT_TEMP_CURRENT)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_GOLD_LIGHT)

        Text('°C')
          .fontSize(CommonConstants.FONT_TEMP_UNIT)
          .fontColor(CommonConstants.COLOR_GOLD_LIGHT)
          .margin({ left: 1, bottom: 4 })
      }
      .alignItems(VerticalAlign.Bottom)
      .margin({ top: 1 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 圆形加减按钮：关机或到达 16°C / 30°C 边界即置灰且不响应
   */
  @Builder
  stepButton(icon: Resource, usable: boolean, delta: number) {
    Image(icon)
      .width(CommonConstants.STEP_BTN)
      .height(CommonConstants.STEP_BTN)
      .objectFit(ImageFit.Contain)
      .borderRadius(CommonConstants.STEP_BTN / 2)
      .clip(true)
      .opacity(usable ? 1 : 0.3)
      .enabled(usable)
      .onClick(() => {
        // 事件只转发：状态变更交给 ViewModel
        this.viewModel.stepTemp(delta)
      })
  }

  @Builder
  setTempBlock() {
    Column() {
      Text(this.viewModel.setTempLabel)
        .fontSize(CommonConstants.FONT_TINY)
        .fontColor(CommonConstants.COLOR_TEXT_HINT)

      Row({ space: 8 }) {
        this.stepButton($r('app.media.home_btn_sub'), this.viewModel.canDecrease, -1)

        Row() {
          Text(`${this.viewModel.setTemp}`)
            .fontSize(CommonConstants.FONT_TEMP_SET)
            .fontWeight(FontWeight.Medium)
            .fontColor(CommonConstants.COLOR_TEXT_MAIN)

          Text('°C')
            .fontSize(CommonConstants.FONT_TEMP_UNIT)
            .fontColor(CommonConstants.COLOR_TEXT_SUB)
            .margin({ left: 1, bottom: 3 })
        }
        .alignItems(VerticalAlign.Bottom)
        .width(50)
        .justifyContent(FlexAlign.Center)

        this.stepButton($r('app.media.home_btn_add'), this.viewModel.canIncrease, 1)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 温度区：关机后整体联动置灰（当前温度仍展示，但不可调）
   */
  @Builder
  tempRow() {
    Row({ space: CommonConstants.SPACE_S }) {
      this.currentTempBlock()

      Blank()

      this.setTempBlock()
    }
    .width('100%')
    .alignItems(VerticalAlign.Bottom)
    .opacity(this.viewModel.powerOn ? 1 : 0.45)
  }

  build() {
    Column({ space: CommonConstants.SPACE_XS }) {
      this.nameRow()

      Divider()
        .width('100%')
        .strokeWidth(1)
        .color(CommonConstants.COLOR_DIVIDER_GOLD)

      this.tempRow()
    }
    .width('100%')
    .padding(CommonConstants.HOME_CARD_PADDING)
    .backgroundColor(CommonConstants.COLOR_CARD_BG)
    .borderRadius(CommonConstants.CARD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_CARD_BORDER })
  }
}