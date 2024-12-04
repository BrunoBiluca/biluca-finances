flutter build windows

$publish_path = "./build\windows\x64\runner\Release"
$output_path = "./dist"
$package_name = "biluca_financas.zip"
$package_path = "$publish_path\$package_name"

Copy-Item ./windows/sqlite3.dll $publish_path

if (Test-Path $package_path) {
    Remove-Item $package_path
}

Compress-Archive -Path "$publish_path/*" -DestinationPath $package_path

while (!(Test-Path $package_path)) {
    Start-Sleep -s 1
}

if (-Not (Test-Path $output_path)) {
    New-Item -Name $output_path -ItemType Directory
}

Move-item $package_path -Destination $output_path -Force