Add-Type -AssemblyName System.Drawing

$src = "C:\Users\syedm\.gemini\antigravity\brain\7d2daa18-b177-4b16-80b4-41a072a7f4fc\vibeflix_logo_v2_1777788272787.png"
$base = "D:\New folder (3)\vibeflix\android\app\src\main\res"

$sizes = @{
  "mipmap-mdpi"    = 48
  "mipmap-hdpi"    = 72
  "mipmap-xhdpi"   = 96
  "mipmap-xxhdpi"  = 144
  "mipmap-xxxhdpi" = 192
}

$img = [System.Drawing.Image]::FromFile($src)

foreach ($folder in $sizes.Keys) {
  $size = $sizes[$folder]
  $dir  = "$base\$folder"
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

  $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g   = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($img, 0, 0, $size, $size)
  $bmp.Save("$dir\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Host "Saved $folder ($size x $size)"
}

$img.Dispose()
Write-Host "All launcher icons updated!"
