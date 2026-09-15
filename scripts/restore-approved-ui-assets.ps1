param(
  [Parameter(Mandatory = $true)]
  [string]$CoinReference,
  [Parameter(Mandatory = $true)]
  [string]$HomeReference
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$mediaDir = Join-Path $projectRoot 'entry\src\main\resources\base\media'

function Remove-Neutral-ScreenshotBackground([string]$fileName) {
  $path = Join-Path $mediaDir $fileName
  $source = [System.Drawing.Bitmap]::new($path)
  $clean = [System.Drawing.Bitmap]::new(
    $source.Width,
    $source.Height,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  try {
    for ($y = 0; $y -lt $source.Height; $y += 1) {
      for ($x = 0; $x -lt $source.Width; $x += 1) {
        $pixel = $source.GetPixel($x, $y)
        $maximum = [Math]::Max($pixel.R, [Math]::Max($pixel.G, $pixel.B))
        $minimum = [Math]::Min($pixel.R, [Math]::Min($pixel.G, $pixel.B))
        $neutral = ($maximum - $minimum) -le 12
        if ($neutral -and $minimum -ge 184) {
          $clean.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        } else {
          $clean.SetPixel($x, $y, $pixel)
        }
      }
    }
    $source.Dispose()
    $clean.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    $source.Dispose()
    $clean.Dispose()
  }
}

function Export-Keyed-Crop(
  [System.Drawing.Bitmap]$source,
  [string]$fileName,
  [System.Drawing.Rectangle]$bounds,
  [switch]$ClipCoinSilhouette
) {
  $crop = $source.Clone(
    $bounds,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  $result = [System.Drawing.Bitmap]::new(
    $crop.Width,
    $crop.Height,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  try {
    for ($y = 0; $y -lt $crop.Height; $y += 1) {
      for ($x = 0; $x -lt $crop.Width; $x += 1) {
        $pixel = $crop.GetPixel($x, $y)
        $brightness = [Math]::Max($pixel.R, [Math]::Max($pixel.G, $pixel.B))
        $outsideCoin = $false
        if ($ClipCoinSilhouette) {
          $normalizedX = ($x - 165.0) / 145.0
          $normalizedY = ($y - 155.0) / 142.0
          $outsideCoin = (($normalizedX * $normalizedX) +
            ($normalizedY * $normalizedY)) -gt 1.0
        }
        if ($brightness -le 90 -or $outsideCoin) {
          $result.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        } else {
          $alpha = [Math]::Min(255, [Math]::Max(0, ($brightness - 90) * 6))
          $result.SetPixel(
            $x,
            $y,
            [System.Drawing.Color]::FromArgb(
              $alpha,
              $pixel.R,
              $pixel.G,
              $pixel.B
            )
          )
        }
      }
    }
    $result.Save(
      (Join-Path $mediaDir $fileName),
      [System.Drawing.Imaging.ImageFormat]::Png
    )
  } finally {
    $crop.Dispose()
    $result.Dispose()
  }
}

function Export-Circular-Crop(
  [System.Drawing.Bitmap]$source,
  [string]$fileName,
  [System.Drawing.Rectangle]$bounds
) {
  $crop = $source.Clone(
    $bounds,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  try {
    $centerX = ($crop.Width - 1) / 2
    $centerY = ($crop.Height - 1) / 2
    $radius = [Math]::Min($crop.Width, $crop.Height) / 2
    for ($y = 0; $y -lt $crop.Height; $y += 1) {
      for ($x = 0; $x -lt $crop.Width; $x += 1) {
        $distance = [Math]::Sqrt(
          [Math]::Pow($x - $centerX, 2) + [Math]::Pow($y - $centerY, 2)
        )
        if ($distance -gt $radius) {
          $crop.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        }
      }
    }
    $crop.Save(
      (Join-Path $mediaDir $fileName),
      [System.Drawing.Imaging.ImageFormat]::Png
    )
  } finally {
    $crop.Dispose()
  }
}

@(
  'ui_history_clear.png',
  'ui_history_number.png',
  'ui_history_coin.png',
  'ui_history_wheel.png',
  'ui_history_draw.png',
  'ui_history_yesno.png'
) | ForEach-Object {
  Remove-Neutral-ScreenshotBackground $_
}

$homeReferenceBitmap = [System.Drawing.Bitmap]::FromFile($HomeReference)
try {
  $homeCrops = @(
    @{ Name = 'ui_home_history.png'; Bounds = [System.Drawing.Rectangle]::new(655, 150, 75, 75); Circular = $false },
    @{ Name = 'ui_home_settings.png'; Bounds = [System.Drawing.Rectangle]::new(797, 150, 75, 75); Circular = $false },
    @{ Name = 'ui_home_wheel.png'; Bounds = [System.Drawing.Rectangle]::new(62, 382, 145, 145); Circular = $true },
    @{ Name = 'ui_home_draw.png'; Bounds = [System.Drawing.Rectangle]::new(492, 382, 145, 145); Circular = $true },
    @{ Name = 'ui_home_finger.png'; Bounds = [System.Drawing.Rectangle]::new(62, 625, 145, 145); Circular = $true },
    @{ Name = 'ui_home_coin.png'; Bounds = [System.Drawing.Rectangle]::new(492, 625, 145, 145); Circular = $true },
    @{ Name = 'ui_home_yesno.png'; Bounds = [System.Drawing.Rectangle]::new(62, 864, 145, 145); Circular = $true },
    @{ Name = 'ui_home_number.png'; Bounds = [System.Drawing.Rectangle]::new(492, 864, 145, 145); Circular = $true },
    @{ Name = 'ui_quick_food.png'; Bounds = [System.Drawing.Rectangle]::new(72, 1152, 82, 78); Circular = $false },
    @{ Name = 'ui_quick_takeout.png'; Bounds = [System.Drawing.Rectangle]::new(72, 1278, 90, 72); Circular = $false },
    @{ Name = 'ui_quick_weekend.png'; Bounds = [System.Drawing.Rectangle]::new(74, 1402, 82, 72); Circular = $false },
    @{ Name = 'ui_quick_first.png'; Bounds = [System.Drawing.Rectangle]::new(72, 1527, 88, 72); Circular = $false }
  )
  foreach ($item in $homeCrops) {
    $darkName = $item.Name.Replace('.png', '_dark.png')
    if ($item.Circular) {
      Export-Circular-Crop $homeReferenceBitmap $darkName $item.Bounds
    } else {
      Export-Keyed-Crop $homeReferenceBitmap $darkName $item.Bounds
    }
  }
} finally {
  $homeReferenceBitmap.Dispose()
}

$reference = [System.Drawing.Bitmap]::FromFile($CoinReference)
try {
  $bounds = [System.Drawing.Rectangle]::new(600, 270, 330, 320)
  if ($reference.Width -lt $bounds.Right -or $reference.Height -lt $bounds.Bottom) {
    throw 'Coin reference is smaller than the approved crop bounds.'
  }
  Export-Keyed-Crop $reference 'ui_coin_dark.png' $bounds -ClipCoinSilhouette
} finally {
  $reference.Dispose()
}

Write-Host 'Approved UI assets restored.'
