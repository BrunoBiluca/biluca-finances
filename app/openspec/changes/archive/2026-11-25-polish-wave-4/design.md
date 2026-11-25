# Design

## Context

Ver `proposal.md` — Why. Esta é a última onda do catálogo e parte das três ondas anteriores já arquivadas ou em conclusão:

- `PreferencesService` (Onda 2) já persiste o estado recolhido da barra lateral e a restauração já foi fiada no `Sidebar` (antecipação do U12 na Onda 3). Restam apenas dicas e rótulos acessíveis.
- `AppColors` já é `ThemeExtension` e a barra lateral, os cabeçalhos e o gráfico de composição já usam tokens do tema (Onda 2), então o U13 não precisa mexer em cores.
- `FutureHandler<T>` já trata erro com nova tentativa (Onda 2) e os relatórios já o usam; o C08 não deve reintroduzir um caminho de carregamento próprio.

Pontos relevantes do código atual:

- `ClosedSidebar` exibe um `Text("N")` no lugar do rótulo "Navegação" e monta `ListTile` sem `title` — logo, sem nome acessível.
- `IdentificationsViewSection.buildCharts` devolve `SizedBox(height: 600)` com uma `Row` de dois filhos: o gráfico de barras (`Expanded`) e `IdentificationsPercentageChart`, que fixa 300 px de largura em dois `SizedBox`.
- `IdentificationsBarChart` desenha duas barras por identificação (valor do mês e valor do mês anterior, este com `alpha 80`) sem legenda.
- O relatório anual fixa `SizedBox(height: 600)` para dois gráficos e usa `childAspectRatio: 1.5` na grade de identificações; as legendas de `BalanceChart` e `IncomesExpensesEvolutionChart` rotulam as duas séries como "Receitas".
- `monthly_report.dart` e `yearly_report.dart` repetem o bloco ícone + título e `buildSection` existe só no relatório mensal.
- Dois testes usam `ignoreOverflowErrors` para silenciar `RenderFlex overflowed` (`yearly_summary_cards_test.dart` e o teste mensal marcado com `skip: true`).

## Goals / Non-Goals

**Goals:**

- Entregar U12 (dicas e nomes acessíveis), U13 (gráficos responsivos com legenda), C08 (cabeçalho e seção compartilhados) e a parte de overflow do C16.
- Manter o comportamento e a aparência atuais nos tamanhos de janela em que eles já funcionam, inclusive claro/escuro.
- Deixar a suíte de testes sem mascaramento de layout, com casos de janela estreita que falhariam sem a mudança.

**Non-Goals:**

- Migrar a barra lateral para `NavigationRail` ou alterar larguras, cores e ordem dos itens.
- Reativar o teste mensal marcado com `skip: true` (falta registrar serviços no `GetIt`; ver Riscos).
- Tipar os `Map<String, dynamic>` remanescentes do relatório mensal (`SummaryLastMonthsSection`) ou trocar `Future<dynamic>` por modelos — pertencem a outra rodada.
- Alterar o cálculo de `related`/`avgRecentMonts` ou a comparação "em relação aos últimos 12 meses" dos cards.

## Decisions

### 1. U12 — Acessibilidade na barra lateral mantendo os widgets atuais

Em `ClosedSidebar`:

- Remover a linha com `Text("N")`.
- Envolver o `ListView` em `Semantics(label: 'Navegação', container: true, explicitChildNodes: true)`, para que o agrupamento continue rotulado quando não há espaço para o texto.
- Envolver cada item em `Tooltip(message: page.title, excludeFromSemantics: true, child: Semantics(label: page.title, button: true, selected: index == selectedPage, child: ExcludeSemantics(child: ListTile(...))))`. O `excludeFromSemantics` evita rótulo duplicado entre `Tooltip` e `Semantics`.

Em `OpenSidebar`:

- Manter o `title: Text(page.title)` e envolver o `ListTile` em `Semantics(selected: index == selectedPage, button: true)`, pois `ListTile.selected` altera só a aparência.
- Adicionar `Tooltip(message: page.title)` para consistência entre os dois estados.

No `Sidebar`:

- `IconButton(key: Key('toggle-sidebar'), tooltip: isOpen ? 'Recolher barra lateral' : 'Expandir barra lateral', ...)`. A `tooltip` do `IconButton` também fornece o nome acessível, então não é preciso `Semantics` extra.

Alternativas consideradas:

- `NavigationRail`/`NavigationDrawer`: trariam dicas prontas, mas mudam estrutura, medidas e tema do `Drawer` customizado; o custo de regressão visual é maior que o ganho.
- `SemanticsService.announce` ou apenas `Tooltip`: não cobrem o nome acessível nem a marcação de selecionado.

### 2. U13 — Layout responsivo dos gráficos do relatório mensal

- `IdentificationsViewSection.buildCharts` passa a decidir pelo `LayoutBuilder` já existente na seção, com o mesmo ponto de quebra usado no restante do relatório (`constraints.maxWidth < 850` para 1 coluna de cards). Abaixo do ponto de quebra, os gráficos ficam em `Column` (barras com ~320 px de altura e composição logo abaixo); a partir dele, mantêm a `Row` em 600 px de altura.
- `IdentificationsPercentageChart` deixa de fixar 300 px: o gráfico recebe `AspectRatio(1)` dentro de um `ConstrainedBox(maxWidth: 300)` e a legenda usa `Wrap`, permitindo que a composição ocupe a largura disponível quando empilhada.
- `IdentificationsBarChart` ganha legenda acima do gráfico com duas entradas: "Mês atual" (cor sólida da identificação) e "Mês anterior" (cor com `alpha 80`).
- Extrair `ChartLegend`/`ChartLegendItem` para `lib/common/ui/reports/charts/chart_legend.dart`, usada pelo gráfico mensal e pelas legendas dos gráficos anuais. Isso corrige de passagem a entrada repetida "Receitas" em `BalanceChart` e `IncomesExpensesEvolutionChart` (a segunda passa a "Despesas").

Alternativas consideradas:

- `Expanded` + `Flexible` sem quebra de linha: em largura estreita o gráfico de composição continuaria com 300 px e voltaria a estourar.
- Altura totalmente intrínseca (`IntrinsicHeight`): caro e frágil com `fl_chart`, que precisa de altura finita.

### 3. U13 — Alturas responsivas no relatório anual

- `SummaryChartCard` ganha `chartHeight`: com valor, o gráfico recebe `SizedBox` dessa altura e o card cresce com o conteúdo; sem valor, mantém `Expanded` para os cards de altura fixa (grade de identificações). No relatório anual o valor é 300 px abaixo de 850 px de largura e 460 px acima.
- `SummaryChartCard` também reorganiza o cabeçalho (título e legenda) em coluna abaixo de 480 px e envolve o título em `Flexible`, e as legendas usam `ChartLegend` (`Wrap`), evitando estouro horizontal em janelas estreitas.
- `YearlyIdentificationsSummaryCharts` troca `childAspectRatio: 1.5` por `mainAxisExtent: 420`, porque a proporção fixa encolhia a altura do card junto com a largura e era a origem do overflow hoje mascarado; o cabeçalho de cada grupo também ganhou `Flexible` no título e no subtítulo.
- `YearlySummaryCards` e os cards de identificação do relatório mensal passam a usar `StaggeredGridTile.fit`, dimensionando a altura pelo conteúdo — a altura fixa só era segura porque o `ignoreOverflowErrors` escondia o estouro. `SummaryValueCard` troca `Spacer` por `MainAxisAlignment.spaceBetween`, para manter o `subInfo` no rodapé com altura limitada e não quebrar com altura intrínseca; `YearlySummaryCards.buildSubInfoText` usa `Wrap`.
- As linhas de legenda e de média dos gráficos anuais (`BalanceChart` e `IncomesExpensesEvolutionChart`) passam a `Wrap`, o que também corrige o rótulo de despesas que repetia "Receitas".

### 4. C08 — Cabeçalho e seção compartilhados em `common/ui/reports/`

- `ReportHeader({required String title, required IconData icon, required Color iconColor, required List<Widget> actions})` em `lib/common/ui/reports/report_header.dart`: reproduz o bloco ícone + título e, via `LayoutBuilder`, usa `Row` com o título em `Expanded` acima do ponto de quebra e `Column` + `Wrap` para os controles abaixo dele.
- `ReportSection({required String title, required IconData icon, required Widget child})` em `lib/common/ui/reports/report_section.dart`: substitui `buildSection` do relatório mensal e é reutilizável pelo anual.
- Local escolhido porque `common/ui/reports/` já concentra os componentes partilhados pelos dois relatórios (`future_handler.dart`, cartões de resumo, gráficos). Alternativa de criar `app/accountability_reports/` foi descartada: criaria um domínio novo só para dois widgets e contrariaria a organização atual.

### 5. C16 — Remover o mascaramento de overflow

- Excluir `test/_helpers/ignore_overflow_erros.dart` e o `export` em `test/helpers.dart`.
- `yearly_summary_cards_test.dart`: remover a sobrescrita de `FlutterError.onError` e manter o viewport explícito já usado, verificando ausência de `tester.takeException()`.
- O teste mensal marcado com `skip: true` perde o `import` e a sobrescrita; continua `skip: true`, e a reativação fica registrada como pendência, não como parte desta mudança.
- Novos testes de janela estreita: `IdentificationsViewSection` e os gráficos anuais renderizados em ~420 px de largura, verificando que ambos os gráficos (e a legenda) aparecem, sem exceção de layout.

### 6. U13 — Carregar os dados apenas quando o período ou os dados mudarem

- O `FutureHandler` compara a identidade do closure `load` para decidir recarregar; como cada rebuild cria um closure novo (inclusive os disparados pelo `LayoutBuilder` interno dos resumos ao mudar a largura), qualquer redimensionamento refazia as consultas consolidadas.
- `FutureHandler` ganha um token explícito `dependency`: só recarrega quando esse valor muda. A comparação de closures sai.
- Os consumidores passam a dependência real: o serviço do mês nos resumos e nas seções do relatório mensal (o serviço é recriado ao trocar o mês e ao atualizar os dados, via `updateDateSelected`) e o ano selecionado no relatório anual.
- Alternativas descartadas: usar apenas `Key` por período (não cobre a atualização de dados dentro do mesmo período, `emitRefresh`), estabilizar os closures convertendo-os em métodos (o relatório anual recria o serviço a cada build, então a dependência real é o ano, não a identidade do closure) e comparar o estado do widget (`oldWidget` não expõe o serviço).

## Risks / Trade-offs

- [Duplicação de rótulo acessível entre `Tooltip` e `Semantics`] → `excludeFromSemantics` no `Tooltip` e um único `Semantics` com o rótulo canônico; os testes leem a árvore semântica, não a dica.
- [Testes de acessibilidade dependem da árvore semântica] → usar `tester.ensureSemantics()` e validar rótulo e seleção por item; validar dicas com `find.byTooltip`.
- [`fl_chart` exige altura finita] → manter alturas por faixa em vez de altura intrínseca; o card de gráfico continua com `Expanded` dentro de altura limitada.
- [Mudança de layout pode alterar capturas visuais] → nenhum teste compara pixels; os testes novos verificam presença dos elementos e ausência de exceção, conforme a constituição.
- [Consumidores precisam informar a dependência correta do `FutureHandler`] → cada uso passa o token que representa o período ou o serviço; sem token, o widget não recarrega sozinho e depende de remontagem (`Key`), comportamento documentado no próprio componente e coberto por teste.
- [Teste mensal permanece `skip: true`] → registrado como pendência; a remoção do mascaramento não o torna executável, pois ele não registra `AccountabilityStatsService` nem usa a API atual do serviço.
- [Gráficos com lista vazia lançam `StateError`] → o `.max` de `IdentificationsBarChart` não trata lista vazia; é um defeito observado fora do escopo desta onda e deve ser registrado no backlog.

## Migration Plan

Sem migração de dados, de banco ou de preferências. Ordem sugerida durante a aplicação: C08 (extração sem mudança de comportamento) → U13 (layout dos gráficos já sobre os componentes extraídos) → U12 (barra lateral, independente) → C16 (remoção do mascaramento depois que os layouts estiverem estáveis). Reversão é apenas de código, sem necessidade de limpeza de estado.
