# Tasks

## 1. C01 — Código morto e dependências

- [x] 1.1 Remover os arquivos mortos (`common/ui/text_shimmer.dart`, `common/ui/text_ballon.dart`, `common/ui/reports/consolidated_value_card.dart`, `values_relation_indicator.dart`, `values_relation_text.dart`, `icon_highlight.dart`, `centered_icon.dart`, `values_comparison_small.dart`, `report_tooltip.dart`, `common/ui/reports/month_selector.dart`) e o teste `test/common/ui/text_ballon_test.dart`, verificando que `flutter analyze` não acusa importações pendentes
- [x] 1.2 Remover a função top-level `futureHandler` de `common/ui/reports/future_handler.dart`, mantendo o widget `FutureHandler`, e verificar que os relatórios continuam importando o widget com `flutter analyze`
- [x] 1.3 Remover as dependências `csv`, `cupertino_icons` e `shimmer` de `pubspec.yaml` e rodar `flutter pub get`, verificando que não há referência restante a `package:csv`, `package:cupertino_icons` ou `package:shimmer` em `lib/` e `test/`
- [x] 1.4 Rodar `flutter test test/common/` e a suíte de relatórios para confirmar que nenhum teste depende dos arquivos removidos

## 2. C02 — Divisões por zero nos relatórios

- [x] 2.1 Criar o helper puro `safeRatio(num value, num base)` (retorna `null` quando `base == 0`) em `common/lib/` com teste unitário em `test/common/lib/` cobrindo base zero, base negativa e base positiva, verificando `flutter test test/common/lib/`
- [x] 2.2 Aplicar `safeRatio` e fallbacks em `month_summary_card.dart`, `summary_values_section.dart` e `identifications_view_section.dart` para economia/participação/varição, verificando os testes de widget do relatório mensal (`flutter test test/app/accountability_monthly_report/`)
- [x] 2.3 Aplicar `safeRatio` e fallbacks em `yearly_summary_cards.dart` e `yearly_identifications_summary_charts.dart`, verificando os testes existentes do relatório anual e adicionando teste de widget que exibe "N/A" quando a média de receitas é zero
- [x] 2.4 Guardar `participationInTotal` em `current_month_report.service.dart` (total de despesas ou receitas zero) e adicionar teste de serviço em `test/core/accountability_monthly_report/` que valida participação zero sem `NaN`

## 3. C05 — Ciclo de vida do relatório mensal

- [x] 3.1 Em `monthly_report.dart`, cancelar a assinatura anterior e descartar o serviço anterior em `updateDateSelected`, e adicionar `dispose()` ao estado, verificando que o aviso `unused_field` de `_subscription` desaparece com `flutter analyze`
- [x] 3.2 Adicionar/ajustar teste em `test/app/accountability_monthly_report/` que troca o mês selecionado e verifica que o serviço antigo é descartado e o relatório continua atualizando, rodando `flutter test test/app/accountability_monthly_report/`

## 4. C11 — Caminho de banco no Linux

- [x] 4.1 Ajustar `DBProvider.getDBPath()` para usar `getApplicationDocumentsDirectory()` em release em todas as plataformas desktop e `Directory.current` em debug, removendo o caminho fixo `/var/home/bruno-note/Documentos`, e registrar aviso (não silencioso) quando a resolução falhar
- [x] 4.2 Adicionar teste em `test/integrations/sqlite/` que valida o caminho retornado em modo não-release e que a falha de resolução não lança exceção não tratada, rodando `flutter test test/integrations/sqlite/db_provider_migration_test.dart`

## 5. C12 — Inicialização resiliente e servidor de predição

- [x] 5.1 Envolver `setup()`, `initDatabase()`, `runStartupBackupSync` e `scheduleStartupAppUpdateCheck` em `main.dart` com tratamento de falha que registra e exibe mensagem antes de encerrar, verificando com `flutter analyze`
- [x] 5.2 Refatorar `EmbeddedPredictServer` para guardar o `Process`, expor `isRunning`, tornar `init()` um `Future<void>` e encerrar por PID em `terminate()`, atualizando `di_container.dart` e `tear_down.dart`
- [x] 5.3 Adicionar/ajustar testes em `test/integrations/embedded_predict_server/` cobrindo `terminate()` sem processo iniciado e `isRunning` refletindo o estado, rodando `flutter test test/integrations/embedded_predict_server/`

## 6. C13 — Tipagem do serviço de predição

- [x] 6.1 Substituir `dynamic result` por estrutura tipada com validação de `cabeçalhos` e `registros` em `embedded_predict_service.dart`, capturando `TypeError`/`IndexError` e retornando o fallback existente
- [x] 6.2 Adicionar teste em `test/integrations/embedded_predict_server/predict_service_test.dart` que responde payload malformado e verifica fallback sem exceção, rodando `flutter test test/integrations/embedded_predict_server/predict_service_test.dart`

## 7. C15 — Nomenclatura e idioma

- [x] 7.1 Renomear `SQLiteAccontabilityMonthService` para `SQLiteAccountabilityMonthService` e o arquivo `accountability_identification_predition_service.dart` para `accountability_identification_prediction_service.dart`, atualizando importações, `di_container.dart` e testes
- [x] 7.2 Traduzir comentários e mensagens de log em português no código para inglês, verificando com `flutter analyze` que as renomeações não quebraram importações

## 8. C14 — Análise estática e empacotamento

- [x] 8.1 Trocar os 9 `withOpacity` por `withValues` nos temas e adicionar `// ignore: experimental_member_use` direcionado ao `SqfliteDatabaseFactoryLogger`, verificando `flutter analyze` com zero problemas
- [x] 8.2 Adicionar etapa `flutter analyze` ao `build.ps1` após os testes, falhando o empacotamento quando houver problemas, e verificar que a inserção está no ponto correto lendo o script
- [x] 8.3 Rodar `flutter analyze` e `flutter test` completos, confirmando zero problemas de análise e suíte verde

## Workflow follow-up

- Arquivar a mudança após revisão, citando os IDs C01, C02, C05, C11, C12, C13, C14 e C15.
- Marcar os itens correspondentes como `implementada` no catálogo `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md`.
