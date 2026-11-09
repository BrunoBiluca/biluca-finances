# accountability-ledger Specification

## Purpose

Define como as pessoas consultam, filtram, percorrem e editam lançamentos na página Prestação de Contas, mantendo as operações atuais de criação, exclusão e importação de extratos em PDF.

## Requirements

### Requirement: Pesquisar lançamentos

A página SHALL permitir pesquisar lançamentos de toda a base local por descrição, categoria ou valor exibido, sem limitar os resultados aos lançamentos carregados anteriormente.

#### Scenario: Encontrar lançamento ainda não carregado
- **WHEN** a pessoa pesquisa por um texto presente em um lançamento além do lote atualmente exibido
- **THEN** a página apresenta o lançamento correspondente entre os resultados paginados

#### Scenario: Pesquisar por valor
- **WHEN** a pessoa informa um texto correspondente ao valor monetário exibido de um lançamento
- **THEN** a página inclui esse lançamento nos resultados

#### Scenario: Combinar busca com categoria
- **WHEN** há um texto de busca e uma categoria selecionada
- **THEN** a página apresenta somente lançamentos que correspondem à busca e à categoria

### Requirement: Filtrar lançamentos por categoria

A página SHALL disponibilizar as categorias existentes como filtros e uma opção para remover o filtro de categoria.

#### Scenario: Selecionar categoria
- **WHEN** a pessoa seleciona uma categoria
- **THEN** a página apresenta os lançamentos dessa categoria em toda a base local, respeitando a paginação

#### Scenario: Remover filtro de categoria
- **WHEN** a pessoa seleciona a opção de todas as categorias
- **THEN** a página deixa de restringir os resultados por categoria e mantém o texto de busca atual

### Requirement: Paginar resultados filtrados

A página SHALL carregar resultados da busca e dos filtros em lotes, sem omitir nem repetir lançamentos ao avançar.

#### Scenario: Carregar o próximo lote
- **WHEN** existem mais resultados para a combinação atual de busca e categoria e a pessoa solicita carregar mais
- **THEN** a página acrescenta o próximo lote sem repetir os resultados já exibidos

#### Scenario: Alterar critérios de filtro
- **WHEN** a pessoa altera o texto de busca ou a categoria selecionada
- **THEN** a página reinicia a paginação para a nova combinação e exibe seus primeiros resultados

#### Scenario: Nenhum resultado correspondente
- **WHEN** a busca e a categoria selecionada não correspondem a nenhum lançamento
- **THEN** a página informa que não há lançamentos correspondentes

### Requirement: Editar lançamentos na tabela

A página SHALL permitir editar e salvar a descrição, o valor e a identificação de um lançamento existente, e cancelar a edição sem persistir alterações. A linha em edição SHALL destacar visualmente seu estado e apresentar campos de edição conforme a referência, sem rótulos individuais acima dos campos.

#### Scenario: Salvar edição
- **WHEN** a pessoa altera campos editáveis de um lançamento e confirma a edição
- **THEN** o lançamento atualizado é persistido e apresentado na tabela

#### Scenario: Edição deixa de corresponder aos filtros
- **WHEN** a pessoa salva alterações que fazem um lançamento deixar de corresponder à busca ou categoria atuais
- **THEN** o lançamento permanece salvo e deixa de aparecer nos resultados filtrados

#### Scenario: Cancelar edição
- **WHEN** a pessoa cancela uma edição em andamento
- **THEN** as alterações não salvas são descartadas e os valores persistidos permanecem

#### Scenario: Identificar a linha em edição
- **WHEN** a pessoa inicia a edição em linha de um lançamento
- **THEN** a linha recebe o destaque visual da referência e exibe “Editando” em seu canto superior, sem adicionar rótulos aos campos de descrição, valor ou identificação

#### Scenario: Manter campos e operações existentes
- **WHEN** a pessoa edita uma linha
- **THEN** somente descrição, valor e identificação permanecem editáveis, com as mesmas validações, controles de salvar e cancelar e operações atuais

### Requirement: Colorir valores conforme seu sinal

A tabela SHALL apresentar os valores monetários com a cor semântica de valor positivo, negativo ou neutro definida pelo tema ativo.

#### Scenario: Apresentar valor positivo
- **WHEN** um lançamento tem valor maior que zero
- **THEN** seu valor é apresentado com a cor semântica positiva do tema

#### Scenario: Apresentar valor negativo
- **WHEN** um lançamento tem valor menor que zero
- **THEN** seu valor é apresentado com a cor semântica negativa do tema

#### Scenario: Apresentar valor neutro
- **WHEN** um lançamento tem valor igual a zero
- **THEN** seu valor é apresentado com a cor semântica neutra do tema

### Requirement: Apresentar identificações com seus atributos

A tabela SHALL apresentar a identificação como um selo compacto com ícone, descrição e cor da identificação, e o seletor SHALL exibir esses mesmos atributos em cada opção.

#### Scenario: Apresentar identificação na linha
- **WHEN** um lançamento possui identificação
- **THEN** seu selo mostra o ícone e a descrição da identificação em um tratamento visual que usa sua cor

#### Scenario: Escolher identificação durante a edição
- **WHEN** a pessoa abre o seletor de identificações na edição em linha
- **THEN** cada opção mostra o ícone, a cor e a descrição da identificação correspondente

#### Scenario: Manter lançamento sem identificação
- **WHEN** a pessoa escolhe a opção sem identificação
- **THEN** a seleção continua disponível e o lançamento mantém o estado “Não identificado”

### Requirement: Preservar operações existentes da página

A página SHALL manter a criação, a exclusão, o carregamento de lançamentos e a importação e conferência de extratos em PDF disponíveis, sem alterar o fluxo de importação.

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

### Requirement: Apresentar a página conforme a referência visual

A área de conteúdo da página SHALL seguir a organização visual da referência fornecida para título e ações, busca e filtros e tabela de lançamentos, sem alterar a navegação compartilhada do aplicativo.

#### Scenario: Exibir a página de prestação de contas
- **WHEN** a pessoa abre a página
- **THEN** o conteúdo apresenta o título e as ações existentes, os controles de busca e categoria e a tabela em uma composição visual coerente com a referência
