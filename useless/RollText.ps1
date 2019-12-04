# Fill the screen with "rolling" text
$m="Merry Christmas to you all   " * 3;while(1){$m;$m=$m.Substring(1,$m.Length-1)+$m[0];sleep -m 100}
