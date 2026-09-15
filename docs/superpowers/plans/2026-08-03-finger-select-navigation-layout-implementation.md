# 指尖选择页导航与触控区优化 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 统一指尖选择页返回键、删除小提示、让底部按钮安全下移，并把多指识别限制在主体触控区。

**Architecture:** `PageHeader` 增加保持默认行为的可选紧凑返回键尺寸。`FingerSelectPage` 使用这个共享页首，并把现有触摸回调移进正文的独立弹性 `Stack`，使页首与底部操作不参与触摸识别。根 `Navigation` 已消费动态安全区，删除小提示后按钮组自然下移到安全区上方。

**Tech Stack:** HarmonyOS Stage、ArkTS、ArkUI、PowerShell 静态约束检查、Hvigor HAP 构建。

---

### Task 1: 创建页面布局静态回归检查

**Files:**
- Create: `scripts/check-finger-select-layout.ps1`
- Modify: `scripts/check-standard.ps1`

- [ ] **Step 1: Write the failing test**

```powershell
$finger = Get-Content -Raw (Join-Path $projectRoot 'entry/src/main/ets/pages/FingerSelect.ets')
if ($finger -notmatch "PageHeader\\(\\{[\\s\\S]*backButtonSize: 44") { throw 'FingerSelect must use the compact shared back button.' }
if ($finger -match '小提示') { throw 'FingerSelect must not render the removed hint.' }
if ($finger -notmatch 'private touchSurface\\(\\): void') { throw 'FingerSelect must own a dedicated touch surface.' }
if ($finger -notmatch 'this\\.touchSurface\\(\\)') { throw 'FingerSelect must render the dedicated touch surface.' }
```

- [ ] **Step 2: Run test to verify it fails**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-finger-select-layout.ps1`

Expected: exits non-zero because the current page still has an inline 36vp return button, renders the removed hint, and attaches touch handling to its root.

- [ ] **Step 3: Write minimal implementation for the check**

```powershell
param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$finger = Get-Content -Raw (Join-Path $projectRoot 'entry/src/main/ets/pages/FingerSelect.ets')
if ($finger -notmatch "PageHeader\\(\\{[\\s\\S]*backButtonSize: 44") { throw 'FingerSelect must use the compact shared back button.' }
if ($finger -match '小提示') { throw 'FingerSelect must not render the removed hint.' }
if ($finger -notmatch 'private touchSurface\\(\\): void') { throw 'FingerSelect must own a dedicated touch surface.' }
if ($finger -notmatch 'this\\.touchSurface\\(\\)') { throw 'FingerSelect must render the dedicated touch surface.' }
if ($finger -match "\\.height\('100%'\\)[\\s\\S]*\\.onTouch") { throw 'Do not attach finger recognition to the full page root.' }
```

Append `& (Join-Path $PSScriptRoot 'check-finger-select-layout.ps1')` to `check-standard.ps1` after its existing checks.

- [ ] **Step 4: Re-run the regression check**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-finger-select-layout.ps1`

Expected: still exits non-zero until Task 2 and Task 3 are implemented.

### Task 2: 支持紧凑共享返回键

**Files:**
- Modify: `entry/src/main/ets/components/common/PageHeader.ets:5-66`

- [ ] **Step 1: Write the failing test**

The Task 1 check already asserts `backButtonSize: 44` at the consuming page; add an assertion that `PageHeader` exposes `@Prop backButtonSize: number = 48`.

```powershell
$header = Get-Content -Raw (Join-Path $projectRoot 'entry/src/main/ets/components/common/PageHeader.ets')
if ($header -notmatch '@Prop backButtonSize: number = 48') { throw 'PageHeader must preserve a 48vp default back button size.' }
```

- [ ] **Step 2: Run test to verify it fails**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-finger-select-layout.ps1`

Expected: exits non-zero because `PageHeader` has no configurable back button size.

- [ ] **Step 3: Implement the minimal shared API**

```ts
@Prop backButtonSize: number = 48;
@Prop backButtonRadius: number = 14;

Button('‹', { type: ButtonType.Normal })
  .width(this.backButtonSize)
  .height(this.backButtonSize)
  .borderRadius(this.backButtonRadius)
```

Leave all existing callers unchanged so their current 48vp button remains unchanged.

- [ ] **Step 4: Run the regression check**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-finger-select-layout.ps1`

Expected: exits non-zero because `FingerSelectPage` has not yet consumed the shared header or added its touch surface.

### Task 3: 重组指尖选择页

**Files:**
- Modify: `entry/src/main/ets/pages/FingerSelect.ets:1-220`

- [ ] **Step 1: Implement the page composition**

```ts
private touchSurface(): void {
  Stack()
    .width('100%')
    .layoutWeight(1)
    .onTouch((event: TouchEvent): void => {
      this.updateTouches(event.touches);
    })
}

PageHeader({
  title: '',
  colors: this.colors,
  backButtonSize: 44,
  backButtonRadius: 13,
  onBack: (): void => this.onBack()
})
```

Render the text and guide illustration in the same flexible body as `touchSurface()`; render `AppButton` controls after that body. Remove the hint `Text` completely, retain the two existing button callbacks, and keep the page’s max width and background behavior unchanged.

- [ ] **Step 2: Run the static regression check**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-finger-select-layout.ps1`

Expected: exits 0.

- [ ] **Step 3: Run full static validation**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1`

Expected: exits 0.

### Task 4: 构建与证据

**Files:**
- Modify: `tasks.md`
- Modify: `changes.md`
- Modify: `design.md`
- Modify: `design-qa.md`
- Create: `docs/qa/2026-08-03-finger-select-layout.md`

- [ ] **Step 1: Build main and test HAPs**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1`

Expected: main and test HAP builds both report `BUILD SUCCESSFUL`.

- [ ] **Step 2: Record fresh evidence**

Document the exact static-check and build outcomes. Only mark phone visual verification `passed` if it is actually run; otherwise mark it `blocked` with the unavailable device reason.

- [ ] **Step 3: Update task status**

Mark `T-20260803-013` as `done` only after the static check and both HAP builds succeed; otherwise retain `in_progress` and record the failed command.
