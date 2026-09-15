param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$checker = 'C:\Users\27363\Desktop\harmonyos-project-standard-cn\scripts\check_harmonyos_standard.py'
python $checker $projectRoot
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& (Join-Path $PSScriptRoot 'check-appgallery-ux.ps1')
& (Join-Path $PSScriptRoot 'check-feedback-release.ps1')
& (Join-Path $PSScriptRoot 'check-finger-select-layout.ps1')
& (Join-Path $PSScriptRoot 'check-dark-theme-coverage.ps1')
& (Join-Path $PSScriptRoot 'check-visual-integrity.ps1')
