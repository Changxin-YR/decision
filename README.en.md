# Make a Decision

A fully offline HarmonyOS decision helper built natively with Stage, ArkTS, and ArkUI for API 24. It contains no WebView or cross-platform runtime.

## Features

- Fair animated wheel with pointer-aligned results
- Repeat-aware drawing tool
- Multi-touch finger selector with countdown and random locking
- Coin flip, yes/no, and random number tools
- Built-in and custom templates, optional history, and theme settings
- Local persistence and lifecycle-safe animation cancellation

## Development

Use DevEco Studio 6.1.1 with the HarmonyOS/OpenHarmony API 24 SDK. Build from PowerShell:

```powershell
$env:DEVECO_SDK_HOME='C:\Program Files\Huawei\DevEco Studio\sdk'
& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' `
  --mode module -p product=default -p module=entry@default `
  assembleHap --no-daemon
```

Build the Hypium test HAP by changing `module=entry@default` to `module=entry@ohosTest`.

## Privacy

The app requests no network, camera, location, microphone, or media permissions. Settings, templates, and history remain on the device. See [docs/PRIVACY.md](docs/PRIVACY.md).

Verification details are documented in [docs/TESTING.md](docs/TESTING.md) and [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md).
