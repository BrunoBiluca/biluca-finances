# Spec Delta

## ADDED Requirements

### Requirement: Filtrar lançamentos por período

A página SHALL permitir filtrar os lançamentos por um período definido por data inicial e data final, combinável com a busca textual e as categorias.

#### Scenario: Filtrar por período
- **WHEN** a pessoa define uma data inicial e uma data final
- **THEN** a página apresenta somente os lançamentos cuja data de criação está no período informado

#### Scenario: Definir apenas uma das datas
- **WHEN** a pessoa informa somente a data inicial ou somente a data final
- **THEN** a página filtra pelo limite informado, sem restringir o outro lado do período

#### Scenario: Combinar período com busca e categoria
- **WHEN** há filtro de período junto com texto de busca ou categoria selecionada
- **THEN** a página apresenta somente os lançamentos que atendem a todos os critérios

#### Scenario: Limpar o filtro de período
- **WHEN** a pessoa remove o filtro de período
- **THEN** a página deixa de restringir por período e mantém os demais critérios

### Requirement: Filtrar lançamentos por faixa de valor

A página SHALL permitir filtrar os lançamentos por uma faixa de valor com mínimo e máximo, combinável com a busca textual, as categorias e o período.

#### Scenario: Filtrar por faixa de valor
- **WHEN** a pessoa informa um valor mínimo e um valor máximo
- **THEN** a página apresenta somente os lançamentos cujo valor está dentro da faixa informada

#### Scenario: Informar somente um dos limites
- **WHEN** a pessoa informa apenas o valor mínimo ou apenas o valor máximo
- **THEN** a página filtra pelo limite informado, sem restringir o outro lado da faixa

#### Scenario: Limpar o filtro de valor
- **WHEN** a pessoa remove o filtro de valor
- **THEN** a página deixa de restringir por valor e mantém os demais critérios

### Requirement: Exibir a quantidade de resultados filtrados

A página SHALL apresentar a quantidade de lançamentos que correspondem aos critérios atuais de busca, categoria, período e valor.

#### Scenario: Consultar a contagem
- **WHEN** a página apresenta os resultados de uma busca ou filtro
- **THEN** a página exibe a quantidade de lançamentos correspondentes

#### Scenario: Nenhum resultado
- **WHEN** nenhum lançamento corresponde aos critérios
- **THEN** a página exibe a contagem igual a zero

### Requirement: Apresentar a identificação prevista no formulário de nova entrada

O formulário de nova entrada SHALL exibir a identificação prevista pela categorização automática e permitir trocá-la antes de salvar.

#### Scenario: Exibir identificação prevista
- **WHEN** a pessoa preenche os dados e a categorização automática retorna uma identificação
- **THEN** o formulário exibe essa identificação como a prevista para a entrada

#### Scenario: Ajustar a identificação prevista
- **WHEN** a pessoa deseja usar outra identificação
- **THEN** o formulário permite trocar a identificação prevista antes de salvar

#### Scenario: Salvar sem identificação prevista
- **WHEN** a categorização automática não retorna uma identificação
- **THEN** o formulário permanece apto a salvar a entrada sem identificação

### Requirement: Apresentar estados vazios com ação de recuperação

A página SHALL apresentar estados vazios informativos com uma ação relevante: criar uma nova entrada quando não há lançamentos cadastrados e limpar os filtros quando os critérios atuais não correspondem a nenhum lançamento.

#### Scenario: Nenhum lançamento cadastrado
- **WHEN** não há lançamentos cadastrados e não há filtros ativos
- **THEN** a página apresenta uma mensagem informativa e uma ação para criar uma nova entrada

#### Scenario: Filtros sem correspondência
- **WHEN** os critérios atuais de busca ou filtro não correspondem a nenhum lançamento
- **THEN** a página apresenta uma mensagem informativa e uma ação para limpar os filtros
