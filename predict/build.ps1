$env:PYDEVD_DISABLE_FILE_VALIDATION=1
pyinstaller --noconfirm --clean .\predict_win.spec
