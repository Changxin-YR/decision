param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

function Assert-True {
  param(
    [bool]$Condition,
    [string]$Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

function Get-PngHeader {
  param([string]$Path)

  Assert-True (Test-Path -LiteralPath $Path) "Missing PNG resource: $Path"
  $bytes = [System.IO.File]::ReadAllBytes($Path)
  Assert-True ($bytes.Length -ge 26) "Invalid PNG resource: $Path"
  $signature = @(137, 80, 78, 71, 13, 10, 26, 10)
  for ($index = 0; $index -lt $signature.Length; $index++) {
    Assert-True ($bytes[$index] -eq $signature[$index]) "Invalid PNG signature: $Path"
  }

  $width = [System.BitConverter]::ToUInt32(@($bytes[19], $bytes[18], $bytes[17], $bytes[16]), 0)
  $height = [System.BitConverter]::ToUInt32(@($bytes[23], $bytes[22], $bytes[21], $bytes[20]), 0)
  return [PSCustomObject]@{
    Width = $width
    Height = $height
    ColorType = [int]$bytes[25]
  }
}

function Assert-TransparentCorners {
  param([string]$Path)

  Add-Type -AssemblyName System.Drawing
  $bitmap = [System.Drawing.Bitmap]::new($Path)
  try {
    $points = @(
      @(0, 0),
      @(($bitmap.Width - 1), 0),
      @(0, ($bitmap.Height - 1)),
      @(($bitmap.Width - 1), ($bitmap.Height - 1))
    )
    foreach ($point in $points) {
      $pixel = $bitmap.GetPixel($point[0], $point[1])
      Assert-True ($pixel.A -eq 0) "Icon foreground corner must be transparent: $Path"
    }
  } finally {
    $bitmap.Dispose()
  }
}

function Assert-OpaqueBoundary {
  param([string]$Path)

  Add-Type -AssemblyName System.Drawing
  $bitmap = [System.Drawing.Bitmap]::new($Path)
  try {
    $points = @(
      @(0, 0),
      @(($bitmap.Width - 1), 0),
      @(0, ($bitmap.Height - 1)),
      @(($bitmap.Width - 1), ($bitmap.Height - 1)),
      @([int]($bitmap.Width / 2), 0),
      @([int]($bitmap.Width / 2), ($bitmap.Height - 1)),
      @(0, [int]($bitmap.Height / 2)),
      @(($bitmap.Width - 1), [int]($bitmap.Height / 2))
    )
    foreach ($point in $points) {
      $pixel = $bitmap.GetPixel($point[0], $point[1])
      Assert-True ($pixel.A -eq 255) "Icon background boundary must be opaque: $Path"
    }
  } finally {
    $bitmap.Dispose()
  }
}

function Assert-LayeredIcon {
  param([string]$MediaRoot)

  $descriptorPath = Join-Path $MediaRoot 'app_icon_layered.json'
  Assert-True (Test-Path -LiteralPath $descriptorPath) "Missing layered icon descriptor: $descriptorPath"
  $descriptor = Get-Content -LiteralPath $descriptorPath -Raw -Encoding utf8 | ConvertFrom-Json
  $layeredImage = $descriptor.'layered-image'
  Assert-True ($null -ne $layeredImage) "Missing layered-image declaration: $descriptorPath"
  Assert-True ($layeredImage.background -eq '$media:app_icon_background') "Incorrect icon background reference: $descriptorPath"
  Assert-True ($layeredImage.foreground -eq '$media:app_icon_foreground') "Incorrect icon foreground reference: $descriptorPath"

  $backgroundPath = Join-Path $MediaRoot 'app_icon_background.png'
  $foregroundPath = Join-Path $MediaRoot 'app_icon_foreground.png'
  $background = Get-PngHeader $backgroundPath
  $foreground = Get-PngHeader $foregroundPath
  Assert-True ($background.Width -eq 1024 -and $background.Height -eq 1024) 'Icon background must be 1024x1024.'
  Assert-True ($foreground.Width -eq 1024 -and $foreground.Height -eq 1024) 'Icon foreground must be 1024x1024.'
  Assert-True ($background.ColorType -eq 2) 'Icon background must be an opaque RGB PNG without cropped corners.'
  Assert-True ($foreground.ColorType -eq 6) 'Icon foreground must be an RGBA PNG.'
  Assert-OpaqueBoundary $backgroundPath
  Assert-TransparentCorners $foregroundPath
}

$entryAbilityPath = Join-Path $projectRoot 'entry/src/main/ets/entryability/EntryAbility.ets'
$indexPath = Join-Path $projectRoot 'entry/src/main/ets/pages/Index.ets'
$settingsPath = Join-Path $projectRoot 'entry/src/main/ets/pages/Settings.ets'
$systemBarServicePath = Join-Path $projectRoot 'entry/src/main/ets/services/SystemBarService.ets'
$entryAbility = Get-Content -LiteralPath $entryAbilityPath -Raw -Encoding utf8
$indexPage = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8
$settingsPage = Get-Content -LiteralPath $settingsPath -Raw -Encoding utf8
$systemBarService = Get-Content -LiteralPath $systemBarServicePath -Raw -Encoding utf8

$scrollContracts = @{
  'entry/src/main/ets/pages/Index.ets' = 2
  'entry/src/main/ets/pages/Draw.ets' = 1
  'entry/src/main/ets/pages/History.ets' = 1
  'entry/src/main/ets/pages/Privacy.ets' = 1
  'entry/src/main/ets/pages/RandomNumber.ets' = 1
  'entry/src/main/ets/pages/Settings.ets' = 1
  'entry/src/main/ets/pages/Wheel.ets' = 1
}
foreach ($relativePath in $scrollContracts.Keys) {
  $pageSource = Get-Content -LiteralPath (Join-Path $projectRoot $relativePath) -Raw -Encoding utf8
  $springCount = [regex]::Matches(
    $pageSource,
    '\.edgeEffect\(EdgeEffect\.Spring,\s*\{\s*alwaysEnabled:\s*true\s*\}\)'
  ).Count
  Assert-True ($springCount -eq $scrollContracts[$relativePath]) `
    "Every scrolling container must enable Spring edge feedback: $relativePath"
}

$tabletContentPages = @(
  'entry/src/main/ets/pages/Coin.ets',
  'entry/src/main/ets/pages/Draw.ets',
  'entry/src/main/ets/pages/FingerSelect.ets',
  'entry/src/main/ets/pages/History.ets',
  'entry/src/main/ets/pages/Privacy.ets',
  'entry/src/main/ets/pages/RandomNumber.ets',
  'entry/src/main/ets/pages/Settings.ets',
  'entry/src/main/ets/pages/Wheel.ets',
  'entry/src/main/ets/pages/YesNo.ets'
)
foreach ($relativePath in $tabletContentPages) {
  $pageSource = Get-Content -LiteralPath (Join-Path $projectRoot $relativePath) -Raw -Encoding utf8
  Assert-True ($pageSource -match '\.constraintSize\(\{\s*maxWidth:\s*720\s*\}\)') `
    "Tablet content must use the 720vp maximum width: $relativePath"
}

Assert-True ($entryAbility -match 'setWindowLayoutFullScreen\(true\)') 'The main window must explicitly enable immersive layout.'
Assert-True ($entryAbility -match 'AvoidAreaType\.TYPE_SYSTEM') 'The system avoid area must be queried.'
Assert-True ($entryAbility -match 'AvoidAreaType\.TYPE_NAVIGATION_INDICATOR') 'The navigation indicator avoid area must be queried.'
Assert-True ($entryAbility -match "on\('avoidAreaChange'") 'Avoid-area changes must be observed dynamically.'
Assert-True ($entryAbility -match 'onConfigurationUpdate') 'System color-mode changes must update the system bars.'
Assert-True ($entryAbility -match 'systemBarService\.initialize') 'The main window must initialize theme-aware system bars.'
Assert-True ($entryAbility -match '(?s)onConfigurationUpdate\([^)]*\).*?systemBarService\.setSystemDark\(systemDark\)') 'System color-mode changes must reach the system-bar service.'
Assert-True ($entryAbility -notmatch "statusBarContentColor:\s*'#172135'") 'System-bar content color must not be fixed to the light-theme value.'
Assert-True ($entryAbility -match "off\('avoidAreaChange'\)") 'The avoid-area listener must be released with the window.'
Assert-True ($indexPage -match "@StorageProp\('topSafeAreaPx'\)") 'The root page must consume the top safe-area inset.'
Assert-True ($indexPage -match "@StorageProp\('bottomSafeAreaPx'\)") 'The root page must consume the bottom safe-area inset.'
Assert-True ($indexPage -match "@StorageProp\('systemDark'\)") 'The root page must follow system color-mode changes.'
Assert-True ($indexPage -match '(?s)\.padding\(\{\s*top:\s*this\.safeAreaLength\(this\.topSafeAreaPx\),\s*bottom:\s*this\.safeAreaLength\(this\.bottomSafeAreaPx\)') 'The root Navigation must apply both safe-area insets.'
Assert-True ($settingsPage -match 'systemBarService\.setThemeMode') 'Explicit theme changes must update the system bars immediately.'
Assert-True ($systemBarService -match 'ThemeResolver\.systemBarContentColor') 'The system-bar service must resolve content color from the active theme.'
Assert-True ($systemBarService -match 'statusBarContentColor:\s*contentColor') 'The status-bar content color must use the resolved theme color.'
Assert-True ($systemBarService -match 'navigationBarContentColor:\s*contentColor') 'The navigation-bar content color must use the resolved theme color.'

$appConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'AppScope/app.json5') -Raw -Encoding utf8 | ConvertFrom-Json
$moduleConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'entry/src/main/module.json5') -Raw -Encoding utf8 | ConvertFrom-Json
Assert-True ($appConfig.app.icon -eq '$media:app_icon_layered') 'AppScope must reference the layered icon.'
Assert-True ($moduleConfig.module.abilities[0].icon -eq '$media:app_icon_layered') 'EntryAbility must reference the layered icon.'
Assert-True ($moduleConfig.module.abilities[0].startWindowIcon -eq '$media:app_icon_foreground') 'The start window must reference the approved icon foreground.'

$appMediaRoot = Join-Path $projectRoot 'AppScope/resources/base/media'
$entryMediaRoot = Join-Path $projectRoot 'entry/src/main/resources/base/media'
Assert-LayeredIcon $appMediaRoot
Assert-LayeredIcon $entryMediaRoot

foreach ($fileName in @('app_icon_background.png', 'app_icon_foreground.png', 'app_icon_layered.json')) {
  $appHash = (Get-FileHash -Algorithm SHA256 (Join-Path $appMediaRoot $fileName)).Hash
  $entryHash = (Get-FileHash -Algorithm SHA256 (Join-Path $entryMediaRoot $fileName)).Hash
  Assert-True ($appHash -eq $entryHash) "AppScope and EntryAbility icon resources must match: $fileName"
}

Write-Host 'AppGallery UX checks passed.'
