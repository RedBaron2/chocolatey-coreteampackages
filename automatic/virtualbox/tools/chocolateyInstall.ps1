﻿#https://www.virtualbox.org/manual/ch02.html#idm819

$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1

$cert = ls cert: -Recurse | ? { $_.Thumbprint -eq 'a88fd9bdaa06bc0f3c491ba51e231be35f8d1ad5' }
if (!$cert) {
    $toolsPath = Split-Path $MyInvocation.MyCommand.Definition
    Start-ChocolateyProcessAsAdmin "certutil -addstore 'TrustedPublisher' '$toolsPath\oracle.cer'"
}

$pp = Get-PackageParameters
$silentArgs = @('-s -l -msiparams REBOOT=ReallySuppress')
$silentArgs += if (!$pp.CurrentUser)      { 'ALLUSERS=1' } else { 'ALLUSERS=2';  Write-Host 'Param: Installing for current user' }
$silentArgs += if ($pp.NoDesktopShortcut) { 'VBOX_INSTALLDESKTOPSHORTCUT=0';     Write-Host 'Param: No desktop shortcut' }
$silentArgs += if ($pp.NoQuickLaunch)     { 'VBOX_INSTALLQUICKLAUNCHSHORTCUT=0'; Write-Host 'Param: No quick launch shortcut' }
$silentArgs += if ($pp.NoRegister)        { 'VBOX_REGISTERFILEEXTENSIONS=0';     Write-Host 'Param: No registration for virtualbox file extensions' }

$packageArgs = @{
  packageName            = 'virtualbox'
  fileType               = 'EXE'
  url                    = 'http://download.virtualbox.org/virtualbox/5.1.22/VirtualBox-5.1.22-115126-Win.exe'
  url64bit               = 'http://download.virtualbox.org/virtualbox/5.1.22/VirtualBox-5.1.22-115126-Win.exe'
  checksum               = 'e36883bb27653aabe20ca0cbf140b2aa19573fc989c47e3cce7986dc544b0e93'
  checksum64             = 'e36883bb27653aabe20ca0cbf140b2aa19573fc989c47e3cce7986dc544b0e93'
  checksumType           = 'sha256'
  checksumType64         = 'sha256'
  silentArgs             = $silentArgs
  validExitCodes         = @(0)
  softwareName           = 'Oracle VM VirtualBox *'
}
Install-ChocolateyPackage @packageArgs

$packageName = $packageArgs.packageName
$installLocation = Get-VirtualBoxIntallLocation
if (!$installLocation)  { Write-Warning "Can't find $packageName install location, can't install extension pack"; return }

if (!$pp.NoExtensionPack) {
    Write-Host "Installing extension pack"

    $url_ep       = 'http://download.virtualbox.org/virtualbox/5.1.22/Oracle_VM_VirtualBox_Extension_Pack-5.1.22.vbox-extpack'
    $checksum_ep  = '244e6f450cba64e0b025711050db3c43e6ce77e12cd80bcd08796315a90c8aaf'
    $file_path_ep = (Get-PackageCacheLocation) + '\' + ($url_ep -split '/' | select -Last 1)
    Get-ChocolateyWebFile `
        -PackageName    'virtualbox-extensionpack' `
        -FileFullPath   $file_path_ep `
        -Url            $url_ep `
        -Url64bit       $url_ep `
        -Checksum       $checksum_ep `
        -Checksum64     $checksum_ep `
        -ChecksumType   'sha256' `
        -ChecksumType64 'sha256'
    if (!(Test-Path $file_path_ep)) { Write-Warning "Can't download latest extension pack" }
    else {
        Set-Alias vboxmanage $installLocation\VBoxManage.exe
        "y" | vboxmanage extpack install --replace $file_path_ep 2>&1
        if ($LastExitCode -ne 0) { Write-Warning "Extension pack installation failed with exit code $LastExitCode" }
    }
}

if (!$pp.NoPath) { Write-Host "Adding to PATH if needed"; Install-ChocolateyPath $installLocation }

Write-Host "$packageName installed to '$installLocation'"
Register-Application "$installLocation\$packageName.exe" vbox
Write-Host "$packageName registered as vbox"
