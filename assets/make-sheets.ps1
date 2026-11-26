Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$imgDir = Join-Path $root 'imagens'
$outDir = $PSScriptRoot

function Open-Img([string]$name) {
  return [System.Drawing.Image]::FromFile((Join-Path $imgDir $name))
}

function Draw-Cell([System.Drawing.Graphics]$g, [System.Drawing.Image]$src, [int[]]$rect) {
  $x = $rect[0]; $y = $rect[1]; $w = $rect[2]; $h = $rect[3]
  $srcRatio = $src.Width / $src.Height
  $dstRatio = $w / $h
  if ($srcRatio -gt $dstRatio) {
    $sw = [int]($src.Height * $dstRatio); $sh = $src.Height
    $sx = [int](($src.Width - $sw) / 2); $sy = 0
  } else {
    $sw = $src.Width; $sh = [int]($src.Width / $dstRatio)
    $sx = 0; $sy = [int](($src.Height - $sh) / 2)
  }
  $g.DrawImage($src, (New-Object System.Drawing.Rectangle($x, $y, $w, $h)), $sx, $sy, $sw, $sh, [System.Drawing.GraphicsUnit]::Pixel)
}

function Make-Sheet([string]$file, [int]$W, [int]$H, [int[][]]$cells, [string[]]$photos) {
  $scale = 0.5
  $W = [int]($W * $scale); $H = [int]($H * $scale)
  $bmp = New-Object System.Drawing.Bitmap($W, $H)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.Clear([System.Drawing.Color]::White)
  for ($i = 0; $i -lt 4; $i++) {
    $im = Open-Img $photos[$i]
    $c = $cells[$i]
    $rect = @([int]($c[0]*$scale),[int]($c[1]*$scale),[int]($c[2]*$scale),[int]($c[3]*$scale))
    Draw-Cell $g $im $rect
    $im.Dispose()
  }
  $path = Join-Path $outDir $file
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
  $g.Dispose(); $bmp.Dispose()
  Write-Host "$file $W x $H"
}

$workCells = @(@(0,0,1336,752), @(1352,0,1336,752), @(0,768,1336,752), @(1352,768,1336,752))
$work2Cells = @(@(0,0,1335,749), @(1356,0,1332,749), @(0,770,1335,750), @(1356,770,1332,750))
$team1Cells = @(@(0,0,864,1156), @(881,0,863,1156), @(0,1175,864,1161), @(881,1175,863,1161))
$team2Cells = @(@(0,0,864,1159), @(880,0,864,1159), @(0,1176,864,1160), @(880,1176,864,1160))
$btsCells = @(@(0,0,865,1160), @(881,0,863,1160), @(0,1176,865,1160), @(881,1176,863,1160))

Make-Sheet 'work1.jpg' 2688 1520 $workCells @('real-04.jpg','real-03.jpg','real-02.jpg','real-06.jpg')
Make-Sheet 'work2.jpg' 2688 1520 $work2Cells @('real-05.jpg','real-07.jpg','real-10.jpg','real-11.jpg')
Make-Sheet 'team1.jpg' 1744 2336 $team1Cells @('real-03.jpg','real-04.jpg','real-02.jpg','real-07.jpg')
Make-Sheet 'team2.jpg' 1744 2336 $team2Cells @('real-05.jpg','real-06.jpg','real-11.jpg','real-12.jpg')
Make-Sheet 'bts.jpg' 1744 2336 $btsCells @('real-10.jpg','real-12.jpg','real-04.jpg','real-07.jpg')

# Hero still: clean editorial composition with cream centre and softly framed cake photography at the edges.
$HW = 2048; $HH = 1360
$hero = New-Object System.Drawing.Bitmap($HW, $HH)
$g = [System.Drawing.Graphics]::FromImage($hero)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.Clear([System.Drawing.Color]::FromArgb(255,248,240))
$left = Open-Img 'real-07.jpg'; $right = Open-Img 'real-04.jpg'
Draw-Cell $g $left @(0,0,560,$HH)
Draw-Cell $g $right @(($HW-560),0,560,$HH)
$left.Dispose(); $right.Dispose()
$veil = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150,255,240,247))
$g.FillRectangle($veil, 0, 0, $HW, $HH)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Point(280, 0)),
  (New-Object System.Drawing.Point(1768, 0)),
  [System.Drawing.Color]::FromArgb(0,250,243,228),
  [System.Drawing.Color]::FromArgb(0,250,243,228))
$blend = New-Object System.Drawing.Drawing2D.ColorBlend
$blend.Positions = @(0, 0.18, 0.82, 1)
$blend.Colors = @(
  [System.Drawing.Color]::FromArgb(0,255,248,240),
  [System.Drawing.Color]::FromArgb(245,255,248,240),
  [System.Drawing.Color]::FromArgb(245,255,248,240),
  [System.Drawing.Color]::FromArgb(0,255,248,240))
$brush.InterpolationColors = $blend
$g.FillRectangle($brush, 280, 0, 1488, $HH)
$hero.Save((Join-Path $outDir 'hero-still.jpg'), [System.Drawing.Imaging.ImageFormat]::Jpeg)
$g.Dispose(); $hero.Dispose()
Write-Host 'hero-still.jpg 2048 x 1360'
