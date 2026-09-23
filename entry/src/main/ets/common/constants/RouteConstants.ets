/**
 * 路由常量：统一收敛，避免魔法字符串散落
 * 命名规范：应用级路由加 app. 前缀，域内路由直接用功能名
 */
export class RouteConstants {
  // 应用级路由（根栈 AppNavigation 注册）；首屏登录页直接作为 Navigation 内容页，不经路由表
  static readonly HOME: string = 'app.Home'      // 智慧客房控制首页（登录页「立即入住」跳转目标）
}