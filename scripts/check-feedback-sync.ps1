param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

function Read-ProjectFile([string]$relativePath) {
  return Get-Content -Raw -Encoding utf8 (Join-Path $projectRoot $relativePath)
}

function Assert-InOrder(
  [string]$content,
  [string]$first,
  [string]$second,
  [string]$message
) {
  $firstIndex = $content.IndexOf($first)
  $secondIndex = $content.IndexOf($second, [Math]::Max(0, $firstIndex))
  if ($firstIndex -lt 0 -or $secondIndex -lt 0 -or $firstIndex -ge $secondIndex) {
    throw $message
  }
}

$sound = Read-ProjectFile 'entry/src/main/ets/services/SoundService.ets'
$yesNo = Read-ProjectFile 'entry/src/main/ets/pages/YesNo.ets'
$coin = Read-ProjectFile 'entry/src/main/ets/pages/Coin.ets'
$draw = Read-ProjectFile 'entry/src/main/ets/pages/Draw.ets'
$wheel = Read-ProjectFile 'entry/src/main/ets/pages/Wheel.ets'
$finger = Read-ProjectFile 'entry/src/main/ets/pages/FingerSelect.ets'
$timing = Read-ProjectFile 'entry/src/main/ets/domain/feedback/DecisionTiming.ets'

if (-not $sound.Contains('STREAM_USAGE_GAME')) {
  throw 'Short interaction sounds must use the game sound-effect stream.'
}
Assert-InOrder $yesNo 'await soundService.play(SoundEffect.TAP)' `
  'this.timerId = setTimeout' `
  'Yes/No must schedule its process sound before starting the result timer.'
Assert-InOrder $yesNo 'await soundService.play(SoundEffect.RESULT)' `
  'this.result = choice' `
  'Yes/No must schedule its result sound before revealing the result.'
Assert-InOrder $coin 'await soundService.play(SoundEffect.COIN)' `
  'this.getUIContext().animateTo' `
  'Coin must schedule its process sound before starting the animation.'
Assert-InOrder $coin 'await soundService.play(SoundEffect.RESULT)' `
  'this.result = next === CoinSide.HEADS' `
  'Coin must schedule its result sound before revealing the result.'
Assert-InOrder $draw 'await soundService.play(SoundEffect.DRAW)' `
  'DrawMotionPlan.SHAKES.forEach' `
  'Draw must schedule its process sound before starting the animation timeline.'
Assert-InOrder $draw 'await soundService.play(SoundEffect.RESULT)' `
  'this.result = pending' `
  'Draw must schedule its result sound before revealing the result.'
Assert-InOrder $wheel 'await soundService.play(SoundEffect.WHEEL)' `
  'this.getUIContext().animateTo' `
  'Wheel must schedule its process sound before starting the animation.'
Assert-InOrder $wheel 'await soundService.play(SoundEffect.RESULT)' `
  'this.result = spin.result' `
  'Wheel must schedule its result sound before revealing the result.'
Assert-InOrder $finger 'await soundService.play(SoundEffect.TAP)' `
  'this.countdownTimer = setInterval' `
  'Finger selection must schedule its process sound before starting the countdown.'
Assert-InOrder $finger 'await soundService.play(SoundEffect.RESULT)' `
  'this.syncMachine()' `
  'Finger selection must schedule its result sound before revealing the selected finger.'

@(
  'YES_NO_RESULT_AT: number = 1400',
  'COIN_RESULT_AT: number = 2500',
  'COIN_ANIMATION_DURATION: number = 2300',
  'DRAW_RESULT_AT: number = 3000',
  'WHEEL_RESULT_AT: number = 3600',
  'FINGER_RESULT_AT: number = 3000'
) | ForEach-Object {
  if (-not $timing.Contains($_)) {
    throw "Decision timing contract is missing: $_"
  }
}

Write-Host 'Feedback synchronization check passed.'
