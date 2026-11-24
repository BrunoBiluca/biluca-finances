# Melhorias priorizadas

> [!important] Resumo
> Catálogo das melhorias identificadas na avaliação do aplicativo em **24/11/2026**: **29 itens** catalogados, sendo **24 selecionados** (8 de experiência de uso e 16 de código) e **5 descartados** nesta rodada. Este documento é a fonte única para decidir, acompanhar e registrar a evolução de cada melhoria.

## Contexto da avaliação

A avaliação percorreu `lib/`, `test/` e `docs/`, com apoio de `flutter analyze` (baseline: 12 problemas) e leitura dirigida das telas, dos blocs, dos serviços e das integrações. As evidências usam **arquivo e símbolo**, e não número de linha, para continuarem rastreáveis após refatorações. Caminhos de código são relativos à pasta `app/`.

Este catálogo complementa os documentos de produto (`DRP`/`RF`): ele não substitui requisitos, apenas prioriza e registra decisões técnicas com impacto observável.

## Critério de pontuação

**Nota = impacto (0–4) + alcance (0–3) + facilidade (0–3)**, limitada ao intervalo de **1 a 10**.

| Critério | O que mede |
| --- | --- |
| Impacto (0–4) | Quanto a melhoria melhora a experiência da pessoa usuária ou reduz risco de defeito e custo de manutenção |
| Alcance (0–3) | Frequência de uso da funcionalidade ou quantidade de código e telas afetadas |
| Facilidade (0–3) | Baixo risco e baixo esforço de execução, considerando dependências e testes |

**Esforço estimado:** `P` (pequeno, até uma sessão), `M` (médio, algumas sessões) e `G` (grande, exige refatoração estrutural).

A nota pode ser revista quando o contexto mudar; a justificativa da revisão deve ser registrada no histórico deste documento.

## Como usar este catálogo

### Status

Cada item tem um único status, com as seguintes transições:

1. `proposta` → `selecionada`: a pessoa responsável decide executar o item.
2. `selecionada` → `em implementação`: o item entra em uma mudança OpenSpec em andamento.
3. `em implementação` → `implementada`: a mudança de implementação foi concluída e arquivada.
4. `proposta` ou `selecionada` → `descartada`: a pessoa responsável decide não executar o item nesta rodada, registrando o motivo.

Itens `descartada` permanecem no documento para reavaliação futura e **não** entram nas ondas de execução.

### Identificadores estáveis

Os IDs usam prefixo de escopo (`U` para experiência de uso, `C` para código) e são **estáveis**: não são renumerados nem reutilizados, mesmo que o item seja descartado ou implementado. Um item novo recebe o próximo número livre do seu prefixo.

### Da seleção à implementação

- Uma seleção vira uma **mudança OpenSpec**, agrupada por onda, e o `proposal.md` da mudança cita os IDs deste catálogo.
- Requisitos de comportamento pertencem ao `spec.md` da mudança de implementação, não a este catálogo.
- Ao arquivar a mudança de implementação, os itens correspondentes passam para `implementada` e o histórico deste documento é atualizado.
- Itens recusados de forma definitiva devem ser movidos para o [[Backlog desqualificado]], com o motivo.

## Decisão de escopo (24/11/2026)

**Selecionadas (24):**

- Experiência de uso: U02, U05, U07, U09, U10, U11, U12 e U13.
- Código: C01 a C16.

**Descartadas nesta rodada (5):**

- U01, U03, U04, U06 e U08 — motivo: "não selecionada nesta rodada".

## Experiência de uso

| ID | Melhoria | Nota | Esforço | Evidência | Dependências | Status |
| --- | --- | --- | --- | --- | --- | --- |
| U01 | Transformar a Home em painel do mês: saldo, receitas, despesas, maiores identificações, evolução e atalhos | 9 | M | `lib/app/home/home.dart` exibe apenas saudação e cartões de backup/atualização; `docs/Produto/DRP 06 - Home` é um esqueleto | — | descartada |
| U02 | Seletor de aparência (claro, escuro, sistema) com persistência | 9 | M | `lib/app/themes/theme_setup.dart` registra `Obsidian Wealth Dark` como tema claro; `obsidian_wealth_light_theme.dart` nunca é aplicado; não há seção de aparência em Configurações | C04, C10 | selecionada |
| U03 | Atalhos de teclado globais: nova entrada, foco na busca, navegação do menu, salvar/cancelar edição | 8 | M | Nenhum uso de `Shortcuts`, `CallbackShortcuts` ou `SingleActivator` em `lib`; a única navegação por teclado está no seletor de identificação | — | descartada |
| U04 | Desfazer exclusão de lançamento (ação reversível) e confirmação em exclusões | 8 | M | `lib/app/accountability_page/accountability_page.dart` envia `DeleteAccountabilityEntry` direto do botão da linha, sem confirmação nem undo | — | descartada |
| U05 | Filtros de período e de faixa de valor na tabela, com contagem de resultados | 8 | G | `RF 01.02.02 - Filtro por data` e `RF 01.02.03 - Filtro por valor` estão sem conclusão; a página só oferece busca textual e chips por identificação | C03, C06 (executar junto) | selecionada |
| U06 | Busca com debounce, botão de limpar e termo preservado ao voltar | 7 | P | `accountability_page.dart` dispara `SearchAccountabilityEntries` a cada tecla; não há debounce no bloc nem botão de limpar; o termo se perde ao navegar | — | descartada |
| U07 | Manter mês e ano selecionados ao navegar entre páginas | 7 | P | `lib/app/accountability_monthly_report/monthly_report.dart` sempre seleciona `result.last`; `yearly_report.dart` usa `snapshot.data!.first.year` quando não há seleção | C10 | selecionada |
| U08 | Exportar a visão filtrada (CSV ou área de transferência) | 7 | M | Nenhuma referência a `Clipboard` ou exportação em `lib`; a dependência `csv` está declarada e sem uso | — | descartada |
| U09 | Importação com progresso, resumo de resultado e falha visível | 7 | M | `accountability_page.dart` aguarda `import()` sem indicador nem `try/catch`; `SQLiteAccountabilityImportService.save()` grava lançamento a lançamento, sem transação | — | selecionada |
| U10 | Exibir e permitir ajustar a identificação prevista no formulário de nova entrada | 7 | M | `accountability_page.dart` aplica a predição silenciosamente e o formulário não mostra nem permite trocar a identificação | — | selecionada |
| U11 | Estados vazios e de erro com ação de recuperação | 6 | P | `accountability_page.dart` mostra texto puro em estado vazio; `common/ui/reports/future_handler.dart` exibe `Erro: <exceção>` sem opção de tentar novamente | C03, C09 | selecionada |
| U12 | Sidebar colapsada com tooltips, rótulos acessíveis e estado persistido | 6 | P | `closed_sidebar.dart` exibe o rótulo "N" no lugar da seção "Navegação" e os ícones não têm `Tooltip`; `isOpen` sempre reinicia aberto; cores fixas `Color(0xFF262A34)` | C10 | selecionada |
| U13 | Gráficos responsivos, com legenda e leitura em janelas estreitas | 6 | M | `identifications_view_section.dart` monta dois gráficos em `Row` fixa de 600 px; testes usam `test/_helpers/ignore_overflow_erros.dart` para ignorar overflow | C04 | selecionada |

## Código

| ID | Melhoria | Nota | Esforço | Evidência | Dependências | Status |
| --- | --- | --- | --- | --- | --- | --- |
| C01 | Remover código morto e dependências sem uso | 9 | P | `common/lib/switch.dart`, `common/ui/text_shimmer.dart`, `common/ui/reports/consolidated_value_card.dart` (com `values_relation_indicator`, `values_relation_text`, `icon_highlight`, `centered_icon`), `values_comparison_small.dart`, `text_ballon.dart` (só teste), `month_selector.dart` duplicado e a função legada `futureHandler`; dependências `csv`, `cupertino_icons` e `shimmer` sem uso efetivo | — | selecionada |
| C02 | Impedir divisões por zero nos relatórios (`NaN`/`Infinity`) | 9 | P | `month_summary_card.dart` usa `balance / incomes` em `LinearProgressIndicator.value`; `current_month_report.service.dart` calcula `total / totalExpenses` e `total / totalIncomes` | — | selecionada |
| C03 | Tratar falhas de repositório no `AccountabilityBloc` e informar na interface | 9 | M | Os handlers de busca e de criação, edição e exclusão chamam o repositório sem `try/catch`; os estados não têm falha nem mensagem de erro | — | selecionada |
| C04 | Substituir cores fixas por tokens do tema, sem `GetIt` dentro de widgets | 9 | M | `Color(0xFF262A34)` em sidebars e cabeçalhos de relatório; `Color(0xFF0A0E17)` e `0xFF1C1F29` em `accountability_table.dart` e `accountability_table_row.dart`; `Colors.grey.shade800` em `identifications_view_section.dart`; `base_toast.dart` e `month_summary_card.dart` buscam cores via `GetIt` | — | selecionada |
| C05 | Corrigir o ciclo de vida do relatório mensal (`StreamSubscription` e serviço) | 8 | P | `monthly_report.dart` mantém `_subscription` sem uso efetivo (aviso do analisador), cria nova assinatura a cada troca de mês e não tem `dispose`; `CurrentMonthReportService.dispose()` nunca é chamado | — | selecionada |
| C06 | Remover `dynamic` da tabela, dos relatórios e dos temas de comparação | 8 | G | `AccountabilityTable` recebe `List<dynamic>` e `onUpdate(dynamic)`; `AccountabilityTableRow.entry` é `dynamic`; `values_comparison.dart` retorna `Map` em `dynamic`; 69 ocorrências de `dynamic` em `lib` | — | selecionada |
| C07 | Dividir `identification_edit_modal.dart` (988 linhas) em componentes coesos | 7 | M | O arquivo acumula formulário, seletor de cor, catálogo de ícones, validações e diálogo de exclusão, contrariando "um conceito por arquivo" da constituição | — | selecionada |
| C08 | Extrair o cabeçalho e as seções repetidas dos relatórios | 7 | P | `monthly_report.dart` e `yearly_report.dart` repetem o bloco de ícone e título; `buildSection` existe só no relatório mensal | — | selecionada |
| C09 | Tipar e melhorar o `FutureHandler` (erro com nova tentativa) | 7 | P | `future_handler.dart` expõe função e widget, usa `Future<dynamic>`, chama `setState` em `initState` e trata `hideLoading` como contorno | — | selecionada |
| C10 | Criar camada de preferências persistidas (tema, sidebar, mês, ano) | 8 | M | Não há persistência local de preferências; `ThemeManager` guarda tudo em memória e o estado de navegação reinicia a cada montagem | — | selecionada |
| C11 | Corrigir caminho de banco fixo no Linux e `catch` vazio | 7 | P | `lib/integrations/sqlite/db_provider.dart` usa `/var/home/bruno-note/Documentos` e engole a falha de `getApplicationDocumentsDirectory()` com `catch (e) {}` | — | selecionada |
| C12 | Inicialização resiliente e ciclo de vida do servidor de predição | 7 | M | `main.dart` não trata falha de `setup()`/`initDatabase()`; `EmbeddedPredictServer.init()` é `void async` sem estado de saúde e `terminate()` encerra por nome de processo, não por PID | — | selecionada |
| C13 | Tipar e validar o retorno do serviço de predição | 7 | P | `EmbeddedPredictService` usa `dynamic result` e `on Exception`, que não captura `TypeError` de payload inesperado nem campos ausentes | — | selecionada |
| C14 | Zerar os avisos do `flutter analyze` e verificar análise no empacotamento | 8 | P | Baseline atual: 12 problemas (1 campo não usado, 9 `withOpacity` obsoletos, 1 `catch` vazio, 1 API experimental); `build.ps1` roda testes, mas não análise | — | selecionada |
| C15 | Corrigir nomenclatura e idioma do código | 5 | P | `SQLiteAccontabilityMonthService` (erro de digitação), arquivo `accountability_identification_predition_service.dart` (`predition`) e comentários em português, contrariando a constituição | — | selecionada |
| C16 | Fortalecer testes: cobrir falhas e remover mascaramento de overflow | 6 | M | Não há testes de falha de repositório no `AccountabilityBloc`; `ignore_overflow_erros.dart` esconde problemas de layout em vez de corrigi-los | U13 (parte de overflow) | selecionada |

## Ondas recomendadas

As ondas consideram apenas os itens selecionados; as melhorias descartadas não entram na execução.

| Onda | Itens | Foco |
| --- | --- | --- |
| 1 – estabilização | C01, C02, C05, C11, C12, C13, C14, C15 | Correções objetivas, remoção de código morto e falhas silenciosas, com baixo risco |
| 2 – fundação | C03, C04, C06, C07, C09, C10, C16 | Tratamento de erro, tipagem, tokens de tema, preferências e testes |
| 3 – experiência | U02, U05, U07, U09, U10, U11 | Aparência, filtros e retorno visual, apoiados na fundação da Onda 2 |
| 4 – polimento | U12, U13, C08 | Acessibilidade da navegação, responsividade dos gráficos e reutilização dos relatórios |

> [!note] C16 entre ondas
> A parte de testes de falha do C16 pode ser feita na Onda 2. A remoção do mascaramento de overflow depende do U13 e deve acompanhar a Onda 4; o item só passa para `implementada` quando as duas partes estiverem concluídas.

## Dependências

- **U02** depende de **C04** (tokens de tema) e **C10** (preferências persistidas).
- **U05** deve ser executada junto de **C03** (erros no bloc) e **C06** (tipagem), pois altera consulta, estado e tabela.
- **U07** depende de **C10**.
- **U11** depende de **C03** e **C09** (erro com nova tentativa).
- **U12** depende de **C10**.
- **U13** depende de **C04** para as cores dos gráficos.
- **C16** depende de **U13** para remover o mascaramento de overflow.

Nenhuma dependência cita item inexistente ou descartado.

## Histórico

- **24/11/2026** — Avaliação inicial do aplicativo, catalogação de 29 melhorias e seleção de escopo: 24 itens mantidos (U02, U05, U07, U09, U10, U11, U12, U13 e C01–C16) e 5 descartados nesta rodada (U01, U03, U04, U06 e U08).
