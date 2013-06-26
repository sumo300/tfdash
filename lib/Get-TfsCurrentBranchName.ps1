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

