# Spec Delta

## ADDED Requirements

### Requirement: Confirmar a criação de identificação com toast

A página SHALL exibir um toast de sucesso quando uma nova identificação é criada com sucesso.

#### Scenario: Criar uma identificação
- **WHEN** a pessoa salva uma nova identificação com valores válidos
- **THEN** a página exibe um toast de sucesso informando que a identificação foi criada

#### Scenario: Cancelar a criação
- **WHEN** a pessoa cancela a criação de uma identificação
- **THEN** a página não exibe toast

### Requirement: Confirmar a edição de identificação com toast

A página SHALL exibir um toast de sucesso quando a edição de uma identificação é salva com sucesso.

#### Scenario: Salvar uma edição
- **WHEN** a pessoa salva as alterações de uma identificação com valores válidos
- **THEN** a página exibe um toast de sucesso informando que a identificação foi atualizada

#### Scenario: Cancelar a edição
- **WHEN** a pessoa cancela a edição de uma identificação
- **THEN** a página não exibe toast

### Requirement: Confirmar a exclusão de identificação com toast

A página SHALL exibir um toast de sucesso quando uma identificação é excluída com sucesso.

#### Scenario: Excluir uma identificação
- **WHEN** a pessoa confirma a exclusão de uma identificação e a exclusão é concluída
- **THEN** a página exibe um toast de sucesso informando que a identificação foi excluída

#### Scenario: Cancelar a exclusão
- **WHEN** a pessoa cancela a confirmação da exclusão
- **THEN** a página não exibe toast
