﻿$ErrorActionPreference = 'Stop'

$toolsPath = Split-Path $MyInvocation.MyCommand.Definition

$packageArgs = @{
  packageName    = 'graphviz'
  fileType       = 'msi'
  file           = Get-Item $toolsPath\*.msi
  silentArgs     = '/Q'
  validExitCodes = @(0)
  softwareName   = 'Graphviz'
}
Install-ChocolateyInstallPackage @packageArgs
Remove-Item $toolsPath\*.msi -ea 0

$packageName = $packageArgs.packageName
$installLocation = Get-AppInstallLocation $packageArgs.softwareName
if (!$installLocation)  { Write-Warning "Can't find $packageName install location"; return }
Write-Host "$packageName installed to '$installLocation'"

@('dot','circo','sfdp','twopi') |ForEach-Object {Install-BinFile $_ "$installLocation\bin\$_.exe"}
