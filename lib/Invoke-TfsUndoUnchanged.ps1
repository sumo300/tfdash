function Invoke-TfsUndoUnchanged {
<#
	.SYNOPSIS
	Undo unchanged files
	.DESCRIPTION
	Uses the tfpt uu command to undo any unchanged files recursively when compared to the latest changes.
	.EXAMPLE
	Invoke-TfsUndoUnchanged
#>
	Write-Host " "
	Write-Host "Undoing unchanged files recursively..." -f $cloc
	& $tfpt uu /recursive .
	Write-Host " "
}

