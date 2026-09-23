/**
 * 独立控制区（子组件）：9 项「图标 + 名称 + 开关」两列网格，末项单独一行
 * 容器：半透明圆角卡片（金描边），与场景模式区上下呼应
 * 视觉：开关图元取自设计稿 light_toggle_on / light_toggle_off；开启时格内淡金高亮、图标与文字提亮，关闭时无色
 * 交互：9 路开关各自独立切换；场景模式选中 / 取消时，由共享状态同步切换对应开关
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { LightControlItem } from '../../../common/model/RoomLightModel'
import { LightViewModel } from '../viewModel/LightViewModel'

/**
 * 单个独立控制格
 */
@ComponentV2
struct LightControlCell {
  @Require @Param item: LightControlItem
  /** 开关回调：仅转发目标状态，联动逻辑由共享状态处理 */
  @Event onSwitch: (on: boolean) => void = (on: boolean) => {}

  build() {
    Row() {
      // 图标：开启提亮，关闭略压
      Image(this.item.icon)
        .width(CommonConstants.LIGHT_CELL_ICON)
        .height(CommonConstants.LIGHT_CELL_ICON)
        .objectFit(ImageFit.Contain)
        .opacity(this.item.on ? 1 : CommonConstants.OPACITY_CONTROL_ICON_IDLE)

      // 名称
      Text(this.item.label)
        .fontSize(CommonConstants.FONT_LIGHT_CELL)
        .fontWeight(this.item.on ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.item.on ? CommonConstants.COLOR_GOLD_LIGHT : CommonConstants.COLOR_TEXT_SUB)
        .maxLines(1)
        .margin({ left: CommonConstants.SPACE_XS })

      Blank()

      // 开关图元：开启 = 滑块在右（light_toggle_on），关闭 = 滑块在左（light_toggle_off）
      Image(this.item.on
        ? $r('app.media.light_toggle_on')
        : $r('app.media.light_toggle_off'))
        .width(CommonConstants.LIGHT_TOGGLE_WIDTH)
        .height(CommonConstants.LIGHT_TOGGLE_HEIGHT)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.onSwitch(!this.item.on)
        })
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ left: CommonConstants.SPACE_XS, right: CommonConstants.SPACE_XS })
    // 开启淡金色高亮，关闭无色
    .backgroundColor(this.item.on ? CommonConstants.COLOR_GOLD_HIGHLIGHT : Color.Transparent)
    .borderRadius(CommonConstants.LIGHT_CARD_RADIUS - 6)
    .alignItems(VerticalAlign.Center)
  }
}

@ComponentV2
export struct LightControlList {
  @Require @Param viewModel: LightViewModel

  /**
   * 分区标题：卡片内白色标题（与场景模式区标题同一字级）
   */
  @Builder
  sectionHeader() {
    Text(this.viewModel.controlSectionTitle)
      .fontSize(CommonConstants.FONT_SECTION_TITLE)
      .fontWeight(FontWeight.Medium)
      .fontColor(CommonConstants.COLOR_TEXT_MAIN)
      .letterSpacing(1)
  }

  /** 单个格子：开关状态来自共享状态，任一页变更即联动刷新 */
  @Builder
  cell(item: LightControlItem) {
    LightControlCell({
      item: item,
      onSwitch: (on: boolean) => {
        this.viewModel.setControl(item.id, on)
      }
    })
  }

  /**
   * 一行两格：等宽弹性分配，行高固定，适配不同设备尺寸
   */
  @Builder
  cellRow(first: LightControlItem, second: LightControlItem) {
    Row({ space: CommonConstants.LIGHT_GRID_GAP }) {
      this.cell(first)
      this.cell(second)
    }
    .width('100%')
    .height(CommonConstants.LIGHT_CELL_HEIGHT)
  }

  build() {
    Column({ space: CommonConstants.LIGHT_CARD_TITLE_GAP }) {
      this.sectionHeader()

      // 9 项两列排布：主灯 / 衣柜灯 · 落地灯 / 壁灯 · 书桌灯 / 右阅读灯 · 左阅读灯 / 排风扇 · 廊灯
      this.cellRow(this.viewModel.roomState.controls[0], this.viewModel.roomState.controls[1])
      this.cellRow(this.viewModel.roomState.controls[2], this.viewModel.roomState.controls[3])
      this.cellRow(this.viewModel.roomState.controls[4], this.viewModel.roomState.controls[5])
      this.cellRow(this.viewModel.roomState.controls[6], this.viewModel.roomState.controls[7])
      Row({ space: CommonConstants.LIGHT_GRID_GAP }) {
        this.cell(this.viewModel.roomState.controls[8])
        Blank()
      }
      .width('100%')
      .height(CommonConstants.LIGHT_CELL_HEIGHT)
    }
    .width('100%')
    .padding(CommonConstants.LIGHT_CARD_PADDING)
    .backgroundColor(CommonConstants.COLOR_LIGHT_CARD_BG)
    .borderRadius(CommonConstants.LIGHT_CARD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_LIGHT_CARD_BORDER })
    // 行高固定、卡片弹性：与场景模式卡片按设计稿高度比 10:7 分摊剩余高度，屏幕较高时行间均分富余
    .layoutWeight(10)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}