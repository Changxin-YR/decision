param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

function Read-ProjectFile([string]$relativePath) {
  return Get-Content -Raw -Encoding utf8 (Join-Path $projectRoot $relativePath)
}

function Assert-Contains([string]$content, [string]$pattern, [string]$message) {
  if (-not $content.Contains($pattern)) {
    throw $message
  }
}

function Assert-NotMatches([string]$content, [string]$pattern, [string]$message) {
  if ($content -match $pattern) {
    throw $message
  }
}

function Assert-NotContains([string]$content, [string]$pattern, [string]$message) {
  if ($content.Contains($pattern)) {
    throw $message
  }
}

$index = Read-ProjectFile 'entry/src/main/ets/pages/Index.ets'
$history = Read-ProjectFile 'entry/src/main/ets/pages/History.ets'
$coinView = Read-ProjectFile 'entry/src/main/ets/components/decision/CoinView.ets'
$wheelCanvas = Read-ProjectFile 'entry/src/main/ets/components/decision/WheelCanvas.ets'
$pageHeader = Read-ProjectFile 'entry/src/main/ets/components/common/PageHeader.ets'
$resultSheet = Read-ProjectFile 'entry/src/main/ets/components/common/ResultSheet.ets'
$confirmDialog = Read-ProjectFile 'entry/src/main/ets/components/common/ConfirmDialog.ets'
$templateSaveDialog = Read-ProjectFile 'entry/src/main/ets/components/decision/TemplateSaveDialog.ets'
$uiSource = $index + "`n" + $history + "`n" + $coinView

Assert-Contains $index "`$r('app.media.ui_home_wheel')" `
  'Home must use the approved original tool artwork.'
Assert-Contains $index "`$r('app.media.ui_home_history')" `
  'Home must use the approved original history icon.'
Assert-Contains $index "`$r('app.media.ui_home_settings')" `
  'Home must use the approved original settings icon.'
Assert-Contains $index "`$r('app.media.ui_home_history_dark')" `
  'Dark home must use its separately approved history icon.'
Assert-Contains $index "`$r('app.media.ui_home_settings_dark')" `
  'Dark home must use its separately approved settings icon.'
Assert-Contains $index "`$r('app.media.ui_quick_food')" `
  'Quick templates must use the approved original artwork.'
Assert-Contains $index 'if (this.theme().isDark)' `
  'Dark-only home details must not overwrite the independent light layout.'
Assert-Contains $index 'Row({ space: this.theme().isDark ? 4 : 6 })' `
  'Home tool spacing must preserve separate dark and light layouts.'
Assert-Contains $index '.width(this.theme().isDark ? 58 : 62)' `
  'Home tool artwork must preserve separate dark and light sizes.'
Assert-Contains $index '.fontSize(this.theme().isDark ? 8 : 9)' `
  'Home descriptions must preserve separate dark and light typography.'
$approvedChevronCount = $index.Split("Text('›')").Length - 1
if ($approvedChevronCount -lt 2) {
  throw 'Dark tool cards and all quick templates require their approved chevrons.'
}
Assert-Contains $history "`$r('app.media.ui_home_coin_dark')" `
  'History rows must reuse the approved clean tool artwork.'
Assert-NotMatches $history 'ui_history_(wheel|draw|coin|yesno|number)' `
  'History rows must not reuse the old screenshot crops with rough edges.'
Assert-Contains $coinView "`$r('app.media.ui_coin')" `
  'CoinView must use the approved light coin artwork.'
Assert-Contains $coinView "`$r('app.media.ui_coin_dark')" `
  'CoinView must use the approved dark coin artwork.'
Assert-NotContains $coinView "backgroundColor('#CCFFFFFF')" `
  'Coin result must not place a white badge over the approved 3D artwork.'
Assert-NotContains $wheelCanvas '.shadow(' `
  'Wheel center must not use a bounding-box shadow that renders as a rectangle.'
Assert-Contains $pageHeader "@Prop rightGlyph: string = '';" `
  'PageHeader must support a clean code-native trailing glyph.'

$historyColorPassCount = ([regex]::Matches(
  $history,
  [regex]::Escape('colors: this.colors')
)).Count
if ($historyColorPassCount -lt 6) {
  throw "History theme propagation is incomplete; found $historyColorPassCount themed child calls."
}

@(
  @{ Name = 'ResultSheet'; Content = $resultSheet; Expected = 2 },
  @{ Name = 'ConfirmDialog'; Content = $confirmDialog; Expected = 2 },
  @{ Name = 'TemplateSaveDialog'; Content = $templateSaveDialog; Expected = 2 }
) | ForEach-Object {
  $themedButtonCount = ([regex]::Matches(
    $_.Content,
    [regex]::Escape('colors: this.colors')
  )).Count
  if ($themedButtonCount -lt $_.Expected) {
    throw "$($_.Name) must pass theme colors to every AppButton; found $themedButtonCount/$($_.Expected)."
  }
}

Add-Type -AssemblyName System.Drawing
$coinPath = Join-Path $projectRoot `
  'entry/src/main/resources/base/media/ui_coin_dark.png'
$coinBitmap = [System.Drawing.Bitmap]::new($coinPath)
try {
  for ($y = 0; $y -lt $coinBitmap.Height; $y += 1) {
    for ($x = 0; $x -lt $coinBitmap.Width; $x += 1) {
      $normalizedX = ($x - 165.0) / 145.0
      $normalizedY = ($y - 155.0) / 142.0
      $outsideCoin = (($normalizedX * $normalizedX) +
        ($normalizedY * $normalizedY)) -gt 1.0
      if ($outsideCoin -and $coinBitmap.GetPixel($x, $y).A -ne 0) {
        throw "Dark coin contains detached pixels outside its approved silhouette at $x,$y."
      }
    }
  }
} finally {
  $coinBitmap.Dispose()
}

Write-Host 'Visual integrity check passed.'
