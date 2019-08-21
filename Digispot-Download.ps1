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
v1.01 2019-80-21 Parsing latest build number from Changes.html

Latest: http://redmine.digispot.ru/Distributives/2.17.0/djinsetup.exe
Recent: http://redmine.digispot.ru/Distributives/2.17.0/old/2.17.0.142/djinsetup.exe

#>

[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

Write-Host
Write-Host "Digispot-Download v1.01" -ForegroundColor Yellow
Write-Host "Batch download Digispot II packages from https://redmine.digispot.ru/projects/digispot/wiki/"
Write-Host "Available versions: 2.16.2; 2.16.3; 2.17.0"

$v = Read-Host -Prompt "Please enter version for download [Press Enter for 2.17.0 or Ctrl+C for exit]"
switch ($v) {
    "2.16.2" { $pattern = [Regex]::new('2\.16\.2\.*\d\d+\d?') }
    "2.16.3" { $pattern = [Regex]::new('2\.16\.3\.*\d\d+\d?') }
    "2.17.0" { $pattern = [Regex]::new('2\.17\.0\.*\d\d+\d?') }
    $null    { $v = "2.17.0"; $pattern = [Regex]::new('2\.17\.0\.*\d\d+\d?') }
    ""       { $v = "2.17.0"; $pattern = [Regex]::new('2\.17\.0\.*\d\d+\d?') }
    DEFAULT  { $v = "2.17.0"; $pattern = [Regex]::new('2\.17\.0\.*\d\d+\d?'); Write-Host "Sorry but $v is not available. Downloading latest 2.17.0" }
}

$v1 = $v.Replace(".","-")
$webpage = Invoke-WebRequest -Uri https://redmine.digispot.ru/projects/digispot/wiki/%D0%98%D1%81%D1%82%D0%BE%D1%80%D0%B8%D1%8F_%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D0%B9_%D0%B2_%D0%BF%D0%BE%D0%BA%D0%BE%D0%BB%D0%B5%D0%BD%D0%B8%D0%B8_$v1
$pageheaders = @($webpage.ParsedHtml.getElementsByTagName("h2"))
[string]$latest = $pattern.Matches($pageheaders[0].innerText)

Write-Host Detected $latest as latest build.
Write-Host 

Write-Host "Creating folder: " $latest
New-Item -Path $latest -Force -ItemType Directory | Out-Null

Write-Host "Downloading latest build" $latest

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
    $url = "http://redmine.digispot.ru/Distributives/"+$v+"/old/"+$latest+"/"+$file
    Write-Host $url -BackgroundColor Gray -ForegroundColor Black
    Invoke-WebRequest $url -OutFile $latest\$latest"_"$file
}
