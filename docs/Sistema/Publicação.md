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

## Contrato consumido pela atualização automática

A aplicação verifica a versão publicada e baixa o instalador diretamente do GitHub, sem intervenção do desenvolvedor. O processo de publicação continua o mesmo (`build.ps1`), mas a aplicação depende de dois pontos do release:

1. **Endpoint consultado na abertura**

   ```
   GET https://api.github.com/repos/BrunoBiluca/biluca-finances/releases/latest
   ```

   A versão publicada é lida de `tag_name`, que deve seguir `major.minor.patch` (com `v` opcional, por exemplo `2.1.0` ou `v2.1.0`). Tag fora desse formato encerra a verificação como falha e nenhuma atualização é oferecida.

2. **Nome do arquivo do instalador anexado ao release**

   ```
   biluca-financas-setup-<versão>.exe
   ```

   Esse é o nome gerado pelo Inno Setup (`OutputBaseFilename` em `setup.iss`) e anexado por `build.ps1`. A aplicação procura primeiro o nome exato da versão publicada e, como tolerância, o primeiro arquivo `.exe` cujo nome comece com `biluca-financas-setup-`. O download usa o `browser_download_url` do arquivo.

Renomear o arquivo do instalador fora desse padrão quebra a atualização automática das instalações existentes: a aplicação informa que o instalador não foi encontrado e a atualização precisa ser feita manualmente pelo release. O release precisa ser publicado como oficial (não rascunho e não pré-release), pois `releases/latest` ignora esses releases.

Não é necessário token para consultar ou baixar: o acesso é anônimo e sujeito ao limite de 60 consultas por hora por IP, suficiente para uma verificação por abertura da aplicação.



