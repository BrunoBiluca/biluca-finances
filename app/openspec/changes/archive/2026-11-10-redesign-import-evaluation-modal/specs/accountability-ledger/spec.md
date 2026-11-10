# Spec Delta

## MODIFIED Requirements

### Requirement: Preservar operações existentes da página

A página SHALL manter a criação, a exclusão, o carregamento de lançamentos e a importação e conferência de extratos em PDF disponíveis, sem alterar as regras de importação. A conferência das entradas importadas SHALL seguir a apresentação redesenhada definida para a conferência de importação.

#### Scenario: Importar extrato PDF
- **WHEN** a pessoa seleciona um extrato PDF para importação
- **THEN** o fluxo de importação continua disponível e abre a conferência redesenhada, mantendo o salvamento das novas entradas e o descarte das duplicadas

#### Scenario: Criar ou excluir lançamento
- **WHEN** a pessoa cria um lançamento com dados válidos ou exclui um lançamento
- **THEN** a operação é concluída e a tabela reflete os dados atualizados

#### Scenario: Confirmar criação bem-sucedida
- **WHEN** a pessoa cria um lançamento válido e sua persistência é concluída com sucesso
- **THEN** a página exibe no canto inferior direito um toast com a mensagem "Registro criado com sucesso", destaque verde no texto, ícone e borda fina, fundo igual ao fundo da aplicação e tipografia do tema ativo

#### Scenario: Não confirmar criação malsucedida
- **WHEN** a pessoa tenta criar um lançamento e sua persistência falha
- **THEN** a página não exibe a mensagem de sucesso

#### Scenario: Criar lançamento sem identificação automática disponível
- **WHEN** a pessoa salva um lançamento válido sem identificação e a categorização automática não retorna uma identificação
- **THEN** o lançamento permanece apto a ser salvo sem falha do fluxo de criação
