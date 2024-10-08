flutter build windows

Copy-Item ./windows/sqlite3.dll ./build\windows\x64\runner\Release

Compress-Archive ./build\windows\x64\runner\Release\* ./build\windows\x64\runner\biluca-financas.zip