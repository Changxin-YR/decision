param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

function Read-ProjectFile([string]$relativePath) {
  return Get-Content -Raw -Encoding utf8 (Join-Path $projectRoot $relativePath)
}

function Assert-Contains(
  [string]$content,
  [string]$pattern,
  [string]$message
) {
  if (-not $content.Contains($pattern)) {
    throw $message
  }
}

function Assert-NotMatches(
  [string]$content,
  [string]$pattern,
  [string]$message
) {
  if ($content -match $pattern) {
    throw $message
  }
}

$tokens = Read-ProjectFile 'entry/src/main/ets/constants/DesignTokens.ets'
$index = Read-ProjectFile 'entry/src/main/ets/pages/Index.ets'
$drawTube = Read-ProjectFile 'entry/src/main/ets/components/decision/DrawTube.ets'
$finger = Read-ProjectFile 'entry/src/main/ets/pages/FingerSelect.ets'
$coinView = Read-ProjectFile 'entry/src/main/ets/components/decision/CoinView.ets'
$randomNumber = Read-ProjectFile 'entry/src/main/ets/pages/RandomNumber.ets'

Assert-Contains $tokens "static readonly DARK_BORDER: string = '#203654';" `
  'Dark borders must use the softer shared cold-blue token.'

Assert-Contains $index "`$r('app.media.ui_home_wheel_dark')" `
  'Index must select the approved dark home artwork.'
Assert-Contains $index "`$r('app.media.ui_quick_food_dark')" `
  'Index must select the approved dark quick-template artwork.'

Assert-Contains $drawTube 'ui_draw_box_dark_v2' `
  'DrawTube must select the dark draw illustration.'
Assert-Contains $drawTube '.borderRadius(this.colors.isDark ? 18 : 0)' `
  'DrawTube dark artwork must use a soft rounded edge.'
Assert-Contains $finger 'ui_finger_guide_dark_v2' `
  'FingerSelect must select the dark guide illustration.'
Assert-Contains $finger '.borderRadius(this.colors.isDark ? 18 : 0)' `
  'FingerSelect dark artwork must use a soft rounded edge.'
Assert-Contains $coinView "`$r('app.media.ui_coin_dark')" `
  'CoinView must use the approved complete dark coin artwork.'

$whiteInputPattern = ".fontColor(this.colors.isDark ? '#FFFFFF' : this.colors.text)"
$whiteInputCount = ([regex]::Matches(
  $randomNumber,
  [regex]::Escape($whiteInputPattern)
)).Count
if ($whiteInputCount -ne 3) {
  throw "RandomNumber must explicitly render all 3 dark inputs in white; found $whiteInputCount."
}

Write-Host 'Dark theme coverage check passed.'
