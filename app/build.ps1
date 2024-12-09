# ####
# Verificação de dependências para o processo de empacotamento
# ####

if (Get-Command iscc -ErrorAction SilentlyContinue) {
    Write-Host "Inno Setup está instalado."
}
else {
    Write-Error "[ERRO] Inno Setup não está instalado. Instale-o e rode o script novamente."
    Exit 1
}

# ####
# Criação do pacote windows
# ####

flutter build windows

# ####
# Compilação do Inno Setup
# ####

$output_path = "./dist"
if (-Not (Test-Path $output_path)) {
    New-Item -Name $output_path -ItemType Directory
}

iscc ./setup.iss