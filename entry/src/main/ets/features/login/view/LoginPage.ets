/**
 * 第一屏：登录入住页（View 层）
 * 分层：背景层（酒店实景 + 压暗遮罩）→ 内容层（品牌标题 / 入住表单 / 底部标语）
 * 零业务逻辑：文案、默认值、跳转决策全部取自 LoginViewModel
 */
import { BusinessError } from '@kit.BasicServicesKit'
import { CommonConstants } from '../../../common/constants/CommonConstants'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { HomeRouteParams } from '../../home/model/HomeModel'
import { LoginViewModel } from '../viewModel/LoginViewModel'

@ComponentV2
export struct LoginPage {
  // 根栈：由 AppNavigation 通过 @Provider 下发，用于后续页面跳转
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()

  // 页面状态与逻辑的唯一持有者
  @Local viewModel: LoginViewModel = new LoginViewModel()

  // ==================== 交互事件 ====================

  /**
   * 「立即入住」点击：校验 → 轻提示 →（客房主页就绪后）跳转
   */
  private handleCheckIn(): void {
    const passed: boolean = this.viewModel.checkIn()
    this.showTip(this.viewModel.tipMessage)
    if (!passed) {
      return
    }
    // 客房首页已接入：携带房号跳转，首页在 aboutToAppear 中读取并展示「房号 XXXX」
    if (this.viewModel.homeReady) {
      this.pageStack.pushPathByName(RouteConstants.HOME, HomeRouteParams.of(this.viewModel.roomNo))
    }
  }

  /**
   * 轻提示：属增强反馈，展示失败不阻断入住主流程
   */
  private showTip(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2000 })
    } catch (err) {
      const error = err as BusinessError
      this.viewModel.logTipFailure(`${error.code} ${error.message}`)
    }
  }

  // ==================== 背景层 ====================

  /**
   * 酒店实景背景 + 上下压暗遮罩：保证浅色文字在照片上依旧清晰
   */
  @Builder
  backgroundLayer() {
    Stack() {
      Image($r('app.media.bg_hotel_full'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      // 中部保持通透，上下两端压暗，形成沉浸式景深
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [CommonConstants.COLOR_SCRIM_TOP, 0],
            [CommonConstants.COLOR_SCRIM_MID, 0.34],
            [CommonConstants.COLOR_SCRIM_BOTTOM, 1]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 品牌标题区 ====================

  /**
   * 主标题 + 鎏金分隔线 + 副标题：字级递进，留白克制
   */
  @Builder
  brandBlock() {
    Column() {
      Text(this.viewModel.title)
        .fontSize(CommonConstants.FONT_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.COLOR_TEXT_MAIN)
        .letterSpacing(CommonConstants.LETTER_SPACING_TITLE)

      Divider()
        .width(46)
        .strokeWidth(2)
        .color(CommonConstants.COLOR_GOLD)
        .margin({ top: CommonConstants.SPACE_M, bottom: CommonConstants.SPACE_M })

      Text(this.viewModel.subtitle)
        .fontSize(CommonConstants.FONT_SUBTITLE)
        .fontColor(CommonConstants.COLOR_GOLD_LIGHT)
        .letterSpacing(CommonConstants.LETTER_SPACING_SUBTITLE)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // ==================== 入住表单区 ====================

  /**
   * 房号输入：仅数字，默认 2006
   */
  @Builder
  roomField() {
    Row() {
      Image($r('app.media.icon_input_room'))
        .width(CommonConstants.ICON_INPUT)
        .height(CommonConstants.ICON_INPUT)
        .objectFit(ImageFit.Contain)
        .margin({ right: CommonConstants.SPACE_S })

      TextInput({ placeholder: this.viewModel.roomPlaceholder, text: this.viewModel.roomNo })
        .type(InputType.Number)
        .maxLength(6)
        .fontSize(CommonConstants.FONT_BODY)
        .fontColor(CommonConstants.COLOR_TEXT_SUB)
        .placeholderColor(CommonConstants.COLOR_TEXT_HINT)
        .placeholderFont({ size: CommonConstants.FONT_BODY })
        .caretColor(CommonConstants.COLOR_GOLD)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding(0)
        .height('100%')
        .layoutWeight(1)
        .onChange((value: string) => {
          // 事件只转发：状态变更交给 ViewModel
          this.viewModel.roomNo = value
        })
    }
    .width('100%')
    .height(CommonConstants.FIELD_HEIGHT)
    .padding({ left: CommonConstants.SPACE_M, right: CommonConstants.SPACE_M })
    .backgroundColor(CommonConstants.COLOR_FIELD_BG)
    .borderRadius(CommonConstants.FIELD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_FIELD_BORDER })
  }

  /**
   * 用户账号输入：常规字符，默认 yi
   */
  @Builder
  accountField() {
    Row() {
      Image($r('app.media.icon_input_user'))
        .width(CommonConstants.ICON_INPUT)
        .height(CommonConstants.ICON_INPUT)
        .objectFit(ImageFit.Contain)
        .margin({ right: CommonConstants.SPACE_S })

      TextInput({ placeholder: this.viewModel.accountPlaceholder, text: this.viewModel.account })
        .type(InputType.Normal)
        .maxLength(20)
        .fontSize(CommonConstants.FONT_BODY)
        .fontColor(CommonConstants.COLOR_TEXT_SUB)
        .placeholderColor(CommonConstants.COLOR_TEXT_HINT)
        .placeholderFont({ size: CommonConstants.FONT_BODY })
        .caretColor(CommonConstants.COLOR_GOLD)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding(0)
        .height('100%')
        .layoutWeight(1)
        .onChange((value: string) => {
          // 事件只转发：状态变更交给 ViewModel
          this.viewModel.account = value
        })
    }
    .width('100%')
    .height(CommonConstants.FIELD_HEIGHT)
    .padding({ left: CommonConstants.SPACE_M, right: CommonConstants.SPACE_M })
    .backgroundColor(CommonConstants.COLOR_FIELD_BG)
    .borderRadius(CommonConstants.FIELD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_FIELD_BORDER })
  }

  /**
   * 「记住我的信息」勾选框：默认勾选，点击即切换
   */
  @Builder
  rememberRow() {
    Row() {
      Image(this.viewModel.rememberMe
        ? $r('app.media.icon_input_checked')
        : $r('app.media.icon_input_unchecked'))
        .width(CommonConstants.ICON_CHECKBOX)
        .height(CommonConstants.ICON_CHECKBOX)
        .objectFit(ImageFit.Contain)

      Text(this.viewModel.rememberLabel)
        .fontSize(CommonConstants.FONT_CAPTION)
        .fontColor(CommonConstants.COLOR_TEXT_SUB)
        .margin({ left: CommonConstants.SPACE_XS })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({
      top: CommonConstants.SPACE_XS,
      bottom: CommonConstants.SPACE_XS
    })
    .onClick(() => {
      this.viewModel.toggleRememberMe()
    })
  }

  /**
   * 「立即入住」主按钮：鎏金渐变，全宽居中
   */
  @Builder
  checkInButton() {
    Button(this.viewModel.checkInLabel)
      .type(ButtonType.Normal)
      .width('100%')
      .height(CommonConstants.BTN_HEIGHT)
      .borderRadius(CommonConstants.BTN_RADIUS)
      .fontSize(CommonConstants.FONT_BUTTON)
      .fontWeight(FontWeight.Medium)
      .fontColor(CommonConstants.COLOR_GOLD_TEXT)
      .stateEffect(true)
      .linearGradient({
        direction: GradientDirection.LeftTop,
        colors: [
          [CommonConstants.COLOR_GOLD_LIGHT, 0],
          [CommonConstants.COLOR_GOLD, 0.5],
          [CommonConstants.COLOR_GOLD_DEEP, 1]
        ]
      })
      .margin({ top: CommonConstants.SPACE_S })
      .onClick(() => {
        this.handleCheckIn()
      })
  }

  /**
   * 入住表单：玻璃拟态卡片，承载两个输入框 + 勾选框 + 主按钮
   */
  @Builder
  formCard() {
    Column({ space: CommonConstants.SPACE_M }) {
      this.roomField()
      this.accountField()
      this.rememberRow()
      this.checkInButton()
    }
    .width('100%')
    .padding(CommonConstants.CARD_PADDING)
    .backgroundColor(CommonConstants.COLOR_GLASS_BG)
    .borderRadius(CommonConstants.CARD_RADIUS)
    .border({ width: 1, color: CommonConstants.COLOR_GLASS_BORDER })
    .backdropBlur(20)
  }

  // ==================== 底部品牌标语 ====================

  /**
   * 页面收尾：细线分隔 + 柔和浅色标语（文案固定，一字不改）
   */
  @Builder
  footerSlogan() {
    Column() {
      Divider()
        .width('100%')
        .strokeWidth(1)
        .color(CommonConstants.COLOR_DIVIDER)
        .margin({ bottom: CommonConstants.SPACE_M })

      Text(this.viewModel.footerSlogan)
        .fontSize(CommonConstants.FONT_FOOTER)
        .fontColor(CommonConstants.COLOR_TEXT_FOOTER)
        .lineHeight(CommonConstants.LINE_HEIGHT_FOOTER)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // ==================== 页面装配 ====================

  build() {
    NavDestination() {
      Stack() {
        // 1. 背景层
        this.backgroundLayer()

        // 2. 内容层：标题置顶 · 表单居中 · 标语置底
        Column() {
          this.brandBlock()

          Column() {
            this.formCard()
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)

          this.footerSlogan()
        }
        .width('100%')
        .height('100%')
        .padding({
          left: CommonConstants.PAGE_PADDING,
          right: CommonConstants.PAGE_PADDING,
          top: CommonConstants.SPACE_XL,
          bottom: CommonConstants.SPACE_L
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }
}