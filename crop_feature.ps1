Add-Type -AssemblyName System.Drawing
$inPath = "C:\Users\syedm\.gemini\antigravity\brain\7d2daa18-b177-4b16-80b4-41a072a7f4fc\vibeflix_feature_graphic_raw_1777786235666.png"
$outPath = "D:\New folder (3)\vibeflix\feature_graphic.jpg"
$img = [System.Drawing.Image]::FromFile($inPath)
$bmp = New-Object System.Drawing.Bitmap(1024, 500)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$srcRect = New-Object System.Drawing.Rectangle(0, 262, 1024, 500)
$destRect = New-Object System.Drawing.Rectangle(0, 0, 1024, 500)
$g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$g.Dispose()
$bmp.Dispose()
$img.Dispose()
Write-Host "File Size (bytes):" (Get-Item $outPath).Length
