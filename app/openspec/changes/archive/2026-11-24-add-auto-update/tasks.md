# Tasks

## 1. Versão e modelos no core

- [x] 1.1 Criar o tipo de versão em `lib/core/app_update/models/` com leitura de `major.minor.patch`, prefixo `v` opcional e comparação componente a componente. Verificar por teste de unidade em `test/core/app_update/app_version_test.dart` cobrindo versão maior, menor, patch, igual, instalada superior e formato inválido, com `flutter test test/core/app_update/app_version_test.dart`.
- [x] 1.2 Criar os modelos de release publicado (versão, nome e URL do instalador) e de estado da atualização (estado, versão instalada, versão disponível, progresso, mensagem de erro) seguindo o padrão dos modelos de backup. Verificar por teste de unidade em `test/core/app_update/app_update_models_test.dart` que os modelos comparam e transportam os valores corretamente.

## 2. Serviço e estado da atualização

- [x] 2.1 Criar a interface `AppUpdateService` em `lib/core/app_update/services/` com `supported`, `currentVersion`, verificação, download e reinício, além da implementação `unsupported` para plataformas sem instalador. Verificar por teste de unidade que a implementação `unsupported` não oferece atualização, não baixa e não reinicia.
- [x] 2.2 Criar `AppUpdateBloc` com eventos e estados em `lib/core/app_update/bloc/`, seguindo o padrão de `BackupBloc`, incluindo progresso de download. Verificar por `bloc_test` em `test/core/app_update/app_update_bloc_test.dart` as transições verificação → atualizada/disponível/falha, download → pronto e reinício recusado.

## 3. Consulta ao GitHub Releases e download

- [x] 3.1 Implementar o cliente do GitHub Releases em `lib/integrations/github_releases/`, com cabeçalhos exigidos, tempo limite de 10 segundos, leitura do `tag_name` e seleção do asset `biluca-financas-setup-<versão>.exe` com tolerância ao prefixo do nome. Verificar por teste de unidade com `MockClient` os cenários de asset exato, asset com prefixo, release sem executável, `404` e `403`.
- [x] 3.2 Implementar o download do instalador para o diretório temporário, gravando em `.part` e renomeando ao concluir, com progresso por bytes recebidos e tempo limite de 5 minutos. Verificar por teste de unidade com `MockClient` e diretório temporário que o arquivo só existe com o nome final ao concluir, que o progresso é reportado e que o arquivo parcial é descartado em falha.
- [x] 3.3 Registrar em `docs/Sistema/Publicação.md` o contrato consumido pela aplicação (endpoint de release mais recente e nome do asset do instalador) e a consequência de renomeá-lo. Verificar que o documento descreve exatamente o comportamento implementado nas tarefas 3.1 e 3.2.

## 4. Encerramento da aplicação e abertura do instalador

- [x] 4.1 Extrair o tratamento de saída do `main.dart` para `lib/app/app_exit/`, mantendo o fluxo atual (sincronização do backup e `tearDown`), e usar o mesmo tratamento em `App` e no registro da atualização. Verificar por `flutter analyze` e pelos testes existentes de `test/app/app_exit` que o comportamento de fechamento não mudou.
- [x] 4.2 Criar o lançador do Inno Setup em `lib/integrations/app_update/`, com função pura que monta o comando do PowerShell (aguardar o PID da aplicação e então abrir o instalador) e injeção das funções de criar processo e encerrar a aplicação. Verificar por teste de unidade dos argumentos gerados, incluindo caminhos com espaços e a ordem das operações.
- [x] 4.3 Implementar a reinicialização no serviço Windows na ordem: fluxo de saída, criação do processo auxiliar e encerramento do processo atual, sem abrir o instalador quando o fechamento não for permitido e informando falha quando o processo auxiliar não puder ser criado. Verificar por teste de unidade com funções falsas os cenários de sucesso, fechamento recusado e falha ao abrir o instalador.
- [x] 4.4 Registrar o serviço e o bloc no `di_container.dart`, escolhendo a implementação real no Windows e a `unsupported` nas demais plataformas, e disparar a verificação na abertura em `main.dart` por uma função testável. Verificar por teste de unidade que a verificação é disparada na abertura e que falhas não interrompem a inicialização, além de `flutter analyze` sem novos diagnósticos.
- [x] 4.5 Atualizar `docs/Sistema/Arquitetura.md` com o novo módulo de atualização (core, integrações, apresentação e fluxo de encerramento). Verificar que o documento reflete os caminhos de arquivo criados.

## 5. Notificação e atualização pela página inicial

- [x] 5.1 Criar o card de notificação de atualização em `lib/app/home/widgets/` e exibi-lo na página inicial, com versão instalada, versão disponível, progresso do download, estado pronto, falha e ação de atualizar ou repetir. Verificar por widget test em `test/app/home/home_update_notification_test.dart` que o card aparece apenas quando há atualização, download em andamento, pronto ou falha, e que a ação dispara o download.
- [x] 5.2 Criar o diálogo de confirmação de atualização, informando que a aplicação será fechada antes da abertura do instalador, e disparar o reinício apenas após o fechamento do diálogo. Verificar por widget test que confirmar dispara o reinício, que cancelar não dispara e que o aviso de fechamento é apresentado.

## 6. Atualização pela página de configurações

- [x] 6.1 Criar a seção de atualização em `lib/app/settings/widgets/`, exibindo versão instalada, versão disponível, ação de verificar novamente, ação de atualizar e motivo das falhas. Verificar por widget test em `test/app/settings/settings_page_test.dart` os estados com e sem atualização, a verificação solicitada pelo botão e a falha com nova tentativa disponível.

## 7. Integração e regressão

- [x] 7.1 Executar `flutter analyze` e as suítes afetadas (`test/core/app_update`, `test/integrations/github_releases`, `test/integrations/app_update`, `test/app/home`, `test/app/settings`, `test/app/app_exit`), verificando ausência de novos diagnósticos e de regressões nos testes de backup e de fechamento.
- [x] 7.2 Validar manualmente o ciclo completo em uma build Windows: com uma versão publicada superior à instalada, confirmar a notificação na página inicial, o download, o fechamento com sincronização do backup, a abertura do wizard do Inno Setup e a reabertura da aplicação atualizada.

## Workflow follow-up

- Arquivar a mudança após a revisão e a validação manual em uma build Windows.
- Verificar que os arquivos do arquivo morto e as specs sincronizadas refletem o comportamento implementado.
