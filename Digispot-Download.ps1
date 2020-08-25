<#
.NOTES
    Copyright (c) Roman Ermakov <r.ermakov@emg.fm>
    Use of this sample source code is subject to the terms of the
    GNU General Public License under which you licensed this sample source code. If
    you did not accept the terms of the license agreement, you are not
    authorized to use this sample source code.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
Latest build: http://redmine.digispot.ru/Distributives/2.17.0/djinsetup.exe
Specific build: http://redmine.digispot.ru/Distributives/2.17.0/old/2.17.0.142/djinsetup.exe

#>

[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[String]$latest = ""

Write-Host "`nDigispot-Download v1.03" -ForegroundColor Yellow
Write-Host "Batch download Digispot II packages from https://redmine.digispot.ru/projects/digispot/wiki/"
Write-Host "Available versions: 2.16.1, 2.16.2; 2.16.3; 2.17.0"

$v = Read-Host -Prompt "Please enter version for download [Press Enter for 2.17.0 or Ctrl+C for exit]"
switch ($v) {
    "2.16.1" { $pattern = [Regex]::new('2\.16\.1\.*\d\d+\d?') }
    "2.16.2" { $pattern = [Regex]::new('2\.16\.2\.*\d\d+\d?') } # search for 2.16.2.dd or 2.16.2.ddd
    "2.16.3" { $pattern = [Regex]::new('2\.16\.3\.*\d\d+\d?') }
    "2.17.0" { $pattern = [Regex]::new('2\.17\.0\.*?\d{2,3}') }
    $null    { $v = "2.17.0"; $pattern = [Regex]::new('2\.17\.0\.*?\d{2,3}') }
    ""       { $v = "2.17.0"; $pattern = [Regex]::new('2\.17\.0\.*?\d{2,3}') }
    DEFAULT  { $v = "2.17.0"; $pattern = [Regex]::new('2\.17\.0\.*?\d{2,3}'); Write-Host "Sorry but $v is not available. Downloading latest 2.17.0" }
}

$v1 = $v.Replace(".","-")

Write-Host `nLooking into redmine.digispot.ru/projects/digispot/wiki/$v1
$url = Invoke-WebRequest -Uri https://redmine.digispot.ru/projects/digispot/wiki/%D0%98%D1%81%D1%82%D0%BE%D1%80%D0%B8%D1%8F_%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D0%B9_%D0%B2_%D0%BF%D0%BE%D0%BA%D0%BE%D0%BB%D0%B5%D0%BD%D0%B8%D0%B8_$v1

# redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-17-0
# redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-16-3
# redmine.digispot.ru/projects/digispot/wiki/История_изменений_в_поколении_2-16-2

$pageheaders = @($url.Content.split('<') | Where-Object {$_ -match '^h2'}) -replace '.*>'
#[string]$latest = $pattern.Matches($pageheaders[0])
[string]$latest = $pageheaders[0] -match $pattern
$latest = $Matches[0]

if ($latest -eq "") {
    Write-Host Latest build version is not detected.
    $latest = $v
} else {
    Write-Host Detected $latest as latest build.
}


Write-Host `nCreating folder: $latest
New-Item -Path $latest -Force -ItemType Directory | Out-Null

Write-Host Downloading latest build $latest`:
$url = "https://redmine.digispot.ru/projects/digispot/wiki/%D0%98%D1%81%D1%82%D0%BE%D1%80%D0%B8%D1%8F_%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D0%B9_%D0%B2_%D0%BF%D0%BE%D0%BA%D0%BE%D0%BB%D0%B5%D0%BD%D0%B8%D0%B8_"+$v1
Write-Host "Changes_$latest.html" -BackgroundColor Gray -ForegroundColor Black
Invoke-WebRequest $url -OutFile $latest\Changes_$latest.html
$url = "http://redmine.digispot.ru/Distributives/"+$v+"/mdb_update.sql"
Write-Host $url -BackgroundColor Gray -ForegroundColor Black
Invoke-WebRequest $url -OutFile $latest\$latest"_mdb_update.sql"

$files = @(
    "djinsetup.exe";
    "tracksetup.exe";
    "mag2setup.exe";
    "loggersetup.exe";
    "mplansetup.exe";
    "newsbrowsersetup.exe";
    "ddbsetup.exe";
    "dbimportsetup.exe";
    "LinkIntegrator.exe";
    "rdssetup.exe";
    "iaudiosetup.exe";
    "sch_to_db.exe"
)

foreach ($file in $files) {
    if ($latest -eq $v) {
        $url = "http://redmine.digispot.ru/Distributives/"+$v+"/"+$file
    } else {
        $url = "http://redmine.digispot.ru/Distributives/"+$v+"/old/"+$latest+"/"+$file
    }
    Write-Host $url -BackgroundColor Gray -ForegroundColor Black
    Invoke-WebRequest $url -OutFile $latest\$latest"_"$file
}
