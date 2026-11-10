# Tasks

## 1. Estrutura e cabeçalho do modal

- [x] 1.1 Substituir o `BaseDialog` por um `Dialog` com altura relativa à viewport (92%, máximo de 960 px), largura máxima de 1400 px e `Column` com cabeçalho, abas, corpo em `Expanded` e rodapé; verificar com teste de widget que o modal ocupa a altura disponível e não gera overflow.
- [x] 1.2 Separar cabeçalho, abas/corpo e aviso de regras em widgets da funcionalidade; verificar que `flutter analyze` não aponta erros e que os arquivos estão em `lib/app/accountability_import_verification/widgets/`.
- [x] 1.3 Receber o nome do arquivo importado pela página e exibi-lo no cabeçalho com o título da conferência; verificar com teste de widget que o nome informado aparece e que um texto padrão é usado quando ausente.
- [x] 1.4 Calcular o saldo líquido pela soma das novas entradas e recalculá-lo após edição, remoção ou `cancelDuplication`; verificar com testes de widget os saldos positivo, negativo e neutro e a atualização após cada operação.

## 2. Abas e corpo

- [x] 2.1 Implementar as abas Novas Entradas, Registros Duplicados e Regras Aplicadas com `DefaultTabController`/`TabBar`/`TabBarView`, iniciando em Novas Entradas e exibindo a quantidade em cada aba de dados; verificar a troca de abas e os contadores com teste de widget.
- [x] 2.2 Exibir a tabela de cada aba de dados ocupando toda a altura vertical do corpo e rolando internamente; verificar com teste de widget a altura da tabela em viewports com poucos e muitos registros.
- [x] 2.3 Garantir que as novas entradas e os duplicados sejam exibidos sem paginação, filtros ou seleção; verificar com teste de widget a ausência de controles de paginação, de busca/filtro e de checkboxes.
- [x] 2.4 Exibir a aba Regras Aplicadas com aviso de funcionalidade em construção e a indisponibilidade da explicação das regras; verificar o texto com teste de widget.

## 3. Novas entradas e duplicados

- [x] 3.1 Reutilizar `AccountabilityTable` com edição em linha e identificações do `AccountabilityBloc` nas novas entradas; verificar com teste de widget a edição de descrição, valor e identificação, incluindo a validação de valor inválido.
- [x] 3.2 Manter a aba de duplicados com data de inserção, edição e a ação “Desconsiderar duplicata”; verificar com teste de widget que a duplicata desconsiderada passa para as novas entradas e atualiza o saldo.
- [x] 3.3 Preservar o salvamento e o cancelamento existentes; verificar com teste de widget que salvar grava todas as novas entradas, incluindo as desconsideradas, e que cancelar não chama `save`.

## 4. Integração e regressão

- [x] 4.1 Atualizar `AccountabilityPage.importEntries` para informar o nome do arquivo e manter o `BlocProvider` ao redor do modal; verificar com teste de widget que a importação abre a conferência com o nome do arquivo e as identificações carregadas.
- [x] 4.2 Usar `Theme.of(context)`, `ThemeManager` e `AppColors` para superfícies, tipografia e cores do saldo; verificar que o modal renderiza no tema claro e no escuro sem cores fixas da referência.
- [x] 4.3 Executar `flutter analyze`, `flutter test test/app/accountability/accountability_page_test.dart`, `flutter test test/app/accountability/table_test.dart` e `flutter test test/integrations/sqlite/import_service_test.dart` e confirmar que não há regressões.

## 5. Correções de acabamento

- [x] 5.1 Alinhar o raio do botão Salvar ao do botão contornado (8 px) e adicionar um ícone de confirmação; verificar o raio e o ícone com teste de widget.
- [x] 5.2 Aplicar `getInputFieldBackgroundColor` ao fundo do campo de identificação no modo de edição; verificar com teste de widget a cor conforme a linha.
