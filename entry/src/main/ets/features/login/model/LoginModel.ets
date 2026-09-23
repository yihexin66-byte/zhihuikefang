/**
 * 登录入住数据模型（纯数据类：零业务逻辑）
 */
export class LoginModel {
  /** 房号：仅数字 */
  roomNo: string = ''
  /** 用户账号 */
  account: string = ''
  /** 是否记住我的信息 */
  rememberMe: boolean = false
}

/**
 * 登录入住页固定参数（需求锁定，请勿改动）
 */
export class LoginDefaults {
  /** 房号默认值 */
  static readonly ROOM_NO: string = '2006'
  /** 用户账号默认值 */
  static readonly ACCOUNT: string = 'yi'
  /** 「记住我的信息」默认勾选 */
  static readonly REMEMBER_ME: boolean = true
}