/**
 * 顶部标题栏（子组件）：左上角返回按钮（仅箭头图元，按钮背景完全透明）+ 居中页面标题
 * 与灯光页 / 窗帘页顶部栏同一套尺寸与字级，保证四个主页面层级一致
 */
import { CommonConstants } from '../../../common/constants/CommonConstants'

@ComponentV2
export struct ServiceTopBar {
  /** 页面标题（固定文案，由 ViewModel 提供） */
  @Require @Param title: string
  /** 返回回调：由导航壳注入（切回首页 Tab） */
  @Event onBack: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        Image($r('app.media.light_icon_back'))
          // 触摸区 32×32、图元内缩后约 20×20；按钮背景保持透明，仅箭头压在页面背景上
          .width(CommonConstants.SERVICE_BACK_BOX)
          .height(CommonConstants.SERVICE_BACK_BOX)
          .padding(CommonConstants.SPACE_XS)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.onBack()
          })

        Blank()
      }
      .width('100%')
      .height('100%')

      Text(this.title)
        .fontSize(CommonConstants.FONT_SERVICE_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .letterSpacing(CommonConstants.LETTER_SPACING_TITLE)
    }
    .width('100%')
    .height(CommonConstants.SERVICE_TOPBAR_HEIGHT)
  }
}
