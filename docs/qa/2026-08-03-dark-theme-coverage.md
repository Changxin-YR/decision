# 深色页面覆盖与柔和边框修复 QA

## 范围

- 首页六个工具图标与四个快捷模板图标。
- 抽签、指尖选择与硬币展示插画。
- 随机数字最小值、最大值、抽取数量输入文字。
- 深色共享描边与抽签/指尖插画边缘。

不涉及布局、路由、交互、随机算法、模板/历史持久化或反馈时序。

## 回归检查

- `scripts/check-dark-theme-coverage.ps1` 首次运行因首页缺少 `ui_home_wheel_dark` 引用按预期失败。
- 接入深色资源、白色输入文字与柔和边缘后再次运行通过。
- 抽签与指尖插画圆角检查单独经历一次先失败、后通过。

## 构建与设备

- `scripts/build-harmony.ps1`：主 HAP 与测试 HAP 均 `BUILD SUCCESSFUL`，ArkTS 类型检查和资源编译通过。
- 模拟器：`127.0.0.1:5555` phone，1320×2856。
- OpenHarmonyTestRunner：76 run，76 pass，Failure 0，Error 0，ResultCode 0。
- `scripts/check-standard.ps1`：项目标准与 AppGallery UX 检查通过；后续发布检查因当前 `build-profile.json5` 的 target API 22 与检查要求 API 24 不一致而停止。该配置在本任务开始前已存在，本次未修改签名或 SDK 元数据。

## 设备截图

| 页面 | 结果 | 证据 |
| --- | --- | --- |
| 首页 | 六个工具与四个快捷模板不再显示浅色矩形画布，冷蓝描边对比降低 | `screenshots/2026-08-03-dark-coverage-home.png` |
| 抽签 | 插画使用完整深海军蓝背景，无白底、缺口或硬切残影 | `screenshots/2026-08-03-dark-coverage-draw.png` |
| 指尖选择 | 手部完整，深色背景与柔和边缘正常 | `screenshots/2026-08-03-dark-coverage-finger.png` |
| 随机数字 | 三个输入值均为白色，输入框与共享描边清晰但不过亮 | `screenshots/2026-08-03-dark-coverage-random.png` |

## 剩余风险

- 当前只完成 phone 模拟器运行验证；tablet/foldable 仍缺少设备证据。
- 标准发布检查需由 SDK/签名配置负责人决定是恢复 target API 24，还是同步调整发布检查基线。
