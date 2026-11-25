# Spec Delta

## Purpose

Define como a aplicação armazena e restaura localmente as preferências da pessoa usuária — modo de aparência, estado recolhido da barra lateral e mês/ano selecionados nos relatórios — de forma que sobrevivam ao reinício.

## ADDED Requirements

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
