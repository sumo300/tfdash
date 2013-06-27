#theme
$cdelim = [ConsoleColor]::DarkCyan;
$chost = [ConsoleColor]::Green;
$cloc = [ConsoleColor]::Cyan;
$cerr = [ConsoleColor]::Red;

function Write-ShortenedPath
{
  Write-Host "$([char]0x0A7) " -n -f $cloc
	Write-Host "{" -n -f $cdelim
	Write-Host (Get-ShortenedPath (pwd).Path) -n -f $cloc
	Write-Host "}" -n -f $cdelim
}

function Write-TfsVcsStatus
{
  # TODO: Fix defect that causes tf.exe to be called regardless if we're in a workspace or not (SLOW)
	Set-TfsGlobals

	if ($global:currentTfsBranch -ne $null) {
		Write-Host " [" -n -f $cdelim
		Write-Host $global:currentTfsBranch -n -f $chost
		Write-Host " " -n
		Write-Host $global:localVersion -n -f DarkYellow
		Write-Host "]" -n -f $cdelim
	}
}
