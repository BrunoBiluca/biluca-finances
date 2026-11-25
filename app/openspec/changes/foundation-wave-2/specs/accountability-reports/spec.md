# Spec Delta

## ADDED Requirements

### Requirement: Apresentar falha de carregamento com nova tentativa

Os relatórios mensal e anual SHALL apresentar uma mensagem de erro legível e uma ação de nova tentativa quando o carregamento dos dados falhar, em vez de exibir apenas a exceção.

#### Scenario: Falha ao carregar o relatório mensal

- **WHEN** o carregamento do relatório mensal falha
- **THEN** o relatório exibe uma mensagem de erro e uma ação para tentar novamente

#### Scenario: Falha ao carregar uma seção do relatório anual

- **WHEN** o carregamento de uma seção do relatório anual falha
- **THEN** essa seção exibe a mensagem de erro com a ação de nova tentativa, sem impedir as demais seções

#### Scenario: Nova tentativa bem-sucedida

- **WHEN** a pessoa aciona a nova tentativa após uma falha
- **THEN** o carregamento é refeito e, em caso de sucesso, o conteúdo é exibido
