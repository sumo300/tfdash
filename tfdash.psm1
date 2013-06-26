<#
	Description: TFS 2010 PowerShell Helper Functions
	Author:      Michael J. Sumerano
	License:     GNU GENERAL PUBLIC LICENSE v3 (see license.txt for full license)
#>

$tfpt = "${Env:ProgramFiles(x86)}\Microsoft Team Foundation Server 2010 Power Tools\TFPT.EXE"

Get-ChildItem $PSScriptRoot\lib -Include *.ps1 -Recurse | %{ . $_.FullName }
