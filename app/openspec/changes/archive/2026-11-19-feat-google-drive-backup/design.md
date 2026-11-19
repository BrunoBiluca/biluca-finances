# Design

## Context

A aplicação é Flutter, com persistência em SQLite por meio de `sqflite_common_ffi`, injeção de dependências via `get_it`, navegação por `go_router` e estado com `flutter_bloc`. O banco é aberto por `DBProvider` ([db_provider.dart](../../../../lib/integrations/sqlite/db_provider.dart)), que expõe o caminho do arquivo em `getDBPath()` e a versão do banco como `migrationsSQL.length`. O ciclo de vida já intercepta o fechamento em `App.didRequestAppExit` ([app.dart](../../../../lib/app/app.dart)), que aguarda o callback `tearDown` ([tear_down.dart](../../../../lib/tear_down.dart)). A motivação da mudança está em [proposal.md](./proposal.md).

Nesta versão, as únicas plataformas-alvo são Windows e Linux, como indicam `setup.iss`, `build.ps1`/`build.sh` e o tratamento de caminho do banco para essas plataformas. A autenticação descrita — abrir o navegador para autorizar — corresponde ao fluxo OAuth de aplicativos desktop.

A primeira validação com uma conta real expôs três problemas que este design passa a tratar: a sincronização falhava com `insufficient_scope` na busca da pasta de topo, o abandono da autorização deixava a interface presa em "conectando" e o build de desenvolvimento disputava o mesmo arquivo remoto da aplicação real.

## Goals / Non-Goals

**Goals:**
- Definir uma interface de backup no `core` e uma implementação Google Drive em `integrations`.
- Estabelecer o fluxo OAuth para desktop com redirecionamento por `localhost`, cancelável e com tempo limite.
- Estabelecer a separação dos backups por perfil de sincronização, com nome fixo definido por configuração.
- Estabelecer a detecção de conflito e as duas resoluções previstas.
- Integrar a sincronização ao ciclo de vida de abertura e fechamento sem descartar dados locais em falhas.
- Expor o estado da sincronização, o perfil ativo e os motivos de falha para a página inicial e para a página de configurações.

**Non-Goals:**
- Suporte a outros serviços de nuvem do Google (fora de escopo declarado).
- Sincronização em segundo plano enquanto a aplicação está em uso.
- Suporte a Android, iOS e web nesta versão; a implementação do backup fica restrita a Windows e Linux.
- Migração automática de backups já existentes na pasta sem perfil.

## Decisions

### Dependências e fluxo OAuth

- Usar `googleapis` (Drive API v3) e `googleapis_auth` (fluxo OAuth e atualização de token), abrindo a URL de autorização no navegador com `url_launcher`.
  - **Alternativas consideradas**: `google_sign_in` (não suporta o fluxo de desktop) e `oauth2` puro (exigiria implementar manualmente as chamadas à Drive API). Ambos rejeitados.
  - **Justificativa de dependências** (Constituição, item 3): `googleapis` fornece o cliente de Drive sem escrever a API na mão; `googleapis_auth` gerencia o code grant com servidor local e o refresh do token; `url_launcher` abre o navegador para a autorização; `crypto` fornece o SHA-256 usado para comparar o conteúdo local com o último backup enviado.
- Usar o fluxo de autorização com redirecionamento `http://localhost:<porta>`, com servidor local próprio em `integrations` e troca do código por `obtainAccessCredentialsViaCodeExchange`.
  - **Alternativa considerada**: `obtainAccessCredentialsViaUserConsent` do `googleapis_auth`. Rejeitada porque aguarda o callback indefinidamente e não expõe como encerrar o servidor, o que deixa a interface presa em "conectando" quando a pessoa fecha o navegador.
  - O servidor local é encerrado no fim da tentativa, com tempo limite de 2 minutos para a autorização; ao estourar o limite ou o servidor ser fechado, a tentativa termina como falha e libera uma nova tentativa.
  - A URL de autorização é montada com `response_type=code`, `access_type=offline` e `prompt=consent` para garantir o refresh token, além de `state` para validar o callback.
- O `clientId` fornecido é informação pública do projeto OAuth e pode ser carregado de configuração. O `clientSecret` é sensível e **não** deve ser versionado: será carregado de um arquivo de configuração fora do repositório (seguindo o padrão da pasta `secrets/`, já ignorada no `.gitignore`). O valor do segredo fornecido não é copiado para os artefatos nem para o código.

### Interface no core e implementação em integrations

- Criar a interface `BackupService` em `lib/core/backup/services/backup_service.dart`, com operações: `isConfigured`, `connect`, `revoke`, `syncOnOpen`, `syncOnClose`, `getStatus` e `resolveConflict`.
- Criar `GoogleDriveBackupService` em `lib/integrations/google_drive/`, implementando `BackupService` e dependendo das abstrações do `core`, conforme o limite de camadas da Constituição.
- Registrar a implementação no `di_container.dart`, injetando o caminho e a versão do banco fornecidos por `DBProvider`.

### Estado e apresentação

- Criar `BackupBloc` em `lib/core/backup/bloc/` seguindo o padrão dos blocs de accountability, expondo estados: não configurado, conectando, configurado, sincronizando, sincronizado (com data e versão), erro e conflito.
- A página inicial passa a consumir o `BackupBloc` para exibir o estado da sincronização; a página de configurações consome o mesmo bloc para conectar, exibir informações e revogar.

### Horário da sincronização

- Persistir a data da última sincronização em UTC (ISO-8601), porque é o mesmo instante comparado com o `modifiedTime` do Google Drive.
- Converter para o fuso local da máquina apenas na apresentação (`DateTime.toLocal()` no formatador), na página inicial e nas configurações.
- **Alternativa considerada**: gravar o horário local nos metadados. Rejeitada porque o instante ficaria ambíguo após mudança de fuso ou horário de verão e dificultaria a comparação com o Drive.

### Detecção de conflito e sincronização

- Após cada sincronização bem-sucedida, persistir metadados locais: hash SHA-256 do arquivo local, id do arquivo remoto e data de modificação remota, além da data da última sincronização.
- Na sincronização, calcular o hash do arquivo local e ler os metadados do arquivo remoto, decidindo pela tabela abaixo.

  | Situação | Ação |
  | --- | --- |
  | Não existe arquivo no Google Drive | Enviar o local |
  | Existe arquivo remoto sem metadados locais (sem base de comparação) | Conflito |
  | Local e remoto inalterados | Nada a transferir, apenas atualizar a data |
  | Somente o local mudou | Enviar o local |
  | Somente o remoto mudou | Baixar o remoto e substituir o local |
  | Ambos mudaram | Conflito |

- Diferenças de menos de um segundo na data de modificação remota são ignoradas, pois o Drive não preserva a precisão completa do horário.
- Resolução "manter o local": enviar o arquivo local para o Google Drive. Resolução "atualizar com o do Google Drive": baixar o arquivo e substituir o banco local.
- A conexão do banco é fechada durante a sincronização e reaberta ao final, garantindo uma cópia consistente para envio e permitindo a substituição segura do arquivo. A reabertura atualiza o registro de `Database` no container de dependências.
- Reutilizar `DBProvider.getDBPath()` para localizar o arquivo do banco e `DBProvider` para abrir/fechar a conexão por meio de um controlador no `core`.

### Pasta de sincronia e perfil

- Localizar ou criar a estrutura de pastas `biluca.com` → `Biluca Finanças` → `<perfil>` via Drive API (`files.list`/`files.create` com `mimeType = application/vnd.google-apps.folder`), armazenando o banco dentro da subpasta do perfil.
- O perfil é um nome fixo, lido de configuração (`BILUCA_BACKUP_PROFILE`) com valor padrão `principal`; não é derivado do modo de build. O desenvolvedor define o perfil de desenvolvimento ao executar a aplicação, evitando que o build local dispute o arquivo da aplicação real.
- O perfil ativo é exibido na página de configurações, junto às informações da conexão.
- Não há migração automática da pasta sem perfil: um backup anterior em `biluca.com/Biluca Finanças` não é reaproveitado; a primeira sincronização com perfil cria uma subpasta e envia o arquivo local.

### Escopo da API e consultas no Drive

- Manter apenas o escopo `drive.file`, que dá acesso somente a arquivos e pastas criados pela aplicação. Não solicitar `drive` (escopo restrito, sujeito a verificação do Google).
- O escopo `https://www.googleapis.com/auth/drive.file` precisa estar habilitado na tela de consentimento (Data Access) do projeto OAuth, além da Drive API habilitada; sem isso o Google concede a autorização apenas com `openid` e `userinfo.email` e todas as chamadas ao Drive falham.
- Consequência observada em execução real: consultas que referenciam um pai não criado pela aplicação, como `'root' in parents`, falham com `insufficient_scope`. As buscas devem filtrar apenas por nome, tipo e `trashed = false` para a pasta de topo, e por `'<id>' in parents` somente para pastas já criadas pela aplicação.
- A pasta de topo `biluca.com` é criada sem `parents` explícitos, ficando na raiz do Meu Drive por padrão.

### Entrega das credenciais na instalação

- O instalador (Inno Setup) copia `secrets/google_oauth.json` para `{app}\secrets`; os atalhos e o pós-instalação usam `WorkingDir: {app}`.
- A aplicação procura as credenciais nesta ordem: `BILUCA_GOOGLE_OAUTH_FILE`, ao lado do executável, diretório atual. Assim funciona tanto instalada quanto executada a partir do projeto.
- O script de empacotamento interrompe o processo quando o arquivo não existe, evitando publicar um instalador sem credenciais.
- **Alternativa considerada**: embutir as credenciais no binário via `--dart-define`. Rejeitada porque o valor continua extraível e qualquer rotação exigiria recompilar e redistribuir o executável.

### Tratamento de erros e diagnóstico

- As falhas de sincronização são convertidas em estado de erro com a mensagem retornada pelo Google (`DetailedApiRequestError.message`), em vez de uma mensagem genérica.
- Falta de permissão do Drive (`insufficient authentication scopes`) recebe uma mensagem orientando revogar a sincronia e conectar novamente.
- A conexão valida os escopos concedidos antes de salvar: sem `drive.file`, a conexão não é configurada e a mensagem indica que o escopo precisa estar habilitado na tela de consentimento OAuth do projeto.
- Tempo limite de 60 segundos por sincronização; ao estourar, a operação termina como falha, mantém os dados locais e libera o botão de finalizar a aplicação.
- O log registra os escopos solicitados e concedidos, o detalhe técnico das falhas; tokens de acesso e refresh tokens nunca são registrados.

### Ciclo de vida

- Na abertura, após `initDatabase()` em `main.dart`, executar `syncOnOpen` quando o backup estiver configurado, sem bloquear a falha de rede.
- No fechamento, substituir o fluxo atual de `didRequestAppExit`: exibir a modal de progresso e o botão para finalizar, executar `syncOnClose` e só então concluir a saída. Quando não configurado, manter o fechamento imediato atual.

## Risks / Trade-offs

- [Token de acesso expira] → `googleapis_auth` renova automaticamente com o refresh token; persistir o refresh token e tratar a falha de renovação oferecendo reconexão.
- [Vazamento do clientSecret] → manter o segredo fora do repositório e do código, carregado de configuração ignorada pelo git.
- [Substituir o banco com a conexão aberta corrompe o arquivo] → fechar a conexão antes de ler ou substituir o arquivo e reabrir ao final.
- [Download parcial corrompe os dados] → gravar em um arquivo temporário e só então substituir o arquivo definitivo.
- [Falha de rede ou do Google Drive] → degradar com estado de erro, mantendo os dados locais intactos.
- [Conflito de porta do servidor local] → usar porta efêmera atribuída pelo sistema.
- [Autorização abandonada deixa a interface presa] → encerrar o servidor local no fim da tentativa e aplicar tempo limite, devolvendo o estado que permite nova tentativa.
- [Sincronização travada impede fechar a aplicação] → tempo limite na sincronização e botão de finalizar sempre disponível após o término da tentativa.
- [Consulta incompatível com `drive.file`] → não referenciar a pasta raiz do Meu Drive em filtros; validar as consultas contra uma conta real.
- [Perfil errado escolhido] → exibir o perfil ativo na página de configurações para tornar a escolha verificável.

## Migration Plan

Não há alteração de esquema SQLite. A mudança adiciona um arquivo local de metadados de sincronização (data da última sincronização, hash local e referência do arquivo remoto), criado na primeira sincronização bem-sucedida. Backup anterior em `biluca.com/Biluca Finanças` sem subpasta de perfil não é reaproveitado: a primeira sincronização com perfil cria a subpasta e envia o arquivo local, podendo ser tratado como conflito se já existir arquivo nessa subpasta. A reversão consiste em remover a dependência da sincronização e manter o uso local do banco, sem migração de dados.
