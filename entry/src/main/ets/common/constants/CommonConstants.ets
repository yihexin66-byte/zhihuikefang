/**
 * 通用常量：集中管理颜色、字号、间距、尺寸，避免魔法数散落在各页面
 * 视觉基调：智慧科技 × 轻奢旅居 —— 深空蓝实景底 + 鎏金点缀 + 浅色前景文字
 */
export class CommonConstants {
  // ==================== 品牌色 ====================
  static readonly COLOR_GOLD_LIGHT: string = '#F6E3A6'    // 鎏金渐变·亮（按钮左上）
  static readonly COLOR_GOLD: string = '#EFD894'          // 鎏金渐变·中
  static readonly COLOR_GOLD_DEEP: string = '#C19A5B'     // 鎏金渐变·深（按钮右下）
  static readonly COLOR_GOLD_TEXT: string = '#3B2E14'     // 金底上的深色文字（对比度足够）

  // ==================== 前景文字（浅色调，压在酒店实景之上）====================
  static readonly COLOR_TEXT_MAIN: string = '#FFFFFF'                    // 主标题
  static readonly COLOR_TEXT_SUB: string = 'rgba(255,255,255,0.78)'      // 次文本 / 输入内容
  static readonly COLOR_TEXT_HINT: string = 'rgba(255,255,255,0.55)'     // 占位提示
  static readonly COLOR_TEXT_FOOTER: string = 'rgba(255,255,255,0.62)'   // 底部标语（柔和浅色）

  // ==================== 玻璃拟态材质（轻奢质感容器）====================
  static readonly COLOR_GLASS_BG: string = 'rgba(255,255,255,0.12)'        // 表单卡片底
  static readonly COLOR_GLASS_BORDER: string = 'rgba(255,255,255,0.22)'    // 表单卡片描边
  static readonly COLOR_FIELD_BG: string = 'rgba(255,255,255,0.10)'        // 输入框底
  static readonly COLOR_FIELD_BORDER: string = 'rgba(255,255,255,0.18)'    // 输入框描边
  static readonly COLOR_DIVIDER: string = 'rgba(255,255,255,0.14)'         // 分隔线

  // ==================== 背景压暗遮罩（保证浅色文字可读）====================
  static readonly COLOR_SCRIM_TOP: string = 'rgba(6,18,38,0.62)'      // 顶部（标题区）
  static readonly COLOR_SCRIM_MID: string = 'rgba(6,18,38,0.20)'      // 中部（保留实景通透感）
  static readonly COLOR_SCRIM_BOTTOM: string = 'rgba(6,18,38,0.72)'   // 底部（标语区）

  // ==================== 字号 ====================
  static readonly FONT_TITLE: number = 30        // 主标题「深信·未来酒店」
  static readonly FONT_SUBTITLE: number = 14     // 副标题「专属智臻旅居体验」
  static readonly FONT_BODY: number = 16         // 输入框正文
  static readonly FONT_BUTTON: number = 17       // 主按钮
  static readonly FONT_CAPTION: number = 13      // 勾选框说明
  static readonly FONT_FOOTER: number = 12       // 底部品牌标语

  // ==================== 尺寸 ====================
  static readonly PAGE_PADDING: number = 28      // 页面左右安全间距
  static readonly FIELD_HEIGHT: number = 52      // 输入框高度
  static readonly FIELD_RADIUS: number = 14      // 输入框圆角
  static readonly CARD_RADIUS: number = 22       // 表单卡片圆角
  static readonly CARD_PADDING: number = 22      // 表单卡片内边距
  static readonly BTN_HEIGHT: number = 52        // 主按钮高度
  static readonly BTN_RADIUS: number = 26        // 主按钮圆角
  static readonly ICON_INPUT: number = 20        // 输入框图标尺寸
  static readonly ICON_CHECKBOX: number = 18     // 勾选框图标尺寸
  static readonly LETTER_SPACING_TITLE: number = 2   // 主标题字距
  static readonly LETTER_SPACING_SUBTITLE: number = 3 // 副标题字距（轻奢留白）
  static readonly LINE_HEIGHT_FOOTER: number = 20      // 底部标语行高

  // ==================== 间距 ====================
  static readonly SPACE_XS: number = 6
  static readonly SPACE_S: number = 10
  static readonly SPACE_M: number = 16
  static readonly SPACE_L: number = 24
  static readonly SPACE_XL: number = 36

  // ==================== 首页（智慧客房）：暖金实景上的金色轻奢卡片 ====================
  /** 背景压暗遮罩：顶部压暗保标题可读，中部留出暖金光晕，底部压暗衬托悬浮导航 */
  static readonly COLOR_HOME_SCRIM_TOP: string = 'rgba(38,25,10,0.58)'
  static readonly COLOR_HOME_SCRIM_MID: string = 'rgba(38,25,10,0.26)'
  static readonly COLOR_HOME_SCRIM_BOTTOM: string = 'rgba(38,25,10,0.62)'

  /** 金色卡片统一材质（场景模式 / 快捷服务 / 晚安模式）：鎏金渐变常亮，不分选中态 */
  static readonly COLOR_GOLD_CARD_RIM: string = 'rgba(255,244,214,0.62)'         // 鎏金卡片亮金描边

  /** 空调主卡片：深色半透明 + 金色描边（承托金色大字温度） */
  static readonly COLOR_CARD_BG: string = 'rgba(40,29,14,0.55)'
  static readonly COLOR_CARD_BORDER: string = 'rgba(239,216,148,0.30)'
  static readonly COLOR_DIVIDER_GOLD: string = 'rgba(239,216,148,0.18)'

  /** 小标签（运行中 / 已关机 / 开始测试） */
  static readonly COLOR_TAG_BG: string = 'rgba(239,216,148,0.16)'
  static readonly COLOR_TAG_BORDER: string = 'rgba(239,216,148,0.48)'
  static readonly COLOR_TAG_BG_OFF: string = 'rgba(255,255,255,0.08)'
  static readonly COLOR_TAG_BORDER_OFF: string = 'rgba(255,255,255,0.20)'

  /** 底部悬浮导航：圆角描边胶囊，左右不占满 */
  static readonly COLOR_TABBAR_BG: string = 'rgba(28,19,8,0.84)'                 // 导航条底
  static readonly COLOR_TABBAR_BORDER: string = 'rgba(239,216,148,0.24)'         // 导航条描边
  static readonly COLOR_TAB_TEXT_ACTIVE: string = '#FFF7E8'                      // 选中：暖白
  static readonly COLOR_TAB_TEXT_IDLE: string = 'rgba(255,255,255,0.58)'         // 未选中：浅灰白
  static readonly COLOR_TAB_HIGHLIGHT: string = 'rgba(239,216,148,0.14)'         // 选中：微弱高亮底
  static readonly COLOR_TAB_ICON_BORDER: string = 'rgba(239,216,148,0.70)'       // 选中：图标圆角描边
  static readonly COLOR_TAB_ICON_BORDER_IDLE: string = 'rgba(255,255,255,0.26)'  // 未选中：图标圆角描边

  // ==================== 首页字号（与登录页同一套字级规范）====================
  static readonly FONT_GREETING: number = 20         // 问候语「欢迎回家，房号 2006」（占一行）
  static readonly FONT_SECTION_TITLE: number = 14    // 分区标题（场景模式 / 快捷服务）
  static readonly FONT_CARD_TITLE: number = 14       // 卡片标题（空调 / 场景 / 服务项）
  static readonly FONT_BANNER_TITLE: number = 15     // 晚安横幅主文案
  static readonly FONT_TEMP_CURRENT: number = 30     // 当前温度数值（金色大字）
  static readonly FONT_TEMP_SET: number = 19         // 设定温度数值
  static readonly FONT_TEMP_UNIT: number = 13        // 温度单位 °C
  static readonly FONT_TINY: number = 11             // 卡片内说明文字 / 场景与服务项文案
  static readonly FONT_TAB: number = 11              // 底部导航文字
  static readonly FONT_TAG: number = 11              // 小标签文字

  // ==================== 首页尺寸（紧凑排布，整屏无需滚动）====================
  static readonly HOME_GAP: number = 14              // 区块间距
  static readonly HOME_CARD_PADDING: number = 16     // 卡片内边距
  static readonly ICON_SCENE: number = 24            // 场景卡片图标
  static readonly ICON_QUICK: number = 24            // 快捷服务卡片图标
  static readonly ICON_TAB: number = 22              // 底部导航图标
  static readonly STEP_BTN: number = 28              // 温度加减圆形按钮尺寸
  static readonly POWER_BTN: number = 40             // 空调电源圆形按钮尺寸
  static readonly SCENE_CARD_HEIGHT: number = 66     // 场景卡片高度
  static readonly QUICK_CARD_HEIGHT: number = 60     // 快捷服务卡片高度
  static readonly NIGHT_BANNER_HEIGHT: number = 56   // 晚安模式通栏横幅高度
  static readonly TABBAR_HEIGHT: number = 56         // 底部悬浮导航高度
  static readonly TABBAR_RADIUS: number = 24         // 导航条圆角
  static readonly TABBAR_SIDE_MARGIN: number = 18    // 导航条左右留白（不占满）
  static readonly TABBAR_BOTTOM_MARGIN: number = 8   // 导航条距屏幕底部
  static readonly HOME_BOTTOM_CLEARANCE: number = 76 // 内容区避让悬浮导航的底部留白

  // ==================== 灯光控制页：暖金实景上的金色轻奢控件 ====================
  /** 背景压暗遮罩：顶部压暗保标题可读，中部留出暖金光晕，底部压暗衬托悬浮导航 */
  static readonly COLOR_LIGHT_SCRIM_TOP: string = 'rgba(38,25,10,0.64)'
  static readonly COLOR_LIGHT_SCRIM_MID: string = 'rgba(38,25,10,0.30)'
  static readonly COLOR_LIGHT_SCRIM_BOTTOM: string = 'rgba(38,25,10,0.72)'

  /** 总开关：开启金色发光，关闭低饱和置灰 */
  static readonly COLOR_SWITCH_GLOW: string = 'rgba(239,216,148,0.80)'   // 开启态金色光晕
  static readonly SWITCH_GLOW_RADIUS: number = 28                        // 光晕半径
  static readonly SWITCH_GLOW_RADIUS_OFF: number = 0                     // 关闭态无光晕
  static readonly OPACITY_SWITCH_OFF: number = 0.55                      // 关闭态整体压暗

  /** 半透明卡片（场景模式 / 独立控制两个分区容器） */
  static readonly COLOR_LIGHT_CARD_BG: string = 'rgba(38,27,12,0.46)'            // 卡片底
  static readonly COLOR_LIGHT_CARD_BORDER: string = 'rgba(239,216,148,0.24)'     // 金色描边

  /** 开启 / 选中态的淡金高亮（独立控制格、首页场景卡共用） */
  static readonly COLOR_GOLD_HIGHLIGHT: string = 'rgba(239,216,148,0.16)'
  static readonly COLOR_GOLD_BORDER_ON: string = 'rgba(239,216,148,0.52)'
  static readonly OPACITY_CONTROL_ICON_IDLE: number = 0.72               // 关闭态图标透明度

  /** 场景胶囊：淡金底 + 选中提亮描边（金字底压深色文字，保证对比度） */
  static readonly COLOR_CAPSULE_BORDER_ON: string = 'rgba(255,244,214,0.95)'  // 选中：亮金描边
  static readonly COLOR_CAPSULE_BORDER_OFF: string = 'rgba(255,244,214,0.26)' // 未选中：弱金描边
  static readonly OPACITY_CAPSULE_IDLE: number = 0.88                          // 未选中：淡金略降饱和
  static readonly BRIGHTNESS_CAPSULE_ON: number = 1.12                         // 选中：提亮
  static readonly BRIGHTNESS_CAPSULE_OFF: number = 0.94                        // 未选中：略压
  static readonly CAPSULE_GLOW_RADIUS: number = 14                             // 选中：金色光晕半径
  static readonly CAPSULE_BORDER_WIDTH_ON: number = 2                          // 选中：描边加粗
  static readonly BRIGHTNESS_SCENE_CARD_ON: number = 1.14                      // 首页场景卡选中提亮
  static readonly SCENE_CARD_BORDER_WIDTH_ON: number = 2                       // 首页场景卡选中描边加粗

  // ==================== 灯光控制页字号 ====================
  static readonly FONT_LIGHT_TITLE: number = 24          // 页面标题「灯光控制」
  static readonly FONT_LIGHT_SWITCH_LABEL: number = 13   // 总开关名称「总开关」
  static readonly FONT_LIGHT_CELL: number = 13           // 独立控制格内名称
  static readonly FONT_LIGHT_CAPSULE: number = 13        // 场景胶囊文案

  // ==================== 灯光控制页尺寸（照第 3 屏设计稿等比换算，整屏不滚动）====================
  static readonly LIGHT_PAGE_PADDING: number = 18        // 页面左右安全间距（设计稿 18）
  static readonly LIGHT_TOPBAR_HEIGHT: number = 44       // 顶部栏（返回 + 标题）高度
  static readonly LIGHT_BACK_BOX: number = 32            // 返回按钮触摸区（背景透明，图元内缩约 20）
  static readonly LIGHT_MAIN_SWITCH: number = 100        // 总开关图片尺寸
  static readonly LIGHT_CARD_RADIUS: number = 18         // 半透卡片圆角
  static readonly LIGHT_CARD_PADDING: number = 12        // 半透卡片内边距
  static readonly LIGHT_CARD_TITLE_GAP: number = 8       // 卡片标题与首行间距
  static readonly LIGHT_CAPSULE_HEIGHT: number = 36      // 场景胶囊高度
  static readonly LIGHT_CELL_HEIGHT: number = 36         // 独立控制格行高（与胶囊同高，网格工整）
  static readonly LIGHT_CAPSULE_ICON: number = 16        // 场景胶囊图标
  static readonly LIGHT_GRID_GAP: number = 8             // 网格横纵间距（胶囊与开关格共用）
  static readonly LIGHT_CELL_ICON: number = 18           // 独立控制格图标
  static readonly LIGHT_TOGGLE_WIDTH: number = 36        // 开关图元宽度（light_toggle_*，比例 1.78:1）
  static readonly LIGHT_TOGGLE_HEIGHT: number = 20       // 开关图元高度

  // ==================== 窗帘控制页：暖金实景上的金色轻奢卡片 ====================
  /** 背景压暗遮罩：顶部压暗保标题可读，中部留出暖金光晕，底部压暗衬托悬浮导航 */
  static readonly COLOR_CURTAIN_SCRIM_TOP: string = 'rgba(38,25,10,0.62)'
  static readonly COLOR_CURTAIN_SCRIM_MID: string = 'rgba(38,25,10,0.24)'
  static readonly COLOR_CURTAIN_SCRIM_BOTTOM: string = 'rgba(38,25,10,0.70)'

  /** 顶部「全部打开 / 全部关闭」胶囊：选中态用设计稿金色胶囊底图，未选中态沿用半透卡片材质 */
  static readonly COLOR_CURTAIN_MODE_BORDER_OFF: string = 'rgba(255,244,214,0.26)'  // 未选中：弱金描边
  static readonly OPACITY_CURTAIN_MODE_IDLE: number = 0.90                          // 未选中：图元与文字略降饱和
  static readonly CURTAIN_MODE_BORDER_WIDTH_ON: number = 2                          // 选中：描边加粗（压住金色底图边缘）

  /** 布帘 / 窗纱卡片与卡片内预览区 */
  static readonly CURTAIN_STAGE_WIDTH_PCT: number = 76   // 预览区（帘体 + 窗帘杆）宽度占卡片内宽百分比
  static readonly CURTAIN_ROD_RATIO: number = 19.3       // 窗帘杆图元宽高比（curtain_icon_top_bar 655:34）
  static readonly CURTAIN_PANEL_CLOSED_PCT: number = 50  // 关闭态单侧帘宽（占预览区宽度）：两半在中间合拢
  static readonly CURTAIN_PANEL_OPEN_PCT: number = 44    // 打开态单侧帘宽（占预览区宽度）：两半收向两侧留出中缝
  static readonly CURTAIN_PANEL_SLIDE_PCT: number = 5    // 开合过程中帘体向外滑动位移（占预览区宽度）

  // ==================== 窗帘控制页字号 ====================
  static readonly FONT_CURTAIN_TITLE: number = 24        // 页面标题「窗帘控制」
  static readonly FONT_CURTAIN_CARD_TITLE: number = 15   // 卡片标题「布帘」「窗纱」
  static readonly FONT_CURTAIN_MODE: number = 14         // 顶部胶囊文案
  static readonly FONT_CURTAIN_BTN: number = 12          // 打开 / 暂停 / 关闭 按钮文案

  // ==================== 窗帘控制页尺寸（照第 4 屏设计稿等比换算，整屏不滚动）====================
  static readonly CURTAIN_PAGE_PADDING: number = 18      // 页面左右安全间距（与灯光页一致）
  static readonly CURTAIN_TOPBAR_HEIGHT: number = 44     // 顶部栏（返回 + 标题）高度（与灯光页一致）
  static readonly CURTAIN_BACK_BOX: number = 32          // 返回按钮触摸区（背景透明，图元内缩约 20）
  static readonly CURTAIN_BLOCK_GAP: number = 10         // 顶部栏 / 胶囊 / 卡片之间的纵向间距
  static readonly CURTAIN_MODE_HEIGHT: number = 38       // 顶部胶囊高度
  static readonly CURTAIN_MODE_ICON: number = 18         // 顶部胶囊图标
  static readonly CURTAIN_CARD_RADIUS: number = 18       // 半透明卡片圆角（与灯光页一致）
  static readonly CURTAIN_CARD_PADDING: number = 10      // 半透明卡片内边距
  static readonly CURTAIN_CARD_TITLE_GAP: number = 6     // 卡片标题与预览区间距
  static readonly CURTAIN_BTN_SIZE: number = 40          // 打开 / 暂停 / 关闭 圆形按钮直径
  static readonly CURTAIN_BTN_ICON: number = 20          // 圆形按钮图标
  static readonly CURTAIN_BTN_ROW_GAP: number = 8        // 按钮行与预览区间距
  static readonly CURTAIN_BTN_LABEL_GAP: number = 4      // 圆形按钮与下方文案间距

  // ==================== 窗帘开合动画 ====================
  /** 开合动画时长：帘体缓缓移动，过渡丝滑（暂停后保持当前位置） */
  static readonly CURTAIN_MOTION_DURATION: number = 1500
}