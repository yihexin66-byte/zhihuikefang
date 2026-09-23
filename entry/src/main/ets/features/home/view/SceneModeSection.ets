/**
 * 场景模式（子组件）：明亮 / 柔和 / 阅读 / 温馨 四张圆角金色卡片，2×2 排布
 * 视觉：四张卡均为鎏金渐变常亮，不再区分选中态
 * 交互：单选互斥（点击未开启的卡开启，再次点击已开启的卡关闭），每次点击弹出开启 / 关闭轻提示
 */
import { BusinessError } from '@kit.BasicServicesKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { SceneModeItem } from '../model/HomeModel'
import { HomeViewModel } from '../viewModel/HomeViewModel'

/**
 * 单张场景卡：鎏金渐变常亮底 + 图标 + 文案
 */
@ComponentV2
struct SceneModeCard {
  @Require @Param item: SceneModeItem
  /** 点击回调：仅转发，状态与轻提示文案由上层处理 */
  @Event onToggle: () => void = () => {}

  build() {
    Stack() {
      // 鎏金渐变常亮底
      Image($r('app.media.home_layer_scenemode'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        Image(this.item.icon)
          .width(CommonConstants.ICON_SCENE)
          .height(CommonConstants.ICON_SCENE)
          .objectFit(ImageFit.Contain)

        Text(this.item.label)
          .fontSize(CommonConstants.FONT_TINY)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.COLOR_GOLD_TEXT)
          .margin({ top: 3 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1)
    .height(CommonConstants.SCENE_CARD_HEIGHT)
    .borderRadius(CommonConstants.FIELD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_GOLD_CARD_RIM })
    .clip(true)
    .onClick(() => {
      this.onToggle()
    })
  }
}

@ComponentV2
export struct SceneModeSection {
  @Require @Param viewModel: HomeViewModel

  /**
   * 分区标题：金色竖条 + 标题文字（与快捷服务分区样式统一）
   */
  @Builder
  sectionHeader() {
    Row() {
      Column()
        .width(3)
        .height(12)
        .backgroundColor(CommonConstants.COLOR_GOLD)
        .borderRadius(2)

      Text(this.viewModel.sceneSectionTitle)
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
   * 场景卡点击：状态交给 ViewModel，轻提示文案由 ViewModel 返回后展示
   */
  private handleSceneTap(id: string): void {
    this.showTip(this.viewModel.toggleScene(id))
  }

  /**
   * 一行两张卡：宽度用 layoutWeight 弹性分配，适配不同设备尺寸
   */
  @Builder
  sceneRow(first: SceneModeItem, second: SceneModeItem) {
    Row({ space: CommonConstants.SPACE_XS }) {
      SceneModeCard({
        item: first,
        onToggle: () => {
          this.handleSceneTap(first.id)
        }
      })
      SceneModeCard({
        item: second,
        onToggle: () => {
          this.handleSceneTap(second.id)
        }
      })
    }
    .width('100%')
  }

  build() {
    Column({ space: CommonConstants.SPACE_XS }) {
      this.sectionHeader()

      // 四张卡按 2×2 弹性排布
      this.sceneRow(this.viewModel.sceneModes[0], this.viewModel.sceneModes[1])
      this.sceneRow(this.viewModel.sceneModes[2], this.viewModel.sceneModes[3])
    }
    .width('100%')
  }
}