$env:PYDEVD_DISABLE_FILE_VALIDATION=1
pyinstaller --noconfirm --clean .\predict_win.spec

if (-Not (Test-Path "./dist/resources")) {
    New-Item -Name "./dist/resources" -ItemType Directory
}
Copy-Item ./resources/* ./dist/resources/