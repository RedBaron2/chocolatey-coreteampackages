$packageName = '{{PackageName}}'
$programName = 'Tuniac 1.0'
$fileType = 'EXE'
$silentArgs = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'

$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'

$uninstaller = Get-ChildItem $key | %{ Get-ItemProperty $_.PSPath } | ?{ $_.DisplayName -match $programName }

$uninstallString = $uninstaller.uninstallString -replace '"', ''

if ($uninstallString) {
    Uninstall-ChocolateyPackage $packageName $fileType $silentArgs $uninstallString
}
