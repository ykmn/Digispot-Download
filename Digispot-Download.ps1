<#
Digispot-Download.ps1

Batch dowload Digispot II packages from https://redmine.digispot.ru/projects/digispot/wiki/Версии_ПО_Digispot
v1.00 2018-08-24 Initial release

Roman Ermakov <r.ermakov@emg.fm>
#>
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

Write-Host
Write-Host "Batch download Digispot II packages from https://redmine.digispot.ru/projects/digispot/wiki/"
Write-Host "Available versions: 2.15; 2.16.0; 2.16.1; 2.16.2; 2.16.3; 2.17.0"

$v = Read-Host -Prompt "Please enter version for download [Press Enter for 2.16.3 or Ctrl+C for exit]"
if (($v -eq $null) -or ($v -eq "")) {
    $v = "2.16.3"
}

Write-Host
Write-Host "Downloading build" $v

$v1 = $v.Replace(".","-")
Write-Host "Changes.html" -BackgroundColor Gray -ForegroundColor Black
Invoke-WebRequest https://redmine.digispot.ru/projects/digispot/wiki/%D0%98%D1%81%D1%82%D0%BE%D1%80%D0%B8%D1%8F_%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D0%B9_%D0%B2_%D0%BF%D0%BE%D0%BA%D0%BE%D0%BB%D0%B5%D0%BD%D0%B8%D0%B8_$v1 -OutFile Changes_$v1.html

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
    "sch_to_db.exe";
    "mdb_update.sql";
    "3_mdb_media_reports.sql";
    "4_mdb_media_reports_en.sql";
    "mdb_mp_update.sql"
)

foreach ($file in $files) {
    Write-Host $v $file -BackgroundColor Gray -ForegroundColor Black
    Invoke-WebRequest http://redmine.digispot.ru/Distributives/$v/$file -OutFile $v"_"$file
}
