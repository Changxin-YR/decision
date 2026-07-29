param(
  [Parameter(Mandatory = $true)]
  [string]$SourceDir
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $projectRoot 'entry\src\main\resources\base\media'

function Export-Crop {
  param(
    [string]$SourceName,
    [string]$OutputName,
    [System.Drawing.Rectangle]$Bounds
  )

  $sourcePath = Join-Path $SourceDir $SourceName
  $outputPath = Join-Path $outputDir $OutputName
  $source = [System.Drawing.Bitmap]::FromFile($sourcePath)
  try {
    if ($source.Width -lt $Bounds.Right -or $source.Height -lt $Bounds.Bottom) {
      throw "Crop $OutputName exceeds source dimensions."
    }
    $crop = $source.Clone($Bounds, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
      $crop.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
      $crop.Dispose()
    }
  } finally {
    $source.Dispose()
  }
}

Export-Crop `
  -SourceName '1ace3e03-13b6-45ea-8b05-c1258ba1f7a6.jpg' `
  -OutputName 'ui_draw_box.png' `
  -Bounds ([System.Drawing.Rectangle]::new(120, 390, 620, 620))

Export-Crop `
  -SourceName '33655a8a-fcbb-4a14-8eac-58e55f988d0c.jpg' `
  -OutputName 'ui_finger_guide.png' `
  -Bounds ([System.Drawing.Rectangle]::new(100, 510, 660, 710))

Export-Crop `
  -SourceName 'a6939ca5-15c2-4357-8700-6cb5ec6b51d9.jpg' `
  -OutputName 'ui_coin.png' `
  -Bounds ([System.Drawing.Rectangle]::new(180, 430, 520, 570))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_wheel.png' `
  -Bounds ([System.Drawing.Rectangle]::new(68, 342, 150, 160))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_draw.png' `
  -Bounds ([System.Drawing.Rectangle]::new(468, 342, 150, 160))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_finger.png' `
  -Bounds ([System.Drawing.Rectangle]::new(68, 600, 150, 170))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_coin.png' `
  -Bounds ([System.Drawing.Rectangle]::new(468, 600, 150, 170))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_yesno.png' `
  -Bounds ([System.Drawing.Rectangle]::new(68, 840, 150, 180))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_number.png' `
  -Bounds ([System.Drawing.Rectangle]::new(468, 840, 150, 180))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_history.png' `
  -Bounds ([System.Drawing.Rectangle]::new(610, 140, 66, 66))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_home_settings.png' `
  -Bounds ([System.Drawing.Rectangle]::new(735, 140, 66, 66))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_quick_food.png' `
  -Bounds ([System.Drawing.Rectangle]::new(62, 1145, 96, 96))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_quick_takeout.png' `
  -Bounds ([System.Drawing.Rectangle]::new(62, 1270, 96, 96))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_quick_weekend.png' `
  -Bounds ([System.Drawing.Rectangle]::new(62, 1390, 96, 100))

Export-Crop `
  -SourceName '27091e94-4671-46df-a81d-378bb76e8f16.jpg' `
  -OutputName 'ui_quick_first.png' `
  -Bounds ([System.Drawing.Rectangle]::new(62, 1510, 96, 100))

Export-Crop `
  -SourceName '4b61dbed-4c98-440d-a33c-3fc3838c1db6.jpg' `
  -OutputName 'ui_history_clear.png' `
  -Bounds ([System.Drawing.Rectangle]::new(765, 95, 70, 70))

Export-Crop `
  -SourceName '4b61dbed-4c98-440d-a33c-3fc3838c1db6.jpg' `
  -OutputName 'ui_history_number.png' `
  -Bounds ([System.Drawing.Rectangle]::new(58, 360, 82, 90))

Export-Crop `
  -SourceName '4b61dbed-4c98-440d-a33c-3fc3838c1db6.jpg' `
  -OutputName 'ui_history_coin.png' `
  -Bounds ([System.Drawing.Rectangle]::new(58, 470, 82, 90))

Export-Crop `
  -SourceName '4b61dbed-4c98-440d-a33c-3fc3838c1db6.jpg' `
  -OutputName 'ui_history_wheel.png' `
  -Bounds ([System.Drawing.Rectangle]::new(58, 575, 82, 90))

Export-Crop `
  -SourceName '4b61dbed-4c98-440d-a33c-3fc3838c1db6.jpg' `
  -OutputName 'ui_history_draw.png' `
  -Bounds ([System.Drawing.Rectangle]::new(58, 680, 82, 90))

Export-Crop `
  -SourceName '4b61dbed-4c98-440d-a33c-3fc3838c1db6.jpg' `
  -OutputName 'ui_history_yesno.png' `
  -Bounds ([System.Drawing.Rectangle]::new(58, 785, 82, 90))

Get-ChildItem -LiteralPath $outputDir -Filter 'ui_*.png' |
  Select-Object Name, Length
