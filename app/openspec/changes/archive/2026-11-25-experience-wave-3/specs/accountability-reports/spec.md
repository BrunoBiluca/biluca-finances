# Spec Delta

## ADDED Requirements

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
