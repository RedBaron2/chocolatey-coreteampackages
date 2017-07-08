﻿Import-Module AU
Import-Module "$PSScriptRoot\..\..\scripts\au_extensions.psm1"

$releasePagePart = 'http://www.xm1math.net/texmaker/'
$releases = "${releasePagePart}download.html"
$softwareName = 'Texmaker'

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }

function global:au_AfterUpdate { Set-DescriptionFromReadme -SkipFirst 1 }

function global:au_SearchReplace {
  @{
    ".\legal\VERIFICATION.txt" = @{
      "(?i)(^\s*location on\:?\s*)\<.*\>" = "`${1}<$releases>"
      "(?i)(\s*1\..+)\<.*\>" = "`${1}<$($Latest.URL32)>"
      "(?i)(^\s*checksum\s*type\:).*" = "`${1} $($Latest.ChecksumType32)"
      "(?i)(^\s*checksum(32)?\:).*" = "`${1} $($Latest.Checksum32)"
    }
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
      "(?i)(^\s*file\s*=\s*`"[$]toolsPath\\).*" = "`${1}$($Latest.FileName32)`""
    }
    ".\tools\chocolateyUninstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
    }
  }
}
function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

  $re = '\.exe$'
  $url32 = $download_page.Links | ? href -match $re | select -first 1 -expand href

  $verRe = 'Texmaker ([\d]+\.[\d\.]+) for Windows'
  $Matches = $null
  $download_page.Content -match $verRe | Out-Null
  if ($Matches) { $version32 = $Matches[1] }

  @{
    URL32 = $releasePagePart + $url32
    Version = $version32
  }
}

update -ChecksumFor none
