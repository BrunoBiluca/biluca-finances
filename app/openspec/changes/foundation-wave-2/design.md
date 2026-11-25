# Design

## Context

Ver `proposal.md` — Why. Onda 2 ("fundação") do catálogo, executada após a Onda 1. Baseline: `flutter analyze` sem problemas e 385 testes passando. A constituição exige código em inglês, testes unitários para regras de negócio, agrupamento por funcionalidade e `common` apenas para código compartilhado. Os itens C04/C06/C10 sustentam as melhorias de experiência das Ondas 3 e 4 (U02, U05, U07, U11, U12 e U13).

## Goals / Non-Goals

**Goals:**

- Expor falhas de repositório no `AccountabilityBloc` com estado de erro e nova tentativa (C03).
- Eliminar `dynamic` da tabela, dos relatórios e dos temas de comparação (C06).
- Centralizar as cores fixas em tokens do tema ativo e remover `GetIt` de dentro dos widgets (C04).
- Dividir `identification_edit_modal.dart` em componentes coesos (C07).
- Tornar `FutureHandler` genérico, sem `setState` em `initState` nem `hideLoading`, com erro e nova tentativa (C09).
- Criar a camada de preferências persistidas (C10) e cobrir falhas com testes (C16).

**Non-Goals:**

- Não adicionar o seletor de aparência (U02, Onda 3).
- Não implementar a fiação de mês/ano nas telas de relatório (U07, Onda 3) nem os tooltips e rótulos acessíveis da sidebar (U12, Onda 4): C10 entrega a camada e as chaves, não a fiação de UI desses consumidores.
- Não remover o mascaramento de overflow dos testes (parte do C16 que depende de U13, Onda 4).
- Não alterar o schema do banco nem o contrato de publicação.

## Decisions

### C03 — Falhas de repositório no AccountabilityBloc

- Adicionar um estado de falha ao `AccountabilityState` (um campo de mensagem ou um subtipo `AccountabilityFailure`), preservando os dados já exibidos quando houver.
- Envolver cada handler que chama o repositório (`updateEntries`, `_loadFirstPage`, `_loadNextPage`, `AddAccountabilityEntry`, `UpdateAccountabilityEntry` e `DeleteAccountabilityEntry`) em `try/catch`, emitindo o estado de falha com uma mensagem amigável e registrando o erro original no logger.
- A página de prestação de contas apresenta a mensagem e uma ação de nova tentativa que reenvia o evento correspondente.
- Justificativa: hoje a exceção propaga para a zona de erro do Flutter sem informar a pessoa, e criação/edição/exclusão falham silenciosamente.
- Alternativa considerada: capturar por evento e exibir apenas um toast — rejeitada, pois a busca precisa de um estado de erro com nova tentativa para se recuperar.

### C04 — Tokens de tema sem GetIt em widgets

- Registrar `AppColors` como `ThemeExtension` nos temas claro e escuro e expor as cores fixas de hoje como tokens: fundo do cabeçalho da tabela e das linhas alternadas (`0xFF0A0E17`/`0xFF1C1F29`), destaque da sidebar e dos cabeçalhos de relatório (`0xFF262A34`), bordas do modal e do card de grupo (`0xFF272D36`), cor neutra dos gráficos (`Colors.grey.shade800`) e os temas de comparação de `values_comparison.dart`.
- Os widgets passam a obter as cores via `Theme.of(context).extension<AppColors>()!`, em vez de `GetIt.I<ThemeManager>().getCurrentTheme(context).colors`.
- Reaproveitar as constantes já existentes nos temas (ex.: `canvasBase`, `cardSurface`, `raisedSurface`, `hairlineBorder` de `obsidian_wealth_dark_theme.dart`) sempre que a cor fixa já corresponder a um token.
- Justificativa: remove o acoplamento a `GetIt` dentro de widgets e faz as cores seguirem o tema ativo, pré-requisito de U02 e U13.
- Alternativa considerada: manter `GetIt` e apenas centralizar as cores em constantes — rejeitada, pois não resolve o acoplamento nem a troca de tema em tempo de execução.

### C06 — Remoção de dynamic

- `AccountabilityTable` passa a receber `List<AccountabilityEntry>` e callbacks tipados (`ValueChanged<AccountabilityEntry>`); `AccountabilityTableRow.entry` vira `AccountabilityEntry`.
- `values_comparison.dart`: substituir as funções que retornam `Map`/`dynamic` por uma classe `ValuesComparisonTheme` com campos tipados (`rotation`, `bgColor`, `txtColor`, `icon`), mantendo `getTheme` como seletor.
- Ajustar os `dynamic` apenas nos pontos listados (tabela, relatórios, temas de comparação e `FutureHandler`), sem expandir o escopo para os `dynamic` legítimos das integrações (Google Drive, GitHub, predição).
- Justificativa: tipagem forte habilita refatorações seguras das Ondas 3/4 (filtros do U05) e elimina os condicionais `entry is AccountabilityEntry`.
- Alternativa considerada: remover todos os `dynamic` do projeto de uma vez — rejeitada, pois os `dynamic` de integrações exigem mudanças específicas com risco próprio.

### C07 — Divisão do identification_edit_modal.dart

- Extrair componentes coesos sob `lib/app/accountability_identifications/widgets/`: formulário principal (`IdentificationEditForm`), campo de status (`IdentificationStatusField`), campo de tipo (`IdentificationTypeField`), campos de ícone/cor (`IdentificationIconColorFields`), seletor de cor (`IdentificationColorPickerDialog`) e opção de status (`IdentificationStatusOption`).
- O `IdentificationEditModal` mantém apenas o estado e a orquestração, delegando os blocos visuais.
- Justificativa: cumpre "um conceito por arquivo" da constituição; o arquivo de 988 linhas mistura formulário, seleção de cor, catálogo de ícones, validações e diálogo de exclusão.
- Alternativa considerada: manter em um único arquivo com mixins e classes privadas — rejeitada, pois não melhora a navegação do arquivo.

### C09 — FutureHandler genérico com nova tentativa

- Tornar `FutureHandler<T>` genérico, com `Future<T> Function() load`, `Widget Function(BuildContext, T) builder` e builders opcionais de carregamento e erro.
- Remover o `setState` em `initState`: criar o futuro a partir de `widget.load()` e tratar a troca de `load` em `didUpdateWidget`.
- Substituir o contorno `hideLoading` por um parâmetro explícito de apresentação (ex.: `loadingBuilder`, que nos gráficos pode retornar `SizedBox.shrink()`).
- No erro, renderizar uma mensagem amigável e um botão de nova tentativa que re-executa `load`.
- Justificativa: elimina `dynamic`, o `setState` durante `initState` e o texto cru `Erro: <exceção>`.
- Alternativa considerada: usar `FutureBuilder` diretamente em cada relatório — rejeitada, pois duplica a lógica de erro e nova tentativa.

### C10 — Camada de preferências persistidas

- Criar `PreferencesService` em `lib/core/preferences/` com leitura e escrita tipadas (`ThemeMode`, `sidebarCollapsed`, `selectedMonth` e `selectedYear`), valores padrão e uma implementação com `shared_preferences`.
- Registrar no `di_container.dart` e inicializar antes de `runApp`; `App` passa a definir `themeMode` a partir da preferência de aparência.
- As chaves de sidebar e mês/ano são criadas e expostas pela camada agora; a fiação nas telas (U07 e U12) fica para as ondas seguintes.
- Justificativa da dependência `shared_preferences`: mecanismo padrão do ecossistema Flutter para preferências simples, com suporte a desktop; a alternativa de arquivo JSON via `path_provider` exigiria serialização manual sem ganho.
- Alternativa considerada: armazenar preferências no banco SQLite — rejeitada, pois acopla preferências ao ciclo de vida do banco.

### C16 — Testes de falha

- Adicionar testes de falha no `AccountabilityBloc` (busca, criação, edição e exclusão lançando no repositório), validando o estado de erro e a nova tentativa, usando o `MockAccountabilityRepo` existente.
- A remoção do `ignoreOverflowErrors` (mascaramento de overflow) fica para a Onda 4 (U13), pois depende de corrigir a responsividade dos gráficos.
- Justificativa: cobrir o comportamento novo de C03 e manter o mascaramento até o U13 resolver os overflows.

## Risks / Trade-offs

- C03 muda a assinatura dos estados e pode quebrar os testes de bloc existentes → rodar `flutter test test/app/accountability/` e a suíte de bloc após a mudança.
- C06 propaga `AccountabilityEntry` por widgets que hoje aceitam `dynamic`; a tabela também é usada no diálogo "Dados do relatório" → verificar `table_test.dart` e `montly_report_v2_test.dart`.
- C04 altera cores em várias telas; a equivalência visual deve ser preservada por tokens que mapeiem os valores atuais → rodar os testes de widget de relatórios, sidebar e home.
- C07 é refatoração pura; o risco é quebrar `identification_edit_test.dart` e `identification_edit_selector_test.dart` → rodar esses testes após dividir.
- C09 muda a API do `FutureHandler` usada nos relatórios mensal e anual → ajustar todos os usos na mesma mudança e rodar os testes de relatório.
- C10 introduz uma dependência nova (`shared_preferences`) e altera a inicialização → registrar antes de `runApp` e garantir fallback para os padrões quando a leitura falhar.

## Migration Plan

Não se aplica: não há migração de dados nem alteração de schema. Preferências ainda não persistidas passam a usar os valores padrão na primeira execução. A reversão é reverter o commit.

## Open Questions

Nenhuma pendência que altere o escopo, as specs ou a divisão de tarefas.
