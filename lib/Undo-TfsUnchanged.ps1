function Undo-TfsUnchanged {
<#
	.SYNOPSIS
	Undo unchanged files
	.DESCRIPTION
	Uses the tfpt uu command to undo any unchanged files recursively when compared to the latest changes.
    .PARAMETER withget
    Run a get before checking.  Alias: wg
	.EXAMPLE
	Undo-TfsUnchanged
    .NOTES
    v1.1 - Now defaults to use /noget parameter and added usage of Verbose to output cmd being executed.
#>
[CmdletBinding()]
Param (
    [switch]
    [Alias("wg")]
    $withget,
    [switch]
    [Alias("r")]
    $recursive = $true,
    [string]
    $itemspec = "*"
)
	Write-Host " "
	Write-Host "Undoing unchanged files recursively..." -f $cloc
	
    $args = @("uu")

    if ($recursive) {
        $args += "/recursive"
    }

    if (-not $withget) {
        $args += "/noget"
    }

    $args += $itemspec

    $cmd = "'$tfpt' $args"
    
    if ($PSBoundParameters['Verbose']) {
        Write-Host "Command: $cmd"
    }
    
    Invoke-Expression "& $cmd"

	Write-Host " "
}

