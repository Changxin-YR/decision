# 第二版反馈能力与上架修复 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复设置页开启音效/振动无即时反馈，替换不可靠的短音效播放链路，补齐工具反馈并生成可复检的 1.0.1 第二版。

**Architecture:** 设置页通过可测试的 `FeedbackSettingsController` 先持久化再预览；`SoundService` 负责设置门控，`SoundPoolBackend` 负责 rawfile 加载、播放和释放。页面只声明反馈时机，Ability 管理音效服务前后台生命周期。

**Tech Stack:** HarmonyOS Stage、ArkTS/ArkUI、MediaKit SoundPool、Vibrator、Preferences、Hypium、Hvigor。

---

## 文件结构

- Create `entry/src/main/ets/services/FeedbackSettingsController.ets`: 设置持久化和开启预览编排。
- Modify `entry/src/main/ets/services/SoundService.ets`: SoundPool 后端与全局音效门控。
- Modify `entry/src/main/ets/pages/Settings.ets`: 调用异步设置控制器并显示失败提示。
- Modify `entry/src/main/ets/pages/FingerSelect.ets`: 最终选中时增加结果音效。
- Modify `entry/src/main/ets/pages/RandomNumber.ets`: 成功生成时增加结果音效。
- Modify `entry/src/main/ets/entryability/EntryAbility.ets`: 等待初始化、后台释放、前台重建。
- Create `entry/src/ohosTest/ets/test/FeedbackSettingsController.test.ets`: 设置预览行为回归。
- Create `entry/src/ohosTest/ets/test/SoundService.test.ets`: 设置门控和后端生命周期回归。
- Modify `entry/src/ohosTest/ets/test/List.test.ets`: 注册新测试。
- Create `scripts/check-feedback-release.ps1`: 页面反馈覆盖与版本一致性静态回归。
- Modify `scripts/check-standard.ps1`: 将本次静态回归纳入标准检查。
- Modify `AppScope/app.json5`, `entry/oh-package.json5`, `entry/src/main/ets/constants/AppStrings.ets`: 统一 1.0.1 版本。
- Modify `build-profile.json5`: 恢复项目约定的 API 24，保留签名身份和材料配置。
- Modify `tasks.md`, `changes.md`, `design.md`, `design-qa.md`, `docs/qa/README.md`: 记录修复、验证与剩余硬件限制。

### Task 1: 设置开关预览控制器

**Files:**
- Create: `entry/src/main/ets/services/FeedbackSettingsController.ets`
- Create: `entry/src/ohosTest/ets/test/FeedbackSettingsController.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

测试使用真实内存 `AppStore` 与最小反馈端口替身，断言：开启保存成功后预览一次；关闭不预览；保存失败不预览并返回 `saved: false`。

```ts
const result: FeedbackUpdateResult = await controller.setSoundEnabled(true);
expect(result.saved).assertTrue();
expect(result.previewed).assertTrue();
expect(sound.calls).assertEqual(1);
```

- [ ] **Step 2: 构建测试 HAP，确认 RED**

Run: `hvigorw --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon`
Expected: FAIL，因为 `FeedbackSettingsController` 尚不存在。

- [ ] **Step 3: 最小实现**

实现 `VibrationPreviewPort`、`SoundPreviewPort`、`FeedbackUpdateResult` 和两个异步更新方法；只有 `AppStore.updateSettings()` 成功且新值为 `true` 才预览。

```ts
async setVibrationEnabled(value: boolean): Promise<FeedbackUpdateResult> {
  const saved: boolean = await this.store.updateSettings({ vibrationEnabled: value });
  const previewed: boolean = saved && value ? await this.vibration.impact(60) : false;
  return { saved, previewed };
}
```

- [ ] **Step 4: 构建测试 HAP，确认 GREEN**

Expected: 测试代码类型检查通过。

### Task 2: SoundPool 短音效后端

**Files:**
- Modify: `entry/src/main/ets/services/SoundService.ets`
- Create: `entry/src/ohosTest/ets/test/SoundService.test.ets`
- Modify: `entry/src/ohosTest/ets/test/List.test.ets`

- [ ] **Step 1: 写失败测试**

通过 `SoundBackend` 端口测试真实 `SoundService`：关闭设置不初始化/播放；开启设置会初始化并播放；重复初始化只调用一次后端；释放后可再次初始化。

```ts
expect(await service.play(SoundEffect.TAP)).assertFalse();
expect(backend.playCalls).assertEqual(0);
```

- [ ] **Step 2: 构建测试 HAP，确认 RED**

Expected: FAIL，因为当前构造器不接受后端且仍使用 AVPlayer。

- [ ] **Step 3: 实现最小 SoundPool 后端**

使用 `media.createSoundPool(4, rendererInfo)`；遍历 `SoundEffect` 的五个 rawfile 路径并缓存 sound ID；`play()` 返回有效 stream ID；`release()` 清空映射并释放 SoundPool。初始化 Promise 去重，异常只写安全警告。

```ts
const rendererInfo: audio.AudioRendererInfo = {
  content: audio.ContentType.CONTENT_TYPE_SONIFICATION,
  usage: audio.StreamUsage.STREAM_USAGE_NOTIFICATION,
  rendererFlags: 0
};
```

- [ ] **Step 4: 构建测试 HAP，确认 GREEN**

Expected: 测试代码和生产代码类型检查通过。

### Task 3: 页面与 Ability 接线

**Files:**
- Modify: `entry/src/main/ets/pages/Settings.ets`
- Modify: `entry/src/main/ets/pages/FingerSelect.ets`
- Modify: `entry/src/main/ets/pages/RandomNumber.ets`
- Modify: `entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `scripts/check-feedback-release.ps1`
- Modify: `scripts/check-standard.ps1`

- [ ] **Step 1: 写失败回归检查**

增加源码集成检查，要求设置页通过控制器预览、指尖和随机数字成功结果调用 `SoundEffect.RESULT`，并确认随机数字的反馈调用位于校验成功分支之后。

- [ ] **Step 2: 构建测试 HAP，确认 RED**

Expected: FAIL，因为策略或调用尚未补齐。

- [ ] **Step 3: 页面最小接线**

设置页等待控制器结果并在保存失败或预览失败时显示明确 toast；指尖锁定和随机数字生成成功处调用 `soundService.play(SoundEffect.RESULT)`；Ability 创建时等待初始化，后台释放，前台重新初始化。

- [ ] **Step 4: 构建测试 HAP，确认 GREEN**

Expected: 类型检查通过，所有页面保持原随机与存储流程。

### Task 4: 第二版元数据与文档

**Files:**
- Modify: `AppScope/app.json5`
- Modify: `entry/oh-package.json5`
- Modify: `entry/src/main/ets/constants/AppStrings.ets`
- Modify: `build-profile.json5`
- Modify: `scripts/check-feedback-release.ps1`
- Modify: `tasks.md`, `changes.md`, `design.md`, `design-qa.md`, `docs/qa/README.md`

- [ ] **Step 1: 添加版本一致性静态检查**

扩展 `scripts/check-feedback-release.ps1`，要求 `1000001`、`1.0.1`、build 2、UI 版本文字和 API 24 一致。

- [ ] **Step 2: 运行检查确认 RED**

Expected: FAIL，当前仍为 1.0.0/build 1 且构建配置为 API 22。

- [ ] **Step 3: 更新元数据和文档**

仅改版本/API 字段和本次修复记录；保留 bundleName、vendor、签名身份、图标、设备范围和所有现有未提交文档内容。

- [ ] **Step 4: 再次运行检查确认 GREEN**

Expected: 标准检查通过，且 QA 文档不包含签名口令、令牌或隐私数据。

### Task 5: 全面验证与自我审核

**Files:**
- Create: `docs/qa/2026-08-03-feedback-release-v2.md`
- Modify: `design-qa.md`, `docs/qa/README.md`, `tasks.md`, `changes.md`

- [ ] **Step 1: 静态检查和构建**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1
git diff --check
```

Expected: exit 0，主 HAP 和测试 HAP 均 `BUILD SUCCESSFUL`。

- [ ] **Step 2: 安装并运行完整设备测试**

安装最新主/测试 HAP，在当前 phone 设备运行 `OpenHarmonyTestRunner`。
Expected: Failure 0、Error 0、ResultCode 0。

- [ ] **Step 3: 复现审核路径**

设置页依次关闭/开启振动和音效，保存布局、截图与安全日志；六个工具各运行三次；验证关闭静默、开启调用、后台/前台恢复。

- [ ] **Step 4: 自我审核**

逐项检查权限、rawfile、SoundPool 生命周期、快速操作、设置持久化、版本一致性、SDK 陈述、签名状态和敏感信息。模拟器无法证明物理振感时明确记录真机人工项。

- [ ] **Step 5: 回填任务状态**

只有全部可执行验证通过后将 `T-20260803-011` 标为 `done`；硬件不可用结论单列，不伪造通过。
