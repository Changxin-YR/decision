param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$wheelPath = Join-Path $projectRoot 'entry/src/main/ets/components/decision/WheelCanvas.ets'
$wheel = Get-Content -Raw -Encoding utf8 $wheelPath

function Require-Match(
  [string]$content,
  [string]$pattern,
  [string]$message
) {
  $match = [regex]::Match($content, $pattern)
  if (-not $match.Success) {
    throw $message
  }
  return $match
}

if ($wheel -notmatch "Stack\(\{ alignContent: Alignment\.Center \}\)") {
  throw 'Wheel canvas and pointer must share the centered full-width Stack axis.'
}
if (-not $wheel.Contains("    .width('100%')")) {
  throw 'Wheel Stack must remain responsive and full width.'
}

$pointer = Require-Match $wheel '(?ms)^\s{6}Polygon\(\)(?<body>.*?)(?=^\s{4}\})' `
  'WheelCanvas must render the top pointer as a Polygon.'
$pointerBody = $pointer.Groups['body'].Value
$pointerWidthMatch = Require-Match $pointerBody '\.width\((?<value>-?\d+(?:\.\d+)?)\)' `
  'Wheel pointer must declare a numeric width.'
$pointerPointsMatch = Require-Match $pointerBody `
  '\.points\(\[\[0,\s*0\],\s*\[(?<width>-?\d+(?:\.\d+)?),\s*0\],\s*\[(?<tipX>-?\d+(?:\.\d+)?),\s*(?<tipY>-?\d+(?:\.\d+)?)\]\]\)' `
  'Wheel pointer must be a downward triangle with a measurable tip.'
$pointerPositionMatch = Require-Match $pointerBody `
  "\.position\(\{\s*x:\s*'(?<percent>-?\d+(?:\.\d+)?)%',\s*y:\s*(?<y>-?\d+(?:\.\d+)?)\s*\}\)" `
  'Wheel pointer x must be anchored to a percentage of the full-width Stack, not to diameter.'
$pointerTranslateMatch = Require-Match $pointerBody `
  '\.translate\(\{\s*x:\s*(?<x>-?\d+(?:\.\d+)?)\s*\}\)' `
  'Wheel pointer must translate its local tip onto the Stack center axis.'

$pointerWidth = [double]$pointerWidthMatch.Groups['value'].Value
$pointsWidth = [double]$pointerPointsMatch.Groups['width'].Value
$tipX = [double]$pointerPointsMatch.Groups['tipX'].Value
$tipY = [double]$pointerPointsMatch.Groups['tipY'].Value
$anchorPercent = [double]$pointerPositionMatch.Groups['percent'].Value
$translateX = [double]$pointerTranslateMatch.Groups['x'].Value

if ($pointsWidth -ne $pointerWidth -or (2 * $tipX) -ne $pointerWidth) {
  throw 'Wheel pointer tip must be horizontally centered within its declared width.'
}
if ($tipY -le 0) {
  throw 'Wheel pointer tip must point down toward the wheel.'
}
if ($anchorPercent -ne 50 -or ($translateX + $tipX) -ne 0) {
  throw 'Wheel pointer tip must resolve exactly to 50% of the full-width Stack.'
}
if ($pointerBody -notmatch '\.fill\(this\.colors\.accent\)') {
  throw 'Wheel pointer must use the shared accent token in both light and dark themes.'
}
if ($wheel -notmatch 'const start: number = index \* sector - Math\.PI / 2;') {
  throw 'Wheel sector boundary must start at 12 o''clock.'
}
if ($wheel -notmatch "this\.context\.strokeStyle = '#FFFFFF';") {
  throw 'Wheel 12 o''clock boundary must retain the white separator stroke.'
}

Write-Host 'Wheel pointer geometry check passed.'
