function Invoke-TfsOnline() {
<#
	.SYNOPSIS
	Recursively checks for files that need to be added, deleted, or checked out for edit, from the current folder.
	.DESCRIPTION
	The Invoke-TfsOnline function uses the TFS Power Tools "tfpt online" command to recursively pend local changes, checking for adds, deletes, and differences from the current folder.
	Current attempts to exclude the following: bin, obj
	.EXAMPLE
	Invoke-TfsOnline
#>
    Write-Host " "
    Write-host "Pending local changes in the current folder with /adds /deletes /diff /recursive /exclude:bin,obj" -f $cloc
    & $tfpt online . /adds /deletes /diff /recursive /exclude:bin,obj
    Write-Host " "
}
