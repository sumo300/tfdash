<#
	Description: TFS 2010 PowerShell Helper Functions
	Author:      Michael J. Sumerano
	License:     GNU GENERAL PUBLIC LICENSE v3 (see license.txt for full license)
#>

$tfpt = "${Env:ProgramFiles(x86)}\Microsoft Team Foundation Server 2010 Power Tools\TFPT.EXE"

function Get-ShortenedPath {
<#
	.SYNOPSIS 
	Gets a shortened version of the current path
	.DESCRIPTION
	Gets a shortened version of the current path by replacing all but the current folder with a single character
	so that deep folder structures do not ruin the prompt.
	Adapted from: http://winterdom.com/2008/08/mypowershellprompt
#>
    param([string] $path)
	$loc = $path.Replace($HOME, '~')
	# remove prefix for UNC paths
	$loc = $loc -replace '^[^:]+::', ''
	# make path shorter like tabs in Vim,
	# handle paths starting with \\ and . correctly
	return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}

function Set-TfsGlobals {
<#
	.SYNOPSIS
	Sets some global TFS variables to avoid constantly calling tf.exe, tfpt.exe,
	and possibly TFPT PowerShell Cmdlets.
#>
	try {
		if ($(Get-TfsWorkspaceMappingNeedsRefresh)) {
		  $branchName = Get-TfsCurrentBranchName

		  if ($branchName -ne $null) {
			$global:localVersion = Get-TfsWorkspaceGetLocalVersion;
			$global:currentTfsBranch = $branchName;
			$global:previousLocation = (pwd).Path;
		  } else {
			Reset-TfsGlobals
		  }
		}
	} catch {
		Reset-TfsGlobals
	}
}

function Reset-TfsGlobals {
<#
	.SYNOPSIS
	Resets global TFS variables.
#>
	$global:localVersion = $null
	$global:previousLocation = $null
	$global:currentTfsBranch = $null
}

#  Matches 2012.02.28 in a TFS workspace folder like
#  $/Web/Source/Release/2012/2012.02.28: D:\tfs\_MainWork
function Get-TfsCurrentBranchName {
<#
	.SYNOPSIS
	Attempts to get the branch name mapped to the current workspace.
	.DESCRIPTION
	Attempts to get the branch name mapped to the current workspace.  Assumes
	that a branch is mapped and not a sub-folder.  Aside from possibly calling
	the TFS Web services directly, discovering a method to finding  the current
	branch is difficult.
	.NOTES
	Matches 2012.02.28 in a TFS workspace folder like
	$/Web/Source/Release/2012/2012.02.28: D:\tfs\_work
#>
	$current = tf workfold .;
	$match = [regex]::Match($current, "([\$][^\:]*[\/])([^\/:]*)[\:]");

	if ($match.Success) {
		Write-Output $match.Groups[2]
	} else {
		Write-Output $null
	}
}

function Get-TfsWorkspaceMappingNeedsRefresh() {
<#
	.SYNOPSIS
	Attempts to determine whether or not the prompt needs to be updated if the
	current folder is a different branch or if it's been switched to another 
	branch.
#>
    $currentLocation = (pwd).Path;
    $needsRefresh = -not $currentLocation.Contains($global:previousLocation) -or $global:currentTfsBranch -eq $null;

    if ($currentLocation.Contains($global:previousLocation) -eq $False) {
      $global:previousLocation = $currentLocation;
    }

    return $needsRefresh;
}

function Get-TfsWorkspaceGetLocalVersion() {
<#
	.SYNOPSIS
	Gets the changeset # of the workspace and server, then compares them.
	Returns just the changeset number if both match, which means local and
	server are in sync.  Returns the local changeset number and the server
	changeset number prepended on it if the numbers don't match.
#>
	$changesets = Get-TfsVersions
    
    # Gets current workspace "version"
	$local = $changesets[0]
	
	# Gets current server "version"
	$server = $changesets[1]

	if ($local -eq $server -or $server -eq $null) {
		return $local;
	}
	
	return "$local *$server" 
}

function Get-TfsVersions() {
<#
	.SYNOPSIS
	Outputs the local and server changeset numbers.
#>
	$local = Get-TfsVersion "W"
	$server = Get-TfsVersion "T"
	
	Write-Output $local
	Write-Output $server
}

function Get-TfsProperties([string]$path = ".") {
<#
	.SYNOPSIS
	Calls the "tf properties" command with the passed in path and returns the output.
	.PARAMETER path
	The local path to get TFS properties for.  Defaults to "."
    .EXAMPLE
	Get-TfsProperties
	.EXAMPLE
	Get-TfsProperties c:\some-path
#>
    return tf properties $path
}

function Get-TfsVersion([string]$versionSpec) {
<#
	.SYNOPSIS
	Gets the largets changeset number of the current workspace based on the versionSpec provided.
	.PARAMETER versionSpec
    Date/Time         D"any .Net Framework-supported format"
                      or any of the date formats of the local machine
    Changeset number  Cnnnnnn
    Label             Llabelname
    Latest version    T
    Workspace         Wworkspacename;workspaceowner
	.EXAMPLE
	Get-TfsVersion T
	.EXAMPLE
	Get-TfsVersion W
	.EXAMPLE
	Get-TfsVersion D"2013-01-01"
	.EXAMPLE
	Get-TfsVersion C12345
#>
	try {
		$history = Get-TfsItemHistory -HistoryItem . -Recurse -StopAfter 1 -Version $versionSpec | %{ $_.ChangesetId }
	} catch {
		$history = $null
	}
	Write-Output $history
}

function Invoke-TfsPull([string]$path) {
<#
	.SYNOPSIS
	Switches your TFS workfolder mapping to the provided TFS path.
	.DESCRIPTION
	The Invoke-TfsPull function uses TFS's command-line "tf workfold" command to re-map your local workfolder to the specified TFS path from the current directory.
	If the current directory is not the root of the workspace, it will map a *new* folder instead of re-mapping the existing folder.  Use caution.
	.PARAMETER path
	The TFS path being mapped to.
	.EXAMPLE
	Invoke-TfsPull "$/Web/Source/UAT"
#>
	if ($path -eq "") {
		Get-Help Invoke-TfsPull -detailed
		return
	}

	tf workfold /map $path .\ | foreach-object {
		$item = "> " + $_
		Write-Progress -id 2 -parentId 1 -Activity "Switching workfolder to $path.  Don't forget to do a 'Invoke-TfsUpdate'" -Status $item
	}
	
	Reset-TfsGlobals
}

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

function Invoke-TfsSync([string]$path) {
<#
	.SYNOPSIS
	Switches your TFS workfolder mapping to the provided TFS path and gets the latest version of the files.
	.DESCRIPTION
	The Invoke-TfsSync function calls Invoke-TfsPull and Invoke-TfsUpdate in order to provide branch switching functionality.
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

  Invoke-TfsUpdate
}

function Invoke-TfsScorch([string]$params = "") {
<#
	.SYNOPSIS
	Recursively scorches the current workfolder from the current directory.
	.DESCRIPTION
	The Invoke-TfsScorch function uses the TFS Power Tools "tfpt scorch" command to 
	recursively delete untracked files and get the latest version based on a 
	diff of the local and server versions of files.
	
	This command is basically a clean-up to bring the local workspace to an 
	exact match of the remote path.
	.PARAMETER params
	Allows additional tfpt scorch switches to be specified.  Available 
	parameters:
	
	/noprompt              Do not show the list of items to be deleted and 
						   redownloaded in a dialog box for confirmation
	/exclude:filespec[,..] Files and directories matching a filespec in this 
						   list are excluded from processing
	/preview               Do not make changes; only list the potential actions
	/batchsize:num         Set the batch size for server calls (default 500)
	filespec...            Only files and directories matching these filespecs
						   are processed (inclusion list)
	.EXAMPLE
	Invoke-TfsScorch
	.EXAMPLE
	Invoke-TfsScorch /noprompt
#>
	if ($params.Contains("/noprompt")) {
		& $tfpt scorch . /recursive /deletes /diff $params | foreach-object {
			$item = "> " + $_
			Write-Progress -id 1 -Activity "Cleaning up your work folder from the current directory" -status $item
		}
	} else {
		& $tfpt scorch . /recursive /deletes /diff $params
	}
	
	Reset-TfsGlobals
}

function Invoke-TfsClean([string]$params = "") {
<#
	.SYNOPSIS
	Recursively deletes files and folders not under version control.
	.DESCRIPTION
	The Invoke-TfsClean function uses the TFS Power Tools "tfpt treeclean" command to 
	recursively delete files and folders not under version control.
	
	This command is basically a clean-up to remove untracked files/folders.
	.PARAMETER params
	Allows additional tfpt treeclean switches to be specified.  Available 
	parameters:
	
	/noprompt              Operate in command-line mode only
	/exclude:filespec[,..] Files and directories matching a filespec in this 
						   list are excluded from processing
	/preview               Do not make changes; only list the potential actions
	/batchsize:num         Set the batch size for server calls (default 500)
	filespec...            Only files and directories matching these filespecs
						   are processed (inclusion list)
	.EXAMPLE
	Invoke-TfsClean
	.EXAMPLE
	Invoke-TfsClean /noprompt
#>
	if ($params.Contains("/noprompt")) {
		& $tfpt treeclean . /recursive $params | foreach-object {
			$item = "> " + $_
			Write-Progress -id 1 -Activity "Cleaning up your work folder from the current directory" -status $item
		}
	} else {
		& $tfpt treeclean . /recursive $params
	}
}

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

function Get-TfsStatus([switch]$all) {
<#
	.SYNOPSIS
	Gets the TFS status of files from the current directory.
	.DESCRIPTION
	The Get-TfsStatus function uses the TFS "tf status" command-line command to check on the status of TFS-tracked files.
	Provide the -all switch and it will also provide a listing of untracked files.
	.PARAMETER all
	Switch to show status of all files, not just TFS-tracked files.
	.EXAMPLE
	Get-TfsStatus
	.EXAMPLE
	Get-TfsStatus -all
#>
	Write-Host " "
	Write-Host "Checking status of current folder recursively..." -f $cloc
	Get-TfsPendingChange . -recurse | 
		select Version, @{name="Date"; expression={"{0:d}" -f $_.CreationDate}}, @{name="Change"; expression={$_.ChangeType}}, @{name="Item"; expression={$_.ServerItem}} |
		Format-Table -AutoSize

	if ($all) {
		tf folderdiff . /recursive /view:targetOnly /noprompt
		Write-Host " "
	}
}

function Get-TfsReview() {
<#
	.SYNOPSIS
	Recursively review (diff/view) workspace or shelveset changes.
	.DESCRIPTION
	Use this command when you would like to recursively review changes in your workspace or shelveset in any order you would like.  Files can be viewed or diffed as appropriate. If no options are specified, all pending changes in the workspace are displayed.
	.EXAMPLE
	Get-TfsReview
#>
	Write-Host " "
	Write-Host "Reviewing current pending changes recursively..." -f $cloc
	& $tfpt review . /recursive
	Write-Host " "
}

function Get-TfsHistory([int]$count = 5) {
<#
	.SYNOPSIS
	Shows the last [n] changesets recursively from the current folder.  Default is 5.
	.DESCRIPTION
	Use this command when you'd like to see the last 5 changeset messages from any file or folder starting with the current folder.  Helpful for when you want to see and use some of the last commit messages.
	.PARAMETER count
	Number of changeset messages to stop after
	.EXAMPLE
	Get-TfsHistory
	.EXAMPLE
	Get-TfsHistory 20
#>
	Write-Host " "
	Write-Host "Showing history of the last $count changesets recursively..." -f $cloc
	$history = Get-TfsItemHistory . -recurse -stopafter:$count
	
    #foreach ($item in $history) {
	#	$item.Committer = $item.Committer -replace "[ActiveDirectoryDomainNameHere]\\", ""
	#}
	
	$history | select @{name="Version"; expression={$_.ChangesetId}}, Committer, @{name="Date"; expression={$_.CreationDate}}, Comment | Format-Table -AutoSize
}

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

function Invoke-TfsCheckin(
	[string]$m = $(Read-Host -prompt "Commit message"),
	[string]$s, 
	[string]$o,
	[switch]$WhatIf
) {
<#
	.SYNOPSIS
	Commits pending changes in the current workspace, or from an existing shelveset.
	.DESCRIPTION
	Uses the tf checkin command to recursively commit pending changes in the current workspace without prompting the user with a GUI interface.  In some cases, it's required to override checkin policies with -o.
	.PARAMETER m
	Commit message - See https://spghp/ghpitweb/Wiki/TFS.aspx for examples of good commit messages.
	.PARAMETER s
	Shelveset name
	.PARAMETER o
	Override message
	.PARAMETER -WhatIf
	Tests checking in without actually doing it.  This option causes checkin to evaluate checkin policies, check check-in notes, and look for conflicts without actually checking in.  Any problems, such as conflicts, that are identified by this option must be resolved before you check in the item.
	.EXAMPLE
	Invoke-TfsCheckin -m "Commit message"
	.EXAMPLE
	Invoke-TfsCheckin -m "Commit message" -o "Override message"
	.EXAMPLE
	Invoke-TfsCheckin -s "Shelveset name" -m "Commit message"
	.EXAMPLE
	Invoke-TfsCheckin -m "Commit message" -WhatIf
#>
	Write-Host " "
	Write-Host "Checking in pending changes..."
	
	$cmd = "tf"
	$params = "checkin", ".", "/noprompt", "/recursive", "/comment:$m"
	
	if ($s.length -gt 0) {
		$params = $params + "/shelveset:$s "
	}
	
	if ($o.length -gt 0) {
		$params = $params + "/override:$o "
	}
	
	if ($WhatIf) {
		$params = $params + "/validate"
	}
	
	& $cmd $params
	
	Reset-TfsGlobals
}

function Invoke-TfsUndo([string]$path = ".", [switch]$WhatIf) {
<#
	.SYNOPSIS
	Undoes pending changes from the provided path recursively.
	.DESCRIPTION
	Uses the tf undo command to recursively undo pending changes from the provided path without prompting the user with a GUI interface.  Path defaults to current folder.  Provide -WhatIf switch to be prompted with a confirmation.
	.PARAMETER path
	Path to undo from.  Defaults to current folder.
	.PARAMETER -WhatIf
	Forces undo to prompt for a confirmation.
	.EXAMPLE
	Invoke-TfsUndo
	.EXAMPLE
	Invoke-TfsUndo .\HelloWorld\*.cs
	.EXAMPLE
	Invoke-TfsUndo -WhatIf
	.EXAMPLE
	Invoke-TfsUndo .\HelloWorld\*.cs -WhatIf
#>
	Write-Output " "
	Write-Output "Undoing pending changes recursively..."
	
	$cmd = "tf"
	$params = "undo", "/recursive", $path
	
	if (-not $WhatIf) {
		$params = $params + "/noprompt"
	}
	
	& $cmd $params
}
