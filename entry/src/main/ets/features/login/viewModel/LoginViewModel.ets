/**
 * 登录入住页 ViewModel：状态与基础交互逻辑，零 UI
 * 页面文案、默认值、跳转决策全部收敛在这里，View 只负责渲染与转发事件
 */
import { Logger } from '../../../common/log/Logger'
import { RouteConstants } from '../../../common/constants/RouteConstants'
import { LoginDefaults } from '../model/LoginModel'

@ObservedV2
export class LoginViewModel {
  // ==================== 页面文案（固定，一字不改）====================
  readonly title: string = '深信·未来酒店'
  readonly subtitle: string = '专属智臻旅居体验'
  readonly roomPlaceholder: string = '请输入房号'
  readonly accountPlaceholder: string = '请输入用户账号'
  readonly rememberLabel: string = '记住我的信息'
  readonly checkInLabel: string = '立即入住'
  readonly footerSlogan: string =
    '感受 智臻智慧酒店体验，让科技始终如一地懂你。欢迎回家，尽享未来舒适之旅。'

  // ==================== 页面状态 ====================
  /** 房号：默认 2006，仅数字输入 */
  @Trace roomNo: string = LoginDefaults.ROOM_NO
  /** 用户账号：默认 yi */
  @Trace account: string = LoginDefaults.ACCOUNT
  /** 记住我的信息：默认勾选 */
  @Trace rememberMe: boolean = LoginDefaults.REMEMBER_ME
  /** 最近一次操作提示（校验失败原因 / 入住欢迎语），由 View 决定如何呈现 */
  @Trace tipMessage: string = ''

  /**
   * 客房主页（第 2 屏）是否已接入：
   * RouteConstants.HOME_READY 置 true 后，「立即入住」即真正跳转
   */
  readonly homeReady: boolean = RouteConstants.HOME_READY

  private logger: Logger = new Logger('[LoginViewModel]')

  /**
   * 切换「记住我的信息」勾选状态
   */
  toggleRememberMe(): void {
    this.rememberMe = !this.rememberMe
    this.logger.info(`记住我的信息：${this.rememberMe ? '已勾选' : '已取消'}`)
  }

  /**
   * 记录轻提示异常：提示属增强反馈，失败不影响入住主流程
   */
  logTipFailure(reason: string): void {
    this.logger.warn(`轻提示展示失败：${reason}`)
  }

  /**
   * 立即入住：本地校验房号与账号（未对接后端接口）
   * @returns true 校验通过，可放行至客房主页
   */
  checkIn(): boolean {
    if (this.roomNo.trim() === '') {
      this.tipMessage = '请填写房号'
      this.logger.warn('入住校验失败：房号为空')
      return false
    }
    if (this.account.trim() === '') {
      this.tipMessage = '请填写用户账号'
      this.logger.warn('入住校验失败：账号为空')
      return false
    }

    this.tipMessage = `欢迎入住 ${this.roomNo} 房`
    this.logger.info(
      `办理入住：房号 ${this.roomNo}，账号 ${this.account}，记住信息 ${this.rememberMe ? '是' : '否'}`
    )
    return true
  }
}