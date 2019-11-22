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




###############################################################################
# Split array into chunks
###############################################################################

#### N objects in each array ####

# One-liner
Get-Process | group {$i=0;{[math]::Floor($script:i++/100)}.GetNewClosure()}.Invoke() | %{"Name contains the number: $($_.Name). Do stuff with these $($_.Group.Count) objects"}

# Multi-line version (without closures)
$i=0
Get-Process | Group-Object -Property {
    [math]::Floor($script:i++ / 100)
} | ForEach-Object -Process {
    "Name contains the number: $($_.Name). Do stuff with these $($_.Group.Count) objects"
}


#### Max N bytes in each file (plus a little overhead) ####
0..1000 | %{'x'*(random 1000)} | group (&{$i=$j=0;{$l=(ConvertTo-Json $_ -D 99 -C).Length;if(($script:j+=$l)-gt199KB){++$script:i;$script:j=$l};$i}.GetNewClosure()}) | %{ConvertTo-Json $_.Group -D 99 -C | sc "chunk-$($_.Name).json"}

# Multi-line version
0..1000 | ForEach-Object -Process {
    'x' * (Get-Random -Maximum 1000)
} | Group-Object -Property (&{
    $i = 0
    $j = 0
    {
        $l = (ConvertTo-Json -InputObject $_ -Depth 99 -Compress).Length
        if (($script:j += $l) -gt 199KB)
        {
            ++$script:i
            $script:j = $l
        }
        $i
    }.GetNewClosure()
}) | ForEach-Object -Process {
    ConvertTo-Json -InputObject $_.Group -Depth 99 -Compress | Set-Content -Path "chunk-$($_.Name).json"
}
