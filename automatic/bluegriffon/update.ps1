﻿import-module au

$releases = 'http://bluegriffon.org/'

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(^\s*url\s*=\s*)('.*')"        = "`$1'$($Latest.URL32)'"
      "(?i)(^\s*checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
      "(?i)(^\s*checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
    }
  }
}

function global:au_GetLatest {
  $download_page = Invoke-WebRequest -UseBasicParsing -Uri $releases

  $re    = '\.exe'
  $url   = $download_page.links | ? href -match $re | select -First 1 -expand href

  $version  = $url -split '[-]|.win32|.exe' | select -Last 1 -Skip 3

  @{ URL32 = $url; Version = $version }
}

update -ChecksumFor 32
