# 测试说明

## 自动测试

构建测试 HAP：

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' `
  --mode module -p product=default -p module=entry@ohosTest `
  assembleHap --no-daemon
```

安装主 HAP 与测试 HAP 后，在 API 24 模拟器运行：

```powershell
$hdc='C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe'
& $hdc -t 127.0.0.1:5555 shell aa test `
  -b com.yr23.decision -m entry_test `
  -s unittest OpenHarmonyTestRunner
```

预期：`Failure: 0`、`Error: 0`、`TestFinished-ResultCode: 0`。

## 构建与静态检查

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' clean --no-daemon
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' `
  --mode module -p product=default -p module=entry@default `
  assembleHap --no-daemon
git diff --check
rg -n "requestPermissions|INTERNET|CAMERA|LOCATION|MICROPHONE|READ_MEDIA|WebView" AppScope entry/src/main
```

## 人工回归

每个决策工具至少执行三次；重点检查快速双击、动画期间禁用、切后台取消、结果保存、重启持久化、深色模式、320vp 小屏和大字体滚动。
