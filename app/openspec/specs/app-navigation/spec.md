# app-navigation Specification

## Purpose

Define como a barra lateral se apresenta e se identifica para a pessoa usuária, inclusive no estado recolhido, garantindo rótulos legíveis, dicas de contexto e nomes acessíveis em cada item de navegação.

## Requirements

### Requirement: Nomear e contextualizar cada item de navegação

A barra lateral SHALL expor, nos estados aberto e recolhido, o título da página como nome acessível de cada item de navegação e SHALL exibir esse título como dica de contexto quando o item estiver recolhido.

#### Scenario: Item recolhido com dica de contexto

- **WHEN** a barra lateral está recolhida e a pessoa posiciona o ponteiro ou o foco sobre um item de navegação
- **THEN** a interface exibe uma dica com o título da página e o item expõe esse mesmo título como nome acessível

#### Scenario: Item aberto com título visível

- **WHEN** a barra lateral está aberta
- **THEN** cada item exibe o título da página como texto visível e mantém o mesmo título como nome acessível

#### Scenario: Item selecionado reconhecido por tecnologias assistivas

- **WHEN** a rota atual corresponde a um item de navegação
- **THEN** esse item é marcado como selecionado, tanto visualmente quanto para tecnologias assistivas

### Requirement: Rotular o agrupamento de navegação

A barra lateral SHALL expor o agrupamento de páginas como área de navegação rotulada, sem depender de texto abreviado ou decorativo no lugar do rótulo.

#### Scenario: Barra recolhida mantém o rótulo do agrupamento

- **WHEN** a barra lateral está recolhida
- **THEN** o agrupamento de páginas continua expondo o rótulo "Navegação" para tecnologias assistivas, sem exibir uma letra abreviada no lugar do rótulo

#### Scenario: Barra aberta mostra o rótulo da seção

- **WHEN** a barra lateral está aberta
- **THEN** o rótulo "Navegação" permanece visível acima dos itens

### Requirement: Alternar a barra lateral com controle acessível

O botão que alterna a barra lateral SHALL expor um nome acessível e uma dica que descrevam a ação que será executada no estado atual.

#### Scenario: Dica ao recolher

- **WHEN** a barra lateral está aberta
- **THEN** o botão que a alterna informa que a ação disponível é recolher a barra lateral

#### Scenario: Dica ao expandir

- **WHEN** a barra lateral está recolhida
- **THEN** o botão que a alterna informa que a ação disponível é expandir a barra lateral
