# “做个决定”UI 像素级还原 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在保留现有功能、状态机和本地数据行为的前提下，将手机竖屏 UI 还原为 12 张已批准设计稿，并完成构建、设备截图和 Claude Code 复核。

**Architecture:** 保留 `domain/`、`stores/`、`services/` 与 `data/`，只重构视觉令牌、媒体资源、共享组件和页面编排。相同功能的多张设计稿由模板数据驱动，共用一套转盘或抽签页面；所有视觉尺寸通过共享令牌和组件控制。

**Tech Stack:** HarmonyOS API 24、Stage 模型、ArkTS、ArkUI、Preferences、Hypium、Hvigor、HDC、PowerShell 图像处理。

---

## 文件结构

**创建：**

- `design/image2-sources/README.md`：记录 12 张批准源图与用途。
- `docs/ui/asset-manifest.md`：记录源图、裁切、资源尺寸与页面用途。
- `scripts/prepare-ui-assets.ps1`：从批准源图生成可重复的 PNG 资源。
- `entry/src/main/resources/base/media/ui_*.png`：抽签盒、指尖、硬币和入口图标资源。
- `entry/src/ohosTest/ets/test/VisualTokens.test.ets`：视觉令牌回归测试。
- `docs/qa/2026-07-29-ui-restoration.md`：构建、运行和视觉比对证据。
- `docs/qa/screenshots/2026-07-29-*.png`：手机与 tablet 运行截图。

**修改：**

- `entry/src/main/ets/constants/DesignTokens.ets`：设计稿颜色、尺寸、圆角与阴影。
- `entry/src/main/ets/constants/PresetTemplates.ets`：设计稿对应模板候选项。
- `entry/src/main/ets/components/common/AppButton.ets`
- `entry/src/main/ets/components/common/AppCard.ets`
- `entry/src/main/ets/components/common/AppInput.ets`
- `entry/src/main/ets/components/common/PageHeader.ets`
- `entry/src/main/ets/components/common/ResultSheet.ets`
- `entry/src/main/ets/components/decision/OptionsEditor.ets`
- `entry/src/main/ets/components/decision/WheelCanvas.ets`
- `entry/src/main/ets/components/decision/DrawTube.ets`
- `entry/src/main/ets/components/decision/CoinView.ets`
- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/pages/Wheel.ets`
- `entry/src/main/ets/pages/Draw.ets`
- `entry/src/main/ets/pages/FingerSelect.ets`
- `entry/src/main/ets/pages/Coin.ets`
- `entry/src/main/ets/pages/YesNo.ets`
- `entry/src/main/ets/pages/RandomNumber.ets`
- `entry/src/main/ets/pages/History.ets`
- `entry/src/main/ets/pages/Settings.ets`
- `entry/src/ohosTest/ets/test/List.test.ets`
- `tasks.md`、`changes.md`、`design.md`、`design-qa.md`：标准化交付记录；若文件缺失则从项目标准模板创建。

## Task 1: 建立基线、标准文件和视觉令牌测试

**Files:**

- Create or modify: `tasks.md`
- Create or modify: `changes.md`
- Create or modify: `design.md`
- Create or modify: `design-qa.md`
- Create or modify: `docs/qa/README.md`
- Create: `entry/src/ohosTest/ets/test/VisualTokens.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`
- Modify: `entry/src/main/ets/constants/DesignTokens.ets`

- [ ] **Step 1: 运行只读标准门禁并记录现有缺口**

Run:

```powershell
python "C:\Users\27363\Desktop\harmonyos-project-standard-cn\scripts\check_harmonyos_standard.py" "C:\Users\27363\Desktop\max\decision" --json
```

Expected: JSON 明确列出缺失标准文件；不把警告记录为已通过。

- [ ] **Step 2: 在 `tasks.md` 登记唯一进行中任务**

```markdown
## UI-20260729

- 目标：按 12 张设计稿还原手机竖屏 UI，保留现有功能。
- 状态：in_progress
- 验收：静态门禁、Hypium、Debug HAP、手机截图、tablet 可用性、Claude Code 复核。
```

- [ ] **Step 3: 写入会失败的视觉令牌测试**

```ts
import { describe, expect, it } from '@ohos/hypium';
import { AppFontSizes, AppRadii, AppSpacing } from '../../../main/ets/constants/DesignTokens';

export default function visualTokensTest(): void {
  describe('VisualTokens', (): void => {
    it('matches approved compact-phone metrics', 0, (): void => {
      expect(AppSpacing.PAGE_HORIZONTAL).assertEqual(16);
      expect(AppRadii.CARD).assertEqual(12);
      expect(AppRadii.PRIMARY_BUTTON).assertEqual(10);
      expect(AppFontSizes.PAGE_TITLE).assertEqual(22);
    });
  });
}
```

在 `List.test.ets` 中导入并调用 `visualTokensTest()`。

- [ ] **Step 4: 构建测试 HAP，确认缺少新令牌而失败**

Run:

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
```

Expected: TypeScript/ArkTS 报告 `PAGE_HORIZONTAL`、`PRIMARY_BUTTON` 或 `PAGE_TITLE` 不存在。

- [ ] **Step 5: 扩展令牌并保持旧调用兼容**

```ts
export class AppSpacing {
  static readonly XS: number = 4;
  static readonly SM: number = 8;
  static readonly MD: number = 16;
  static readonly LG: number = 24;
  static readonly XL: number = 32;
  static readonly PAGE_HORIZONTAL: number = 16;
  static readonly SECTION: number = 18;
  static readonly ROW: number = 12;
}

export class AppRadii {
  static readonly INPUT: number = 8;
  static readonly CARD: number = 12;
  static readonly DIALOG: number = 20;
  static readonly PRIMARY_BUTTON: number = 10;
  static readonly ICON_BUTTON: number = 10;
}

export class AppFontSizes {
  static readonly PAGE_TITLE: number = 22;
  static readonly TITLE: number = 24;
  static readonly HEADING: number = 18;
  static readonly BODY: number = 15;
  static readonly CAPTION: number = 12;
}
```

- [ ] **Step 6: 重新构建测试 HAP**

Expected: `BUILD SUCCESSFUL`。

- [ ] **Step 7: 提交任务 1**

```powershell
git add tasks.md changes.md design.md design-qa.md docs/qa/README.md entry/src/main/ets/constants/DesignTokens.ets entry/src/ohosTest/ets/test/VisualTokens.test.ets entry/src/ohosTest/ets/test/List.test.ets
git commit -m "test: establish UI restoration baseline"
```

## Task 2: 建立可审计的设计资源流水线

**Files:**

- Create: `design/image2-sources/README.md`
- Create: `docs/ui/asset-manifest.md`
- Create: `scripts/prepare-ui-assets.ps1`
- Create: `entry/src/main/resources/base/media/ui_home_*.png`
- Create: `entry/src/main/resources/base/media/ui_draw_box.png`
- Create: `entry/src/main/resources/base/media/ui_finger_guide.png`
- Create: `entry/src/main/resources/base/media/ui_coin.png`

- [ ] **Step 1: 记录批准源图**

`design/image2-sources/README.md` 必须列出规格文档中 12 个源文件名、原始尺寸和页面映射，并声明源文件保留在用户提供的只读目录，仓库只保存派生资源和清单。

- [ ] **Step 2: 创建可重复裁切脚本**

脚本使用 `System.Drawing`，对每个资源执行 `Clone(Rectangle, PixelFormat)`、保存 PNG，
并在保存前校验源图尺寸为 `863x1822` 或 `941x1672`。输出统一写入：

```powershell
$outputDir = Join-Path $projectRoot 'entry\src\main\resources\base\media'
```

资源名固定为：

```text
ui_home_wheel.png
ui_home_draw.png
ui_home_finger.png
ui_home_coin.png
ui_home_yesno.png
ui_home_number.png
ui_draw_box.png
ui_finger_guide.png
ui_coin.png
```

- [ ] **Step 3: 执行脚本并检查资源**

Run:

```powershell
.\scripts\prepare-ui-assets.ps1 -SourceDir 'C:\Users\27363\Desktop\decision_jpg'
Get-ChildItem entry\src\main\resources\base\media\ui_*.png | Select-Object Name,Length
```

Expected: 9 个 PNG 均存在且大小大于 1 KB。

- [ ] **Step 4: 写入资源清单**

`docs/ui/asset-manifest.md` 对每个资源记录源文件、裁切矩形、最终像素尺寸、ArkUI 用途和浅/深色背景策略。

- [ ] **Step 5: 视觉检查资源**

使用本地图片查看器检查轮廓、JPEG 边缘、透明区域和小尺寸识别度；不合格资源回到批准源图重新裁切。仅在源图无法提供干净资源时，使用 image2/imagegen 生成同风格透明 PNG，并把提示词和原图加入清单。

- [ ] **Step 6: 提交任务 2**

```powershell
git add design/image2-sources/README.md docs/ui/asset-manifest.md scripts/prepare-ui-assets.ps1 entry/src/main/resources/base/media/ui_*.png
git commit -m "feat: add approved UI visual assets"
```

## Task 3: 重构共享视觉组件

**Files:**

- Modify: `entry/src/main/ets/components/common/AppButton.ets`
- Modify: `entry/src/main/ets/components/common/AppCard.ets`
- Modify: `entry/src/main/ets/components/common/AppInput.ets`
- Modify: `entry/src/main/ets/components/common/PageHeader.ets`
- Modify: `entry/src/main/ets/components/common/ResultSheet.ets`
- Modify: `entry/src/main/ets/components/decision/OptionsEditor.ets`

- [ ] **Step 1: 将主按钮接口扩展为设计稿尺寸**

保留现有 props，并增加：

```ts
@Prop height: number = 48;
@Prop radius: number = AppRadii.PRIMARY_BUTTON;
```

主按钮使用蓝色视觉、白字、轻阴影；次按钮使用白底细边框；危险和文字按钮保持语义色。

- [ ] **Step 2: 统一卡片和输入框**

`AppCard` 使用 12vp 圆角、浅边框与低强度阴影。`AppInput` 统一 44vp 高度、
14fp 正文、8vp 圆角，并保留焦点和错误边框。

- [ ] **Step 3: 重建页面头部**

`PageHeader` 固定返回按钮占位、居中标题与副标题，增加可选右侧操作：

```ts
@Prop rightLabel: string = '';
onRightPress: () => void = (): void => {};
```

标题最长两行，左右操作不挤压标题。

- [ ] **Step 4: 统一结果层与选项编辑器**

结果层沿用现有回调，只改变视觉。选项行固定拖拽图标区、输入区和删除区，
使用 `constraintSize({ minWidth: 0 })` 防止长文本溢出。

- [ ] **Step 5: 构建主 HAP**

Run:

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@default assembleHap --no-daemon
```

Expected: `TYPE CHECK SUCCESSFUL` 和 `BUILD SUCCESSFUL`。

- [ ] **Step 6: 提交任务 3**

```powershell
git add entry/src/main/ets/components/common entry/src/main/ets/components/decision/OptionsEditor.ets
git commit -m "feat: align shared components with approved UI"
```

## Task 4: 还原首页和模板入口

**Files:**

- Modify: `entry/src/main/ets/constants/PresetTemplates.ets`
- Modify: `entry/src/main/ets/pages/Index.ets`
- Test: `entry/src/ohosTest/ets/test/ResponsiveLayout.test.ets`

- [ ] **Step 1: 保持模板映射测试通过**

为四个内置模板断言名称、工具类型和候选项；“今天吃什么”“周末去哪里”与设计稿候选项一致，抽签模板在无联系人数据时继续使用现有默认项初始化规则。

- [ ] **Step 2: 重建首页头部和六个工具卡片**

使用 2 列 Grid、16vp 页面边距、12vp 间距。卡片含批准图标、标题和单行说明；
历史与设置使用右上角图标按钮。保留 `openTool` 和 `openTemplate` 原调用。

- [ ] **Step 3: 重建快速模板列表和隐私尾注**

模板行按设计稿显示图标、标题、摘要和箭头；自定义模板仍保留删除能力。

- [ ] **Step 4: 验证响应式列数**

Run:

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
```

Expected: `ResponsiveLayout.test.ets` 与模板断言通过构建。

- [ ] **Step 5: 提交任务 4**

```powershell
git add entry/src/main/ets/constants/PresetTemplates.ets entry/src/main/ets/pages/Index.ets entry/src/ohosTest/ets/test/ResponsiveLayout.test.ets
git commit -m "feat: restore home and template UI"
```

## Task 5: 还原转盘和抽签页面

**Files:**

- Modify: `entry/src/main/ets/components/decision/WheelCanvas.ets`
- Modify: `entry/src/main/ets/components/decision/DrawTube.ets`
- Modify: `entry/src/main/ets/pages/Wheel.ets`
- Modify: `entry/src/main/ets/pages/Draw.ets`
- Test: `entry/src/ohosTest/ets/test/WheelGeometry.test.ets`
- Test: `entry/src/ohosTest/ets/test/DrawSession.test.ets`

- [ ] **Step 1: 保留功能测试基线**

先构建并运行现有转盘几何、结果映射和抽签重复/不重复测试，记录通过数量。

- [ ] **Step 2: 还原转盘组件**

保留 `rotation`、`options`、`selectedIndex` 接口；把直径、指针、中心按钮、
分区颜色和标签位置调整为设计稿。结果角度仍只由 `WheelGeometry` 计算。

- [ ] **Step 3: 还原转盘页面编排**

页面顺序固定为头部、转盘、主按钮、选项管理、保存模板。模板标题和副标题来自现有参数，
三张转盘稿共享实现。

- [ ] **Step 4: 还原抽签盒和抽签页面**

`DrawTube` 使用 `ui_draw_box` 作为批准底图，动态签条继续响应
`shakeAngle`、`stickOffset` 和 `liftedLabel`。页面顺序与两个抽签稿一致。

- [ ] **Step 5: 重新运行相关测试和主构建**

Expected: Wheel/Draw 测试 `Failure: 0`，主 HAP `BUILD SUCCESSFUL`。

- [ ] **Step 6: 提交任务 5**

```powershell
git add entry/src/main/ets/components/decision/WheelCanvas.ets entry/src/main/ets/components/decision/DrawTube.ets entry/src/main/ets/pages/Wheel.ets entry/src/main/ets/pages/Draw.ets
git commit -m "feat: restore wheel and draw UI"
```

## Task 6: 还原指尖、硬币、是或否和随机数字

**Files:**

- Modify: `entry/src/main/ets/components/decision/CoinView.ets`
- Modify: `entry/src/main/ets/pages/FingerSelect.ets`
- Modify: `entry/src/main/ets/pages/Coin.ets`
- Modify: `entry/src/main/ets/pages/YesNo.ets`
- Modify: `entry/src/main/ets/pages/RandomNumber.ets`
- Test: `entry/src/ohosTest/ets/test/FingerSelectionMachine.test.ets`
- Test: `entry/src/ohosTest/ets/test/SimpleDecisionState.test.ets`
- Test: `entry/src/ohosTest/ets/test/RandomService.test.ets`

- [ ] **Step 1: 还原指尖选择空闲态**

在无触点时显示 `ui_finger_guide`、标题、说明、蓝色主按钮和返回按钮；
触点存在时覆盖现有圆形触点、倒计时和选中态，不改变状态机调用。

- [ ] **Step 2: 还原硬币页面**

`CoinView` 使用批准硬币资源并保持 Y 轴旋转；页面加入顶部正反统计、
中央硬币、双列统计卡片、主按钮和重置按钮。计数仍来自 `CoinSession`。

- [ ] **Step 3: 还原是或否页面**

使用问题输入卡、并列“是/否”圆按钮和底部主操作；一次操作仍只调用一次
`RandomService.randomBoolean()`，结果保存逻辑不变。

- [ ] **Step 4: 还原随机数字页面**

按设计稿分为设置范围、结果、快捷范围和历史摘要；不引入新的持久化数据，
页面历史摘要只读取现有 `appStore.history` 中数字类型记录。

- [ ] **Step 5: 运行三组领域测试和主构建**

Expected: Finger/SimpleDecision/Random 测试无失败，主 HAP 构建成功。

- [ ] **Step 6: 提交任务 6**

```powershell
git add entry/src/main/ets/components/decision/CoinView.ets entry/src/main/ets/pages/FingerSelect.ets entry/src/main/ets/pages/Coin.ets entry/src/main/ets/pages/YesNo.ets entry/src/main/ets/pages/RandomNumber.ets
git commit -m "feat: restore compact decision tool UI"
```

## Task 7: 还原历史记录和设置

**Files:**

- Modify: `entry/src/main/ets/pages/History.ets`
- Modify: `entry/src/main/ets/pages/Settings.ets`
- Test: `entry/src/ohosTest/ets/test/HistoryRepository.test.ets`
- Test: `entry/src/ohosTest/ets/test/ThemeResolver.test.ets`

- [ ] **Step 1: 新增纯 UI 筛选状态**

历史页筛选仅影响内存中的渲染列表，不改 Preferences 模型：

```ts
@State private filter: string = '全部';

private visibleHistory(): HistoryRecord[] {
  if (this.filter === '全部') return this.store.history;
  return this.store.history.filter((record: HistoryRecord): boolean =>
    this.toolName(record.toolType) === this.filter);
}
```

- [ ] **Step 2: 还原历史页**

增加顶部筛选条、日期分组、紧凑记录行和右上角清空按钮。详情、再次使用、长按删除和空状态
继续调用现有逻辑。

- [ ] **Step 3: 还原设置页**

按反馈、主题、历史与数据、关于分组；开关使用现有 settings 字段，主题使用三段控件，
危险操作保留原确认弹窗。

- [ ] **Step 4: 运行仓库和主题测试**

Expected: 历史上限/倒序、清除范围和主题解析测试全部通过。

- [ ] **Step 5: 提交任务 7**

```powershell
git add entry/src/main/ets/pages/History.ets entry/src/main/ets/pages/Settings.ets
git commit -m "feat: restore history and settings UI"
```

## Task 8: 设备视觉迭代、标准化回填和 Claude Code 验收

**Files:**

- Modify: all UI files found by screenshot comparison
- Create: `docs/qa/2026-07-29-ui-restoration.md`
- Create: `docs/qa/screenshots/2026-07-29-*.png`
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design-qa.md`

- [ ] **Step 1: 全量静态与构建门禁**

Run:

```powershell
python "C:\Users\27363\Desktop\harmonyos-project-standard-cn\scripts\check_harmonyos_standard.py" "C:\Users\27363\Desktop\max\decision"
git diff --check
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' clean --no-daemon
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@default assembleHap --no-daemon
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
```

Expected: 静态门禁通过、`git diff --check` 无输出、两个 HAP 均 `BUILD SUCCESSFUL`。

- [ ] **Step 2: 安装并运行测试**

使用 `hdc list targets` 确认 API 24 模拟器，安装 main/test HAP 后运行：

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe' -t 127.0.0.1:5555 shell aa test -b com.yr23.decision -m entry_test -s unittest OpenHarmonyTestRunner
```

Expected: `Failure: 0`、`Error: 0`、`TestFinished-ResultCode: 0`。

- [ ] **Step 3: 捕获 12 个设计状态**

依次打开首页、设置、历史、指尖、硬币、随机数字、是或否、两个抽签状态和三个转盘状态。
每个状态使用系统截图命令保存原分辨率 PNG 到
`docs/qa/screenshots/2026-07-29-<scene>.png`。

- [ ] **Step 4: 逐层视觉比对**

将运行截图与对应设计稿缩放到相同内容尺寸，检查：

```text
安全区 -> 头部 -> 主内容 -> 底部操作 -> 字号 -> 间距 -> 颜色 -> 圆角 -> 阴影 -> 图标/插画
```

每次只修改造成差异的共享令牌或所属组件，重新构建并重截受影响页面。系统状态栏、
动态时间和平台字体栅格化差异单独记录。

- [ ] **Step 5: tablet 可用性验证**

在 tablet 模拟器检查页面滚动、长文本、按钮可达和组件不重叠；截图至少覆盖首页和内容最密集的设置页。

- [ ] **Step 6: 回填交付证据**

`docs/qa/2026-07-29-ui-restoration.md` 写入命令、退出码、HAP 路径/大小、设备、截图映射和剩余平台差异。
`tasks.md` 仅在全部门禁完成后改为 `done`；`changes.md` 与 `design-qa.md` 只记录真实结果。

- [ ] **Step 7: 请求 Claude Code 复核**

向现有 VS Code/Claude Code 会话发送：

```text
请复核当前工作区的 UI 还原结果。基准为 decision_jpg 的 12 张设计稿；
功能层不得修改。请检查 ArkTS 合法性、共享组件一致性、手机截图差异、
tablet 可用性和测试/构建证据。若全部满足，请明确回复 CLAUDE_CODE_ACCEPTED；
否则按 文件:行号、页面、严重度、复现步骤 输出问题。
```

- [ ] **Step 8: 处理反馈直至通过**

对每条反馈补充复现或失败证据，修改后重跑相关测试、全量构建和受影响截图。
重复复核，直到收到 `CLAUDE_CODE_ACCEPTED`。

- [ ] **Step 9: 最终提交**

```powershell
git add entry/src/main docs design scripts tasks.md changes.md design.md design-qa.md
git commit -m "feat: complete pixel-perfect HarmonyOS UI restoration"
```
