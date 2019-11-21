###############################################################################
# PowerShell one-liners
# - though some are better on multiple lines!
###############################################################################




###############################################################################
# Wait for a (log) file to be be created and tail the content after it is created
###############################################################################

# One-liner
$p='C:\Transcripts';$c=@(gci $p).Count;while($c -eq @(gci $p).Count){sleep 1};gc -wai (gci $p | sort LastWriteTime -d)[0].FullName

# Multi-line version
$path = 'C:\Transcripts'
$count = @(Get-ChildItem -Path $path).Count
while ($count -eq @(Get-ChildItem -Path $path).Count)
{
    Start-Sleep -Seconds 1
}
Get-Content -Wait -Path (Get-ChildItem -Path $path | Sort-Object -Property LastWriteTime -Descending)[0].FullName




###############################################################################
# Don't escape single quotes in JSON
# - Easier readable ARM templates when updating them with PowerShell
###############################################################################

# One-liner
@{variables = @{varName = "[concat('x','y')]"}} | ConvertTo-Json | %{$_-replace'\\u0027',"'"}




###############################################################################
# Escape non-ASCII
# - Sometimes it's hard to get data out with non ASCII charsets - JSON support escaping
###############################################################################

# One-liner
@{Prop="Non-ASCII: זרו"} | ConvertTo-Json | %{$_.ToCharArray()}|%{$s=''}{$s+=if(($x=[int]$_)-gt127){'\u{0:x4}'-f$x}else{$_}}{$s}

# Multi-line version
$data = @{Prop="Non-ASCII: זרו"}
$data | ConvertTo-Json | ForEach-Object -Process {
    $_.ToCharArray()
} | ForEach-Object -Begin {
    $s = ''
} -Process {
    $s += if (($x = [int] $_) -gt 127)
    {
        '\u{0:x4}' -f $x
    }
    else
    {
        $_
    }
} -End {
    $s
}
