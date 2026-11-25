# Spec Delta

## ADDED Requirements

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
