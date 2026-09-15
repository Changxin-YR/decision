param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$fingerPath = Join-Path $projectRoot 'entry/src/main/ets/pages/FingerSelect.ets'
$headerPath = Join-Path $projectRoot 'entry/src/main/ets/components/common/PageHeader.ets'
$finger = Get-Content -Raw -Encoding utf8 $fingerPath
$header = Get-Content -Raw -Encoding utf8 $headerPath
$removedHint = [string]::Concat([char]0x5C0F, [char]0x63D0, [char]0x793A)

if ($finger -notmatch "import \{ PageHeader \} from '../components/common/PageHeader';") {
  throw 'FingerSelect must use the shared PageHeader.'
}
if ($finger -notmatch "PageHeader\(\{[\s\S]*backButtonSize: 44") {
  throw 'FingerSelect must use the compact 44vp shared back button.'
}
if ($header -notmatch '@Prop backButtonSize: number = 48') {
  throw 'PageHeader must preserve a configurable 48vp default back button size.'
}
if ($finger.Contains($removedHint)) {
  throw 'FingerSelect must not render the removed hint.'
}
if ($finger -notmatch '@Builder\s+private touchSurface\(\)') {
  throw 'FingerSelect must own a dedicated touch surface.'
}
if ($finger -notmatch 'this\.touchSurface\(\)') {
  throw 'FingerSelect must render the dedicated touch surface.'
}
if ($finger -notmatch "layoutWeight\(1\)[\s\S]*onTouch\(\(event: TouchEvent\)") {
  throw 'Finger recognition must be attached to the flexible body surface.'
}
