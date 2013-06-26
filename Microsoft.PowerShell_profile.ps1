Import-Module tfdash

Initialize-VsVars32 > $null

function prompt
{
  Print-TfsStatus
  return '> '
}
