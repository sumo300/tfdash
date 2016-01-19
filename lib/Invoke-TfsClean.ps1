function Invoke-TfsClean([string]$params = "") {
<#
	.SYNOPSIS
	Recursively deletes files and folders not under version control.
	.DESCRIPTION
	The Invoke-TfsClean function uses the TFS "tf reconcile" command to 
	recursively delete files and folders not under version control.
	
	This command is basically a clean-up to remove untracked files/folders.
	.PARAMETER params
	Allows additional tf reconcile switches to be specified.  Available 
	parameters:
	
	/noprompt                        Operate in command-line mode only
	/preview                         Do not make changes; only list the potential actions
    /noignore
    /exclude:itemspec1,itemspec2,... Files and directories matching an itemspec
                                     in this list are excluded from processing
	itemspec                         Only files and directories matching these filespecs
						             are processed (inclusion list)
	.EXAMPLE
	Invoke-TfsClean
	.EXAMPLE
	Invoke-TfsClean /noprompt
#>
	if ($params.Contains("/noprompt")) {
        & tf reconcile /clean /diff /recursive /unmapped . $params | foreach-object {
			$item = "> " + $_
			Write-Progress -id 1 -Activity "Cleaning up your work folder from the current directory" -status $item
		}
	} else {
		& tf reconcile /clean /diff /recursive /unmapped . $params
	}
}
