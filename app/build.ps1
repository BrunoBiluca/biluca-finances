# modo de uso: 
# ./build.ps1 [major|minor|patch]

# ####
# Verificação dos argumentos
# ####

$update_version_type = $args[0]

if (-Not $update_version_type) {
    Write-Error "[ERRO] Argumento inválido. Use 'major', 'minor' ou 'patch'."
    Exit 1
}

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
# Controle de versão da aplicação
# ####

$versionFilePath = "./pubspec.yaml"
$fileContent = Get-Content $versionFilePath

$version = $fileContent | Select-String "version:"
Write-Host "Versão atual da aplicação: $version"

if ($version -match "version:\s(\d+)\.(\d+)\.(\d+)") {
    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    $patch = [int]$matches[3]

    if ($update_version_type -eq "major") {
        $major++
        $minor = 0
        $patch = 0
    }
    elseif ($update_version_type -eq "minor") {
        $minor++
        $patch = 0
    }
    elseif ($update_version_type -eq "patch") {
        $patch++
    }

    $newVersionLine = "$major.$minor.$patch"
    Write-Host "Nova versão da aplicação: $newVersionLine"

    $updatedContent = $fileContent -replace "version:\s+\d+\.\d+\.\d+", "version: $newVersionLine"
    $updatedContent | Set-Content $versionFilePath
    
    Write-Host "A versão foi atualizada para '$newVersionLine'"  -ForegroundColor Green
}
else {
    Write-Error "[ERRO] Nenhuma versão encontrada ou versão inválida no arquivo $filePath"
    Exit 1
}

# ####
# Criação do pacote windows
# ####

Write-Host "Criando o pacote windows..."
Write-Host ""

flutter build windows | Foreach-Object { Write-Host $_ -ForegroundColor DarkGray }

Write-Host "O pacote windows foi criado." -ForegroundColor Green
Write-Host ""

# ####
# Compilação do Inno Setup
# ####

$output_path = "./dist"
if (-Not (Test-Path $output_path)) {
    New-Item -Name $output_path -ItemType Directory
}

iscc ./setup.iss "/DVersion=$newVersionLine" | Foreach-Object { Write-Host $_ -ForegroundColor DarkGray }

Write-Host "Instalador criado com sucesso." -ForegroundColor Green

# ####
# Commitar as alterações
# ####

git add $versionFilePath

$deploy_icon_value = [System.Convert]::toInt32("1f680", 16)
$deploy_icon = ([System.Char]::ConvertFromUtf32($deploy_icon_value))

git commit -m "$deploy_icon Deployment of version $newVersionLine"
git tag $newVersionLine
git push
git push origin $newVersionLine

Write-Host "Tag: $newVersionLine criado." -ForegroundColor Green