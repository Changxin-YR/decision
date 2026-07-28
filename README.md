# 做个决定

一款完全离线、无需登录的 HarmonyOS 决策工具。项目使用 Stage 模型、ArkTS 与 ArkUI 原生开发，目标 API 为 HarmonyOS API 24，不包含 WebView 或跨端运行时。

## 功能

- 幸运转盘：公平预选结果，动画最终位置与结果一致
- 抽签：支持允许重复与不重复模式
- 指尖选择：支持多人多点触控、倒计时与随机选中
- 抛硬币、是或否、随机数字
- 内置模板、自定义模板、历史记录与深浅色设置
- 本地持久化、后台动画取消、自动或手动保存历史

## 开发环境

- DevEco Studio 6.1.1
- HarmonyOS SDK / OpenHarmony API 24
- Windows PowerShell

打开仓库根目录并等待 DevEco Studio 完成同步。命令行构建：

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' `
  --mode module -p product=default -p module=entry@default `
  assembleHap --no-daemon
```

测试包构建：

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' `
  --mode module -p product=default -p module=entry@ohosTest `
  assembleHap --no-daemon
```

## 项目结构

- `entry/src/main/ets/pages`：页面
- `entry/src/main/ets/components`：ArkUI 组件
- `entry/src/main/ets/domain`：随机算法、校验和状态机
- `entry/src/main/ets/data`：Preferences 本地仓储
- `entry/src/main/ets/stores`：应用状态
- `entry/src/ohosTest`：Hypium 测试

## 隐私

应用不声明网络、相机、位置、麦克风或媒体读取权限。设置、模板与历史只保存在当前设备。详见 [docs/PRIVACY.md](docs/PRIVACY.md)。

## 验证

测试、构建与人工验收步骤见 [docs/TESTING.md](docs/TESTING.md) 和 [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md)。
