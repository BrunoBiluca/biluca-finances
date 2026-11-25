# Design

## Context

Ver `proposal.md` — Why. Onda 3 ("experiência") do catálogo, executada após a Onda 2. A fundação já entregue disponibiliza: `PreferencesService` em `lib/core/preferences/` (chaves de `ThemeMode`, `sidebarCollapsed`, `selectedMonth` e `selectedYear`), tokens `AppColors` como `ThemeExtension`, `FutureHandler<T>` genérico com nova tentativa, e o `AccountabilityBloc` com estado de falha e evento de retry. A constituição exige código em inglês, testes unitários para regras de negócio, agrupamento por funcionalidade e `common` apenas para código compartilhado. Os itens desta onda (U02, U05, U07, U09, U10, U11) são as primeiras melhorias de experiência sobre essa fundação.

## Goals / Non-Goals

**Goals:**

- Adicionar o seletor de aparência e aplicar o tema em tempo de execução, corrigindo o tema claro (U02).
- Adicionar filtros de período e de faixa de valor com contagem de resultados na Prestação de Contas (U05).
- Restaurar e persistir o mês/ano selecionados nos relatórios (U07).
- Tornar a importação visível: progresso, falha com nova tentativa e salvamento transacional (U09).
- Exibir e permitir ajustar a identificação prevista no formulário de nova entrada (U10).
- Substituir os estados vazios por estados com ação de recuperação (U11).

**Non-Goals:**

- Não implementar a Home como painel do mês (U01), atalhos de teclado (U03), desfazer exclusão (U04), busca com debounce (U06) nem exportação (U08): itens descartados.
- Não implementar tooltips nem rótulos acessíveis da sidebar (restante do U12, Onda 4) nem a responsividade dos gráficos (U13). A **persistência** do estado recolhido da sidebar, que pertence ao U12, foi antecipada nesta mudança porque a capability `app-preferences` já a exige desde a Onda 2 e a fiação é pequena.
- Não alterar o schema do banco de dados nem o contrato de publicação.
- Não alterar as regras de importação, de categorização nem de duplicatas existentes.

## Decisions

### U02 — Seletor de aparência com aplicação imediata
- **Corrigir o tema claro:** em `theme_setup.dart`, `setupThemes()` passa a chamar `setLight("Obsidian Wealth Light")` em vez de `setLight("Obsidian Wealth Dark")`, aplicando o `ObsidianWealthLightTheme` já existente.
- **Aplicar o modo em tempo de execução:** criar `ThemeModeController` (um `ValueNotifier<ThemeMode>`) em `lib/app/themes/`, registrado como singleton no `di_container.dart` e inicializado com `PreferencesService.themeMode`. `App` deixa de receber um `themeMode` fixo e passa a observar o controlador.
- **Não recriar o roteador a cada troca:** `App` vira `StatefulWidget` e mantém um único `GoRouter` (criado uma vez via `routes()`); a troca de tema reconstrói apenas o `MaterialApp.router` com o mesmo `routerConfig`, preservando a navegação atual.
- **Seção em Configurações:** criar `AppearanceSection` em `lib/app/settings/widgets/`, com `SegmentedButton<ThemeMode>` (Sistema, Claro, Escuro) que atualiza o controlador e persiste via `PreferencesService.setThemeMode`.
- Justificativa: um `ValueNotifier` é suficiente para um valor reativo e evita a sobrecarga de um Bloc; o ponto sensível é não recriar o `GoRouter`, pois `routes()` retorna uma instância nova e reconstruí-la perderia o estado de navegação.
- Alternativa considerada: usar `ThemeModeBloc` — rejeitada, pois o ganho de reatividade não justifica o acoplamento adicional para uma preferência única.

### U12 (antecipado) — Persistir o estado recolhido da sidebar

- **Restauração:** `Sidebar` inicializa `isOpen` a partir de `PreferencesService.sidebarCollapsed` (padrão aberta) e grava a nova preferência ao recolher ou expandir.
- **Escopo:** apenas a persistência foi antecipada da Onda 4; tooltips e rótulos acessíveis continuam no U12 original e o item permanece `selecionada` no catálogo.
- Justificativa: a capability `app-preferences` já exige a restauração da barra lateral desde a Onda 2, e a fiação cabe em poucas linhas sobre a camada existente.
- Alternativa considerada: manter a preferência em memória até a Onda 4 — rejeitada, pois a interface já reinicia sempre aberta e o requisito de restauração não estaria atendido.

### U05 — Filtros de período e de faixa de valor com contagem

- **Modelo de filtro:** adicionar um objeto de critérios tipado (ex.: `AccountabilityEntryFilter` com `startDate`, `endDate`, `minValue`, `maxValue`) em `lib/core/accountability/models/`, evitando crescer a lista de parâmetros de `searchEntries` indefinidamente.
- **Evento e estado:** `SearchAccountabilityEntries` passa a carregar os critérios de filtro; `AccountabilityState` ganha os mesmos campos e um `resultCount`.
- **Repositório:** estender `AccountabilityRepo.searchEntries` (e a implementação SQLite) para aceitar os critérios e adicionar um `countEntries` com a mesma cláusula `WHERE` sem `limit`/`offset`; `SQLiteAccountabilityRepo` traduz os filtros para `a.createdAt >=/<=` e `a.value >=/<=`.
- **Contagem:** o bloc consulta a contagem junto com a primeira página e exibe "N resultados" acima da tabela, refletindo busca, categoria, período e valor.
- **Interface:** em `_buildSearchAndFilters`, adicionar campos de data inicial/final e de valor mínimo/máximo (reaproveitando `DatePickerField` e `RealInputFormatter`), com ação de limpar.
- Justificativa: concentrar os critérios em um objeto preserva a assinatura do repositório e a `equatable` dos eventos/estados; a contagem exige uma consulta própria porque os resultados são paginados.
- Alternativa considerada: calcular a contagem no cliente a partir dos resultados paginados — rejeitada, pois subestima o total quando há mais de uma página.

### U07 — Manter mês e ano selecionados

- **Relatório mensal:** após carregar `availableMonths`, `fillMonths()` seleciona o mês de `PreferencesService.selectedMonth` quando ele existe na lista; caso contrário, mantém o comportamento atual (`result.last`). A alteração pelo `MonthSelector` persiste o mês via `setSelectedMonth`.
- **Relatório anual:** após carregar os anos, `currentYear` é inicializado a partir de `PreferencesService.selectedYear` quando o valor existe na lista; caso contrário, mantém `snapshot.data!.first.year` ("Últimos 12 meses"). A alteração pelo `YearSelector` persiste via `setSelectedYear`.
- **Persistência no ponto de interação:** gravar apenas quando a pessoa altera a seleção no seletor, não no refresh interno do serviço mensal (`onChange`), para evitar escritas redundantes.
- Justificativa: as chaves e o serviço já existem na Onda 2; aqui só se faz a fiação nas telas, que hoje reiniciam a seleção a cada montagem.
- Alternativa considerada: manter a seleção apenas em memória sem persistir — rejeitada, pois o requisito de restauração entre sessões já é da capability `app-preferences`.

### U09 — Importação com progresso, falha visível e transação

- **Progresso:** em `importEntries`, exibir um diálogo modal de progresso (indeterminado) enquanto `importService.import(file)` executa, e fechá-lo antes de abrir a conferência.
- **Falha visível:** envolver `import()` em `try/catch`; em caso de falha, fechar o progresso e apresentar uma mensagem de erro com ação de tentar novamente (que re-executa `import()` com o mesmo arquivo), sem abrir a conferência.
- **Salvamento transacional:** adicionar `Future<void> addAll(List<AccountabilityEntryRequest>)` ao `AccountabilityRepo`, implementado no `SQLiteAccountabilityRepo` com `db.transaction`; `SQLiteAccountabilityImportService.save()` passa a chamar `repo.addAll(entries)`. A conferência também envolve `save()` em `try/catch` e apresenta o erro no modal sem fechá-lo.
- Justificativa: o serviço de importação depende da abstração `AccountabilityRepo`, então a transação pertence ao repositório; gravar entrada a entrada deixa importações parciais em caso de falha.
- Alternativa considerada: injetar o `Database` no serviço de importação — rejeitada, pois acopla o serviço ao SQLite e fura a abstração do `core`.

### U10 — Identificação prevista no formulário de nova entrada

- **Previsão no formulário:** `AccountabilityEntryForm` passa a executar `AccountabilityIdentificationPredictionService.predict(entries: [request])` quando descrição e valor estão preenchidos (na ação de salvar), e exibe a identificação prevista como um selo compacto.
- **Ajuste:** o selo permite abrir o `AccountabilityIdentificationSelector` (já existente em `lib/app/accountability_table/widgets/`) com a lista de identificações obtida via `AccountabilityRepo.getIdentifications()`, permitindo trocar a identificação antes de salvar.
- **Retorno do formulário:** o `AccountabilityEntryRequest` retornado já contém a identificação escolhida ou prevista; a chamada silenciosa de predição que hoje ocorre em `AccountabilityPage.newEntry` é removida, pois a responsabilidade migra para o formulário.
- Justificativa: a predição passa a ser visível e ajustável antes da confirmação, atendendo ao U10; o formulário continua retornando um request compatível com o fluxo atual de `AddAccountabilityEntry`.
- Alternativa considerada: manter a predição após o formulário e apenas exibir um aviso — rejeitada, pois não permite ajustar a identificação antes de salvar.

### U11 — Estados vazios com ação de recuperação

- **Estados vazios:** em `_buildEntries`, substituir o texto puro por um estado ilustrado com mensagem e ação: "Nova entrada" quando não há lançamentos e não há filtros, e "Limpar filtros" quando há critérios ativos sem correspondência. A ação de limpar reenvia `SearchAccountabilityEntries` sem filtros.
- **Erro:** a mensagem e a ação de nova tentativa do erro já existem (C03) e são preservadas; o `FutureHandler` dos relatórios já apresenta nova tentativa (C09).
- Justificativa: o erro com recuperação já foi entregue na Onda 2; o que resta é transformar os vazios em orientações acionáveis.
- Alternativa considerada: apenas melhorar o texto do estado vazio — rejeitada, pois não oferece a ação de recuperação exigida.

## Risks / Trade-offs

- **U02 troca de tema em tempo de execução pode resetar a navegação** se o `GoRouter` for recriado → manter uma única instância do roteador em `App` e reconstruir somente o `MaterialApp.router`.
- **U02 altera a aparência de várias telas** ao aplicar o tema claro → validar com os testes de widget de relatórios, sidebar e home e comparar visualmente claro/escuro.
- **U05 muda a assinatura de `searchEntries` e dos estados** e afeta os testes de bloc e do repositório SQLite → atualizar `mock_accountability_repo.dart`, `bloc_test.dart`, `accountability_repo_test.dart` e `accountability_page_test.dart`.
- **U05 contagem exige uma consulta adicional** em cada busca → mantê-la na mesma chamada de primeira página e evitar contagens redundantes ao paginar.
- **U07 persiste seleções** e pode conflitar com o valor padrão quando a seleção salva deixa de existir → tratar o valor salvo como opcional e cair para o padrão quando não estiver na lista.
- **U09 transação em `addAll`** muda o caminho de gravação usado pela conferência e pelos testes de importação → atualizar `import_service_test.dart` e `import_verification_test.dart`; `save()` deve continuar respeitando o `cancelDuplication`.
- **U10 move a predição para o formulário** e altera o teste de nova entrada → atualizar `accountability_new_entry_form_test.dart` e cobrir a troca de identificação.

## Migration Plan

Não se aplica: não há migração de dados nem alteração de schema. O `addAll` transacional preserva o comportamento externo de `save()` (todas as novas entradas gravadas), e a reversão é reverter o commit. A fiação do U07 e do U02 usa preferências já existentes; valores ausentes continuam caindo nos padrões atuais.

## Open Questions

Nenhuma pendência que altere o escopo, as specs ou a divisão de tarefas.
