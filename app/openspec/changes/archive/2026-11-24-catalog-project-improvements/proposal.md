# Proposal

## Why

O projeto acumulou, ao longo da Fase 2, um conjunto de lacunas de experiência de uso e de manutenção de código que não está registrado em um único lugar priorizado. A avaliação encontrou evidências objetivas: tema claro existente e nunca aplicado, ausência total de atalhos de teclado, exclusão de lançamentos sem confirmação ou desfazer, requisitos de filtro por data e valor sem implementação, divisões por zero que podem gerar `NaN`/`Infinity` nos relatórios, vazamento de `StreamSubscription` no relatório mensal, código e dependências sem uso, cores fixas que impedem o tema claro e 12 avisos no `flutter analyze`. Sem um catálogo com escopo e valor explícitos, a decisão sobre o que fazer primeiro fica subjetiva e o trabalho de refatoração se dispersa.

## What Changes

- Criar um catálogo versionado e priorizado de melhorias em `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md`, com 13 melhorias de experiência de uso e 16 melhorias de código.
- Cada item recebe um identificador estável (`U01`–`U13`, `C01`–`C16`), a nota de 1 a 10, o esforço estimado, a evidência que a originou (arquivo e símbolo), as dependências, a onda recomendada e o status da decisão de escopo.
- Registrar a decisão de escopo já tomada: 8 melhorias de experiência (U02, U05, U07, U09, U10, U11, U12, U13) e as 16 melhorias de código (C01–C16) foram selecionadas; U01, U03, U04, U06 e U08 foram descartadas nesta rodada.
- Registrar no documento o critério de pontuação, para que novas melhorias sejam avaliadas da mesma forma.
- Vincular o catálogo ao documento da Fase 2, tornando-o a fonte única para decisão e acompanhamento.
- Não alterar código de produção nesta mudança: o escopo selecionado define as mudanças de implementação seguintes.

## Catálogo de melhorias

### Critério de pontuação

Nota = impacto para a pessoa usuária ou para a manutenção (0–4) + frequência de uso ou alcance no código (0–3) + facilidade e baixo risco de execução (0–3), limitada ao intervalo de 1 a 10.

### Decisão de escopo

**Selecionadas (24):** U02, U05, U07, U09, U10, U11, U12, U13 e C01–C16.
**Descartadas nesta rodada (5):** U01, U03, U04, U06 e U08, com status `descartada` e motivo "não selecionada nesta rodada". Elas permanecem no catálogo para reavaliação futura, sem entrar na execução.

### Experiência de uso

| ID | Melhoria | Nota | Esforço | Evidência | Status |
| --- | --- | --- | --- | --- | --- |
| U01 | Transformar a Home em painel do mês: saldo, receitas, despesas, maiores identificações, evolução e atalhos | 9 | M | `lib/app/home/home.dart` exibe apenas saudação e cartões de backup/atualização; `docs/Produto/DRP 06 - Home` é um esqueleto | descartada |
| U02 | Seletor de aparência (claro, escuro, sistema) com persistência | 9 | M | `lib/app/themes/theme_setup.dart` registra `Obsidian Wealth Dark` como tema claro; `obsidian_wealth_light_theme.dart` nunca é aplicado; não há seção de aparência em Configurações | selecionada |
| U03 | Atalhos de teclado globais: nova entrada, foco na busca, navegação do menu, salvar/cancelar edição | 8 | M | Nenhum uso de `Shortcuts`, `CallbackShortcuts` ou `SingleActivator` em `lib`; a única navegação por teclado está no seletor de identificação | descartada |
| U04 | Desfazer exclusão de lançamento (ação reversível) e confirmação em exclusões | 8 | M | `lib/app/accountability_page/accountability_page.dart` envia `DeleteAccountabilityEntry` direto do botão da linha, sem confirmação nem undo | descartada |
| U05 | Filtros de período e de faixa de valor na tabela, com contagem de resultados | 8 | G | `RF 01.02.02 - Filtro por data` e `RF 01.02.03 - Filtro por valor` estão sem conclusão; a página só oferece busca textual e chips por identificação | selecionada |
| U06 | Busca com debounce, botão de limpar e termo preservado ao voltar | 7 | P | `accountability_page.dart` dispara `SearchAccountabilityEntries` a cada tecla; não há debounce no bloc nem botão de limpar; o termo se perde ao navegar | descartada |
| U07 | Manter mês e ano selecionados ao navegar entre páginas | 7 | P | `lib/app/accountability_monthly_report/monthly_report.dart` sempre seleciona `result.last`; `yearly_report.dart` usa `snapshot.data!.first.year` quando não há seleção | selecionada |
| U08 | Exportar a visão filtrada (CSV ou área de transferência) | 7 | M | Nenhuma referência a `Clipboard` ou exportação em `lib`; a dependência `csv` está declarada e sem uso | descartada |
| U09 | Importação com progresso, resumo de resultado e falha visível | 7 | M | `accountability_page.dart` aguarda `import()` sem indicador nem `try/catch`; `SQLiteAccountabilityImportService.save()` grava lançamento a lançamento, sem transação | selecionada |
| U10 | Exibir e permitir ajustar a identificação prevista no formulário de nova entrada | 7 | M | `accountability_page.dart` aplica a predição silenciosamente e o formulário não mostra nem permite trocar a identificação | selecionada |
| U11 | Estados vazios e de erro com ação de recuperação | 6 | P | `accountability_page.dart` mostra texto puro em estado vazio; `common/ui/reports/future_handler.dart` exibe `Erro: <exceção>` sem opção de tentar novamente | selecionada |
| U12 | Sidebar colapsada com tooltips, rótulos acessíveis e estado persistido | 6 | P | `closed_sidebar.dart` exibe o rótulo "N" no lugar da seção "Navegação" e os ícones não têm `Tooltip`; `isOpen` sempre reinicia aberto; cores fixas `Color(0xFF262A34)` | selecionada |
| U13 | Gráficos responsivos, com legenda e leitura em janelas estreitas | 6 | M | `identifications_view_section.dart` monta dois gráficos em `Row` fixa de 600 px; testes usam `test/_helpers/ignore_overflow_erros.dart` para ignorar overflow | selecionada |

### Código

| ID | Melhoria | Nota | Esforço | Evidência | Status |
| --- | --- | --- | --- | --- | --- |
| C01 | Remover código morto e dependências sem uso | 9 | P | `common/lib/switch.dart`, `common/ui/text_shimmer.dart`, `common/ui/reports/consolidated_value_card.dart` (com `values_relation_indicator`, `values_relation_text`, `icon_highlight`, `centered_icon`), `values_comparison_small.dart`, `text_ballon.dart` (só teste), `month_selector.dart` duplicado e a função legada `futureHandler`; dependências `csv`, `cupertino_icons` e `shimmer` sem uso efetivo | selecionada |
| C02 | Impedir divisões por zero nos relatórios (`NaN`/`Infinity`) | 9 | P | `month_summary_card.dart` usa `balance / incomes` em `LinearProgressIndicator.value`; `current_month_report.service.dart` calcula `total / totalExpenses` e `total / totalIncomes` | selecionada |
| C03 | Tratar falhas de repositório no `AccountabilityBloc` e informar na interface | 9 | M | Os handlers de busca e de criação, edição e exclusão chamam o repositório sem `try/catch`; os estados não têm falha nem mensagem de erro | selecionada |
| C04 | Substituir cores fixas por tokens do tema, sem `GetIt` dentro de widgets | 9 | M | `Color(0xFF262A34)` em sidebars e cabeçalhos de relatório; `Color(0xFF0A0E17)` e `0xFF1C1F29` em `accountability_table.dart` e `accountability_table_row.dart`; `Colors.grey.shade800` em `identifications_view_section.dart`; `base_toast.dart` e `month_summary_card.dart` buscam cores via `GetIt` | selecionada |
| C05 | Corrigir o ciclo de vida do relatório mensal (`StreamSubscription` e serviço) | 8 | P | `monthly_report.dart` mantém `_subscription` sem uso efetivo (aviso do analisador), cria nova assinatura a cada troca de mês e não tem `dispose`; `CurrentMonthReportService.dispose()` nunca é chamado | selecionada |
| C06 | Remover `dynamic` da tabela, dos relatórios e dos temas de comparação | 8 | G | `AccountabilityTable` recebe `List<dynamic>` e `onUpdate(dynamic)`; `AccountabilityTableRow.entry` é `dynamic`; `values_comparison.dart` retorna `Map` em `dynamic`; 69 ocorrências de `dynamic` em `lib` | selecionada |
| C07 | Dividir `identification_edit_modal.dart` (988 linhas) em componentes coesos | 7 | M | O arquivo acumula formulário, seletor de cor, catálogo de ícones, validações e diálogo de exclusão, contrariando "um conceito por arquivo" da constituição | selecionada |
| C08 | Extrair o cabeçalho e as seções repetidas dos relatórios | 7 | P | `monthly_report.dart` e `yearly_report.dart` repetem o bloco de ícone e título; `buildSection` existe só no relatório mensal | selecionada |
| C09 | Tipar e melhorar o `FutureHandler` (erro com nova tentativa) | 7 | P | `future_handler.dart` expõe função e widget, usa `Future<dynamic>`, chama `setState` em `initState` e trata `hideLoading` como contorno | selecionada |
| C10 | Criar camada de preferências persistidas (tema, sidebar, mês, ano) | 8 | M | Não há persistência local de preferências; `ThemeManager` guarda tudo em memória e o estado de navegação reinicia a cada montagem | selecionada |
| C11 | Corrigir caminho de banco fixo no Linux e `catch` vazio | 7 | P | `lib/integrations/sqlite/db_provider.dart` usa `/var/home/bruno-note/Documentos` e engole a falha de `getApplicationDocumentsDirectory()` com `catch (e) {}` | selecionada |
| C12 | Inicialização resiliente e ciclo de vida do servidor de predição | 7 | M | `main.dart` não trata falha de `setup()`/`initDatabase()`; `EmbeddedPredictServer.init()` é `void async` sem estado de saúde e `terminate()` encerra por nome de processo, não por PID | selecionada |
| C13 | Tipar e validar o retorno do serviço de predição | 7 | P | `EmbeddedPredictService` usa `dynamic result` e `on Exception`, que não captura `TypeError` de payload inesperado nem campos ausentes | selecionada |
| C14 | Zerar os avisos do `flutter analyze` e verificar análise no empacotamento | 8 | P | Baseline atual: 12 problemas (1 campo não usado, 9 `withOpacity` obsoletos, 1 `catch` vazio, 1 API experimental); `build.ps1` roda testes, mas não análise | selecionada |
| C15 | Corrigir nomenclatura e idioma do código | 5 | P | `SQLiteAccontabilityMonthService` (erro de digitação), arquivo `accountability_identification_predition_service.dart` (`predition`) e comentários em português, contrariando a constituição | selecionada |
| C16 | Fortalecer testes: cobrir falhas e remover mascaramento de overflow | 6 | M | Não há testes de falha de repositório no `AccountabilityBloc`; `ignore_overflow_erros.dart` esconde problemas de layout em vez de corrigi-los | selecionada |

### Ondas recomendadas

As ondas consideram apenas os itens selecionados; as melhorias descartadas não entram na execução.

- **Onda 1 – estabilização (baixo risco, alto retorno):** C01, C02, C05, C11, C12, C13, C14, C15.
- **Onda 2 – fundação:** C03, C04, C06, C07, C09, C10, C16.
- **Onda 3 – experiência:** U02, U05, U07, U09, U10, U11.
- **Onda 4 – polimento:** U12, U13, C08.

### Dependências relevantes

- U02 depende de C04 e C10.
- U07 e U12 dependem de C10.
- U11 depende de C03 e C09.
- U13 depende de C04 para as cores dos gráficos.
- U05 depende de alteração de consulta e estado; deve ser feita junto de C03 e C06.

## Capabilities

### New Capabilities

Nenhuma. A mudança produz documentação de planejamento e não altera comportamento observável do sistema; por isso o `.openspec.yaml` declara `skip_specs: true`, conforme a orientação de não inventar requisitos para mudanças apenas documentais.

### Modified Capabilities

Nenhuma. Os itens do catálogo que alterarem comportamento serão propostos em mudanças próprias, com os deltas de especificação correspondentes.

## Impact

- `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md`: novo catálogo priorizado, em português, com critério, itens, dependências e ondas.
- `docs/Projeto/Fase 2 - Re-design/Fase 2 - Re-design.md`: link para o catálogo na seção de escopo.
- Nenhuma dependência nova, nenhuma alteração em `lib/` e nenhuma migração de dados.
- A seleção dos itens pelo responsável define quais mudanças de implementação serão propostas em seguida.
