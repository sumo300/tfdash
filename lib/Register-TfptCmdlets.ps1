# Make the TFPT PowerShell Cmdlets available
function Register-TfptCmdlets([string]$version = "2015") {
	$posh_reg_key = 'HKLM:\SOFTWARE\Microsoft\PowerShell\'
	$tfpt_suffix = '\PowerShellSnapIns\Microsoft.TeamFoundation.PowerShell'
	$poshVersion = $PSVersionTable.PSVersion.Major
	
	if ($poshVersion -lt 3) {
		Write-Warning "PowerShell v3 or later is required to register Microsoft Team Foundation Server $version Power Tools PowerShell CmdLets."
		return
	}
	
	if (Test-Win64) {
		$psv = Join-Path $posh_reg_key $poshVersion
		$tfpt_reg_key = Join-Path $psv $tfpt_suffix
			
		if (-not (Test-Path $tfpt_reg_key)) {
			$regPath = Join-Path $PSScriptRoot "..\tfpt$version-x64.reg"
			regedit /s $regPath
		}
	}
	
	$tfpt_assm = "${Env:ProgramFiles(x86)}\Microsoft Team Foundation Server $version Power Tools\Microsoft.TeamFoundation.PowerTools.PowerShell.dll"
	if (Test-Path $tfpt_assm) {
		Add-PSSnapin Microsoft.TeamFoundation.PowerShell
	} else {
		Write-Warning "Microsoft Team Foundation Server $version Power Tools PowerShell CmdLets failed to register.  Make sure the cmdlets are installed (from TFPT installer).  If they are, run your PowerShell command line again if this was your first time using them."
	}
}

function Test-Win64() {
    return [IntPtr]::size -eq 8
}
