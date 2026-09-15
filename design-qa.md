# 设计与交互 QA

## 2026-08-03 SDK 与默认反馈最终复核（T-20260803-016）

| 场景 | 验证 | 结果 |
| --- | --- | --- |
| 运行平台 | `build-profile.json5` 的 target/compatible SDK 均为 `6.0.2(22)`，`runtimeOS` 为 `HarmonyOS` | `passed` |
| 原生实现 | Stage、ArkTS、ArkUI；无 WebView 或跨端运行时 | `passed` |
| 振动反馈 | `FeedbackService` 调用系统 `physicalFeedback`，设置开关与控制器回归覆盖 | `passed` |
| 默认反馈 | 新设置、清除全部数据和损坏设置回退均为音效关闭、振动开启 | `passed` |
| 构建与设备 | 主/测试 HAP 构建；OpenHarmonyTestRunner 80/80 | `passed` |

- 标准检查、AppGallery UX、反馈发布检查、深色覆盖和视觉完整性检查均已通过。

## 2026-08-03 全面视觉与反馈时序审查（T-20260803-015）

| 审查轮次 | 范围 | 结果 |
| --- | --- | --- |
| 第一轮：逐项需求 | 双首页隔离、指针几何、图标/硬币伪影、历史主题、五工具音画顺序与时长 | `passed` |
| 第二轮：跨页面/主题 | 浅色首页保持旧版，深色首页使用独立资源；界面冻结后仅调整动画时间和声音调度 | `passed` |
| 第三轮：构建/设备 | 主 HAP、ohosTest HAP 构建成功；OpenHarmonyTestRunner 80/80，Failure 0，Error 0 | `passed` |

- 用户视角时长：是/否 1.4 秒适合轻决策；硬币 2.5 秒保留翻转体验；抽签 3.0 秒覆盖摇动、抽出和余光；罗盘 3.6 秒有完整减速但不再随机拖到 5 秒；指尖 3.0 秒与可见倒计时一致。
- `scripts/check-feedback-sync.ps1` 在罗盘尚未等待过程音时先失败，修复五工具顺序和时间契约后通过。
- 是/否过程态与结果态证据：`docs/qa/screenshots/2026-08-03-final-sync-yesno-pending.png`、`docs/qa/screenshots/2026-08-03-final-sync-yesno-result.png`。
- 模拟器验证 UI 时间和调用顺序；未宣称已完成 HarmonyOS 真机扬声器延迟或多指手感验收。
- `scripts/check-standard.ps1` 已按当前 API 22 / HarmonyOS 6.0.2 配置通过；签名凭据字段仅作为本地发布配置存在，未在文档中记录敏感值。

详细证据：`docs/qa/2026-08-03-visual-audio-audit.md`。

## 2026-08-03 深色页面覆盖与柔和边框修复

| 场景 | 验证 | 结果 |
| --- | --- | --- |
| 静态回归 | `scripts/check-dark-theme-coverage.ps1` 先因缺少深色资源引用失败，修复后覆盖资源、白色输入字、柔和描边和插画圆角 | `passed` |
| 主/测试 HAP | `scripts/build-harmony.ps1` 完成 ArkTS、资源编译、打包与签名 | `passed` |
| 设备测试 | 安装当前主/测试 HAP 并运行 OpenHarmonyTestRunner | `passed`：76/76，Failure 0，Error 0 |
| phone 深色截图 | 首页、抽签、指尖选择、随机数字均在 1320×2856 phone 模拟器复拍 | `passed` |
| 标准检查 | `scripts/check-standard.ps1` 的项目标准与 AppGallery UX 通过；发布检查要求 target API 24，但现工作区配置为 API 22 | `blocked`：既有 SDK 配置不一致，与本次主题改动无关 |

证据：`docs/qa/2026-08-03-dark-theme-coverage.md` 与 `docs/qa/screenshots/2026-08-03-dark-coverage-*.png`。

## 2026-08-03 夜间模式视觉还原

| 场景 | 验证 | 结果 |
| --- | --- | --- |
| 深色令牌 | ThemeResolver 断言覆盖深色背景、卡片、输入、描边、主操作与浅色隔离 | `passed` |
| 主/测试 HAP | 使用 `scripts/build-harmony.ps1` 构建 | `passed` |
| 静态检查 | 使用 `scripts/check-standard.ps1` | `passed` |
| phone 设备截图 | 本轮未启动可用模拟器 | `blocked` |

状态仅使用 `passed`、`blocked` 或明确失败描述。

## 2026-07-29｜API 24 phone 模拟器

### 运行环境

- 设备/模拟器：`127.0.0.1:5555` phone，1320×2856。
- 包名与 Ability：`com.yr23.decision / EntryAbility`。
- 构建产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`。

### 检查结果

| 场景 | 操作前状态 | 用户动作 | 操作后状态 | 结果 | 证据 |
| --- | --- | --- | --- | --- | --- |
| 首屏 | 应用未启动 | 启动 EntryAbility | 首页非白屏，六工具与四模板完整显示 | `passed` | `docs/qa/screenshots/2026-07-29-home-final.jpeg` |
| 导航 | 首页 | 依次点击九个入口 | 对应页面标题、主体和底部操作可见 | `passed` | `docs/qa/screenshots/` |
| 历史空态 | 无历史记录 | 点击历史 | 筛选条与空态完整显示 | `passed` | `docs/qa/screenshots/2026-07-29-history-final.jpeg` |
| 随机数字 | 默认范围 1–100 | 点击 1–10 并生成 | 最大值更新为 10，结果使用大号数字 | `passed` | `docs/qa/screenshots/feedback-random-generated.jpeg` |
| 抛硬币 | 未输入问题 | 抛出反面 | 问题输入可用，“反”与“反面”始终正向可读 | `passed` | `docs/qa/screenshots/feedback-coin-result.jpeg` |
| 历史空态 | 无历史记录 | 点击历史 | 大号筛选条、空态和返回首页按钮完整显示 | `passed` | `docs/qa/screenshots/feedback-history.jpeg` |
| 键盘避让 | 转盘输入框聚焦 | 键盘弹出后向上滑动 | 添加选项与保存模板仍可见、可操作 | `passed` | `docs/qa/screenshots/feedback-wheel-keyboard-scroll.jpeg` |
| 转盘持久化 | 六个模板选项 | 旋转并关闭结果 | Canvas 与下方输入项均保留原值 | `passed` | `docs/qa/screenshots/feedback-wheel-after-close.jpeg` |
| 模板默认值 | 点击两个抽签模板 | 进入抽签页 | 玩家A/B 与张三/李四/王五自动填充 | `passed` | `docs/qa/screenshots/feedback-template-takeout.jpeg` |
| 隐私说明 | 设置页 | 打开隐私说明 | 卡片、间距、标题和正文层级清晰 | `passed` | `docs/qa/screenshots/feedback-privacy.jpeg` |
| 功能回归 | 测试 HAP 已安装 | 运行 OpenHarmonyTestRunner | 63/63 通过 | `passed` | `docs/qa/2026-07-29-ui-restoration.md` |
| 抽签动效 | “谁先开始”模板 | 点击开始抽签 | 五段摇动后签条正向升起并显示结果 | `passed` | `docs/qa/screenshots/2026-07-29-draw-motion-final.jpeg` |
| 转盘二次转动 | 手动输入 Alpha/Beta | 连续转动两次并关闭结果 | Canvas、只读结果行和输入框均保留 Alpha/Beta | `passed` | `docs/qa/screenshots/2026-07-29-wheel-manual-repeat-after-two.jpeg` |
| 功能回归 | 测试 HAP 已安装 | 运行 OpenHarmonyTestRunner | 67/67 通过 | `passed` | `docs/qa/2026-07-29-ui-restoration.md` |
| 最终版本恢复 | 源码被误回退 | 重放原始成功补丁并重新构建安装 | 68/68 设备测试通过 | `passed` | `docs/qa/restored-final-random.json` |
| 随机数字单击 | 默认范围 1–100 | 单击一次 1–10 | 最大值为 10，仅 1–10 高亮 | `passed` | `docs/qa/restored-final-random.json` |
| 应用图标透明 | 1024×1024 黑底圆角图标 | 移除外围黑底并检查 Alpha | 尺寸不变、四角透明、主体像素不变 | `passed` | `entry/src/main/resources/base/media/icon_1.png` |
| 系统导航区避让 | phone 手势导航开启 | 启动首页并进入转盘、滚动到底 | 页面背景延伸至系统栏，底部按钮完整位于导航区上方 | `passed` | `docs/qa/screenshots/2026-07-30-appgallery-wheel-bottom.jpeg` |
| 分层应用图标 | 用户指定 PNG 含像素棋盘格 | 生成并编译 1024×1024 前景/背景资源 | 配置引用分层描述，背景满画布且无透明圆角 | `passed` | `docs/qa/app-icon-layered-composite.png` |
| 深色系统栏 | 设置页为深色主题 | 点击“深色”并截取运行画面 | 状态栏与导航栏内容为白色，在深色背景上清晰可读 | `passed` | `docs/qa/screenshots/2026-07-30-theme-dark.jpeg` |
| 功能回归 | 主/测试 HAP 已安装 | 运行 OpenHarmonyTestRunner | 69/69 通过，Failure 0，Error 0 | `passed` | `docs/qa/2026-07-30-appgallery-ux.md` |
| 滚动边界反馈 | 首页位于顶部 | 从顶部继续向下拖动 | 内容产生 Spring 位移并自动回弹，滚动条不可见 | `passed` | `docs/qa/screenshots/2026-07-30-edge-feedback-active.jpeg` |
| 内页导航区避让 | 进入随机数字与设置页 | 检查页面底部与手势导航区 | 内容完整且背景连续，没有控件被 98px 导航区遮挡 | `passed` | `docs/qa/screenshots/2026-07-30-random-navigation-safe.jpeg` |

### 多设备覆盖

| 设备类型 | 状态 | 说明 |
| --- | --- | --- |
| phone | `passed` | API 24 模拟器完成构建、安装、截图和测试 |
| foldable | `blocked` | 无可用 API 24 foldable 模拟器或真机；动态系统避让逻辑已实现 |
| tablet | `blocked` | 无可用 tablet 设备；720vp 内容宽度、响应式首页与动态系统避让逻辑已实现，未进行设备验收 |
| 2in1 | `blocked` | 当前 module 未声明，不在本轮发布范围 |

### 结论与风险

- phone 竖屏页面已按批准源图完成结构、资源和视觉层级复核。
- 13 条测试反馈均已完成代码修复与 phone 模拟器交互复测。
- 系统状态栏时间、平台字体栅格化和动态随机结果允许存在运行时差异。
- AppGallery 服务端复检仍需使用本次新构建包重新提交；本地 DevEco 资源编译已启用官方 `iconCheck`。

## 2026-08-03｜第二版反馈能力自审

| 场景 | 操作 | 结果 | 状态 | 证据 |
| --- | --- | --- | --- | --- |
| 设置开关关闭 | 依次关闭振动与音效 | 两项设置均保存为关闭，关闭动作不预览反馈 | `passed` | `docs/qa/release-settings-off.json` |
| 设置开关开启 | 依次开启振动与音效 | 两项设置均保存为开启，无“反馈不可用”提示或系统能力错误 | `passed` | `docs/qa/release-settings-on.json`、`docs/qa/screenshots/2026-08-03-feedback-settings-on.jpeg` |
| 重启持久化 | 强制停止并重新启动应用 | 振动与音效仍保持开启 | `passed` | `docs/qa/release-settings-restart.json` |
| 前后台生命周期 | 切到后台再回前台，重新切换音效 | SoundPool 释放后可重新初始化，无播放错误 | `passed` | `docs/qa/release-settings-foreground.json` |
| 六工具反馈覆盖 | 检查转盘、抽签、硬币、是/否、指尖、随机数字调用链 | 六个工具均具有结果音效；可单触操作的五个工具完成运行回归 | `passed` | `docs/qa/2026-08-03-feedback-release-v2.md` |
| 功能回归 | 安装主/测试签名 HAP 并运行 OpenHarmonyTestRunner | 76/76 通过，Failure 0，Error 0 | `passed` | `docs/qa/2026-08-03-feedback-release-v2.md` |

真机马达触感与指尖多触点场景无法由当前模拟器证明；代码调用、开关门控和状态机测试已通过，提交审核前需补一次 HarmonyOS 真机手感验收。

## 2026-08-03｜指尖选择页导航与触控区优化

| 场景 | 操作 | 结果 | 状态 | 证据 |
| --- | --- | --- | --- | --- |
| 浅色布局 | 进入指尖选择页 | 44vp 卡片式返回键、小提示移除、两个功能键位于手势导航区上方 | `passed` | `docs/qa/screenshots/2026-08-03-finger-layout-light.jpeg` |
| 深色布局 | 切换深色主题后进入指尖选择页 | 返回键、文本与底部功能键保持清晰，底部不侵入手势导航区 | `passed` | `docs/qa/screenshots/2026-08-03-finger-layout-dark.jpeg` |
| 触控边界 | 审计主体触控层与按钮层 | 多指监听只绑定至可伸展主体，返回键与两个功能键在监听层外 | `passed` | `scripts/check-finger-select-layout.ps1`、`FingerSelectionMachine` 设备测试 |
| 功能回归 | 安装主/测试 HAP 并运行 OpenHarmonyTestRunner | 76/76 通过，Failure 0，Error 0 | `passed` | `docs/qa/2026-08-03-finger-select-layout.md` |
