# 指尖选择页导航与触控区优化 QA

## 自动验证

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-finger-select-layout.ps1`：通过。
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-standard.ps1`：通过；现有 `common` 目录、`2in1` 声明和签名字段提示均为非阻断既有警告。
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-harmony.ps1`：主 HAP 与测试 HAP 均 `BUILD SUCCESSFUL`。

## phone 模拟器验证

- 环境：`127.0.0.1:5555`，OpenHarmony API 22，1320×2856。
- 浅色和深色主题均确认：共享卡片式返回键使用 44vp 紧凑尺寸，小提示已删除，两个功能键完整位于手势导航区上方。
- 主体触摸事件仅绑定至可伸展触控层；返回键与两个功能键不在该层内。设备测试包含 `FingerSelectionMachine` 的两指开始、手指变化重启、三次倒计时锁定及重置回归。
- 安装当前主/测试签名 HAP 后运行 OpenHarmonyTestRunner：`Tests run: 76, Failure: 0, Error: 0, Pass: 76`，`TestFinished-ResultCode: 0`。

## 证据

- `screenshots/2026-08-03-finger-layout-light.jpeg`
- `screenshots/2026-08-03-finger-layout-dark.jpeg`

多指手感仍应在真机补验；当前证据证明模拟器页面布局、按钮安全区、自动状态机与触控层边界，不伪造真实多指触感结论。
