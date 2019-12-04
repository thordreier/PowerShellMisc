# Show some snow in the console
# Uses too much CPU!
# This does not work in ISE
$snow = [System.Collections.ArrayList] @(@{X=0;Y=0})
while ($true)
{
    0..(random ($Host.UI.RawUI.WindowSize.Width / 3)) | %{$null = $snow.Insert((random ($snow.Count)), @{X=random ($Host.UI.RawUI.WindowSize.Width -2); Y=-1})}
    foreach ($s in $snow.ToArray())
    {
        if ($s.Y -ge 0)
        {
            $Host.UI.RawUI.CursorPosition = $s
            Write-Host -NoNewline ' '
        }
        if (++$s.Y -ge $Host.UI.RawUI.WindowSize.Height)
        {
            $null = $snow.Remove($s)
        }
        else
        {
            $Host.UI.RawUI.CursorPosition = $s
            Write-Host -NoNewline '*'
        }
    }
}
