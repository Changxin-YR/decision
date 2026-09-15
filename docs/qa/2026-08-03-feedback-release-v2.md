# 第二版反馈能力与上架修复 QA

## 审核问题与根因

审核路径为“设置 → 反馈 → 振动反馈/音效 → 开启”。旧实现中的开关回调仅调用 `AppStore.updateSettings` 保存布尔值，没有在开启成功后触发任何预览，因此审核人员在该路径上必然感知不到反馈。

音效链路还存在第二个问题：旧 `SoundService` 给 AVPlayer 设置 `fdSrc` 后立即调用 `prepare`，播放器状态切换是异步的，初始化与准备之间存在状态竞争。短音效可能初始化失败并被非阻断异常处理吞掉，最终表现为工具页无声。

覆盖审计同时发现指尖选择和随机数字只有振动、没有结果音效，与其余工具行为不一致。

## 修复范围

- 设置开关改为“保存成功 → 开启时预览”；振动预览 60ms，音效预览使用 TAP。
- 短音效后端改为 SoundPool，预加载原有 rawfile WAV，后台释放并在前台重新初始化。
- 指尖选择、随机数字补齐 RESULT 音效，六个决策工具统一受设置开关门控。
- 新增 7 项回归测试，覆盖设置预览、关闭不预览、保存失败不预览、音效禁用、初始化复用和释放后重建。
- 版本升级为 1.0.1（versionCode 1000001、buildVersion 2），target API 24、compatible API 22。

## 自动验证

- `scripts/check-standard.ps1`：通过；反馈发布检查与 AppGallery UX 检查均通过。
- `scripts/build-harmony.ps1`：主 HAP 与测试 HAP 均 `BUILD SUCCESSFUL`，均为签名产物。
- 设备测试：OpenHarmonyTestRunner 共 76 项，76 pass，Failure 0，Error 0，ResultCode 0。
- `git diff --check`：通过。

候选产物：

- `entry-default-signed.hap`：5,848,638 bytes，SHA-256 `F04204DA3B50B034B70EAEBE29BAF2DE1A9F80757393E7D5E501DE7653332976`。
- `entry-ohosTest-signed.hap`：6,552,977 bytes，SHA-256 `7A3E0F179FA8829B72772CF9A5EEFC9B1244CA8B7067A102F210F1BDEC6DBC9B`。

构建中的测试资源覆盖提示、`common` 目录建议、未声明 `2in1` 建议和签名字段安全提示均为已知非阻断项；本次已消除旧音效 API 的弃用警告。QA 文档不记录签名口令、令牌或用户数据。

## 设备回归

- 环境：`127.0.0.1:5555` phone 模拟器，OpenHarmony 6.0.2.130，API 22，1320×2856。
- 设置：关闭振动/音效、重新开启、强制停止后重启、前后台恢复均通过；开启状态持久化，无“反馈不可用”提示。
- 工具：转盘、抽签、硬币、是/否、随机数字分别连续执行 3 次；运行日志未发现 SoundPool、540010、振动服务或预览失败。
- 指尖选择：状态机与反馈调用由自动测试和静态覆盖检查通过；当前 UI 自动化不支持可靠的多触点注入，未伪造多指设备结论。

主要证据：

- `release-settings-off.json`
- `release-settings-on.json`
- `release-settings-restart.json`
- `release-settings-foreground.json`
- `release-wheel-result.json`
- `release-draw-result.json`
- `release-coin-result.json`
- `release-yesno-result.json`
- `release-random-result.json`
- `screenshots/2026-08-03-feedback-settings-on.jpeg`
- `screenshots/2026-08-03-feedback-random-result.jpeg`

## 自我审核结论

- 设置审核路径已经形成可感知反馈，不再只是保存配置。
- 音效资源、生命周期、设置门控和失败降级职责集中，未修改随机算法、结果状态机或 Preferences 字段。
- 六个工具的结果反馈覆盖一致，前后台恢复后仍可播放。
- 主/测试签名 HAP 可作为第二版候选包。

剩余风险只有物理设备差异：模拟器不能证明真实马达触感、扬声器音量或多指触控手感。提交 AppGallery 前，应在一台 HarmonyOS 真机上按审核路径验证一次振动、音效和指尖多触点选择。
