# Show a text, letters are coloured, the colours are "rolling"
# This does not work in ISE
$Message = "Merry Christmas and Happy New Year to all PowerShellers out there!!"
$colors = 0..($Message.Length -1) | %{random 16}
while ($true)
{
    $pos = $Host.UI.RawUI.CursorPosition
    $pos.X = $pos.Y = 0
    $Host.UI.RawUI.CursorPosition = $pos
    $null, $colors = $colors + (random 16)
    0..($Message.Length -1) | %{
        Write-Host -ForegroundColor $colors[$_] $Message[$_] -NoNewline
    }
    sleep -Milliseconds 200
}
