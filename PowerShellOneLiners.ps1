###############################################################################
# PowerShell one-liners
# - though some are better on multiple lines!
###############################################################################




###############################################################################
# Some examples on multiple ways to achieve the same
# - There's more than one way to do it ;-)
###############################################################################

                                         # Get #
                                      # all unique #
                                    # process names #
                                   # starting with S, #
                                # seperated with comma. #
                               # Some methods are better #
                               # than other! And removing #
                             # all unneeded spaces doesn't #
                             # make the code more readable! #
                          ((gps).Name|?{$_-like'S*'}|gu)-join','
                    ((gps).Name.Where({$_-like'S*'})|sort -U)-join','
                   ((gps).Name|sort -U|%{if($_-like'S*'){$_}})-join','
              gps|?{$_.Name-like'S*'}|sort Name -U|&{@($input.Name)-join','}
             gps|select -Expand Name|?{$_-match'^S'}|gu|&{@($input)-join','}
             (gps).Name|%{$h=@{}}{if($_-like'S*'){$h[$_]=1}}{$h.Keys-join','}
           gps|select -Expand Name|?{$_-like'S*'}|sort -U|&{@($input)-join','}
           gps|select -Expand Name|?{$_[0]-eq'S'}|sort -U|&{@($input)-join','}
           gps|? Name -Like S*|sort Name -U|%{$a=@()}{$a+=$_.Name}{$a-join','}
           gps|select -Expand Name|?{$_-match'^S'}|sort -U|&{@($input)-join','}
        gps|? Name -Like S*|sort Name -U|select -Expand Name|&{@($input)-join','}
      gps|sort Name -U|?{$_.Name-like'S*'}|select -Expand Name|&{@($input)-join','}
      gps|?{$_.Name-like'S*'}|sort Name -U|select -Expand Name|&{@($input)-join','}
(gps).Name|%{$a=@()}{if(($s=$_-replace'^[^S].*')-and!$a.Contains($s)){$a+=$s}}{$a-join','}
                                        gps|%{$a=
                                        @()}{$a+=
                                       $_.PSObject.
                                       Properties.
                                        Where({$_.
                                        Name-like
                                        'Name'-and
                                      $_.Value-like
                                     'S*'}).Foreach(
                                      {$_.Value})}{
                                    ($a|gu)-join,','}




###############################################################################
# Wait for a file to be be created and tail the content after it is created
# - Good for log files
###############################################################################

# One-liner
$p='C:\Transcripts';$c=@(gci $p).Count;while($c -eq @(gci $p).Count){sleep 1};gc -wai (gci $p | sort LastWriteTime -d)[0].FullName

# Multi-line version with comments
$path = 'C:\Transcripts'                               # Directory to look in
$count = @(Get-ChildItem -Path $path).Count            # Get number of files in directory
while ($count -eq @(Get-ChildItem -Path $path).Count)  # Loop while number of files hasn't changed
{                                                      #
    Start-Sleep -Seconds 1                             # Sleep 1 second between each check
}                                                      #
Get-Content -Wait -Path (                              # Get content of file. -Wait works basically the same way as (GNU) tail
    Get-ChildItem -Path $path |                        # Get all files in directory
    Sort-Object -Property LastWriteTime -Descending    # Sort by LastWriteTime
)[0].FullName                                          # Get the one that has been written to last, get the full path




###############################################################################
# Don't escape single quotes in JSON
# - Easier readable ARM templates when updating them with PowerShell
###############################################################################

# One-liner
@{variables = @{varName = "[concat('x','y')]"}} | ConvertTo-Json | %{$_-replace'\\u0027',"'"}

# Multi-line version with comments
@{variables= @{varName = "[concat('x','y')]"}} |  # Just a hashtable with some test data
ConvertTo-Json |                                  # Convert the hashtable to JSON
ForEach-Object -Process {                         # Just makes it possible to take what is on the pipeline
    $_ -replace '\\u0027', "'"                    # Replace \u0027 with '
}                                                 #




###############################################################################
# Escape non-ASCII
# - Sometimes it's hard to get data out with non ASCII charsets - JSON support escaping
###############################################################################

# One-liner
@{Prop="Non-ASCII: זרו"} | ConvertTo-Json | %{$_.ToCharArray()}|%{$s=''}{$s+=if(($x=[int]$_)-gt127){'\u{0:x4}'-f$x}else{$_}}{$s}

# Multi-line version with comments
@{Prop="Non-ASCII: זרו"} |              # Just a hashtable with some test data
ConvertTo-Json |                        # Convert the hashtable to JSON
ForEach-Object -Process {               # Just makes it possible to take what is on the pipeline
    $_.ToCharArray()                    # Convert JSON string to [char[]]
} | ForEach-Object -Begin {             # Used to loop through all [char]
    $s = ''                             # Initialize $s
} -Process {                            # Loop through all [char]
    $s += if (($x = [int] $_) -gt 127)  # The return value from the if statement is put in $s
    {                                   # $x contains the nummeric value for the [char]
        '\u{0:x4}' -f $x                # If it's non-ASCII (above 127), it is escaped in the \uXXXX format
    }                                   #   and appended to $s
    else                                #
    {                                   #
        $_                              # If it's ASCII it just get appended to $s
    }                                   #
} -End {                                #
    $s                                  # When all [char] on the pipeline has been processed the new string
}                                       # with escaped non-ASCII is returned




###############################################################################
# Split array into chunks
# - N objects in each array
###############################################################################

# One-liner
gps | group (&{$i=0;{[math]::Floor($script:i++/100)}.GetNewClosure()}) | %{"Name contains the number: $($_.Name). Do stuff with these $($_.Group.Count) objects"}

# Multi-line version with comments
Get-Process |                                        # Get-Process is just used to generate some test data
Group-Object -Property {                             # Group-Object is used to group objects into chunks
    $i=0                                             # Initialize counter
    {                                                # Begin of [ScriptBlock] that will be returned as closure
        [math]::Floor($script:i++ / 100)             # This makes sure that return value is incremented with one each time 100 objects has been processed
    }.GetNewClosure()                                # This inner [ScriptBlock] is the one that is returned to Group-Object - converted to closure
                                                     #   the closure makes sure that $i is initialized to zero but can be incremented for each object on the pipeline
}.Invoke() |                                         # Run the outer [ScriptBlock] (which returns the inner [ScriptBlock]) - in the one-liner we used &{} instead of {}.Invoke()
ForEach-Object -Process {                            # Loop through all the "chunks"
    "Name contains the number: $($_.Name). " +       #
    "Do stuff with these $($_.Group.Count) objects"  # $_.Group contain the objects in the "chunk"
}                                                    #




###############################################################################
# Split array into chunks
# - Max N bytes in each file (plus a little overhead)
###############################################################################

# One-liner
0..1000 | %{'x'*(random 1000)} | group (&{$i=$j=0;{$l=(ConvertTo-Json $_ -D 99 -C).Length;if(($script:j+=$l)-gt199KB){++$script:i;$script:j=$l};$i}.GetNewClosure()}) | %{ConvertTo-Json $_.Group -D 99 -C | sc "chunk-$($_.Name).json"}

# Multi-line version with comments
0..1000 | ForEach-Object -Process {                                       # Generate som test data. Array with 1000 objects
    'x' * (Get-Random -Maximum 1000)                                      # Each object is a string that is between 0 and 1000 bytes long
} | Group-Object -Property {                                              # Group-Object is used to group objects into chunks
    $i = 0                                                                # Initialize counter
    $j = 0                                                                # Initialize size of chunk
    {                                                                     # Begin of [ScriptBlock] that will be returned as closure
        $l = (ConvertTo-Json -InputObject $_ -Depth 99 -Compress).Length  # Put size of object (converted to JSON) in $l
        if (($script:j += $l) -gt 199KB)                                  # Add $l to the total size of chunk ($j). If it's above 199 KB
        {                                                                 #   then...
            ++$script:i                                                   # Increase counter by one - make sure that this object is put in the next chunk
            $script:j = $l                                                # Reset the total size of the chunk to be only the size of this object
        }                                                                 #   (there's a little overhead in the final output (some extra commas and square brackets))
        $i                                                                # Return counter - which chunk should the object be in
    }.GetNewClosure()                                                     # This inner [ScriptBlock] is the one that is returned to Group-Object - converted to closure
}.Invoke() |                                                              # Run the outer [ScriptBlock] (which returns the inner [ScriptBlock]) - in the one-liner we used &{} instead of {}.Invoke()
ForEach-Object -Process {                                                 # Loop through all the "chunks"
    ConvertTo-Json -InputObject $_.Group -Depth 99 -Compress |            # Convert the chunk to JSON
    Set-Content -Path "chunk-$($_.Name).json"                             # And write it to a file ($_.Name contains the chunk-number)
}                                                                         #
