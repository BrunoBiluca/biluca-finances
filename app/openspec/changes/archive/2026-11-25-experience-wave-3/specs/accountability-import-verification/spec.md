# Spec Delta

## ADDED Requirements

### Requirement: Apresentar o progresso da importação

A página SHALL apresentar um indicador de progresso enquanto o arquivo de extrato é processado, antes de abrir a conferência da importação.

#### Scenario: Processar um extrato
- **WHEN** a pessoa seleciona um extrato PDF para importar
- **THEN** a página exibe um indicador de progresso durante o processamento e abre a conferência ao concluir

### Requirement: Informar falha na importação

A página SHALL apresentar uma mensagem de erro quando o processamento de um arquivo de importação falhar e não abrir a conferência nesse caso, permitindo tentar novamente.

#### Scenario: Falha ao processar o arquivo
- **WHEN** o processamento do extrato falha
- **THEN** a página exibe uma mensagem de erro e não abre a conferência

#### Scenario: Tentar novamente após falha
- **WHEN** a pessoa aciona a nova tentativa após uma falha de processamento
- **THEN** o processamento é refeito e, em caso de sucesso, a conferência é aberta

### Requirement: Salvar a importação em uma única transação

O salvamento das novas entradas SHALL gravar todos os registros em uma única transação; em caso de falha, nenhuma nova entrada parcial SHALL ser persistida e a página SHALL informar o erro.

#### Scenario: Falha durante o salvamento
- **WHEN** o salvamento da importação falha no meio do processo
- **THEN** nenhuma das novas entradas é gravada e a página informa o erro
