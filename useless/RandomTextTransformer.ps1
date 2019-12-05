# Use Get-Random to transform text
('slow helper'.ToCharArray()|random -C 99 -S 431524)-join''    # will output "powershell "
('hells power'.ToCharArray()|random -C 99 -S 100085736)-join'' # will output "powershell "



# And the code that can generate these anagrams ...

# Choose a string that is not too long - else you won't be able to find matches


# "X,X,X | Get-Random -SetSeed YY -Count ZZ", will always return objects in the same order as long as:
# - X array contains tha same number of elements
# - YY (seed) is the same
# - ZZ (count) is at least the number of elements in x
# Eg:
0,1,2,3,4                | Get-Random -SetSeed 9 -Count 9 # Return 1, 4, 3, 2, 0
'0x','1x','2x','3x','4x' | Get-Random -SetSeed 9 -Count 9 # Return 1x,4x,3x,2x,0x
# both are sorted in the same order even though the objects aren't the same

# (seed is 31 bit for Get-Random (no not 32 bit!))

# Use an anagram generator to find a good anagram (or more)
start https://www.google.com/search?q=anagram+generator

# This is the text you wan't to end up with
$str = 'powershell '

# Loop through all two billion (31 bit) possible seeds (or until you get tired and press CTRL-c)
# And yes, it could be optimized a lot to use multiple threads and such
0..[Int32]::MaxValue | ForEach-Object -Process {

    # $order is the order elements get randomized with the specific seed
    # so if it's an array with 5 elements and the seed is 9 it will be @(1,4,3,2,0) - see example above
    $order = 0..($str.Length -1) | Get-Random -Count 99 -SetSeed $_

    # $str2 is where the transformed string will end
    # here we just define it as an array with the same lenght as $str is long
    $str2 = 0..($str.Length -1)

    # we "build" $str2 out of the order in $order
    0..($str.Length -1) | ForEach-Object -Process {
        $str2[$order[$_]] = $str[$_]
    }

    # Best practice!? - naaahhh - is $str2 [char[]] eller [string] !?
    $str2 = $str2 -join ''

    # Just show some progress
    if (-not ($_ % 1000000))
    {
        Write-Verbose -Verbose -Message $_
    }

    if (
        # Math this before is is show
        # Must have the exact same characters as $str - spaces etc.
        # Case does not matter
        $str2 -eq 'hells power' -or
        $str2 -eq 'slow helper'

        # you could also just comment out the above and comment this in to show all strings
        #$true

        # or you could implement something that checked if it was a valid anagram here based on a dictionary!
    )
    {
        # Generates the PowerShell command
        '(''{0}''.ToCharArray()|random -C 99 -S {1})-join''''' -f $str2,$_
    }
}
