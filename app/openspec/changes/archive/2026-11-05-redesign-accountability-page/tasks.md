# Tasks

## 1. Consulta e paginação de lançamentos

- [x] 1.1 Estender a interface do repositório para combinar busca por descrição, categoria ou valor com filtro de identificação e paginação; verificar a compilação e atualizar testes de contrato do repositório.
- [x] 1.2 Implementar a consulta SQLite parametrizada, incluindo descrição original/alternativa, categoria, valor em formato brasileiro e `LIMIT`/`OFFSET`; verificar com testes de integração que encontram resultados além dos primeiros 100 registros, combinam critérios e não repetem itens entre lotes.
- [x] 1.3 Implementar e testar a normalização da busca monetária para valores digitados em formato brasileiro ou numérico simples; verificar valores equivalentes em testes unitários.

## 2. Estado dos filtros e carregamento

- [x] 2.1 Atualizar o estado e os eventos do bloco para manter texto, categoria, resultados paginados e disponibilidade de mais resultados; verificar os estados com testes de bloco.
- [x] 2.2 Implementar a reinicialização da paginação ao alterar critérios e descartar respostas obsoletas de consultas anteriores; verificar com testes de bloco para busca, categoria combinada, remoção de categoria e troca rápida de critérios.
- [x] 2.3 Preservar os critérios ativos ao criar, editar ou excluir lançamentos e atualizar os resultados após cada operação; verificar cada ação com testes unitários do bloco, incluindo o caso em que um registro editado deixa de corresponder aos filtros.

## 3. Redesign e edição na interface

- [x] 3.1 Atualizar a página e a tabela para refletir a referência visual usando o tema existente, sem alterar a navegação compartilhada; verificar a composição, os controles e a rolagem em testes de widget.
- [x] 3.2 Implementar busca, chips de categoria combináveis e estados de resultados vazios/carregamento adicional; verificar busca, seleção de categoria, combinação, limpeza e ausência de resultados em testes de widget.
- [x] 3.3 Implementar edição na linha com rascunho local, salvar e cancelar para descrição, valor e identificação; verificar persistência ao salvar e descarte ao cancelar em testes de widget.
- [x] 3.4 Preservar os botões e os fluxos existentes de criação, exclusão e importação/conferência PDF; verificar suas ações nos testes de widget e de integração pertinentes.

## 4. Verificação integrada

- [x] 4.1 Executar os testes Flutter dos componentes de prestação de contas, bloco e repositório SQLite e corrigir regressões; verificar que todos os testes selecionados passam.
- [x] 4.2 Executar `flutter analyze` no projeto; verificar que não há novos erros ou avisos causados pela mudança.
