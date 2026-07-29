# 设计与交互 QA

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

### 多设备覆盖

| 设备类型 | 状态 | 说明 |
| --- | --- | --- |
| phone | `passed` | API 24 模拟器完成构建、安装、截图和测试 |
| tablet | `blocked` | 无可用 tablet 设备；响应式逻辑单测已通过 |
| 2in1 | `blocked` | 当前 module 未声明，不在本轮发布范围 |

### 结论与风险

- phone 竖屏页面已按批准源图完成结构、资源和视觉层级复核。
- 13 条测试反馈均已完成代码修复与 phone 模拟器交互复测。
- 系统状态栏时间、平台字体栅格化和动态随机结果允许存在运行时差异。
