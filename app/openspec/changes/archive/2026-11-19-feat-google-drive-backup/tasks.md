# Tasks

## 1. Dependências e configuração

- [x] 1.1 Adicionar `googleapis`, `googleapis_auth` e `url_launcher` ao `pubspec.yaml`, justificando cada dependência conforme o design. Verificar por `flutter pub get` e `flutter analyze` que as dependências resolvem sem novos diagnósticos.
- [x] 1.2 Criar o carregamento das credenciais OAuth (`clientId` e `clientSecret`) a partir de configuração fora do repositório, seguindo o padrão da pasta `secrets/` ignorada no `.gitignore`, sem versionar o segredo. Verificar que o segredo não aparece em nenhum arquivo versionado e que a configuração carrega as credenciais.
- [x] 1.3 Criar a estrutura de pastas `lib/core/backup/` e `lib/integrations/google_drive/`. Verificar que os diretórios e arquivos iniciais existem conforme o design.

## 2. Interface e estado no core

- [x] 2.1 Criar a interface `BackupService` e os modelos de estado (configurado, sincronizando, sincronizado, erro, conflito) em `lib/core/backup/`, com a data da última sincronização e a versão do banco. Verificar por teste de unidade que os modelos serializam e comparam corretamente.
- [x] 2.2 Criar a regra de detecção de conflito como função pura no core, comparando o hash local e a data de modificação remota desde a última sincronização. Verificar por teste de unidade os cenários sem conflito, conflito e sincronização inicial.
- [x] 2.3 Criar `BackupBloc` com eventos e estados em `lib/core/backup/bloc/`, seguindo o padrão dos blocs de accountability. Verificar por `bloc_test` as transições de não configurado para conectando, configurado, sincronizando, sincronizado, erro e conflito.

## 3. Integração com o Google Drive

- [x] 3.1 Implementar `GoogleDriveBackupService` em `lib/integrations/google_drive/`, com `connect` e `revoke` usando o fluxo OAuth com redirecionamento `localhost` e atualização de token. Verificar manualmente que conectar abre o navegador, persiste o refresh token e revogar limpa o acesso e o estado.
- [x] 3.2 Implementar a localização ou criação da pasta `biluca.com` → `Biluca Finanças` pela Drive API. Verificar manualmente que a pasta é criada quando ausente e reutilizada quando existente.
- [x] 3.3 Implementar a sincronização (`syncOnOpen` e `syncOnClose`) com persistência dos metadados (hash local, id e data de modificação remotos) e substituição atômica do banco, fechando e reabrindo a conexão do `DBProvider`. Verificar por teste de unidade da persistência de metadados e da resolução de conflito usando um cliente fake.
- [x] 3.4 Registrar `BackupService` e `BackupBloc` no `di_container.dart`, injetando o caminho e a versão do banco de `DBProvider`. Verificar que `setup()` conclui sem erro e que o `BackupBloc` está disponível.

## 4. Página de configurações

- [x] 4.1 Criar a página de configurações em `lib/app/settings/`, adicionar a rota em `routes.dart` e a entrada no menu lateral. Verificar por widget test que a página abre pela navegação e o menu marca a página selecionada.
- [x] 4.2 Exibir na página de configurações o botão "Conectar ao Google Drive" quando não configurado e, quando configurado, as informações gerais da conexão e a opção de revogar. Verificar por widget test os estados conectado e não conectado.

## 5. Página inicial com estado da sincronização

- [x] 5.1 Adicionar à página inicial a exibição do estado da sincronização com a última data de sincronização e a versão do banco, indicando também quando não há backup configurado. Verificar por widget test os estados sincronizado e não configurado.

## 6. Ciclo de vida da aplicação

- [x] 6.1 Executar a sincronização na abertura após `initDatabase()` em `main.dart`, quando o backup estiver configurado, sem bloquear a abertura em falha de rede. Verificar por teste de unidade que o disparo ocorre somente quando configurado e que falhas mantêm os dados locais.
- [x] 6.2 Substituir o fluxo de fechamento em `didRequestAppExit` para exibir a modal de progresso com o botão para finalizar a aplicação e concluir a saída após `syncOnClose`, mantendo o fechamento imediato quando não configurado. Verificar por widget test que a modal aparece e que o botão finaliza a aplicação.

## 7. Integração e regressão

- [x] 7.1 Executar `flutter analyze` e os testes focados de `lib/core/backup`, `lib/app/settings` e da página inicial, além dos testes existentes de `test/core` e `test/app`, verificando que não há novos diagnósticos ou regressões.
- [x] 7.2 Revisar a documentação de produto pertinente em `docs/` para registrar o novo fluxo de backup e configuração, quando aplicável. Verificar que o texto documentado reflete o comportamento implementado.

## 8. Separação por perfil de sincronização

- [x] 8.1 Criar a configuração do perfil de sincronização com nome fixo, valor padrão `principal` e sobrescrita por `BILUCA_BACKUP_PROFILE`, sem derivar do modo de build, e disponibilizá-la ao serviço de backup. Verificar por teste de unidade a resolução do nome padrão e do valor configurado.
- [x] 8.2 Compor o caminho remoto como `biluca.com/Biluca Finanças/<perfil>` na localização e criação de pastas. Verificar por teste de unidade da composição do caminho que perfis diferentes geram subpastas distintas e que o nome usa o perfil configurado.
- [x] 8.3 Exibir o perfil ativo na página de configurações junto às informações da conexão. Verificar por widget test que o perfil aparece quando o backup está configurado.

## 9. Autorização e sincronização com tempo limite

- [x] 9.1 Substituir o fluxo de autorização por um servidor loopback controlado pela aplicação, com troca de código por `obtainAccessCredentialsViaCodeExchange`, validação de `state`, `access_type=offline` e `prompt=consent`. Verificar manualmente com uma conta real que a autorização conclui e devolve credenciais com refresh token.
- [x] 9.2 Encerrar a tentativa de autorização após 2 minutos ou quando o servidor local for fechado, devolvendo um estado que permita nova tentativa. Verificar por teste de unidade que o estouro do tempo e o cancelamento terminam a operação com falha e mantêm o backup não configurado.
- [x] 9.3 Aplicar tempo limite de 60 segundos à sincronização e exibir o motivo da falha na modal de fechamento, mantendo o botão "Finalizar aplicação" disponível. Verificar por teste de unidade da falha por tempo limite e por widget test da modal em estado de falha.

## 10. Escopo do Drive e mensagens de erro

- [x] 10.1 Montar as consultas de busca em funções testáveis: pasta de topo filtrada apenas por nome, tipo e `trashed = false`, sem `'root' in parents`, criada sem `parents` explícitos; pastas filhas filtradas por `'<id>' in parents`. Verificar por teste de unidade das consultas geradas que nenhuma referencia a pasta raiz do Meu Drive.
- [x] 10.2 Propagar a mensagem retornada pelo Google para o estado de erro e registrar no log o detalhe técnico e os escopos concedidos, sem registrar tokens. Verificar por teste de unidade que o erro da API aparece na mensagem apresentada.
- [x] 10.3 Revalidar manualmente as tarefas 3.1 e 3.2 com uma conta real: conexão pelo navegador, criação das pastas com perfil, sincronização na abertura e no fechamento e revogação do acesso.

## 11. Horário local da sincronização

- [x] 11.1 Converter o horário da última sincronização para o fuso local da máquina na apresentação (página inicial e configurações), mantendo o armazenamento em UTC. Verificar por teste de widget com um horário UTC conhecido que o texto exibido corresponde ao horário local da máquina.
- [x] 11.2 Validar no aplicativo que a data antes exibida em UTC passa a aparecer no horário local. Verificar comparando o valor exibido com o relógio da máquina após uma sincronização.

## 12. Empacotamento das credenciais

- [x] 12.1 Incluir `secrets/google_oauth.json` no instalador e fixar `WorkingDir: {app}` nos atalhos e no pós-instalação. Verificar pela compilação do instalador com `iscc setup.iss` que o log registra a compactação do arquivo de credenciais.
- [x] 12.2 Resolver as credenciais ao lado do executável, com fallback para o diretório atual e sobrescrita por `BILUCA_GOOGLE_OAUTH_FILE`. Verificar por teste de unidade os cenários de caminho configurado, arquivo ao lado do executável, diretório do projeto e ausência do arquivo.
- [x] 12.3 Interromper o empacotamento quando o arquivo de credenciais não existir, antes da geração do instalador. Verificar por leitura de `build.ps1` que a checagem precede a chamada ao `iscc` e encerra com código de erro.
