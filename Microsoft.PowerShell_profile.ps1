Import-Module tfdash

Initialize-VsVars32 > $null

function prompt
{
  Write-TfsVcsStatus
  return '> '
}
