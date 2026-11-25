# Proposal

## Why

A Onda 4 ("polimento") é a última onda do catálogo [Melhorias priorizadas](../../../../docs/Projeto/Fase%202%20-%20Re-design/Melhorias%20priorizadas.md) e fecha os itens que só fazem sentido depois da fundação (Onda 2) e da experiência (Onda 3). Hoje a barra lateral recolhida mostra a letra "N" no lugar do rótulo "Navegação" e seus ícones não têm dica de contexto nem nome acessível; o relatório mensal monta dois gráficos em uma `Row` fixa de 600 px de altura, sem legenda para a série de comparação, o que estoura a largura em janelas estreitas; o relatório mensal e o anual repetem o mesmo bloco de cabeçalho e de seção; e os testes escondem falhas de layout com o auxiliar `ignoreOverflowErrors` em vez de verificá-las.

## What Changes

Implementa os itens U12, U13 e C08 do catálogo, mais a parte de mascaramento de overflow do C16, citando os IDs no código, nos testes e na documentação:

- **U12 — Barra lateral recolhida com dicas e rótulos acessíveis:** substituir a letra "N" por um rótulo de seção legível para tecnologias assistivas, dar nome acessível e dica (tooltip) a cada item de navegação no estado recolhido e ao botão que alterna a barra lateral, mantendo o estado selecionado e o indicador visual atual. A persistência do estado recolhido, antecipada para a Onda 3, permanece como está.
- **U13 — Gráficos responsivos, com legenda e leitura em janelas estreitas:** apresentar os gráficos de identificações do relatório mensal em uma coluna quando a largura for estreita e em duas colunas quando houver espaço, com altura proporcional em vez de 600 px fixos; adicionar legenda explícita ao gráfico de barras (valor atual e comparação com os últimos 12 meses); aplicar o mesmo tamanho responsivo aos gráficos do relatório anual que hoje usam altura fixa ou grade com proporção fixa.
- **C08 — Extrair o cabeçalho e as seções repetidas dos relatórios:** criar componentes compartilhados de cabeçalho de relatório (ícone, título e controles do período) e de seção de relatório (ícone, título e conteúdo) em `common/ui/reports/` e usá-los nos relatórios mensal e anual, removendo a duplicação e mantendo o comportamento atual, inclusive a ordem e o conteúdo dos controles.
- **C16 (parte de overflow) — Remover o mascaramento de overflow dos testes:** eliminar o auxiliar `ignoreOverflowErrors` e seus usos, fixando viewports determinísticos nos testes e verificando ausência de exceção de layout; corrigir qualquer overflow que o mascaramento escondia. Esta é a parte do C16 que depende do U13.

## Capabilities

### New Capabilities

- `app-navigation`: comportamento de navegação pela barra lateral — estados aberto e recolhido, identificação de cada página, estado selecionado, nome acessível e dica de contexto de cada item, inclusive no estado recolhido.

### Modified Capabilities

- `accountability-reports`: apresentação dos relatórios mensal e anual em janelas estreitas — gráficos responsivos com legenda explícita, cabeçalho e seções de relatório com a mesma estrutura e sem estouro de layout.

## Impact

- `lib/app/app_layout/sidebar/` (rótulos, dicas e semântica dos itens e do botão que alterna a barra) — U12.
- `lib/app/accountability_monthly_report/widgets/` (seção de identificações, gráfico de barras e gráfico de composição) e `lib/app/accountability_yearly_report/widgets/` (alturas responsivas dos gráficos) — U13.
- Novos componentes em `lib/common/ui/reports/` e seus usos em `lib/app/accountability_monthly_report/monthly_report.dart` e `lib/app/accountability_yearly_report/yearly_report.dart` — C08.
- `test/` (remoção de `test/_helpers/ignore_overflow_erros.dart`, ajuste dos testes de relatório e de sidebar, novos testes de comportamento) — C16.
- `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md` (status dos itens ao arquivar a mudança).
- Sem novas dependências, sem mudança de schema de banco de dados e sem mudança de contrato de publicação.
