/**
 * 应用唯一入口（唯一 @Entry）：创建根栈、注册应用级路由、承载首屏
 */
import { RouteConstants } from '../common/constants/RouteConstants'
import { HomePage } from '../features/home/view/HomePage'
import { LoginPage } from '../features/login/view/LoginPage'

@Entry
@ComponentV2
struct AppNavigation {
  // 一级导航：根栈。@Provider 下发全局，任意层级用 @Consumer('pageStack') 直接消费
  @Provider('pageStack') pageStack: NavPathStack = new NavPathStack()

  /**
   * 应用级路由注册表
   * 首屏为登录入住页，直接作为 Navigation 的内容页（栈空时展示），不经此表
   * HOME：智慧客房控制首页，路由参数为 HomeRouteParams（携带房号）
   */
  @Builder
  RootRouter(name: string, param: Object) {
    if (name === RouteConstants.HOME) {
      // 房号经 param 传入，由 HomePage 在 aboutToAppear 中解析（未传时保底 2002）
      HomePage({ routeParam: param })
    }
  }

  build() {
    Navigation(this.pageStack) {
      // 首屏：登录入住页（栈空时显示的内容页）
      LoginPage()
    }
    .mode(NavigationMode.Stack)
    .navDestination(this.RootRouter)
    .hideTitleBar(true)
  }
}