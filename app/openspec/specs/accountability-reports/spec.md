# accountability-reports Specification

## Purpose

Define como os relatórios mensal e anual apresentam os valores consolidados e as comparações entre períodos de forma legível e segura, sem exibir resultados inválidos quando não há dados no período.

## Requirements

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

### Requirement: Manter o mês e o ano selecionados

Os relatórios mensal e anual SHALL restaurar o período selecionado anteriormente ao serem abertos e SHALL persistir a seleção ao alterá-la, usando o período mais recente disponível quando não houver seleção salva.

#### Scenario: Reabrir o relatório mensal
- **WHEN** a pessoa selecionou um mês no relatório mensal e navega para outra página e volta
- **THEN** o relatório mensal restaura o mês selecionado anteriormente

#### Scenario: Reabrir o relatório anual
- **WHEN** a pessoa selecionou um ano no relatório anual e navega para outra página e volta
- **THEN** o relatório anual restaura o ano selecionado anteriormente

#### Scenario: Restaurar após reiniciar
- **WHEN** a aplicação é reiniciada após a pessoa ter selecionado um mês ou um ano
- **THEN** o relatório correspondente restaura essa seleção

#### Scenario: Sem seleção salva
- **WHEN** não há mês ou ano salvo
- **THEN** o relatório mensal seleciona o mês mais recente disponível e o relatório anual seleciona o período mais recente disponível

#### Scenario: Alterar a seleção
- **WHEN** a pessoa altera o mês ou o ano em um relatório
- **THEN** a nova seleção é gravada para as próximas visitas e sessões
