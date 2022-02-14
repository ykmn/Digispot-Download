<#
.NOTES
    Copyright (c) Roman Ermakov <r.ermakov@emg.fm>
    Use of this sample source code is subject to the terms of the
    GNU General Public License under which you licensed this sample source code. If
    you did not accept the terms of the license agreement, you are not
    authorized to use this sample source code.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    THIS CODE IS PROVIDED "AS IS" WITH NO WARRANTIES.
    
.SYNOPSIS
    Batch dowload Digispot II packages from https://redmine.digispot.ru/projects/digispot/wiki/Версии_ПО_Digispot

.DESCRIPTION
    Batch dowload Digispot II packages from https://redmine.digispot.ru/projects/digispot/wiki/Версии_ПО_Digispot

.LINK
    https://github.com/ykmn/Digispot-Download

.EXAMPLE
    .\Digispot-Download.ps1
#>

<#
v1.00 2018-08-24 Initial release
v1.01 2019-80-21 Parsing latest build number from
	https://redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-16-3
	https://redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-17-0
v1.02 2020-06-18 Web-page parsing now Powershell Core compatible
v1.03 2020-08-03 Some regex cleanup
v1.04 2020-11-30 Build detection changes
v1.05 2021-03-18 Added SJM download; optimizing
v1.06 2022-02-14 Move links from http to https; check for PowerShell Core;
                 always download latest build instead of specific; added D2Matrix download;
                 default download: 2.17.2
Latest build: https://redmine.digispot.ru/Distributives/2.17.0/djinsetup.exe
Specific build: https://redmine.digispot.ru/Distributives/2.17.0/old/2.17.0.142/djinsetup.exe
#>

[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[String]$latest = ""
function Get-FilesFromURL {
    param (
      [string[]]$array = "",
      [string]$urlPrefix,
      [string]$outPrefix
    )
    # Foreach array iterate, write to host on a new line.
    $array | ForEach-Object {
#        Write-Host "Iterate content: $_"  }
        #https://redmine.digispot.ru/Distributives/2.17.0/mdb_update.sql
        [string]$file = $_
        $url = $urlPrefix+$file
        Write-Host "`nDownload: " -NoNewline
        Write-Host $url -BackgroundColor Gray -ForegroundColor Black
        $outfile = $outPrefix+$file
        Invoke-WebRequest $url -OutFile $outfile -Resume
        Write-Host "`nSaved to: $outfile"
    }
}

Write-Host "`nDigispot-Download v1.06" -ForegroundColor Yellow
Write-Host "Batch download Digispot II packages from https://redmine.digispot.ru/projects/digispot/wiki/"
Write-Host "Available versions: 2.16.3; 2.17.0; 2.17.2; 2.17.3"
if ($PSVersionTable.PSEdition -eq "Core") {
    Write-Host "PowerShell Core detected`n"
    $pscore = $true
} else {
    Write-Host "PowerShell Core is not detected. Please run script in PS Core!`n" -ForegroundColor Red
}


$v = Read-Host -Prompt "Please enter version for download [Press Enter for 2.17.2 or Ctrl+C for exit]"
switch ($v) {
    "2.16.3" { $pattern = [Regex]::new('2\.16\.3\.*\d\d+\d?') }
    "2.17.0" { $pattern = [Regex]::new('2\.17\.0\.*?\d{2,3}') }
    "2.17.2" { $pattern = [Regex]::new('2\.17\.2\.*?\d{2,3}') }
    "2.17.3" { $pattern = [Regex]::new('2\.17\.3\.*?\d{2,3}') }
    $null    { $v = "2.17.2"; $pattern = [Regex]::new('2\.17\.2\.*?\d{2,3}') }
    ""       { $v = "2.17.2"; $pattern = [Regex]::new('2\.17\.2\.*?\d{2,3}') }
    DEFAULT  { $v = "2.17.2"; $pattern = [Regex]::new('2\.17\.2\.*?\d{2,3}'); Write-Host "Sorry but $v is not available. Downloading latest 2.17.0" }
}

$v1 = $v.Replace(".","-")

Write-Host "`nLooking into https://redmine.digispot.ru/projects/digispot/wiki/Версии_ПО_Digispot"
$url = Invoke-WebRequest -Uri https://redmine.digispot.ru/projects/digispot/wiki/%D0%92%D0%B5%D1%80%D1%81%D0%B8%D0%B8_%D0%9F%D0%9E_Digispot
# redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-17-0
# redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-16-3
# redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-16-2

<# Expecting:
D2 - 2.17.0.210
D3 - 2.17.0.131
#>
$pageheaders = @($url.Content.split('<') | Where-Object {$_ -match $pattern}) -replace '.*>'
[string]$latest = $pageheaders[0] -match $pattern
$latest = $Matches[0]
[string]$latestD3 = $pageheaders[1] -match $pattern
$latestD3 = $Matches[0]

if (($latest -eq "") -or ($null -eq $latest)) {
    Write-Host "Latest build version is not detected."
    $latest = $v
    $latestD3 = $v
} else {
    Write-Host "Detected $latest as latest D2 build."
    Write-Host "Detected $latestD3 as latest D3 build."
}

$folder = "djin "+$latest
Write-Host "`nCreating folder: ./$folder"
New-Item -Path $folder -Force -ItemType Directory | Out-Null

Write-Host "Downloading latest build $latest"
$url = "https://redmine.digispot.ru/projects/digispot/wiki/%D0%98%D1%81%D1%82%D0%BE%D1%80%D0%B8%D1%8F_%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D0%B9_%D0%B2_%D0%BF%D0%BE%D0%BA%D0%BE%D0%BB%D0%B5%D0%BD%D0%B8%D0%B8_"+$v1
Write-Host "Download: " -NoNewline
Write-Host "Changes_$latest.html" -BackgroundColor Gray -ForegroundColor Black
$outfile = $folder+"\"+$latest+"_Changes.html"
Invoke-WebRequest $url -OutFile $outfile
Write-Host "`nSaved to: $outfile"

# Download SQL templates
$files = @(
    "mdb_create.sql";
    "mdb_update.sql";
    "mdb_mp_update.sql";
    "3_mdb_media_reports.sql"
)
$urlPrefix = "https://redmine.digispot.ru/Distributives/"+$v+"/"
$outPrefix = $folder+"\"+$latest+"_"
Get-FilesFromURL $files $urlPrefix $outPrefix


# Download executables
$files = @(
    "djinsetup.exe";
    "ddbsetup.exe";
    "mag2setup.exe";
    "tracksetup.exe";
    "loggersetup.exe";
    "mplansetup.exe";
    "newsbrowsersetup.exe";
    "dbimportsetup.exe";
    "LinkIntegrator.exe";
    "rdssetup.exe";
    "iaudiosetup.exe";
    "sch_to_db.exe";
    "switchersetup.exe";
    "d2matrixsetup.exe";
    "d2matrix_client_setup.exe"
)
$urlPrefix = "https://redmine.digispot.ru/Distributives/"+$v+"/"+$file
<# # Leave specific build download for future reconsideration...
if ($latest -eq $v) { # build doesn't detected, get latest
    $urlPrefix = "https://redmine.digispot.ru/Distributives/"+$v+"/"+$file
} else { # build detected, get specific
    $urlPrefix = "https://redmine.digispot.ru/Distributives/"+$v+"/old/"+$latest+"/"+$file
}
#>
$outPrefix = $folder+"\"+$latest+"_"
Get-FilesFromURL $files $urlPrefix $outPrefix


# Download SJM
$files = @(
    "CompleteSetup.exe";
    "D3.NjmComplete.exe"
)
$urlPrefix = "https://redmine.digispot.ru/Distributives/D3/"+$v+"/"
$outPrefix = $folder+"\"+$latestD3+"_"
Get-FilesFromURL $files $urlPrefix $outPrefix

# Download extra 2.17.2 files
$files = @(
    "LicenceManagerComplete.exe";
    "DigispotAPIServiceSetup.exe";
)
$urlPrefix = "https://redmine.digispot.ru/Distributives/"+$v+"/"+$file
$outPrefix = $folder+"\"+$latest+"_"
Get-FilesFromURL $files $urlPrefix $outPrefix
# and last one from non-standard path
$files = "DigispotLicenceService.msi"
$urlPrefix = "https://redmine.digispot.ru/Distributives/"+$v+"/ru-RU/"
$outPrefix = $folder+"\"+$latest+"_"
Get-FilesFromURL $files $urlPrefix $outPrefix

