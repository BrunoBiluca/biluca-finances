# Spec Delta

## ADDED Requirements

### Requirement: Informar falhas de repositório

A página SHALL informar a pessoa quando uma operação de busca, criação, edição ou exclusão de lançamentos falhar por erro de repositório, em vez de permanecer silenciosamente sem efeito, e SHALL oferecer uma ação de nova tentativa quando a operação puder ser repetida.

#### Scenario: Falha ao carregar lançamentos

- **WHEN** a busca ou o carregamento de lançamentos falha por erro de repositório
- **THEN** a página exibe uma mensagem de erro e permite tentar novamente

#### Scenario: Falha ao salvar novo lançamento

- **WHEN** a persistência de um novo lançamento falha
- **THEN** a página informa o erro e não exibe a mensagem de sucesso

#### Scenario: Falha ao editar lançamento

- **WHEN** a persistência de uma edição falha
- **THEN** a página informa o erro e o lançamento permanece com os valores anteriores

#### Scenario: Falha ao excluir lançamento

- **WHEN** a exclusão de um lançamento falha
- **THEN** a página informa o erro e o lançamento permanece listado
