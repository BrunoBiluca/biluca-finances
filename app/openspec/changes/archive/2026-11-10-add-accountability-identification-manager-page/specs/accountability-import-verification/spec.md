# Spec Delta

## MODIFIED Requirements

### Requirement: Permitir editar os registros antes de importar

A conferência SHALL permitir editar a descrição, o valor e a identificação das novas entradas e dos registros duplicados, preservando as validações existentes, e SHALL gravar as alterações somente ao salvar a importação. As opções de identificação SHALL excluir categorias descontinuadas, exceto a identificação descontinuada já vinculada ao registro, que permanece disponível para ser mantida. A seleção de identificação SHALL permitir apenas escolher uma categoria existente, sem criar, editar ou excluir categorias.

#### Scenario: Editar uma nova entrada
- **WHEN** a pessoa altera a descrição, o valor ou a identificação de uma nova entrada e confirma a edição
- **THEN** a tabela apresenta a nova entrada atualizada

#### Scenario: Editar um registro duplicado
- **WHEN** a pessoa altera a descrição, o valor ou a identificação de um registro duplicado e confirma a edição
- **THEN** a tabela apresenta o registro duplicado atualizado

#### Scenario: Salvar as alterações
- **WHEN** a pessoa salva a importação após editar registros
- **THEN** as alterações confirmadas são gravadas junto com as novas entradas

#### Scenario: Cancelar a importação
- **WHEN** a pessoa cancela a conferência após editar registros
- **THEN** as alterações não são gravadas e nenhum registro é importado

#### Scenario: Não oferecer categoria descontinuada
- **WHEN** a pessoa abre o seletor de identificações de uma nova entrada ou de um registro duplicado
- **THEN** as categorias descontinuadas não são oferecidas como opção

#### Scenario: Manter categoria descontinuada já vinculada
- **WHEN** uma entrada da conferência já utiliza uma categoria descontinuada
- **THEN** o seletor apresenta essa categoria como a seleção atual e permite mantê-la ao salvar a importação

#### Scenario: Não oferecer gerenciamento de categorias
- **WHEN** a pessoa abre o seletor de identificações de uma entrada da conferência
- **THEN** o seletor não oferece ações de criar, editar ou excluir categorias, apenas a busca e a seleção de identificações existentes
