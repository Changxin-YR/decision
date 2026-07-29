param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$checker = 'C:\Users\27363\Desktop\harmonyos-project-standard-cn\scripts\check_harmonyos_standard.py'
python $checker $projectRoot
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
