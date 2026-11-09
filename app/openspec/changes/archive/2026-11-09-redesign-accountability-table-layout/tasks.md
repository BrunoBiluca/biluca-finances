# Tasks

## 1. Linha de edição e valores

- [x] 1.1 Atualizar o destaque da linha, os campos editáveis e o selo “Editando” conforme o design, sem adicionar rótulos por campo nem alterar os controles existentes; verificar com testes de widget a linha em edição e a ausência desses rótulos.
- [x] 1.2 Aplicar as cores semânticas do tema aos valores positivos, negativos e iguais a zero, na linha e durante a edição; verificar cada sinal com testes de widget.

## 2. Identificações

- [x] 2.1 Atualizar o selo de identificação para apresentar ícone, descrição e cor configurada; verificar os atributos visuais com teste de widget.
- [x] 2.2 Atualizar as opções do seletor para exibir ícone, cor e descrição, mantendo disponível “Não identificado”; verificar os itens e a seleção/salvamento da identificação com testes de widget.

## 3. Regressão integrada

- [x] 3.1 Executar `flutter test test/app/accountability/accountability_page_test.dart` e confirmar que os fluxos existentes de salvar, cancelar, validar valor inválido, editar lançamento pendente e adaptar a tabela a telas estreitas continuam passando.
