# ####
# Verifica��o de depend�ncias para o processo de empacotamento
# ####

if (Get-Command iscc -ErrorAction SilentlyContinue) {
    Write-Host "Inno Setup est� instalado."
}
else {
    Write-Error "[ERRO] Inno Setup n�o est� instalado. Instale-o e rode o script novamente."
    Exit 1
}

# ####
# Cria��o do pacote windows
# ####

flutter build windows

# ####
# Compila��o do Inno Setup
# ####

$output_path = "./dist"
if (-Not (Test-Path $output_path)) {
    New-Item -Name $output_path -ItemType Directory
}

iscc ./setup.iss