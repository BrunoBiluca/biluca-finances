# app-preferences Specification

## Purpose

Define como a aplicação armazena e restaura localmente as preferências da pessoa usuária — modo de aparência, estado recolhido da barra lateral e mês/ano selecionados nos relatórios — de forma que sobrevivam ao reinício.

## Requirements

### Requirement: Selecionar o modo de aparência

A aplicação SHALL permitir escolher o modo de aparência — claro, escuro ou do sistema — em uma seção de aparência nas Configurações, aplicando a mudança imediatamente e persistindo a escolha para as próximas sessões.

#### Scenario: Alternar para o modo escuro
- **WHEN** a pessoa seleciona o modo escuro na seção de aparência
- **THEN** a aplicação passa a exibir o tema escuro imediatamente e grava a escolha

#### Scenario: Alternar para o modo claro
- **WHEN** a pessoa seleciona o modo claro na seção de aparência
- **THEN** a aplicação passa a exibir o tema claro imediatamente e grava a escolha

#### Scenario: Usar o modo do sistema
- **WHEN** a pessoa seleciona o modo do sistema na seção de aparência
- **THEN** a aplicação passa a acompanhar o tema do sistema operacional e grava a escolha

### Requirement: Persistir preferências entre sessões

A aplicação SHALL armazenar localmente o modo de aparência (claro, escuro ou do sistema), o estado recolhido da barra lateral e o mês e o ano selecionados nos relatórios, restaurando esses valores ao iniciar.

#### Scenario: Restaurar modo de aparência

- **WHEN** a pessoa definiu um modo de aparência (claro, escuro ou do sistema) e a aplicação é reiniciada
- **THEN** a aplicação inicia com esse modo de aparência

#### Scenario: Restaurar estado recolhido da barra lateral

- **WHEN** a pessoa recolheu a barra lateral e a aplicação é reiniciada
- **THEN** a barra lateral permanece recolhida ao iniciar

#### Scenario: Restaurar mês e ano selecionados

- **WHEN** a pessoa selecionou um mês ou um ano nos relatórios e a aplicação é reiniciada
- **THEN** os relatórios restauram essa seleção

#### Scenario: Usar valores padrão sem preferência salva

- **WHEN** não há preferência salva para um desses valores
- **THEN** a aplicação usa o valor padrão correspondente (modo do sistema, barra lateral aberta e o período mais recente disponível)
