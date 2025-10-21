#!/bin/bash

# Definir variável de ambiente
export PYDEVD_DISABLE_FILE_VALIDATION=1

# Executar pyinstaller
pyinstaller --noconfirm --clean ./predict_win.spec

# Verificar se o diretório existe e criar se necessário
if [ ! -d "./dist/resources" ]; then
    mkdir -p "./dist/resources"
fi

# Copiar arquivos
cp -r ./resources/* ./dist/resources/