<#
	Description: TFS 2010 PowerShell Helper Functions
	Author:      Michael J. Sumerano
	License:     GNU GENERAL PUBLIC LICENSE v3 (see license.txt for full license)
#>

$tfpt = "${Env:ProgramFiles(x86)}\Microsoft Team Foundation Server 2010 Power Tools\TFPT.EXE"

$cdelim = [ConsoleColor]::DarkCyan;
$chost = [ConsoleColor]::Green;
$cloc = [ConsoleColor]::Cyan;
$cerr = [ConsoleColor]::Red;

Get-ChildItem $PSScriptRoot\lib -Include *.ps1 -Recurse | %{ . $_.FullName }

Set-Alias tf-pull Switch-TfsPath
Set-Alias tf-pu Switch-TfsPath
Set-Alias tf-update Get-TfsLatest
Set-Alias tf-up Get-TfsLatest
Set-Alias tf-latest Get-TfsLatest
Set-Alias tf-sync Switch-TfsBranch
Set-Alias tf-sy Switch-TfsBranch
Set-Alias tf-switch Switch-TfsBranch
Set-Alias tf-sw Switch-TfsBranch
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
Set-Alias tf-uu Undo-TfsUnchanged
Set-Alias tf-clean Invoke-TfsClean
Set-Alias tf-cl Invoke-TfsClean
Set-Alias tf-scorch Invoke-TfsScorch
Set-Alias tf-sc Invoke-TfsScorch
Set-Alias tf-undo Undo-TfsChange
Set-Alias tf-un Undo-TfsChange

Export-ModuleMember -Function * -Alias *
