#theme
$cdelim = [ConsoleColor]::DarkCyan;
$chost = [ConsoleColor]::Green;
$cloc = [ConsoleColor]::Cyan;
$cerr = [ConsoleColor]::Red;

$isWin7AndUp = [Environment]::OSVersion.Version -ge (new-object 'Version' 6,1)
$myDocuments = [Environment]::GetFolderPath("MyDocuments")
$modulesPath = "\WindowsPowerShell\Modules"

if ($myDocuments -eq "" -or $myDocuments -eq $null) {
	Write-Error "Cannot determine where your My Documents folder is.  Are you running as Administrator?  Exiting profile without continuing."
	return;
}

# Add necessary registry entry to be able to use the TFPT cmdlets from x64
if ($isWin7AndUp) {
	if (-not (Test-Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\Microsoft.TeamFoundation.PowerShell)) {
		$regPath = Join-Path $localModulesPath -ChildPath "tfpt-x64.reg"
		regedit /s "$regPath"
	}
}

# Import some utilities
Import-Module lib\Select-WriteHost
Import-Module lib\Invoke-CmdScript
Import-Module lib\VsVars32
Import-Module lib\New-CommandWrapper
Import-Module lib\Write-ColorLS

# Make the TFPT PowerShell Cmdlets available
$tfptPath = Join-Path $programFiles -ChildPath "Microsoft Team Foundation Server 2010 Power Tools\Microsoft.TeamFoundation.PowerTools.PowerShell.dll"
if ((Test-Path $tfptPath) -eq $True) {
    Add-PSSnapin Microsoft.TeamFoundation.PowerShell
} else {
    Write-Warning "Microsoft Team Foundation Server 2010 Power Tools PowerShell CmdLets failed to register.  Make sure the cmdlets are installed (from TFPT installer).  If they are, run your PowerShell command line again if this was your first time using them."
}

# Import TFS commands
Import-Module Tfs

# Initialize Visual Studio command line environment
Initialize-VsVars32 > $null

# Overriding the command prompt
function prompt
{
	Write-Host "$([char]0x0A7) " -n -f $cloc
	Write-Host "{" -n -f $cdelim
	Write-Host (Get-ShortenedPath (pwd).Path) -n -f $cloc
	Write-Host "}" -n -f $cdelim
	
    # In Tfs.psm1
    # TODO: Fix defect that causes tf.exe to be called regardless if we're in a workspace or not (SLOW)
	Set-TfsGlobals

	if ($global:currentTfsBranch -ne $null) {
		Write-Host " [" -n -f $cdelim
		Write-Host $global:currentTfsBranch -n -f $chost
		Write-Host " " -n
		Write-Host $global:localVersion -n -f DarkYellow
		Write-Host "]" -n -f $cdelim
	}
		
    return " "
}

# Set up aliases for many of the commands here
Set-Alias tf-pull Invoke-TfsPull
Set-Alias tf-pu Invoke-TfsPull

Set-Alias tf-update Invoke-TfsUpdate
Set-Alias tf-up Invoke-TfsUpdate

Set-Alias tf-sync Invoke-TfsSync
Set-Alias tf-sy Invoke-TfsSync
Set-Alias tf-switch Invoke-TfsSync
Set-Alias tf-sw Invoke-TfsSync

Set-Alias tf-status Get-TfsStatus
Set-Alias tf-stat Get-TfsStatus
Set-Alias tf-st Get-TfsStatus

Set-Alias tf-review Get-TfsReview
Set-Alias tf-rev Get-TfsReview

Set-Alias tf-history Get-TfsHistory
Set-Alias tf-hi Get-TfsHistory
Set-Alias tf-log Get-TfsHistory
Set-Alias tf-hist Get-TfsHistory

Set-Alias tf-checkin Invoke-TfsCheckin
Set-Alias tf-ci Invoke-TfsCheckin
Set-Alias tf-commit Invoke-TfsCheckin
Set-Alias tf-co Invoke-TfsCheckin

Set-Alias tf-properties Get-TfsProperties
Set-Alias tf-prop Get-TfsProperties

Set-Alias tf-revisions Get-TfsVersions
Set-Alias tf-rev Get-TfsVersions
Set-Alias tf-versions Get-TfsVersions
Set-Alias tf-ver Get-TfsVersions

Set-Alias tf-uu Invoke-TfsUndoUnchanged

Set-Alias tf-clean Invoke-TfsClean
Set-Alias tf-cl Invoke-TfsClean

Set-Alias tf-scorch Invoke-TfsScorch
Set-Alias tf-sc Invoke-TfsScorch

Set-Alias tf-undo Invoke-TfsUndo
Set-Alias tf-un Invoke-TfsUndo
