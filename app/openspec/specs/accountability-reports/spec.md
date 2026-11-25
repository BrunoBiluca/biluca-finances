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

### Requirement: Adaptar a disposição dos gráficos à largura disponível

Os relatórios SHALL dimensionar e organizar seus gráficos conforme a largura disponível, sem depender de uma única altura fixa para todos os tamanhos de janela, apresentando gráficos agrupados em uma coluna quando a largura útil for estreita e lado a lado quando houver espaço suficiente.

#### Scenario: Janela estreita empilha os gráficos

- **WHEN** o relatório mensal é aberto em uma janela cuja largura útil não comporta dois gráficos lado a lado
- **THEN** os gráficos de identificações são apresentados um abaixo do outro, cada um com a largura disponível

#### Scenario: Janela larga mantém os gráficos lado a lado

- **WHEN** o relatório mensal é aberto em uma janela com largura suficiente para dois gráficos
- **THEN** os gráficos de identificações são apresentados lado a lado

#### Scenario: Altura dos gráficos acompanha a janela

- **WHEN** a janela é redimensionada
- **THEN** os gráficos se ajustam à nova largura sem exigir rolagem horizontal e sem se sobrepor ao conteúdo seguinte

### Requirement: Identificar as séries dos gráficos com legenda

Cada gráfico que apresenta mais de uma série SHALL exibir uma legenda com o nome de cada série, usando o nome correto em cada entrada.

#### Scenario: Legenda do gráfico de barras das identificações

- **WHEN** o relatório mensal apresenta o gráfico de barras de identificações
- **THEN** a legenda nomeia a série do mês atual e a série do mês anterior

#### Scenario: Legenda do gráfico de evolução anual

- **WHEN** o relatório anual apresenta o gráfico de evolução de receitas e despesas
- **THEN** a legenda nomeia cada série com seu próprio nome, sem repetir o nome de uma série na outra

### Requirement: Manter cabeçalho e seções com estrutura comum

Os relatórios mensal e anual SHALL apresentar um cabeçalho com ícone, título e controles do período, e SHALL apresentar cada seção do relatório com ícone, título e conteúdo no mesmo padrão, preservando o conteúdo e a ordem dos controles já disponíveis.

#### Scenario: Cabeçalho do relatório mensal

- **WHEN** o relatório mensal é exibido
- **THEN** o cabeçalho mostra o ícone do relatório, o título "Relatório mensal", a ação de dados do relatório e o seletor de mês

#### Scenario: Cabeçalho do relatório anual

- **WHEN** o relatório anual é exibido
- **THEN** o cabeçalho mostra o ícone do relatório, o título "Relatório Anual" e o seletor de ano

#### Scenario: Seções do relatório mensal

- **WHEN** o relatório mensal exibe suas seções de valores e de identificações
- **THEN** cada seção mantém ícone e título no mesmo padrão visual

### Requirement: Recarregar os dados apenas quando o período ou os dados mudarem

Os relatórios SHALL manter os valores já carregados quando apenas o tamanho da janela mudar, refazendo o carregamento somente quando o período selecionado mudar ou quando os dados do período forem atualizados.

#### Scenario: Redimensionar a janela

- **WHEN** a janela é redimensionada com um relatório aberto
- **THEN** os valores consolidados permanecem os mesmos, sem novo carregamento e sem indicador de carregamento

#### Scenario: Alterar o período

- **WHEN** a pessoa altera o mês ou o ano do relatório
- **THEN** os valores consolidados do novo período são carregados

#### Scenario: Atualizar os dados do período

- **WHEN** os dados do período selecionado são atualizados
- **THEN** o relatório recarrega os valores consolidados

### Requirement: Evitar estouro de layout em janelas estreitas

Os relatórios SHALL se reorganizar em janelas estreitas de modo que nenhum conteúdo estoure a largura ou a altura disponível.

#### Scenario: Relatório mensal em janela estreita

- **WHEN** o relatório mensal é exibido em uma janela estreita
- **THEN** o cabeçalho reorganiza seus controles e o conteúdo é exibido sem erros de layout

#### Scenario: Relatório anual em janela estreita

- **WHEN** o relatório anual é exibido em uma janela estreita
- **THEN** os cards e gráficos se ajustam à largura disponível sem erros de layout
