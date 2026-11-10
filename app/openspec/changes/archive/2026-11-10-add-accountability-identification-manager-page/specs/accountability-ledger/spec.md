# Spec Delta

## MODIFIED Requirements

### Requirement: Apresentar identificações com seus atributos

A tabela SHALL apresentar a identificação como um selo compacto com ícone, descrição e cor. O seletor SHALL exibir esses atributos em cada opção, oferecer apenas categorias ativas — mantendo a categoria descontinuada já vinculada — e servir somente para selecionar, sem criar, editar ou excluir categorias.

#### Scenario: Apresentar identificação na linha
- **WHEN** um lançamento possui identificação
- **THEN** seu selo mostra o ícone e a descrição da identificação em um tratamento visual que usa sua cor

#### Scenario: Escolher identificação durante a edição
- **WHEN** a pessoa abre o seletor de identificações na edição em linha
- **THEN** cada opção mostra o ícone, a cor e a descrição da identificação correspondente

#### Scenario: Manter lançamento sem identificação
- **WHEN** a pessoa escolhe a opção sem identificação
- **THEN** a seleção continua disponível e o lançamento mantém o estado “Não identificado”

#### Scenario: Não oferecer categoria descontinuada
- **WHEN** a pessoa abre o seletor de identificações para escolher uma nova identificação
- **THEN** as categorias descontinuadas não são oferecidas como opção

#### Scenario: Manter categoria descontinuada já vinculada
- **WHEN** o lançamento já utiliza uma categoria descontinuada
- **THEN** o seletor apresenta essa categoria como a seleção atual e permite mantê-la ao salvar a edição

#### Scenario: Selecionar uma identificação
- **WHEN** a pessoa seleciona uma identificação no seletor
- **THEN** a identificação é aplicada ao lançamento e o seletor fecha

#### Scenario: Não oferecer gerenciamento de categorias
- **WHEN** a pessoa abre o seletor de identificações
- **THEN** o seletor não oferece ações de criar, editar ou excluir categorias, apenas a busca e a seleção de identificações existentes
