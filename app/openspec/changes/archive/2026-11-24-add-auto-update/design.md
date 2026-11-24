# Design

## Context

A aplicação é Flutter com injeção de dependências por `get_it`, estado com `flutter_bloc`, HTTP por `package:http` e versão instalada obtida por `package_info_plus` (já usado em [sidebar.dart](../../../../lib/app/app_layout/sidebar/sidebar.dart)). A versão exibida vem do recurso de versão do executável, gerado a partir do `version` do `pubspec.yaml` no build Windows.

O fechamento da aplicação já passa por [`App.didRequestAppExit`](../../../../lib/app/app.dart) → callback de `main.dart` → [`runApplicationExitFlow`](../../../../lib/app/app_exit/app_exit_flow.dart) (modal de sincronização do backup) → [`tearDown`](../../../../lib/tear_down.dart). Esse é o fluxo que a atualização precisa reaproveitar. A publicação atual (`build.ps1` + `setup.iss`) já anexa ao release o arquivo `biluca-financas-setup-<versão>.exe`; a motivação da mudança está em [proposal.md](./proposal.md) e o comportamento esperado em [specs/app-update/spec.md](./specs/app-update/spec.md).

Restrições relevantes: a Constituição exige regra de negócio testada, código em inglês, documentação em português, agrupamento por funcionalidade e dependências justificadas. A API do GitHub sem autenticação é limitada a 60 requisições por hora por IP.

## Goals / Non-Goals

**Goals:**
- Definir a leitura da versão publicada, a comparação de versões e o estado de atualização no `core`, com a integração de rede/processo em `integrations`.
- Estabelecer um contrato estável entre a aplicação e o release publicado (nome do asset do instalador).
- Garantir que a instalação só comece depois que o processo da aplicação terminar, sem pular o fluxo de fechamento.
- Manter qualquer falha de atualização isolada: a aplicação continua utilizável.

**Non-Goals:**
- Atualização silenciosa, em segundo plano ou sem interação da pessoa usuária.
- Verificação de assinatura digital ou hash do instalador.
- Atualização de plataformas sem instalador Inno Setup (Linux, Android, web).
- Exibição de notas do release, canais (beta/estável) ou rollback de versão.
- Alterar o processo de publicação: `build.ps1` e `setup.iss` continuam sob responsabilidade da pessoa desenvolvedora.

## Decisions

### Fonte da versão publicada

- Consultar `GET https://api.github.com/repos/BrunoBiluca/biluca-finances/releases/latest` com `Accept: application/vnd.github+json`, `X-GitHub-Api-Version: 2022-11-28` e `User-Agent` explícito (o GitHub rejeita requisições sem identificação).
- Usar o `tag_name` como versão publicada e os `assets` para localizar o instalador.
- **Alternativas consideradas**: ler a página HTML de releases (frágil a mudanças de layout), listar todos os releases (payload maior e sem ganho) e consumir o feed Atom (não informa os assets). Rejeitadas.
- Sem token de acesso: a verificação é anônima, uma vez por abertura da aplicação. O limite de 60 requisições por hora por IP é suficiente; resposta `403` por limite é tratada como falha informada, com nova tentativa disponível.
- Tempo limite de 10 segundos na consulta; falha ou `404` (nenhum release publicado) resulta em estado de falha com mensagem, sem bloquear a abertura.

### Contrato do instalador publicado

- O instalador é o asset cujo nome segue `biluca-financas-setup-<versão>.exe`, já produzido por `setup.iss` (`OutputBaseFilename=biluca-financas-setup-{#Version}`) e anexado por `build.ps1`.
- A aplicação procura primeiro o nome exato para a versão publicada e, como tolerância, o primeiro asset `.exe` cujo nome começa com `biluca-financas-setup-`. Sem asset compatível, a atualização falha informando que o instalador não foi encontrado.
- O download usa `browser_download_url` do asset; nenhuma chamada autenticada é necessária.
- Consequência para a publicação: renomear o instalador publicado quebra a atualização. Isso fica documentado em `docs/Sistema/Publicação.md`.

### Comparação de versões

- Criar um tipo de versão no `core` que lê `major.minor.patch`, aceita prefixo `v` opcional e compara componente a componente, tratando sufixos de pré-release como iguais ao número base.
- Versão publicada inválida encerra a verificação como falha, sem oferecer atualização.
- **Alternativa considerada**: adicionar `pub_semver`. Rejeitada pela Constituição (item 3): a comparação de três números inteiros não justifica uma dependência nova.

### Camadas e injeção de dependências

- `lib/core/app_update/`:
  - `models/`: versão da aplicação, release publicado e estado da atualização.
  - `services/app_update_service.dart`: interface com `supported`, `currentVersion`, `checkForUpdate`, `downloadInstaller` e `restartWithInstaller`; e uma implementação `unsupported` para plataformas sem instalador.
  - `bloc/`: `AppUpdateBloc` com os eventos e estados, no mesmo padrão de `BackupBloc` (estado único `AppUpdateStatusChanged`).
- `lib/integrations/`:
  - `github_releases/github_releases_client.dart`: consulta e interpretação da resposta do GitHub sobre um `http.Client` injetado.
  - `app_update/inno_setup_installer_launcher.dart`: monta e executa o comando que abre o wizard do Inno Setup depois do encerramento.
  - `app_update/windows_app_update_service.dart`: implementação de `AppUpdateService` para Windows, compondo cliente HTTP, download e instalador.
- `lib/app/home/widgets/update_notification_card.dart` e `lib/app/settings/widgets/app_update_section.dart`: apresentação, consumindo o bloc por `BlocProvider.value`, como já ocorre com o backup.
- Registro no `di_container.dart`: em Windows registra a implementação real; nas demais plataformas registra a implementação `unsupported`. A escolha de plataforma fica na raiz de composição, não no `core`.

### Fluxo de encerramento para atualizar

- O encerramento reaproveita o mesmo callback de saída já usado por `App.didRequestAppExit`. Para permitir isso sem acoplamento circular, o tratamento de saída sai de `main.dart` para um arquivo próprio em `lib/app/app_exit/` e passa a ser usado tanto por `App` quanto pelo registro da atualização no container.
- Ao confirmar a atualização, o serviço executa o callback de saída (sincronização do backup e `tearDown`). Se o encerramento não for permitido, nada é aberto e a aplicação continua em execução.
- Sendo permitido, o serviço cria um processo auxiliar em segundo plano e, em seguida, encerra o processo atual com `exit(0)` do `dart:io`.
- O processo auxiliar é um `powershell.exe` oculto cujo comando aguarda o término do PID da aplicação (limite de 60 segundos) e só então executa `Start-Process` do instalador baixado, abrindo o wizard.
- **Alternativas consideradas**:
  - Abrir o instalador imediatamente e contar com o gerenciador de reinicialização do Inno Setup para fechar a aplicação: rejeitada porque encerraria o processo sem executar a sincronização de fechamento.
  - Fechar a janela para disparar `didRequestAppExit`: rejeitada porque não garante que o processo termine antes da abertura do instalador e arrisca executar o fluxo de saída duas vezes.
  - Instalar com `/SILENT` ou `/VERYSILENT`: rejeitada porque o requisito define a abertura do wizard.
  - Criar um executável auxiliar próprio: rejeitada por exigir etapa extra de build e distribuição.
  - `ProcessStartMode.detached` do `dart:io`: rejeitada após validação em build Windows — no Windows o processo auxiliar criado nesse modo não chegava a executar o `powershell.exe`, então o wizard nunca abria. O modo padrão foi adotado: o processo auxiliar é criado sem aguardar o término, sobrevive ao `exit(0)` da aplicação e não recebe saída que pudesse bloquear em pipe.
- O processo auxiliar não é escrito em disco: o comando é passado por argumento ao PowerShell, disponível em todas as versões suportadas do Windows.
- A espera pelo término do processo e a abertura do instalador ficam em `try/catch` independentes: uma falha em `WaitForExit` não impede a abertura, e o resultado (instalador aberto ou motivo da falha) é registrado em `<instalador>.launch.log`, ao lado do instalador baixado, porque o auxiliar sobrevive ao processo da aplicação e não pode escrever no log da própria aplicação.
- `exit(0)` é usado de propósito, e não o fechamento de janela, porque o fluxo de saída já foi executado e o arquivo do executável precisa ser liberado para o instalador. Testes cobrem a ordem (saída → criação do processo auxiliar → encerramento) por meio de funções injetadas.

### Download do instalador

- Baixar para o diretório temporário da aplicação (`path_provider`), em `biluca-financas-update/`, com o nome do asset.
- Gravar primeiro em arquivo `.part` e renomear ao concluir, para que um download interrompido nunca seja tratado como pronto.
- Progresso calculado por bytes recebidos sobre `content-length`; quando o servidor não informa o tamanho, a interface mostra o download em andamento sem percentual.
- Tempo limite total de 5 minutos por download e novo download recomeça do zero, descartando o arquivo parcial.
- **Alternativa considerada**: `dio` com progresso nativo. Rejeitada: `package:http` já está no projeto e permite o mesmo resultado com uma requisição em stream.

### Estado e comportamento da interface

- `AppUpdateStatus` expõe: estado (`checking`, `upToDate`, `updateAvailable`, `downloading`, `readyToInstall`, `failed`, `unsupported`), versão instalada, versão disponível, progresso e mensagem de erro.
- A verificação é disparada na abertura da aplicação, a partir de `main.dart`, mantendo o `AppUpdateBloc` como singleton no container (mesmo padrão do `BackupBloc`).
- Página inicial: notificação (card) somente quando há atualização disponível, download em andamento/pronto ou falha de download, com a ação de atualizar/repetir. Sem atualização, nada é exibido — a versão já aparece na barra lateral.
- Página de configurações: seção com versão instalada, versão disponível, ação de verificar novamente e ação de atualizar, além da mensagem de falha.
- A confirmação de instalação usa um diálogo próprio que avisa que a aplicação será fechada; o evento de reinício é disparado pela página depois que o diálogo é fechado, evitando empilhar diálogos com a modal de sincronização do fechamento.
- Falhas são registradas no log por `LoggerManager`, com o mesmo padrão do backup, sem dados sensíveis.

### Estratégia de testes

- Regra de comparação e leitura de versões: testes de unidade puros no `core`.
- Interpretação da resposta do GitHub e seleção do asset: testes de unidade com `MockClient` de `package:http`.
- Transições do bloc: `bloc_test` com serviço falso, cobrindo verificação, atualização disponível, falha, download, pronto e reinício recusado.
- Montagem do comando do PowerShell: teste de unidade da função pura que gera os argumentos.
- Interface: widget tests da notificação na página inicial e da seção nas configurações, verificando textos e ações observáveis, sem acoplar a estilos.

## Risks / Trade-offs

- [Limite de requisições anônimas do GitHub] → uma verificação por abertura, falha informada sem bloquear a aplicação e nova tentativa disponível; token opcional fica como evolução futura.
- [Renomear o asset do instalador quebra a atualização] → contrato documentado em `docs/Sistema/Publicação.md` e seleção tolerante ao prefixo do nome.
- [Instalador baixado corrompido] → gravação em `.part` e renomeação só ao concluir; o próprio Inno Setup valida o pacote antes de instalar.
- [Aplicação não encerra antes do instalador] → o processo auxiliar aguarda o PID terminar; após o limite de 60 segundos o instalador assume e o Inno Setup trata o arquivo em uso.
- [Processo auxiliar não executa o PowerShell] → validado em build Windows que o modo `detached` do `dart:io` não executava o auxiliar; o modo padrão, que sobrevive ao `exit(0)`, é o utilizado.
- [Falha invisível do processo auxiliar] → espera e abertura ficam em `try/catch` independentes e o resultado é gravado em `<instalador>.launch.log`, ao lado do instalador baixado.
- [Releases com pré-versão ou tag fora do padrão] → versão inválida termina como falha informada, sem instalar nada.
- [Antivírus bloqueando o executável baixado] → a falha é informada com o motivo local e a instalação manual pelo GitHub continua possível.
- [Primeira versão com atualização] → apenas instalações que já contêm o recurso conseguem se atualizar; a transição para a primeira versão com updater continua manual.

## Migration Plan

Não há alteração de esquema nem migração de dados. A primeira versão publicada com o recurso precisa ser instalada manualmente; a partir dela as versões seguintes podem ser instaladas pela própria aplicação. A reversão consiste em remover a verificação e as ações de atualização, mantendo a instalação manual pelos releases, sem impacto nos dados da aplicação.
