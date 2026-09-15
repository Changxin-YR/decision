# 2026-07-30 AppGallery UX 合规验证

## 范围

- 修复 phone、foldable、tablet 底部系统导航栏避让。
- 将应用图标改为 1024×1024 前景/背景分层资源。
- 让透明系统栏内容色跟随显式主题和系统颜色模式。
- 不修改决策算法、业务状态、路由、存储或功能回调。

## 静态与资源证据

- `EntryAbility` 启用 `setWindowLayoutFullScreen(true)`，查询并监听 `TYPE_SYSTEM` 与 `TYPE_NAVIGATION_INDICATOR`。
- 根 `Navigation` 消费 `topSafeAreaPx` 与 `bottomSafeAreaPx`，系统栏颜色设为透明并与应用背景融合。
- `SystemBarService` 使用 `ThemeResolver.systemBarContentColor` 同步状态栏与导航栏内容色；系统配置变化和设置页主题保存均接入该服务。
- AppScope 和 EntryAbility 均引用 `$media:app_icon_layered`。
- 两处前景均为 1024×1024 RGBA 且四角透明，两处背景均为 1024×1024 RGB 且边界不透明，对应文件哈希一致。
- DevEco 生成的 `resConfig.json` 中 `iconCheck` 为 `true`，资源媒体压缩为关闭状态。
- 用户指定源图 SHA-256：`F439622F74ED26F23140BB12E76B73365677593111EE357C005C34D9E152FC9B`。

## API 24 phone 模拟器

- 设备：`127.0.0.1:5555`，1320×2856。
- 状态栏高度：136px；底部手势导航区高度：98px，起始 y=2758。
- 转盘滚动到底后，“保存为模板”边界为 `[56,2492][1264,2660]`，完整位于导航区上方。

| 场景 | 操作 | 断言 | 结果 | 证据 |
| --- | --- | --- | --- | --- |
| 首页 | 启动 EntryAbility | 内容避开状态栏和底部手势区，背景连续 | `passed` | `screenshots/2026-07-30-appgallery-home.jpeg` |
| 转盘首屏 | 从首页进入转盘 | 页头、转盘和输入区未被系统栏遮挡 | `passed` | `screenshots/2026-07-30-appgallery-wheel.jpeg` |
| 转盘底部 | 将整页滚动到底 | 添加选项、完成和保存区域可见且位于导航区上方 | `passed` | `screenshots/2026-07-30-appgallery-wheel-bottom.jpeg` |
| 分层图标 | 合成前景与背景预览 | 用户指定主体清晰，棋盘格未进入生产资源 | `passed` | `app-icon-layered-composite.png` |
| 深色系统栏 | 设置页切换到深色主题 | 状态栏和导航栏内容保持浅色且清晰可读 | `passed` | `screenshots/2026-07-30-theme-dark.jpeg` |
| 功能回归 | 运行 OpenHarmonyTestRunner | 69/69，Failure 0，Error 0 | `passed` | 设备测试输出 |
| 顶部边界反馈 | 首页位于顶部时继续向下拖动 | 内容发生 Spring 位移并回弹，滚动条保持隐藏 | `passed` | `screenshots/2026-07-30-edge-feedback-active.jpeg` |
| 随机数字导航区 | 进入随机数字页 | 底部生成按钮完整位于手势导航区上方 | `passed` | `screenshots/2026-07-30-random-navigation-safe.jpeg` |
| 设置页导航区 | 进入设置页并查看末尾内容 | 隐私入口和说明文字可见，导航区背景连续 | `passed` | `screenshots/2026-07-30-settings-navigation-safe.jpeg` |

UI 树证据：`decision-layout-2026-07-30.json`、`decision-wheel-bottom-2026-07-30.json`、`decision-theme-dark-2026-07-30.json`。

## 构建与回归

- 标准检查：`scripts/check-standard.ps1` 通过，AppGallery UX 检查通过。
- 主 HAP：`entry/build/default/outputs/default/entry-default-signed.hap`，5,838,579 bytes，SHA-256 `88764F8CBFE9B297F76D8F1AC6A3FED2BCEAABFF44D28B87DB7CAE1C56EEE7FA`。
- 测试 HAP：`entry/build/default/outputs/ohosTest/entry-ohosTest-signed.hap`，6,509,845 bytes，SHA-256 `4D552A31216D31788A265B4BD90DEFBC0FB72CA9BCFD9F267048EBECD63DCFEE`。
- Hvigor 主包与测试包均为 `BUILD SUCCESSFUL`，ArkTS 类型检查通过。
- 两个 HAP 重新安装成功；OpenHarmonyTestRunner 为 69 pass、0 failure、0 error。
- `CompileResource` 仅提示工具链生成的密度资源 `icon.png`/`icon_startwindow.png` 无 base 副本；分层源资源的尺寸、描述和官方 `iconCheck` 均通过，该提示不阻断打包。

## 多设备结论

| 设备类型 | 状态 | 说明 |
| --- | --- | --- |
| phone | `passed` | API 24 模拟器完成安装、运行、截图与 69 项测试 |
| foldable | `blocked` | 当前没有可用的 API 24 foldable 模拟器或真机；代码使用动态避让区，不写死 phone 数值 |
| tablet | `blocked` | 当前没有可用的 API 24 tablet 模拟器或真机；九个内页采用 720vp 最大内容宽度并监听窗口避让区变化，未进行设备验收 |

AppGallery 服务端结论只能在重新提交本次新构建包后确认，本文件不把本地检查写成服务端复审通过。
