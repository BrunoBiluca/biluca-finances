# Tasks

## 1. C08 — Cabeçalho e seção compartilhados

- [x] 1.1 Criar `ReportHeader` em `lib/common/ui/reports/report_header.dart` com ícone, título e ações, usando `LayoutBuilder` para colocar as ações abaixo do título em largura estreita; verificar com `flutter analyze` e com um teste de widget que confirme ícone, título e ações nos dois tamanhos
- [x] 1.2 Criar `ReportSection` em `lib/common/ui/reports/report_section.dart` com ícone, título e conteúdo no padrão de `buildSection` do relatório mensal; verificar com `flutter analyze`
- [x] 1.3 Usar `ReportHeader` e `ReportSection` no relatório mensal (título, ação "Dados do relatório", `MonthSelector` e seções) e no relatório anual (título e `YearSelector`), removendo `buildSection`; verificar com `flutter test test/app/accountability_monthly_report/` e `flutter test test/app/accountability_yearly_report/`

## 2. U13 — Gráficos responsivos e com legenda

- [x] 2.1 Extrair `ChartLegend`/`ChartLegendItem` para `lib/common/ui/reports/charts/chart_legend.dart` e usá-los em `BalanceChart` e `IncomesExpensesEvolutionChart`, corrigindo a entrada de despesas que hoje repete o rótulo "Receitas"; verificar com `flutter analyze` e `flutter test test/app/accountability_yearly_report/`
- [x] 2.2 Adicionar legenda "Mês atual" e "Mês anterior" ao `IdentificationsBarChart`, distinguindo a cor sólida da cor translúcida usada para o mês anterior; verificar com teste de widget que encontre as duas entradas da legenda
- [x] 2.3 Tornar `IdentificationsViewSection.buildCharts` responsivo (gráficos empilhados abaixo de 850 px de largura, lado a lado acima) e remover as larguras fixas de `IdentificationsPercentageChart`, mantendo o gráfico quadrado e a legenda quebrando linha quando faltar espaço; verificar com teste de widget em ~420 px e em ~1200 px de largura
- [x] 2.4 Aplicar alturas por faixa em `YearlySummaryCharts`, trocar o `childAspectRatio` da grade de `YearlyIdentificationsSummaryCharts` por extensão fixa de eixo principal e permitir quebra de linha em `YearlySummaryCards.buildSubInfoText`; verificar com `flutter test test/app/accountability_yearly_report/`
- [x] 2.5 Evitar recarregamento ao redimensionar a janela: trocar a comparação de identidade do closure `load` do `FutureHandler` por um token explícito `dependency` e informar o serviço do mês (resumos e seções do relatório mensal) ou o ano selecionado (relatório anual) nos consumidores; verificar com `flutter test test/common/ui/reports/future_handler_test.dart` e com os testes dos relatórios

## 3. U12 — Barra lateral com dicas e rótulos acessíveis

- [x] 3.1 Em `ClosedSidebar`, remover o texto "N", rotular o agrupamento com `Semantics(label: 'Navegação')` e envolver cada item em `Tooltip` com o título da página e `Semantics` com rótulo, papel de botão e estado selecionado; verificar com `flutter test test/app/app_layout/sidebar/sidebar_test.dart` incluindo asserções de `find.byTooltip` e da árvore semântica
- [x] 3.2 Em `OpenSidebar`, adicionar `Tooltip` com o título e `Semantics` de botão e seleção aos itens, mantendo o título visível; verificar com `flutter test test/app/app_layout/sidebar/sidebar_test.dart`
- [x] 3.3 Dar ao botão `toggle-sidebar` dica e nome acessível que descrevam a ação do estado atual ("Recolher barra lateral" ou "Expandir barra lateral"); verificar com `flutter test test/app/app_layout/sidebar/sidebar_test.dart`

## 4. C16 — Remover o mascaramento de overflow

- [x] 4.1 Remover `FlutterError.onError = ignoreOverflowErrors` de `yearly_summary_cards_test.dart` e do teste mensal marcado com `skip: true`, excluir `test/_helpers/ignore_overflow_erros.dart` e seu `export` em `test/helpers.dart`, e confirmar que os testes de relatório passam sem relatar exceção de layout; verificar com `flutter test test/app/accountability_yearly_report/` e `flutter test test/app/accountability_monthly_report/`
- [x] 4.2 Adicionar testes de janela estreita (~420 x 900) para `IdentificationsViewSection` e para os gráficos do relatório anual, verificando que os gráficos e a legenda aparecem e que `tester.takeException()` permanece nulo; verificar com `flutter test test/app/accountability_monthly_report/` e `flutter test test/app/accountability_yearly_report/`

## 5. Documentação e verificação integrada

- [x] 5.1 Registrar no histórico do catálogo `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md` a entrada da Onda 4 em implementação (U12, U13, C08 e a parte de overflow do C16), mantendo os itens como `selecionada`; verificar que o documento cita os IDs corretos e a dependência do C16 com o U13
- [x] 5.2 Rodar `flutter analyze` com zero problemas e `flutter test` completo com a suíte verde, confirmando que nenhuma mudança regrediu o comportamento existente

## Workflow follow-up

- Arquivar a mudança após concluir todas as tarefas e revisar os artefatos, marcando U12, U13 e C08 como `implementada` e fechando o C16 (parte de falhas na Onda 2 e parte de overflow nesta onda) no catálogo.
- Sincronizar as specs principais: criar `app-navigation` e aplicar o delta de `accountability-reports`.
