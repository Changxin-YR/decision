param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$hvigor = 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat'

Push-Location $projectRoot
try {
  & $hvigor --mode module -p product=default -p module=entry@default assembleHap --no-daemon
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
  & $hvigor --mode module -p product=default -p module=entry@ohosTest assembleHap --no-daemon
  exit $LASTEXITCODE
} finally {
  Pop-Location
}
