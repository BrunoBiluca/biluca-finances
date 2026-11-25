# Tasks

## 1. U02 — Seletor de aparência

- [x] 1.1 Corrigir `setupThemes()` para aplicar o tema claro (`setLight("Obsidian Wealth Light")`) e criar `ThemeModeController` (um `ValueNotifier<ThemeMode>`) registrado no `di_container.dart` e inicializado com `PreferencesService.themeMode`; verificar com `flutter analyze`
- [x] 1.2 Tornar `App` reativo ao tema, mantendo uma única instância do `GoRouter` para não reiniciar a navegação ao trocar o modo; verificar com `flutter analyze` e os testes de widget existentes da aplicação
- [x] 1.3 Criar `AppearanceSection` em Configurações com seletor de Sistema/Claro/Escuro que aplica imediatamente e persiste via `PreferencesService.setThemeMode`; verificar com `flutter test test/app/settings/settings_page_test.dart`
- [x] 1.4 Antecipar a parte de persistência do U12 (Onda 4): restaurar o estado recolhido da barra lateral a partir de `PreferencesService.sidebarCollapsed` e gravá-lo ao recolher ou expandir; verificar com `flutter test test/app/app_layout/sidebar/sidebar_test.dart`

## 2. U05 — Filtros de período e faixa de valor com contagem

- [x] 2.1 Criar o modelo de critérios de filtro (data inicial/final e valor mínimo/máximo) e estender `SearchAccountabilityEntries` e `AccountabilityState` com esses campos e um `resultCount`; verificar com `flutter analyze` e `flutter test test/app/accountability/bloc_test.dart`
- [x] 2.2 Estender `AccountabilityRepo.searchEntries` e adicionar `countEntries` com a mesma cláusula, implementando ambos no `SQLiteAccountabilityRepo` e atualizando `MockAccountabilityRepo`/fakes; verificar com `flutter test test/integrations/sqlite/accountability_repo_test.dart`
- [x] 2.3 Adicionar os controles de data e de valor na página, com ação de limpar, e exibir a contagem de resultados acima da tabela; verificar com `flutter test test/app/accountability/accountability_page_test.dart`

## 3. U07 — Manter mês e ano selecionados

- [x] 3.1 Restaurar o mês salvo em `PreferencesService.selectedMonth` ao abrir o relatório mensal e persistir a seleção ao alterá-la no `MonthSelector`; verificar com `flutter test test/app/accountability_monthly_report/montly_report_v2_test.dart`
- [x] 3.2 Restaurar o ano salvo em `PreferencesService.selectedYear` ao abrir o relatório anual e persistir a seleção ao alterá-la no `YearSelector`; verificar com `flutter test test/app/accountability_yearly_report/year_selector_test.dart`

## 4. U09 — Importação com progresso, falha visível e transação

- [x] 4.1 Adicionar `addAll` transacional a `AccountabilityRepo` e usá-lo no `save()` do serviço de importação, atualizando o fake usado pelos testes; verificar com `flutter test test/integrations/sqlite/import_service_test.dart` e `flutter test test/integrations/sqlite/accountability_repo_test.dart`
- [x] 4.2 Adicionar indicador de progresso e tratamento de falha com nova tentativa em `importEntries`, sem abrir a conferência em caso de erro; verificar com `flutter test test/app/accountability/accountability_page_test.dart`
- [x] 4.3 Envolver o `save()` da conferência em `try/catch` e apresentar a falha no modal sem fechá-lo; verificar com `flutter test test/app/accountability/import_verification_test.dart`

## 5. U10 — Identificação prevista no formulário de nova entrada

- [x] 5.1 Executar a predição dentro do `AccountabilityEntryForm`, exibir a identificação prevista e permitir trocá-la pelo seletor existente; remover a predição silenciosa de `newEntry` na página; verificar com `flutter test test/app/accountability/accountability_new_entry_form_test.dart`

## 6. U11 — Estados vazios com ação de recuperação

- [x] 6.1 Substituir os estados vazios da página por mensagem informativa com ação de criar nova entrada (sem filtros) ou de limpar os filtros (com critérios ativos); verificar com `flutter test test/app/accountability/accountability_page_test.dart`

## 7. Documentação e verificação integrada

- [x] 7.1 Atualizar o histórico do catálogo `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md` registrando a entrada da Onda 3 em implementação, mantendo os itens U02, U05, U07, U09, U10 e U11 como `selecionada`; verificar que o documento reflete os IDs corretos
- [x] 7.2 Rodar `flutter analyze` com zero problemas e `flutter test` completo com a suíte verde, confirmando que nenhuma mudança regrediu o comportamento existente

## Workflow follow-up

- Arquivar a mudança após concluir todas as tarefas e revisar os artefatos, marcando os itens U02, U05, U07, U09, U10 e U11 como `implementada` no catálogo.
