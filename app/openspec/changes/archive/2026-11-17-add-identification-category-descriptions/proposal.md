# Proposal

## Why

As categorias e subcategorias existentes não possuem um campo próprio para explicar seu significado ou orientar seu uso. Isso dificulta diferenciar identificações semelhantes e exige conhecimento prévio ao selecionar uma identificação para um lançamento.

## What Changes

- Adicionar uma descrição opcional a todas as categorias e subcategorias.
- Exibir a descrição das categorias e subcategorias na página de identificações.
- Exibir o nome e a descrição das identificações no modal de seleção.
- Permitir editar a descrição na modal de criação e edição das categorias.
- Manter as tags utilizadas nas tabelas limitadas ao ícone e ao nome atual dado por `description`, sem exibir a descrição auxiliar.
- Manter nome, categoria pai, status, tipo, ícone e cor inalterados fora da alteração da descrição.
- Preservar a compatibilidade dos registros existentes, tratando descrições ainda não cadastradas como vazias.

## Capabilities

### New Capabilities

Nenhuma.

### Modified Capabilities

- `accountability-identifications`: inclui uma descrição opcional no modelo e no fluxo de criação, edição e seleção das identificações.

## Impact

- Modelo de domínio `AccountabilityIdentification`.
- Modal de criação e edição de identificações.
- Modal de seleção de identificações usado nos lançamentos.
- Persistência SQLite das identificações, incluindo migração da tabela.
- Testes de modelo, repositório, modal de edição e seleção.
- Nenhuma alteração de dependências externas ou de APIs além da persistência local.
