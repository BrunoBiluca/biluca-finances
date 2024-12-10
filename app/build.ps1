# ####
# Verificação de dependências para o processo de empacotamento
# ####

Write-Host "Verificando dependências..." -ForegroundColor Gray

if (Get-Command iscc -ErrorAction SilentlyContinue) {
    Write-Host "Inno Setup está instalado." -ForegroundColor Green
}
else {
    Write-Error "[ERRO] Inno Setup não está instalado. Instale-o e rode o script novamente."
    Exit 1
}

# ####
# Testes
# ####

Write-Host "Inicializando os testes..." -ForegroundColor Gray

$result = flutter test -r json
$summary = ConvertFrom-Json $result[-1]

if (-Not $summary.success) {
    Write-Error "[ERRO] Os testes falharam."
    Exit 1
}

Write-Host "Os testes passaram." -ForegroundColor Green

# ####
# Criação do pacote windows
# ####

Write-Host "Criando o pacote windows..."
Write-Host ""

flutter build windows | Foreach-Object { Write-Host $_ -ForegroundColor DarkGray }

Write-Output "O pacote windows foi criado." -ForegroundColor Green
Write-Host ""

# ####
# Compilação do Inno Setup
# ####

$output_path = "./dist"
if (-Not (Test-Path $output_path)) {
    New-Item -Name $output_path -ItemType Directory
}

iscc ./setup.iss | Foreach-Object { Write-Host $_ -ForegroundColor DarkGray }

Write-Host "Instalador criado com sucesso." -ForegroundColor Green