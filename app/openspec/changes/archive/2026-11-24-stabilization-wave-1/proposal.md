# Proposal

## Why

A Onda 1 do catálogo [Melhorias priorizadas](../../../../../docs/Projeto/Fase%202%20-%20Re-design/Melhorias%20priorizadas.md) reúne as correções de baixo risco e alto retorno: código morto, divisões por zero que exibem `NaN`/`Infinity` nos relatórios, vazamento de assinatura no relatório mensal, caminho de banco fixo no Linux, inicialização sem tratamento de falha, serviço de predição sem validação de payload, avisos no `flutter analyze` e nomes/idioma fora do padrão. São defeitos silenciosos que hoje não quebram a execução no fluxo principal, mas geram saída inválida, consumo de recursos e dívida técnica que dificultam as ondas seguintes.

## What Changes

Implementa os itens C01, C02, C05, C11, C12, C13, C14 e C15 do catálogo, citando os IDs no código e nos testes:

- **C01 — Remover código morto e dependências sem uso:** remover `common/ui/text_shimmer.dart`, `common/ui/text_ballon.dart` (e seu teste), `common/ui/reports/consolidated_value_card.dart`, `values_relation_indicator.dart`, `values_relation_text.dart`, `icon_highlight.dart`, `centered_icon.dart`, `values_comparison_small.dart`, `report_tooltip.dart`, o `month_selector.dart` duplicado de `common/ui/reports/` e a função legada `futureHandler`; remover as dependências `csv`, `cupertino_icons` e `shimmer`.
- **C02 — Impedir divisões por zero nos relatórios:** apresentar valor seguro ("N/A", "0%" ou progresso zero) em vez de `NaN`/`Infinity` nos cards, seções e gráficos dos relatórios mensal e anual quando o denominador é zero (sem receitas, sem despesas ou sem base de comparação).
- **C05 — Corrigir o ciclo de vida do relatório mensal:** cancelar a assinatura anterior e descartar o serviço ao trocar de mês, adicionar `dispose()` ao widget e descartar o `CurrentMonthReportService`.
- **C11 — Corrigir caminho de banco e `catch` vazio:** usar o diretório de documentos da plataforma também no Linux e registrar a falha de resolução em vez de engoli-la.
- **C12 — Inicialização resiliente e ciclo de vida do servidor de predição:** tratar falha de `setup()`/`initDatabase()` na inicialização, expor estado de saúde do `EmbeddedPredictServer` e encerrar o processo por PID em vez de por nome.
- **C13 — Tipar e validar o retorno do serviço de predição:** substituir `dynamic` por tipos explícitos e tratar payload inesperado sem derrubar o fluxo.
- **C14 — Zerar os avisos do `flutter analyze` e analisar no empacotamento:** eliminar os 12 problemas atuais e adicionar `flutter analyze` ao `build.ps1`.
- **C15 — Corrigir nomenclatura e idioma do código:** renomear `SQLiteAccontabilityMonthService` e o arquivo `accountability_identification_predition_service.dart` para a grafia correta e traduzir comentários para inglês.

## Capabilities

### New Capabilities

- `accountability-reports`: comportamento dos relatórios mensal e anual, começando pela regra de apresentar valores numéricos seguros quando não há dados no período (sem `NaN`/`Infinity`).

### Modified Capabilities

Nenhuma. Os demais itens (C01, C05, C11, C12, C13, C14 e C15) são refatoração, robustez interna e ferramentaria que não alteram requisitos de comportamento observável; as decisões técnicas ficam no `design.md`.

## Impact

- `lib/common/` (remoção de código morto) e `lib/app/accountability_monthly_report/` + `lib/app/accountability_yearly_report/` (divisões por zero e ciclo de vida).
- `lib/integrations/sqlite/db_provider.dart`, `lib/integrations/embedded_server/`, `lib/main.dart` e `lib/tear_down.dart` (caminho de banco, servidor de predição e inicialização).
- Renomeações em `lib/` e `test/` de `SQLiteAccontabilityMonthService` e `accountability_identification_predition_service.dart`.
- `pubspec.yaml` (remoção de `csv`, `cupertino_icons` e `shimmer`), `analysis_options.yaml` (se necessário) e `build.ps1` (análise no empacotamento).
- Sem mudanças de schema de banco de dados nem de contrato de publicação.
