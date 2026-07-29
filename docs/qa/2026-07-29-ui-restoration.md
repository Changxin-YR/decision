# 2026-07-29 UI 还原验证

## 构建

```powershell
hvigorw.bat clean --no-daemon
hvigorw.bat --mode module -p product=default -p module=entry@default assembleHap --no-daemon
hvigorw.bat --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
```

- clean：退出码 0。
- main HAP：`BUILD SUCCESSFUL`，3,315,247 bytes。
- ohosTest HAP：`BUILD SUCCESSFUL`，4,013,299 bytes。
- 预期警告：未配置 signingConfig；测试资源重复声明 `start_window_background`。

## 设备测试

```powershell
hdc -t 127.0.0.1:5555 shell aa test -b com.yr23.decision -m entry_test -s unittest OpenHarmonyTestRunner
```

结果：`Tests run: 67, Failure: 0, Error: 0, Pass: 67`，
`TestFinished-ResultCode: 0`。

随机数字预设修复后结果：`Tests run: 68, Failure: 0, Error: 0, Pass: 68`，
`TestFinished-ResultCode: 0`。

## 随机数字预设单击回归

- 初始状态：`1–100` 高亮，输入值为 `1/100`。
- 单击一次 `1–10`：输入值为 `1/10`，仅 `1–10` 高亮。
- 单击一次 `1–1000`：输入值为 `1/1000`，仅 `1–1000` 高亮。
- 单击一次 `1–100`：输入值为 `1/100`，仅 `1–100` 高亮。
- 界面树证据：`random-preset-10.json`、`random-preset-100.json`、`random-preset-1000.json`。

## 抽签动效与转盘草稿回归

- 抽签时间线：`420ms` 摇动结束，`560ms` 开始升签，`1450ms` 回落稳定，`2000ms` 显示结果。
- 反馈节点：开始 `draw.wav + 18ms`，末次摇动 `28ms`，结果 `result.wav + 70ms`。
- 手动转盘：输入 `Alpha/Beta` 后连续完成两次转动；两次结果阶段和最终关闭后均保留原选项。
- 音效与震动继续由设置开关统一控制；后台生命周期仍调用页面取消与音频释放。

## 截图索引

- `screenshots/2026-07-29-home-final.jpeg`
- `screenshots/2026-07-29-history-final.jpeg`
- `screenshots/2026-07-29-settings-final.jpeg`
- `screenshots/2026-07-29-wheel-final.jpeg`
- `screenshots/2026-07-29-draw-final.jpeg`
- `screenshots/2026-07-29-finger-final.jpeg`
- `screenshots/2026-07-29-coin-final.jpeg`
- `screenshots/2026-07-29-yesno-final.jpeg`
- `screenshots/2026-07-29-random-final.jpeg`
- `screenshots/feedback-random-generated.jpeg`
- `screenshots/feedback-coin.jpeg`
- `screenshots/feedback-coin-result.jpeg`
- `screenshots/feedback-history.jpeg`
- `screenshots/feedback-privacy.jpeg`
- `screenshots/feedback-wheel-keyboard-scroll.jpeg`
- `screenshots/feedback-wheel-filled.jpeg`
- `screenshots/feedback-wheel-template-result.jpeg`
- `screenshots/feedback-wheel-after-close.jpeg`
- `screenshots/feedback-template-first.jpeg`
- `screenshots/feedback-template-takeout.jpeg`
- `screenshots/2026-07-29-draw-motion-final.jpeg`
- `screenshots/2026-07-29-wheel-manual-repeat-result-two.jpeg`
- `screenshots/2026-07-29-wheel-manual-repeat-after-two.jpeg`

全部为 API 24 phone 模拟器原始 1320×2856 JPEG。tablet 运行验证未执行，
在 `design-qa.md` 中记录为 `blocked`。
