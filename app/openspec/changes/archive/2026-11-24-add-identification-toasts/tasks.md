# Tasks

## 1. Estado e bloc de identificações

- [x] 1.1 Adicionar `creationVersion`, `updateVersion` e `deletionVersion` a `IdentificationCategoriesState` (com `props` atualizados) e verificar que os testes do bloc continuam passando com `flutter test test/app/accountability_identifications/identification_categories_bloc_test.dart`
- [x] 1.2 Incrementar o contador correspondente após cada criação, edição e exclusão bem-sucedidas no bloc e adicionar testes em `identification_categories_bloc_test.dart` que validem o incremento correto de cada contador, verificando que os testes passam

## 2. Apresentação dos toasts na página

- [x] 2.1 Envolver o conteúdo da página com um `BlocListener` que exibe toasts de sucesso para criação, edição e exclusão e adicionar testes em `accountability_identifications_page_test.dart` que validem a exibição do toast após cada ação, verificando que os testes passam com `flutter test test/app/accountability_identifications/`
- [x] 2.2 Adicionar testes em `accountability_identifications_page_test.dart` que validem a ausência de toast quando a criação, a edição ou a exclusão é cancelada e verificar que os testes passam

## Workflow follow-up

- Arquivar a mudança após a revisão do projeto.
