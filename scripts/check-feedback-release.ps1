param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

function Read-ProjectFile([string]$relativePath) {
  return Get-Content -Raw -Encoding UTF8 (Join-Path $projectRoot $relativePath)
}

function Assert-Matches([string]$content, [string]$pattern, [string]$message) {
  if ($content -notmatch $pattern) {
    throw $message
  }
}

$settings = Read-ProjectFile 'entry/src/main/ets/pages/Settings.ets'
$finger = Read-ProjectFile 'entry/src/main/ets/pages/FingerSelect.ets'
$random = Read-ProjectFile 'entry/src/main/ets/pages/RandomNumber.ets'
$ability = Read-ProjectFile 'entry/src/main/ets/entryability/EntryAbility.ets'
$appScope = Read-ProjectFile 'AppScope/app.json5'
$appStrings = Read-ProjectFile 'entry/src/main/ets/constants/AppStrings.ets'
$entryPackage = Read-ProjectFile 'entry/oh-package.json5'
$buildProfile = Read-ProjectFile 'build-profile.json5'

Assert-Matches $settings 'feedbackSettingsController\.setVibrationEnabled' 'Settings vibration preview is missing.'
Assert-Matches $settings 'feedbackSettingsController\.setSoundEnabled' 'Settings sound preview is missing.'
Assert-Matches $finger 'soundService\.play\(SoundEffect\.RESULT\)' 'Finger result sound is missing.'
Assert-Matches $random 'soundService\.play\(SoundEffect\.RESULT\)' 'Random-number result sound is missing.'
Assert-Matches $ability 'await soundService\.initialize\(this\.context\)' 'Sound initialization is not awaited.'
Assert-Matches $ability 'onForeground\(\): void[\s\S]*soundService\.initialize\(this\.context\)' 'Foreground sound recovery is missing.'

$validationIndex = $random.IndexOf('if (!validation.valid)')
$soundIndex = $random.IndexOf('soundService.play(SoundEffect.RESULT)')
if ($validationIndex -lt 0 -or $soundIndex -le $validationIndex) {
  throw 'Random-number sound must run after successful validation.'
}

Assert-Matches $appScope '"versionCode"\s*:\s*1000001' 'App versionCode is not 1000001.'
Assert-Matches $appScope '"versionName"\s*:\s*"1\.0\.1"' 'App versionName is not 1.0.1.'
Assert-Matches $appScope '"buildVersion"\s*:\s*"2"' 'App buildVersion is not 2.'
Assert-Matches $appStrings "APP_VERSION: string = '.*1\.0\.1'" 'Visible app version is not 1.0.1.'
Assert-Matches $entryPackage '"version"\s*:\s*"1\.0\.1"' 'Entry package version is not 1.0.1.'
Assert-Matches $buildProfile '"compatibleSdkVersion"\s*:\s*"6\.0\.2\(22\)"' 'Compatible SDK is not API 22.'
Assert-Matches $buildProfile '"targetSdkVersion"\s*:\s*"6\.0\.2\(22\)"' 'Target SDK is not API 22.'
Assert-Matches $buildProfile '"runtimeOS"\s*:\s*"HarmonyOS"' 'Runtime OS is not HarmonyOS.'

Write-Host 'Feedback release checks passed.'
