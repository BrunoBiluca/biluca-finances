# Tasks

## 1. C03 — Falhas de repositório no AccountabilityBloc

- [x] 1.1 Adicionar estado de falha ao `AccountabilityState` (mensagem ou subtipo) preservando os dados já exibidos, e envolver os handlers de busca, criação, edição e exclusão em `try/catch` que emite o estado de falha e registra o erro no logger; verificar com `flutter analyze` e com os testes de bloc existentes (`flutter test test/app/accountability/bloc_test.dart`)
- [x] 1.2 Exibir a mensagem de falha na página de prestação de contas com ação de nova tentativa que reenvia o evento correspondente; verificar com `flutter test test/app/accountability/accountability_page_test.dart`

## 2. C16 — Fortalecer testes (parte de falhas)

- [x] 2.1 Adicionar testes de falha no `AccountabilityBloc` cobrindo busca/carregamento, criação, edição e exclusão lançando exceção no repositório, validando o estado de falha emitido e a recuperação por nova tentativa; verificar com `flutter test test/app/accountability/bloc_test.dart`
- [x] 2.2 Registrar no catálogo `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md` que apenas a parte de testes de falha do C16 foi concluída nesta onda e que a remoção do mascaramento de overflow fica para a Onda 4 (U13)

## 3. C06 — Remoção de dynamic da tabela e dos temas de comparação

- [x] 3.1 Tipar `AccountabilityTable` (`List<AccountabilityEntry>` e callbacks tipados) e `AccountabilityTableRow.entry` como `AccountabilityEntry`, removendo os condicionais `entry is AccountabilityEntry`; verificar com `flutter analyze` e `flutter test test/app/accountability/table_test.dart`
- [x] 3.2 Substituir os retornos `Map`/`dynamic` de `values_comparison.dart` por uma classe tipada `ValuesComparisonTheme`; verificar com `flutter analyze` e os testes de relatório existentes

## 4. C09 — FutureHandler genérico com nova tentativa

- [x] 4.1 Tornar `FutureHandler<T>` genérico, remover o `setState` em `initState` e o contorno `hideLoading`, e apresentar erro com ação de nova tentativa que re-executa o carregamento; verificar com `flutter analyze`
- [x] 4.2 Atualizar os usos do `FutureHandler` nos relatórios mensal e anual para a nova API; verificar com `flutter test test/app/accountability_monthly_report/` e `flutter test test/app/accountability_yearly_report/`

## 5. C04 — Tokens de tema sem GetIt em widgets

- [x] 5.1 Registrar `AppColors` como `ThemeExtension` nos temas claro e escuro e adicionar tokens para as cores fixas atuais (cabeçalho/linhas da tabela, destaque da sidebar e dos cabeçalhos de relatório, bordas de modal e temas de comparação); verificar com `flutter analyze`
- [x] 5.2 Substituir as cores fixas e o acesso a `GetIt.I<ThemeManager>()` dentro dos widgets (sidebar, tabela, cabeçalhos de relatório, célula de valor, toast, resumo mensal e moeda) pelo token via `Theme.of(context)`; verificar com os testes de widget de relatórios, sidebar e home

## 6. C07 — Divisão do identification_edit_modal.dart

- [x] 6.1 Extrair os componentes coesos do modal para arquivos próprios sob `lib/app/accountability_identifications/widgets/` (formulário, status, tipo, ícone/cor, seletor de cor e opção de status), mantendo `IdentificationEditModal` como orquestrador; verificar com `flutter analyze`
- [x] 6.2 Verificar que a divisão preserva o comportamento com `flutter test test/app/accountability/identification_edit_test.dart` e `flutter test test/app/accountability/identification_edit_selector_test.dart`

## 7. C10 — Camada de preferências persistidas

- [x] 7.1 Adicionar a dependência `shared_preferences` ao `pubspec.yaml` e criar `PreferencesService` em `lib/core/preferences/` com leitura e escrita tipadas (`ThemeMode`, `sidebarCollapsed`, `selectedMonth`, `selectedYear`) e valores padrão; verificar com `flutter pub get` e `flutter analyze`
- [x] 7.2 Registrar `PreferencesService` no `di_container.dart`, inicializá-lo antes de `runApp` e definir `themeMode` em `App` a partir da preferência de aparência; verificar com `flutter analyze` e os testes de inicialização existentes
- [x] 7.3 Adicionar testes do serviço de preferências cobrindo persistência entre instâncias, restauração e valores padrão; verificar com `flutter test test/core/preferences/`

## 8. Verificação integrada

- [x] 8.1 Rodar `flutter analyze` com zero problemas e `flutter test` completo com a suíte verde, confirmando que nenhuma mudança regrediu o comportamento existente
