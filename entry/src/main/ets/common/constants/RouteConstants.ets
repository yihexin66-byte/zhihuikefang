/**
 * 路由常量：统一收敛，避免魔法字符串散落
 * 命名规范：应用级路由加 app. 前缀，域内路由直接用功能名
 */
export class RouteConstants {
  // 应用级路由（根栈 AppNavigation 注册）
  static readonly LOGIN: string = 'app.Login'    // 登录入住页（首屏）
  static readonly HOME: string = 'app.Home'      // 智慧客房控制首页（第 2 屏）

  /** 智慧客房控制首页（第 2 屏）是否已接入：就绪后置 true，「立即入住」即真正跳转 */
  static readonly HOME_READY: boolean = true
}