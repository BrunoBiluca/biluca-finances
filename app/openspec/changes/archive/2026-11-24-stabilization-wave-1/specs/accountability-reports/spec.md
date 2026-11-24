# Spec Delta

## Purpose

Define como os relatórios mensal e anual apresentam os valores consolidados e as comparações entre períodos de forma legível e segura, sem exibir resultados inválidos quando não há dados no período.

## ADDED Requirements

### Requirement: Apresentar valores seguros quando não há dados no período

Os relatórios mensal e anual SHALL apresentar um valor seguro e legível em vez de `NaN` ou `Infinity` sempre que uma proporção ou variação for calculada com denominador zero, como meses sem receitas, sem despesas ou sem base de comparação no período anterior.

#### Scenario: Mês sem receitas

- **WHEN** o relatório mensal calcula a economia do mês ou o progresso de retenção em um mês cujo total de receitas é zero
- **THEN** a interface apresenta um valor seguro, como "N/A" ou progresso zero, sem exibir `NaN` ou `Infinity`

#### Scenario: Mês sem despesas

- **WHEN** o relatório mensal calcula a participação de cada identificação em um mês cujo total de despesas é zero
- **THEN** cada identificação apresenta participação zero em vez de `NaN`

#### Scenario: Sem base de comparação no período anterior

- **WHEN** o relatório mensal ou anual compara o valor atual com um período anterior cujo total é zero
- **THEN** a comparação apresenta um valor seguro, como "N/A" ou "Sem variação", sem exibir `Infinity`

#### Scenario: Relatório anual sem receitas médias

- **WHEN** o relatório anual calcula proporções que usam a média de receitas no denominador e essa média é zero
- **THEN** o relatório apresenta um valor seguro no card correspondente, sem exibir `NaN` ou `Infinity`
