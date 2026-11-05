# Proposal

## Why

A página Prestação de Contas apresenta os lançamentos em uma tabela funcional, mas não oferece busca nem filtros e seu layout não acompanha a referência visual definida. O redesign deve facilitar encontrar e alterar lançamentos sem remover comportamentos existentes.

## What Changes

- Atualizar a apresentação da página e da tabela conforme a referência visual, mantendo a navegação compartilhada do aplicativo inalterada.
- Adicionar busca por descrição, categoria ou valor e filtros por categoria, combináveis e aplicados à base local inteira, com paginação dos resultados.
- Melhorar a edição dos lançamentos na tabela, preservando os campos atualmente editáveis: descrição, valor e identificação.
- Preservar criação, exclusão, carregamento paginado e importação/conferência de extratos em PDF sem alterar o fluxo de importação.
- Não adicionar formatos ou fluxos de importação, edição de campos que hoje não são editáveis, anexos ou outras funções além das listadas.

## Capabilities

### New Capabilities

- `accountability-ledger`: Exibição, busca, filtragem, paginação e edição dos lançamentos da prestação de contas, preservando as ações existentes da página.

### Modified Capabilities

Nenhuma. O projeto ainda não possui especificações publicadas para capacidades existentes.

## Impact

- Página Flutter em `lib/app/accountability_page/`, tabela em `lib/app/accountability_table/` e o estado de apresentação relacionado em `lib/core/accountability/bloc/`.
- Interface de consulta em `lib/core/accountability/services/accountability_repo.dart` e implementação SQLite em `lib/integrations/sqlite/sqlite_accountability_repo.dart`, para buscar e filtrar todos os lançamentos com paginação.
- Testes unitários da lógica de consulta/filtros e testes de widget da página e tabela, seguindo as ferramentas de teste Flutter já usadas pelo projeto.
- Nenhuma dependência nova. A sidebar e o fluxo de importação PDF permanecem sem alterações funcionais.
