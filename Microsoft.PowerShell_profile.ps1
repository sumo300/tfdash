$isWin7AndUp = [Environment]::OSVersion.Version -ge (new-object 'Version' 6,1)

# Add necessary registry entry to be able to use the TFPT cmdlets from x64
if ($isWin7AndUp) {
	if (-not (Test-Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\Microsoft.TeamFoundation.PowerShell)) {
		$regPath = Join-Path $localModulesPath -ChildPath "tfpt-x64.reg"
		regedit /s "$regPath"
	}
}

# Make the TFPT PowerShell Cmdlets available
$tfptPath = Join-Path $programFiles -ChildPath "Microsoft Team Foundation Server 2010 Power Tools\Microsoft.TeamFoundation.PowerTools.PowerShell.dll"
if ((Test-Path $tfptPath) -eq $True) {
    Add-PSSnapin Microsoft.TeamFoundation.PowerShell
} else {
    Write-Warning "Microsoft Team Foundation Server 2010 Power Tools PowerShell CmdLets failed to register.  Make sure the cmdlets are installed (from TFPT installer).  If they are, run your PowerShell command line again if this was your first time using them."
}

Import-Module tfdash

Initialize-VsVars32 > $null

function prompt
{
  Write-VcsStatus
  return '> '
}
