function Invoke-TfsUpdate() {
<#
	.SYNOPSIS
	Updates your TFS workfolder to the latest version based on the workspace mapping.
	.DESCRIPTION
	The Invoke-TfsUpdate function uses TFS's command-line "tf get" command to get the latest version of files based on the current workspace mapping.
	When used in conjunction with Invoke-TfsPull, it provides a way to use the same workfolder for different TFS path mappings, effectively giving you branch switching.
	.EXAMPLE
	Invoke-TfsUpdate
#>
	tf get . /version:T /remap /overwrite /recursive | foreach-object {
		$item = "> " + $_
		Write-Progress -id 2 -parentId 1 -Activity "Updating workfolder" -status $item
	}
}
