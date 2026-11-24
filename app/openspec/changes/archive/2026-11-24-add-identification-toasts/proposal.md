# Proposal

## Why

A página de identificações permite criar, editar e excluir categorias, mas não confirma visualmente o sucesso dessas ações. Sem esse retorno, a pessoa usuária precisa interpretar a atualização da lista para concluir que a operação funcionou, o que gera incerteza principalmente após exclusões e alterações.

## What Changes

- Exibir um toast de sucesso ao criar uma identificação.
- Exibir um toast de sucesso ao salvar a edição de uma identificação.
- Exibir um toast de sucesso ao excluir uma identificação.
- Reutilizar a infraestrutura de toasts já existente (`BaseToast` + `FToast`), sem adicionar dependências nem alterar as operações atuais de criação, edição e exclusão.

## Capabilities

### New Capabilities

<!-- Nenhuma: o retorno visual complementa o comportamento já coberto pela capability existente. -->

### Modified Capabilities

- `accountability-identifications`: adiciona requisitos de retorno visual por toast após criação, edição e exclusão de identificações.

## Impact

- `lib/app/accountability_identifications/accountability_identifications_page.dart`: ouvir os sucessos do bloc e apresentar os toasts.
- `lib/core/accountability/bloc/identification_categories_bloc.dart` e `identification_categories_states.dart`: sinalizar no estado quando uma criação, edição ou exclusão é concluída com sucesso.
- Testes de widget da página de identificações, para validar o comportamento observável dos toasts.
- Nenhuma dependência nova; nenhuma mudança nas regras de negócio existentes.
