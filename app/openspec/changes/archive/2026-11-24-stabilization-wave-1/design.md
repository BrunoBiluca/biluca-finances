# Design

## Context

Ver `proposal.md` — Why. Onda 1 do catálogo, executada antes das ondas que dependem dela (C03/C04/C06/C10 sustentam as melhorias de UX). As correções são pontuais, sem mudança de schema nem de contrato de publicação. Baseline do `flutter analyze`: 12 problemas (1 campo não usado, 9 `withOpacity` obsoletos, 1 `catch` vazio e 1 API experimental). A constituição exige código em inglês e agrupamento por funcionalidade; a remoção de código morto segue o princípio de manter `common` apenas para código reutilizado por mais de uma funcionalidade.

## Goals / Non-Goals

**Goals:**

- Eliminar código e dependências sem uso, sem alterar comportamento de funcionalidades vivas.
- Garantir que nenhum relatório exiba `NaN`/`Infinity`.
- Eliminar vazamento de assinatura e serviço não descartado no relatório mensal.
- Tornar a inicialização e o servidor de predição previsíveis diante de falhas.
- Zerar `flutter analyze` e passar a verificar análise no empacotamento.
- Corrigir nomenclatura e idioma sem mudar o contrato público dos serviços.

**Non-Goals:**

- Não tratar falhas de repositório no `AccountabilityBloc` (C03, Onda 2).
- Não substituir cores fixas por tokens do tema (C04, Onda 2).
- Não remover `dynamic` da tabela e dos relatórios (C06, Onda 2).
- Não alterar a apresentação visual dos relatórios além da correção de valores inválidos.

## Decisions

### C01 — Código morto e dependências

- **Remover** os arquivos sem importadores: `common/ui/text_shimmer.dart`, `common/ui/text_ballon.dart`, `common/ui/reports/consolidated_value_card.dart`, `values_relation_indicator.dart`, `values_relation_text.dart`, `icon_highlight.dart`, `centered_icon.dart`, `values_comparison_small.dart`, `report_tooltip.dart`, `common/ui/reports/month_selector.dart` e o teste `test/common/ui/text_ballon_test.dart`.
- **Remover** a função top-level `futureHandler` de `common/ui/reports/future_handler.dart`, mantendo o widget `FutureHandler` (API viva usada pelos relatórios).
- **Manter** `values_comparison.dart` (usada por `values_comparison_full_text.dart`), `common/lib/switch.dart` (usado por `values_relation.dart`), `font_awesome_flutter`, `flutter_colorpicker`, `flutter_staggered_grid_view` e `data_table_2`.
- **Remover dependências** `csv`, `cupertino_icons` e `shimmer` de `pubspec.yaml`; `shimmer` fica sem uso após excluir `text_shimmer.dart`.
- Justificativa: cada arquivo foi confirmado sem importadores (contagem zero) ou referenciado apenas por outro arquivo morto. A remoção é reversível via git.
- Alternativa considerada: manter `text_ballon.dart` por ter teste próprio — rejeitada, pois o componente não é usado por nenhuma tela e a constituição manda manter `common` enxuto.

### C02 — Divisões por zero

- **Centralizar** uma função pura de proporção segura em `common/lib/` (por exemplo, `double? safeRatio(num value, num base)` retornando `null` quando `base == 0`), evitando espalhar comparações de ponto flutuante.
- **Guardar em cada ponto** listado no catálogo e no spec: `month_summary_card.dart`, `summary_values_section.dart`, `identifications_view_section.dart`, `current_month_report.service.dart`, `yearly_summary_cards.dart`, `yearly_identifications_summary_charts.dart` e `identifications_barchart.dart`.
- **Fallbacks:** percentual exibido como `"N/A"` ou `"Sem variação"`, participação e progresso como zero.
- Justificativa: manter o cálculo no domínio (serviços) e a formatação na apresentação, sem introduzir dependência nova.
- Alternativa considerada: tratar só em `Formatter.relationWithoutSign` — rejeitada, porque `LinearProgressIndicator.value` e `participationInTotal` também dividem fora do `Formatter`.

### C05 — Ciclo de vida do relatório mensal

- Em `_MonthlyReportState`, **cancelar** o `StreamSubscription` anterior e **descartar** o `CurrentMonthReportService` anterior antes de criar um novo em `updateDateSelected`.
- Adicionar `dispose()` ao estado para cancelar a assinatura e descartar o serviço ao sair da tela.
- Justificativa: elimina o aviso de campo não usado e o acúmulo de assinaturas a cada troca de mês.
- Alternativa considerada: converter o relatório para `StreamBuilder` — rejeitada nesta onda para limitar o escopo.

### C11 — Caminho do banco no Linux

- `DBProvider.getDBPath()` deve usar `getApplicationDocumentsDirectory()` em release em todas as plataformas desktop, e `Directory.current` apenas em debug; **remover** o caminho fixo `/var/home/bruno-note/Documentos`.
- Quando a resolução do diretório falhar, **registrar** um aviso no logger e manter `Directory.current` como fallback, em vez de `catch (e) {}`.
- Justificativa: corrige um defeito específico da máquina de desenvolvimento sem alterar o comportamento de Windows nem o caminho de debug.

### C12 — Inicialização resiliente e servidor de predição

- `main()` deve envolver `setup()`, `initDatabase()`, `runStartupBackupSync` e `scheduleStartupAppUpdateCheck` em `try/catch`, registrando o erro e exibindo uma mensagem clara antes de encerrar.
- `EmbeddedPredictServer` deve guardar a referência do `Process` iniciado, expor `bool get isRunning` e `init()` deve retornar `Future<void>`; `terminate()` deve encerrar por `_process.kill()` (PID), com fallback por nome apenas se a referência não existir.
- Justificativa: evita processo órfão e permite saber se o servidor subiu, hoje impossível com `void async`.
- Alternativa considerada: um supervisor/retry do servidor — rejeitada; fora do escopo desta onda.

### C13 — Tipagem do serviço de predição

- Substituir `dynamic result` por uma estrutura tipada com validação de `cabeçalhos` e `registros`; capturar `TypeError`/`IndexError` (não apenas `Exception`) e, em payload inesperado, retornar o fallback existente (entradas sem identificação ou lista vazia).
- Justificativa: o parse atual indexa campos do payload sem verificar presença e só captura `Exception`, deixando `TypeError` derrubar o fluxo.

### C14 — Análise estática e empacotamento

- Trocar os 9 `withOpacity` por `withValues`.
- Adicionar `// ignore: experimental_member_use` direcionado ao `SqfliteDatabaseFactoryLogger` (uso legítimo apenas em debug) ou mover a criação para um escopo anotado.
- Adicionar etapa `flutter analyze` ao `build.ps1`, logo após os testes e antes do empacotamento, falhando o build se houver problemas.
- Justificativa: os problemas são pontuais e a verificação no build evita regressão.

### C15 — Nomenclatura e idioma

- Renomear `SQLiteAccontabilityMonthService` → `SQLiteAccountabilityMonthService` e o arquivo `accountability_identification_predition_service.dart` → `accountability_identification_prediction_service.dart` (a pasta `core/accountability_identification_prediction/` já está correta), atualizando importações e testes.
- Traduzir comentários e mensagens de log em português no código para inglês, preservando o comportamento.
- Justificativa: cumpre a seção 4 da constituição (código e comentários em inglês).
- Alternativa considerada: renomear também a pasta `app/accountability_page` — rejeitada; fora do escopo desta onda.

## Risks / Trade-offs

- C15 toca muitas referências e pode quebrar testes sem análise → rodar `flutter analyze` e a suíte completa após cada grupo de tarefas.
- C01 pode remover algo referenciado por código gerado ou por caminho dinâmico → validar com `flutter analyze` e `flutter test` antes de marcar concluído.
- C02 pode alterar textos exibidos ("N/A"/"Sem variação") → os cenários do spec cobrem os casos de denominador zero; testes de widget devem validar o texto seguro.
- C14 troca `withOpacity` por `withValues`; equivalência visual garantida pela própria API (ambos representam alfa), mas exige inspeção dos temas → rodar os testes de widget dos relatórios e da home.
- C12 muda a assinatura de `EmbeddedPredictServer.init` → ajustar `di_container.dart` e `tear_down.dart` na mesma mudança.

## Migration Plan

Não se aplica: não há migração de dados nem alteração de schema. Reversão é reverter o commit; o comportamento dos fluxos principais permanece o mesmo.

## Open Questions

Nenhuma pendência que altere o escopo, as specs ou a divisão de tarefas.
