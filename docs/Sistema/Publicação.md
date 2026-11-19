# Publicação

## Windows

Para a plataforma Windows a compilação da aplicação é feita utilizando o [Inno Setup](https://jrsoftware.org/).

São necessários:

- Instalação do Inno Setup
- Configuração da variável de ambiente PATH para a pasta de instalação do Inno Setup

## Arquivos obrigatórios antes de empacotar

O pacote `./build.ps1` verifica e embarca arquivos que não são versionados:

- `secrets/google_oauth.json` — credenciais do cliente OAuth usadas pelo backup no Google Drive. São copiadas para `{app}\secrets` na instalação; sem elas o backup não conecta.
- `secrets/release_token.txt` — token do GitHub, usado apenas na etapa de publicação.

Ambos ficam na pasta `secrets/`, ignorada pelo Git. O script interrompe a geração se `secrets/google_oauth.json` não existir.


