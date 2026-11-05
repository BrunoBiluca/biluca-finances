# accountability-ledger Specification

## Purpose

Define como as pessoas consultam, filtram, percorrem e editam lançamentos na página Prestação de Contas, mantendo as operações atuais de criação, exclusão e importação de extratos em PDF.

## Requirements

### Requirement: Pesquisar lançamentos

A página SHALL permitir pesquisar lançamentos de toda a base local por descrição, categoria ou valor exibido, sem limitar os resultados aos lançamentos carregados anteriormente.

#### Scenario: Encontrar lançamento ainda não carregado
- **WHEN** a pessoa pesquisa por um texto presente em um lançamento além do lote atualmente exibido
- **THEN** a página apresenta o lançamento correspondente entre os resultados paginados

#### Scenario: Pesquisar por valor
- **WHEN** a pessoa informa um texto correspondente ao valor monetário exibido de um lançamento
- **THEN** a página inclui esse lançamento nos resultados

#### Scenario: Combinar busca com categoria
- **WHEN** há um texto de busca e uma categoria selecionada
- **THEN** a página apresenta somente lançamentos que correspondem à busca e à categoria

### Requirement: Filtrar lançamentos por categoria

A página SHALL disponibilizar as categorias existentes como filtros e uma opção para remover o filtro de categoria.

#### Scenario: Selecionar categoria
- **WHEN** a pessoa seleciona uma categoria
- **THEN** a página apresenta os lançamentos dessa categoria em toda a base local, respeitando a paginação

#### Scenario: Remover filtro de categoria
- **WHEN** a pessoa seleciona a opção de todas as categorias
- **THEN** a página deixa de restringir os resultados por categoria e mantém o texto de busca atual

### Requirement: Paginar resultados filtrados

A página SHALL carregar resultados da busca e dos filtros em lotes, sem omitir nem repetir lançamentos ao avançar.

#### Scenario: Carregar o próximo lote
- **WHEN** existem mais resultados para a combinação atual de busca e categoria e a pessoa solicita carregar mais
- **THEN** a página acrescenta o próximo lote sem repetir os resultados já exibidos

#### Scenario: Alterar critérios de filtro
- **WHEN** a pessoa altera o texto de busca ou a categoria selecionada
- **THEN** a página reinicia a paginação para a nova combinação e exibe seus primeiros resultados

#### Scenario: Nenhum resultado correspondente
- **WHEN** a busca e a categoria selecionada não correspondem a nenhum lançamento
- **THEN** a página informa que não há lançamentos correspondentes

### Requirement: Editar lançamentos na tabela

A página SHALL permitir editar e salvar a descrição, o valor e a identificação de um lançamento existente, e cancelar a edição sem persistir alterações.

#### Scenario: Salvar edição
- **WHEN** a pessoa altera campos editáveis de um lançamento e confirma a edição
- **THEN** o lançamento atualizado é persistido e apresentado na tabela

#### Scenario: Edição deixa de corresponder aos filtros
- **WHEN** a pessoa salva alterações que fazem um lançamento deixar de corresponder à busca ou categoria atuais
- **THEN** o lançamento permanece salvo e deixa de aparecer nos resultados filtrados

#### Scenario: Cancelar edição
- **WHEN** a pessoa cancela uma edição em andamento
- **THEN** as alterações não salvas são descartadas e os valores persistidos permanecem

### Requirement: Preservar operações existentes da página

A atualização da página SHALL manter a criação, a exclusão, o carregamento de lançamentos e a importação e conferência de extratos em PDF disponíveis, sem alterar o fluxo de importação.

#### Scenario: Importar extrato PDF
- **WHEN** a pessoa seleciona um extrato PDF para importação
- **THEN** o fluxo atual de importação e conferência continua disponível e funciona sem mudança de comportamento

#### Scenario: Criar ou excluir lançamento
- **WHEN** a pessoa cria ou exclui um lançamento
- **THEN** a operação existente é executada e a tabela reflete os dados atualizados

### Requirement: Apresentar a página conforme a referência visual

A área de conteúdo da página SHALL seguir a organização visual da referência fornecida para título e ações, busca e filtros e tabela de lançamentos, sem alterar a navegação compartilhada do aplicativo.

#### Scenario: Exibir a página de prestação de contas
- **WHEN** a pessoa abre a página
- **THEN** o conteúdo apresenta o título e as ações existentes, os controles de busca e categoria e a tabela em uma composição visual coerente com a referência
