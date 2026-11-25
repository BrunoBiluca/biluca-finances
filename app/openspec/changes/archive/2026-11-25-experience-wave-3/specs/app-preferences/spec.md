# Spec Delta

## ADDED Requirements

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
