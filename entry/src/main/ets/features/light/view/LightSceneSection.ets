/**
 * 场景模式区（子组件）：明亮 / 柔和 / 阅读 / 温馨 / 睡眠 五个淡金胶囊，两两一行，末项单独一行
 * 容器：半透明圆角卡片（金描边），与独立控制区上下呼应
 * 视觉：淡金胶囊底 + 深色文字；选中提亮并加亮金描边与光晕，未选中略压暗；默认全部未选中
 * 交互：单选互斥，再次点击已选中项取消；选中 / 取消均联动独立控制区对应开关，并与首页同名场景双向同步
 */
import { BusinessError } from '@kit.BasicServicesKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { LightSceneItem } from '../model/LightModel'
import { LightViewModel } from '../viewModel/LightViewModel'

/**
 * 单个场景胶囊：图标 + 文案，选中 / 未选中两套观感
 */
@ComponentV2
struct LightSceneCapsule {
  @Require @Param item: LightSceneItem
  @Require @Param selected: boolean
  /** 点击回调：仅转发，选中状态与轻提示文案由上层处理 */
  @Event onTap: () => void = () => {}

  private glowOn: ShadowOptions = {
    radius: CommonConstants.CAPSULE_GLOW_RADIUS,
    color: CommonConstants.COLOR_SWITCH_GLOW
  }
  private glowOff: ShadowOptions = {
    radius: CommonConstants.SWITCH_GLOW_RADIUS_OFF,
    color: CommonConstants.COLOR_SWITCH_GLOW
  }

  build() {
    Stack() {
      // 淡金胶囊底：选中满色提亮，未选中略压暗
      Image($r('app.media.light_btn_mode_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .opacity(this.selected ? 1 : CommonConstants.OPACITY_CAPSULE_IDLE)
        .brightness(this.selected
          ? CommonConstants.BRIGHTNESS_CAPSULE_ON
          : CommonConstants.BRIGHTNESS_CAPSULE_OFF)

      Row({ space: CommonConstants.SPACE_XS }) {
        Image(this.item.icon)
          .width(CommonConstants.LIGHT_CAPSULE_ICON)
          .height(CommonConstants.LIGHT_CAPSULE_ICON)
          .objectFit(ImageFit.Contain)

        Text(this.item.label)
          .fontSize(CommonConstants.FONT_LIGHT_CAPSULE)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_GOLD_TEXT)
          .maxLines(1)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .layoutWeight(1)
    .height(CommonConstants.LIGHT_CAPSULE_HEIGHT)
    .borderRadius(CommonConstants.LIGHT_CAPSULE_HEIGHT / 2)
    .border({
      width: this.selected ? CommonConstants.CAPSULE_BORDER_WIDTH_ON : 1,
      color: this.selected
        ? CommonConstants.COLOR_CAPSULE_BORDER_ON
        : CommonConstants.COLOR_CAPSULE_BORDER_OFF
    })
    .shadow(this.selected ? this.glowOn : this.glowOff)
    .clip(true)
    .onClick(() => {
      this.onTap()
    })
  }
}

@ComponentV2
export struct LightSceneSection {
  @Require @Param viewModel: LightViewModel

  /**
   * 分区标题：卡片内白色标题（与独立控制区标题同一字级）
   */
  @Builder
  sectionHeader() {
    Text(this.viewModel.sceneSectionTitle)
      .fontSize(CommonConstants.FONT_SECTION_TITLE)
      .fontWeight(FontWeight.Medium)
      .fontColor(CommonConstants.COLOR_TEXT_MAIN)
      .letterSpacing(1)
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
   * 胶囊点击：状态交给共享状态，轻提示文案由 ViewModel 返回后展示
   */
  private handleSceneTap(id: string): void {
    this.showTip(this.viewModel.toggleScene(id))
  }

  /**
   * 单个胶囊：选中与否直接取自共享状态，任一页面变更即联动刷新
   */
  @Builder
  capsule(item: LightSceneItem) {
    LightSceneCapsule({
      item: item,
      selected: this.viewModel.roomState.selectedSceneId === item.id,
      onTap: () => {
        this.handleSceneTap(item.id)
      }
    })
  }

  /**
   * 一行两个胶囊：宽度用 layoutWeight 弹性分配，适配不同设备尺寸
   */
  @Builder
  capsuleRow(first: LightSceneItem, second: LightSceneItem) {
    Row({ space: CommonConstants.LIGHT_GRID_GAP }) {
      this.capsule(first)
      this.capsule(second)
    }
    .width('100%')
  }

  build() {
    Column({ space: CommonConstants.LIGHT_CARD_TITLE_GAP }) {
      this.sectionHeader()

      // 五选一：两个一行，末项（睡眠模式）单独一行，左侧对齐保持网格感
      this.capsuleRow(this.viewModel.scenes[0], this.viewModel.scenes[1])
      this.capsuleRow(this.viewModel.scenes[2], this.viewModel.scenes[3])
      Row({ space: CommonConstants.LIGHT_GRID_GAP }) {
        this.capsule(this.viewModel.scenes[4])
        Blank()
      }
      .width('100%')
    }
    .width('100%')
    .padding(CommonConstants.LIGHT_CARD_PADDING)
    .backgroundColor(CommonConstants.COLOR_LIGHT_CARD_BG)
    .borderRadius(CommonConstants.LIGHT_CARD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_LIGHT_CARD_BORDER })
    // 与独立控制卡片按设计稿高度比 7:10 分摊剩余高度：屏幕较高时行间均分富余，屏幕较矮时为内容高度
    .layoutWeight(7)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}