flutter build windows

Copy-Item ./windows/sqlite3.dll ./build\windows\x64\runner\Release

if (Test-Path ./build\windows\x64\runner\biluca-financas.zip) {
    Remove-Item ./build\windows\x64\runner\biluca-financas.zip
}

$archivePath = "./build\windows\x64\runner\biluca-financas.zip"
Compress-Archive -Path "./build\windows\x64\runner\Release\*" -DestinationPath $archivePath

while (!(Test-Path $archivePath)) {
    Start-Sleep -s 1
}

if (-Not (Test-Path ./dist)) {
    New-Item -Name "./dist" -ItemType Directory
}


Move-item $archivePath -Destination "./dist" -Force