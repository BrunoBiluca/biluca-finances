# Spec Delta

## MODIFIED Requirements

### Requirement: Preservar operações existentes da página

A atualização da página SHALL manter a criação, a exclusão, o carregamento de lançamentos e a importação e conferência de extratos em PDF disponíveis, sem alterar o fluxo de importação.

#### Scenario: Importar extrato PDF
- **WHEN** a pessoa seleciona um extrato PDF para importação
- **THEN** o fluxo atual de importação e conferência continua disponível e funciona sem mudança de comportamento

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

### Requirement: Diferenciar visualmente os toasts por categoria

Os toasts SHALL usar uma cor de destaque correspondente à categoria da mensagem: verde para sucesso, azul-claro para informação e vermelho para erro. A cor de destaque SHALL ser aplicada ao texto, ícone e borda; o fundo SHALL permanecer igual ao fundo da aplicação e a tipografia SHALL seguir o tema ativo.

#### Scenario: Exibir informação
- **WHEN** a aplicação exibe um toast de informação ou log informativo
- **THEN** o texto, ícone e borda usam azul-claro

#### Scenario: Exibir erro
- **WHEN** a aplicação exibe um toast de erro
- **THEN** o texto, ícone e borda usam vermelho

## ADDED Requirements

### Requirement: Validar os campos obrigatórios de uma nova entrada

O formulário SHALL exigir descrição não vazia, valor monetário válido e data de criação válida antes de permitir salvar uma nova entrada.

#### Scenario: Descrição ausente ou em branco
- **WHEN** a pessoa tenta salvar uma entrada sem descrição ou com descrição composta somente por espaços
- **THEN** o formulário indica que a descrição é obrigatória e não envia a entrada

#### Scenario: Valor ausente
- **WHEN** a pessoa tenta salvar uma entrada sem informar um valor
- **THEN** o formulário indica que o valor é obrigatório e não envia a entrada

#### Scenario: Valor inválido
- **WHEN** a pessoa informa um valor que não pode ser interpretado como quantia monetária válida
- **THEN** o formulário indica o erro no campo de valor e não envia a entrada

#### Scenario: Valor válido
- **WHEN** a pessoa informa uma quantia monetária válida, inclusive zero ou valor negativo
- **THEN** o formulário preserva a quantia numérica correspondente ao texto formatado

#### Scenario: Data de criação ausente ou inválida
- **WHEN** a data de criação da entrada está ausente ou fora das datas permitidas pelo formulário
- **THEN** o formulário indica que a data é inválida e não envia a entrada

#### Scenario: Salvar todos os campos válidos
- **WHEN** a pessoa informa uma descrição não vazia, um valor válido e uma data de criação válida
- **THEN** o formulário envia a entrada com os três valores correspondentes ao que foi informado ou selecionado
