# Proposal

## Why

O seletor atual permite pesquisar e escolher identificações, mas não deixa claro qual lançamento está sendo editado nem oferece um caminho rápido até a configuração das categorias. O redesenho aproxima o seletor da referência visual e mantém visíveis os dados necessários para escolher a identificação correta.

## What Changes

- Redesenhar o modal de seleção com base em `openspec/sources/accountability-identification-selector-modal.html`, preservando a busca e a seleção de identificações existentes.
- Exibir no topo o título e a descrição do lançamento em edição, junto ao valor, e manter visíveis o nome e a descrição auxiliar das identificações.
- Oferecer um acesso rápido à página dedicada de configurações de identificações.
- Manter o item correspondente destacado no menu lateral quando a página de configurações é aberta por esse acesso e ao retornar ao ledger.
- Preservar a navegação da lista pelo teclado e a seleção por teclado.
- Manter o seletor restrito à busca e à seleção; criação, edição e exclusão de categorias permanecem na página dedicada.

## Capabilities

### New Capabilities

Nenhuma.

### Modified Capabilities

- `accountability-ledger`: atualizar o comportamento e a apresentação do seletor de identificações usado nos lançamentos.
- `accountability-identifications`: manter o destaque do menu lateral sincronizado com a rota ativa, inclusive em navegação iniciada fora do próprio menu.

## Impact

- Widget `AccountabilityIdentificationSelector` e seu acionador na célula de identificação da tabela de lançamentos.
- Rota existente `/identifications` para abrir a página de gerenciamento.
- Destaque de rota em `Sidebar` e testes de navegação do modal e do menu.
- Especificações `accountability-ledger` e `accountability-identifications`.
