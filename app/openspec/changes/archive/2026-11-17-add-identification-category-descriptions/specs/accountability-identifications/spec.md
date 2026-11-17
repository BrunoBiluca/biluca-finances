# Spec Delta

## MODIFIED Requirements

### Requirement: Criar uma categoria em modal

A página SHALL permitir criar uma categoria em modal própria, com nome, descrição opcional, categoria pai, status, tipo, ícone e cor, salvando a nova categoria ou cancelando sem criá-la.

#### Scenario: Abrir a criação pela página
- **WHEN** a pessoa aciona a criação de uma nova identificação
- **THEN** a modal abre em modo de criação, com nome e descrição vazios, sem categoria pai, status ativa, tipo despesa e valores padrão de ícone e cor

#### Scenario: Criar uma subcategoria a partir de uma categoria pai
- **WHEN** a pessoa aciona a adição de subcategoria em uma categoria pai ativa
- **THEN** a modal abre em modo de criação com essa categoria pai já selecionada e com o tipo herdado da categoria pai

#### Scenario: Salvar uma criação
- **WHEN** a pessoa preenche os campos com valores válidos e confirma a criação
- **THEN** a categoria é persistida com a descrição informada ou vazia, a modal fecha e a lista e as consolidações são atualizadas

#### Scenario: Cancelar uma criação
- **WHEN** a pessoa cancela a criação na modal
- **THEN** a modal fecha sem persistir uma nova categoria

### Requirement: Editar uma categoria em modal

A página SHALL permitir editar o nome, a descrição opcional, a categoria pai, o status, o tipo, o ícone e a cor de uma categoria em uma modal própria, salvando as alterações ou cancelando sem persistir mudanças.

#### Scenario: Abrir a modal de edição
- **WHEN** a pessoa aciona a edição de uma categoria na lista
- **THEN** a modal apresenta os valores atuais de nome, descrição, categoria pai, status, tipo, ícone e cor, com as ações de salvar, cancelar e excluir

#### Scenario: Salvar uma edição
- **WHEN** a pessoa altera os campos da modal com valores válidos e confirma o salvamento
- **THEN** a descrição alterada é persistida, a modal fecha e a lista e as consolidações são atualizadas

#### Scenario: Remover uma descrição
- **WHEN** a pessoa limpa o campo de descrição e confirma o salvamento
- **THEN** a categoria passa a ter descrição vazia sem alterar suas outras propriedades

#### Scenario: Cancelar uma edição
- **WHEN** a pessoa cancela a edição na modal
- **THEN** a modal fecha sem persistir as alterações não salvas

### Requirement: Apresentar os campos e seletores da modal

A modal de criação e edição SHALL apresentar seus campos com borda de 1px na cor #272D36, usar a cor de foco mais clara e a cor de erro do tema, exibir ícones visíveis no seletor de ícones, mostrar ícone e cor nas opções de categoria pai e manter o seletor de cor dentro da área da modal.

#### Scenario: Aplicar as bordas dos campos
- **WHEN** a pessoa abre a modal
- **THEN** os campos de nome, descrição, categoria pai, status, tipo, ícone e cor usam borda de 1px na cor #272D36, o foco clareia a borda e um erro de validação usa a cor de erro do tema

#### Scenario: Selecionar um ícone
- **WHEN** a pessoa abre o seletor de ícones
- **THEN** a modal apresenta uma grade de ícones Materiais visíveis, e a seleção atualiza a pré-visualização e o ícone salvo da categoria

#### Scenario: Escolher a categoria pai
- **WHEN** a pessoa abre a seleção de categoria pai
- **THEN** cada opção apresenta ícone, descrição e fundo tintado com a cor da categoria, e o valor selecionado mantém esse mesmo formato, como na tabela de prestação de contas

#### Scenario: Escolher uma cor
- **WHEN** a pessoa abre o seletor de cor
- **THEN** o seletor é apresentado em formato compacto com rolagem, oferece entrada de cor por texto hexadecimal e não extrapola a área da modal

### Requirement: Validar os dados da modal

A modal SHALL exigir um nome não vazio, aceitar os demais campos editáveis da categoria e não oferecer campos que não fazem parte do modelo de identificação.

#### Scenario: Nome obrigatório na criação
- **WHEN** a pessoa tenta criar uma categoria com o nome vazio ou composto somente por espaços
- **THEN** a modal indica que o nome é obrigatório e não cria a categoria

#### Scenario: Nome obrigatório na edição
- **WHEN** a pessoa tenta salvar uma edição com o nome vazio ou composto somente por espaços
- **THEN** a modal indica que o nome é obrigatório e não salva a categoria

#### Scenario: Oferecer somente os campos editáveis
- **WHEN** a pessoa abre a modal de criação ou de edição
- **THEN** a modal oferece nome, descrição opcional, categoria pai, status, tipo, ícone e cor, sem atributos externos ao modelo de identificação

## ADDED Requirements

### Requirement: Exibir descrição na página de identificações

A página de identificações SHALL apresentar a descrição auxiliar de cada categoria pai e subcategoria, mantendo a descrição oculta quando estiver vazia.

#### Scenario: Exibir descrição de uma categoria pai
- **WHEN** a pessoa abre a página e uma categoria pai possui descrição auxiliar
- **THEN** o card da categoria pai apresenta o nome e a descrição auxiliar

#### Scenario: Exibir descrição de uma subcategoria
- **WHEN** a pessoa abre a página e uma subcategoria possui descrição auxiliar
- **THEN** o item da subcategoria apresenta o nome e a descrição auxiliar

#### Scenario: Ocultar descrição vazia na página
- **WHEN** uma categoria ou subcategoria possui descrição auxiliar vazia
- **THEN** a página não apresenta texto auxiliar vazio no card ou item correspondente

### Requirement: Exibir descrição no modal de seleção

O modal de seleção SHALL apresentar a descrição de cada identificação disponível junto ao seu nome, mantendo oculto o texto auxiliar quando a descrição estiver vazia.

#### Scenario: Selecionar identificação com descrição
- **WHEN** a pessoa abre o modal de seleção e uma identificação possui descrição
- **THEN** a opção apresenta o nome da identificação e sua descrição como texto auxiliar

#### Scenario: Selecionar identificação sem descrição
- **WHEN** a pessoa abre o modal de seleção e uma identificação não possui descrição
- **THEN** a opção apresenta o nome da identificação sem texto auxiliar vazio

#### Scenario: Buscar identificação pela descrição
- **WHEN** a pessoa busca por texto que existe somente na descrição de uma identificação
- **THEN** a aplicação não precisa alterar o nome como critério de busca e a busca continua baseada no nome da identificação

### Requirement: Manter tags compactas nas tabelas

As tags de identificação exibidas nas tabelas SHALL apresentar somente o ícone e o nome da identificação fornecido pela propriedade `description`, sem apresentar sua descrição auxiliar.

#### Scenario: Exibir identificação em uma tag
- **WHEN** uma identificação possui nome, ícone e descrição auxiliar
- **THEN** a tag da tabela apresenta o ícone e o nome da identificação, mantendo a descrição auxiliar fora da tag

#### Scenario: Exibir identificação sem descrição auxiliar
- **WHEN** uma identificação possui nome e descrição auxiliar vazia
- **THEN** a tag da tabela continua apresentando o mesmo ícone e o mesmo nome, sem espaço vazio ou texto auxiliar

#### Scenario: Atualizar o nome da identificação em uma tag
- **WHEN** o nome da identificação é alterado
- **THEN** as tags existentes passam a apresentar o novo nome junto ao ícone atual, sem incluir a descrição auxiliar

### Requirement: Preservar descrições de identificações existentes

O sistema SHALL persistir uma descrição opcional para cada identificação e SHALL tratar registros existentes ou migrations sem descrição como identificações com descrição vazia.

#### Scenario: Criar registro sem descrição
- **WHEN** uma identificação é criada sem descrição
- **THEN** o sistema persiste a identificação com descrição vazia

#### Scenario: Editar somente a descrição
- **WHEN** a pessoa altera apenas a descrição de uma identificação
- **THEN** o sistema mantém todos os demais atributos da identificação e persiste somente o novo texto auxiliar

#### Scenario: Migrar identificação existente
- **WHEN** o banco existente é aberto após a aplicação da migração
- **THEN** todas as identificações existentes continuam disponíveis e recebem descrição vazia
