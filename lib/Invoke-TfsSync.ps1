function Invoke-TfsSync([string]$path) {
<#
	.SYNOPSIS
	Switches your TFS workfolder mapping to the provided TFS path and gets the latest version of the files.
	.DESCRIPTION
	The Invoke-TfsSync function calls Invoke-TfsPull and Get-TfsLatest in order to provide branch switching functionality.
	.PARAMETER path
	The TFS path being mapped to.
	.NOTES
	Command must be run from the root folder of the workspace.
	.EXAMPLE
	Invoke-TfsSync "$/Web/Source/UAT"
#>
  if ($path -eq "") {
    Get-Help Invoke-TfsSync -detailed
    return
  }

  $pattern = "\$.+:\s(.+)"
  $workspacePath = (tf workfold | Select-String -pattern $pattern).Matches[0].Groups[1].Value.Trim()
  $localPath = (pwd).Path.Trim()
  
  if ($workspacePath -ne $localPath) {
	Write-Host " "
	Write-Host "You must run this command from $workspacePath" -f $cerr
	return
  }
  
  Invoke-TfsPull $path | foreach-object {
	Write-Progress -id 1 -Activity "Synchronizing workfolder to $path"
  }

  Get-TfsLatest
}
