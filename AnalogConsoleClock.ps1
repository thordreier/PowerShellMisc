<#PSScriptInfo
	.VERSION    1.0.0
	.GUID       d70b01d9-6d5d-4775-9ae6-36724119dda1
	.AUTHOR     Thor Dreier-Hansen
	.COPYRIGHT  This is free and unencumbered software released into the public domain
	.TAGS       Analog Console Clock Watch
	.LICENSEURI http://unlicense.org
	.PROJECTURI https://github.com/thordreier/PowerShellMisc
#>




# Console character doesn't have same width and height
$scale        = 2

# Border between dial numbers and window edge
$border       = 1

# Radius of dial
$radius       = 20

# Colours
$colorDial    = [ConsoleColor]::White
$colorSecond  = [ConsoleColor]::Red
$colorMinute  = [ConsoleColor]::Green
$colorHour    = [ConsoleColor]::Magenta
$colorDigital = [ConsoleColor]::DarkGreen




# Get point on cirkle. Degree is between 0 and 360 (unles you want to go aroung the circle more than once)
function GetCirclePoint ([Double] $CenterX, [Double] $CenterY, [Double] $Radius, [Double] $Degree)
{
    $radian = [Math]::PI / 180 * $Degree
    ($CenterX + $Radius * [Math]::Sin($radian))
    ($CenterY - $Radius * [Math]::Cos($radian))
}


# Get point on dial based on time
function GetTimePoint ([Double] $Scale, [Double] $CenterX, [Double] $CenterY, [Double] $Radius, [ValidateSet('Hour','Minute','Second')][string] $Type, [Double] $Value)
{
    $div = 60
    if ($Type -eq 'Hour')
    {
        $div = 12
    }

    $degree = 360 / $div * $Value
    $x, $y = GetCirclePoint -CenterX $centerX -CenterY $centerY -Radius $radius -Degree $degree

    $x * $Scale
    $y
}


# Write to a specific point in the console
function DrawPoint ([Double] $X, [Double] $Y, [ConsoleColor] $Color, [string] $Text)
{
    $Host.UI.RawUI.CursorPosition = @{
        X = [int] $X
        Y = [int] $Y
    }
    Write-Host -Object $Text -NoNewline -ForegroundColor $Color
}


# Draw the numbers on the dial
function DrawDial ([Double] $Scale, [Double] $CenterX, [Double] $CenterY, [Double] $Radius, [ConsoleColor] $Color)
{
    foreach ($hour in 1..12)
    {
        $x, $y = GetTimePoint -Scale $Scale -CenterX $CenterX -CenterY $CenterY -Radius $Radius -Type Hour -Value $hour
        DrawPoint -X $x -Y $y -Color $Color -Text $hour
    }
}


# Draw one hand - or whipe a hand when the hand has moved
function DrawHand ([Double] $Scale, [Double] $CenterX, [Double] $CenterY, [Double] $Radius, [ConsoleColor] $Color, [ValidateSet('Hour','Minute','Second')][string] $Type, [Double] $Value, [string] $Text)
{
    foreach ($r in 0..($Radius * $Scale))
    {
        $r /= $Scale
        $x, $y = GetTimePoint -Scale $Scale -CenterX $CenterX -CenterY $CenterY -Radius $r -Type $Type -Value $Value
        DrawPoint -X $x -Y $y -Color $Color -Text $Text
    }
}


# Fix window with and height
function SetConsole ([Double] $Scale, [Double] $Border, [Double] $Radius)
{
    $diameterwithBorder = 2 * ($Border + $Radius) + 1
    $windowSize = @{
        Width  = [int] ($diameterwithBorder * $Scale)
        Height = [int]  $diameterwithBorder
    }

    # Do it twice, else it doesn't always work
    foreach ($i in 1..2)
    {
        $Host.ui.RawUI.BufferSize = $windowSize
        $Host.ui.RawUI.WindowSize = $windowSize
    }

    Clear-Host

    $Host.UI.RawUI.CursorSize = 0
}


# Starts the clock
function StartClock ([Double] $Scale, [Double] $Border, [Double] $Radius, [ConsoleColor] $ColorDial, [ConsoleColor] $ColorSecond, [ConsoleColor] $ColorMinute, [ConsoleColor] $ColorHour, [ConsoleColor] $ColorDigital)
{
    SetConsole -Scale $Scale -Border $border -Radius $radius

    $centerX      = $radius + $border
    $centerY      = $radius + $border

    $radiusSecond = $radius * 0.9
    $radiusMinute = $radius * 0.8
    $radiusHour   = $radius * 0.6

    $lastSecond = $null
    $lastMinute = $null
    $lastHour   = $null

    DrawDial -Scale $Scale -CenterX $centerX -CenterY $centerY -Radius $Radius -Color $colorDial

    # Loop forever. If we just sleep 1 second we will sometime miss a second because the drawing also takes time
    # If we sleep less (100 ms), but only do stuff if the second has changed, we don't have that problem
    while ($true)
    {
        $second = Get-Date -Format ss

        if ($second -ne $lastSecond)
        {
            $minute = Get-Date -Format mm
            $hour   = (Get-Date -Format hh) + (Get-Date -Format mm) / 60

            # Whipe the old
            DrawHand -Scale $Scale -CenterX $centerX -CenterY $centerY -Radius $radiusSecond -Color $colorSecond -Type Second -Value $lastSecond -Text ' '
            if ($minute -ne $lastMinute)
            {
                DrawHand -Scale $Scale -CenterX $centerX -CenterY $centerY -Radius $radiusMinute -Color $colorMinute -Type Minute -Value $lastMinute -Text ' '
                DrawHand -Scale $Scale -CenterX $centerX -CenterY $centerY -Radius $radiusHour   -Color $colorHour   -Type Hour   -Value $lastHour   -Text ' '
            }

            # Draw the new
            DrawHand -Scale $Scale -CenterX $centerX -CenterY $centerY -Radius $radiusSecond -Color $colorSecond -Type Second -Value $second -Text 'S'
            DrawHand -Scale $Scale -CenterX $centerX -CenterY $centerY -Radius $radiusMinute -Color $colorMinute -Type Minute -Value $minute -Text 'M'
            DrawHand -Scale $Scale -CenterX $centerX -CenterY $centerY -Radius $radiusHour   -Color $colorHour   -Type Hour   -Value $hour   -Text 'H'

            $lastSecond = $second
            $lastMinute = $minute
            $lastHour   = $hour

            # Also show a digital clock in the corner
            DrawPoint -X 0 -Y 0 -Color $ColorDigital -Text (Get-Date -Format HH:mm:ss)
        }

        Start-Sleep -Milliseconds 100
    }
}




StartClock -Scale $scale -Border $border -Radius $radius -ColorDial $colorDial -ColorSecond $colorSecond -ColorMinute $colorMinute -ColorHour $colorHour -ColorDigital $colorDigital
