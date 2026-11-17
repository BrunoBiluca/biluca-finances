# Tasks

## 1. Redesenhar o seletor com contexto do lançamento

- [x] 1.1 Encaminhar ao seletor a descrição exibida na linha e o valor do lançamento, apresentando-os com o título no cabeçalho; verificar com teste de widget que os três dados ficam disponíveis ao abrir um registro.
- [x] 1.2 Reorganizar o diálogo conforme a referência, mantendo a busca e a lista rolável, com nome e descrição auxiliar legíveis e sem controles de gerenciamento; verificar com testes de widget de conteúdo e lista longa, sem asserts meramente visuais.
- [x] 1.3 Usar a cor de fundo da página no cabeçalho e rodapé e ampliar o espaçamento entre essas áreas e o conteúdo; verificar o fluxo nos testes de widget existentes e executar `flutter analyze`, sem asserts meramente visuais.
- [x] 1.4 Relacionar fundo, borda e descrição de cada opção à cor cadastrada e indicar a identificação atual com um check à direita; verificar com teste de widget que apenas a opção atual exibe o check e com `flutter analyze`.

## 2. Preservar busca e navegação por teclado

- [x] 2.1 Manter a busca por nome sobre as opções disponíveis; verificar que resultados correspondentes podem ser selecionados e que a busca sem resultado mantém a mensagem vazia.
- [x] 2.2 Fazer as setas percorrerem os resultados filtrados em ambas as direções, incluindo a passagem pelos extremos, manter o item destacado visível e selecionar com Enter; verificar os limites e a seleção em testes de widget.

## 3. Integrar o acesso às configurações dedicadas

- [x] 3.1 Adicionar acesso à rota existente `/identifications`, fechando o seletor antes da navegação e permitindo retornar ao ledger; verificar a navegação e o retorno em teste de widget e confirmar que o seletor não oferece ações de criar, editar ou excluir.
- [x] 3.2 Sincronizar o item destacado do menu lateral com a rota ativa, inclusive ao abrir configurações pelo modal e ao retornar ao ledger; verificar o estado dos dois itens em teste de navegação.

## 4. Validar o fluxo integrado

- [x] 4.1 Executar `flutter test test/app/accountability/identification_edit_selector_test.dart` e `openspec validate redesign-identification-selector-modal --strict`; resolver falhas antes de concluir.
