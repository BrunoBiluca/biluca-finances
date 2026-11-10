# accountability-identifications Specification

## Purpose

Permite consultar, criar e manter as categorias de identificação dos lançamentos, com hierarquia de um nível, estado de descontinuação e uma página dedicada de gerenciamento.

## Requirements

### Requirement: Acessar a página de categorias pelo menu lateral

A aplicação SHALL oferecer a página "Identificações & Categorias" no menu lateral, com rota própria, mantendo a navegação compartilhada e as demais páginas disponíveis.

#### Scenario: Abrir a página pelo menu
- **WHEN** a pessoa seleciona o item de identificações no menu lateral
- **THEN** a aplicação abre a página de gerenciamento de categorias e marca esse item como selecionado

#### Scenario: Manter a navegação compartilhada
- **WHEN** a página de gerenciamento de categorias está aberta
- **THEN** o menu lateral e a estrutura de layout do aplicativo continuam disponíveis, como nas demais páginas

### Requirement: Apresentar as consolidações no topo

A página SHALL apresentar caixas de consolidação com a quantidade total de categorias, de categorias pai, de subcategorias e de categorias descontinuadas, calculadas sobre todas as categorias cadastradas.

#### Scenario: Consolidar total e descontinuadas
- **WHEN** existem categorias ativas e descontinuadas cadastradas
- **THEN** a caixa de total apresenta a quantidade de todas as categorias e a caixa de descontinuadas apresenta a quantidade das categorias descontinuadas, incluindo subcategorias

#### Scenario: Consolidar categorias pai e subcategorias
- **WHEN** existem categorias com e sem categoria pai
- **THEN** a caixa de categorias pai apresenta a quantidade de categorias sem pai e a caixa de subcategorias apresenta a quantidade de categorias com pai

#### Scenario: Atualizar as consolidações após uma alteração
- **WHEN** a pessoa salva uma criação, uma alteração de categoria pai ou de status ou uma exclusão
- **THEN** as caixas de consolidação passam a apresentar as quantidades atualizadas

### Requirement: Listar as categorias em hierarquia de um nível

A página SHALL listar todas as categorias cadastradas e agrupar cada subcategoria sob sua categoria pai, sem permitir mais de um nível de aninhamento.

#### Scenario: Exibir todas as categorias
- **WHEN** a pessoa abre a página na aba de todas as categorias
- **THEN** a lista apresenta todas as categorias cadastradas, ativas e descontinuadas

#### Scenario: Exibir uma categoria pai
- **WHEN** uma categoria não possui categoria pai
- **THEN** a lista apresenta essa categoria como cabeçalho de um grupo, identificada como categoria pai

#### Scenario: Exibir uma subcategoria
- **WHEN** uma categoria possui categoria pai
- **THEN** a lista apresenta essa categoria dentro do grupo da categoria pai, identificada como subcategoria

#### Scenario: Subcategoria cujo pai não corresponde ao filtro
- **WHEN** uma subcategoria corresponde à aba selecionada e sua categoria pai não corresponde
- **THEN** a lista apresenta a subcategoria como item de topo, identificando a categoria pai à qual pertence

### Requirement: Ordenar categorias descontinuadas por último

A página SHALL ordenar as categorias ativas antes das descontinuadas na aba Todas as categorias, tanto entre as categorias raiz quanto entre as subcategorias de cada grupo, mantendo a ordem alfabética dentro de cada status.

#### Scenario: Ordenar categorias raiz
- **WHEN** a pessoa abre a aba Todas as categorias com categorias raiz ativas e descontinuadas
- **THEN** todas as categorias raiz ativas aparecem antes das descontinuadas, e cada grupo de status é ordenado alfabeticamente

#### Scenario: Ordenar subcategorias
- **WHEN** um grupo possui subcategorias ativas e descontinuadas
- **THEN** as subcategorias ativas aparecem antes das descontinuadas, e cada grupo de status é ordenado alfabeticamente

#### Scenario: Manter a ordenação com filtro de tipo
- **WHEN** a pessoa aplica um filtro de tipo na aba Todas as categorias
- **THEN** a ordem de ativas antes das descontinuadas continua sendo aplicada às categorias exibidas

#### Scenario: Manter a ordenação nas abas filtradas
- **WHEN** a pessoa seleciona a aba Categorias ativas ou Categorias descontinuadas
- **THEN** as categorias exibidas continuam ordenadas alfabeticamente

### Requirement: Dividir a listagem em abas por status

A página SHALL dividir a listagem em três abas — Todas as categorias, Categorias ativas e Categorias descontinuadas —, abrindo na aba Todas as categorias e filtrando cada categoria pelo próprio status.

#### Scenario: Abrir na aba de todas as categorias
- **WHEN** a pessoa abre a página
- **THEN** a aba Todas as categorias está selecionada e a lista apresenta categorias ativas e descontinuadas

#### Scenario: Filtrar categorias ativas
- **WHEN** a pessoa seleciona a aba Categorias ativas
- **THEN** a lista apresenta somente categorias não descontinuadas que correspondem ao filtro

#### Scenario: Filtrar categorias descontinuadas
- **WHEN** a pessoa seleciona a aba Categorias descontinuadas
- **THEN** a lista apresenta somente categorias descontinuadas que correspondem ao filtro

#### Scenario: Aba sem categorias
- **WHEN** a aba selecionada não possui categorias correspondentes
- **THEN** a lista informa que não há categorias naquela aba

### Requirement: Filtrar a listagem por tipo

A página SHALL oferecer, à direita da barra de abas de status, um filtro por tipo com as opções Todos, Receita, Despesa e Investimento, combinado com a aba selecionada.

#### Scenario: Abrir com todos os tipos
- **WHEN** a pessoa abre a página
- **THEN** o filtro por tipo está em Todos e a lista apresenta categorias de todos os tipos

#### Scenario: Filtrar por tipo
- **WHEN** a pessoa seleciona Receita, Despesa ou Investimento no filtro por tipo
- **THEN** a lista apresenta somente as categorias do tipo selecionado que também correspondem à aba de status

#### Scenario: Combinar abas e tipo
- **WHEN** a pessoa seleciona a aba Categorias ativas e o tipo Despesa
- **THEN** a lista apresenta somente categorias ativas do tipo despesa

#### Scenario: Contadores das abas com filtro de tipo
- **WHEN** a pessoa seleciona um tipo no filtro
- **THEN** os contadores das abas passam a apresentar as quantidades daquele tipo

#### Scenario: Nenhuma categoria do tipo
- **WHEN** a combinação da aba com o tipo selecionado não possui categorias
- **THEN** a lista informa que não há categorias para os filtros atuais

### Requirement: Criar uma categoria em modal

A página SHALL permitir criar uma categoria em modal própria, com nome, categoria pai, status, tipo, ícone e cor, salvando a nova categoria ou cancelando sem criá-la.

#### Scenario: Abrir a criação pela página
- **WHEN** a pessoa aciona a criação de uma nova identificação
- **THEN** a modal abre em modo de criação, com nome vazio, sem categoria pai, status ativa, tipo despesa e valores padrão de ícone e cor

#### Scenario: Criar uma subcategoria a partir de uma categoria pai
- **WHEN** a pessoa aciona a adição de subcategoria em uma categoria pai ativa
- **THEN** a modal abre em modo de criação com essa categoria pai já selecionada e com o tipo herdado da categoria pai

#### Scenario: Salvar uma criação
- **WHEN** a pessoa preenche os campos com valores válidos e confirma a criação
- **THEN** a categoria é persistida, a modal fecha e a lista e as consolidações são atualizadas

#### Scenario: Cancelar uma criação
- **WHEN** a pessoa cancela a criação na modal
- **THEN** a modal fecha sem persistir uma nova categoria

### Requirement: Editar uma categoria em modal

A página SHALL permitir editar o nome, a categoria pai, o status, o tipo, o ícone e a cor de uma categoria em uma modal própria, salvando as alterações ou cancelando sem persistir mudanças.

#### Scenario: Abrir a modal de edição
- **WHEN** a pessoa aciona a edição de uma categoria na lista
- **THEN** a modal apresenta os valores atuais de nome, categoria pai, status, tipo, ícone e cor, com as ações de salvar, cancelar e excluir

#### Scenario: Salvar uma edição
- **WHEN** a pessoa altera os campos da modal com valores válidos e confirma o salvamento
- **THEN** as alterações são persistidas, a modal fecha e a lista e as consolidações são atualizadas

#### Scenario: Cancelar uma edição
- **WHEN** a pessoa cancela a edição na modal
- **THEN** a modal fecha sem persistir as alterações não salvas

### Requirement: Apresentar os campos e seletores da modal

A modal de criação e edição SHALL apresentar seus campos com borda de 1px na cor #272D36, usar a cor de foco mais clara e a cor de erro do tema, exibir ícones visíveis no seletor de ícones, mostrar ícone e cor nas opções de categoria pai e manter o seletor de cor dentro da área da modal.

#### Scenario: Aplicar as bordas dos campos
- **WHEN** a pessoa abre a modal
- **THEN** os campos de nome, categoria pai, status, tipo, ícone e cor usam borda de 1px na cor #272D36, o foco clareia a borda e um erro de validação usa a cor de erro do tema

#### Scenario: Selecionar um ícone
- **WHEN** a pessoa abre o seletor de ícones
- **THEN** a modal apresenta uma grade de ícones Materiais visíveis, e a seleção atualiza a pré-visualização e o ícone salvo da categoria

#### Scenario: Escolher a categoria pai
- **WHEN** a pessoa abre a seleção de categoria pai
- **THEN** cada opção apresenta ícone, descrição e fundo tintado com a cor da categoria, e o valor selecionado mantém esse mesmo formato, como na tabela de prestação de contas

#### Scenario: Escolher uma cor
- **WHEN** a pessoa abre o seletor de cor
- **THEN** o seletor é apresentado em formato compacto com rolagem, oferece entrada de cor por texto hexadecimal e não extrapola a área da modal

### Requirement: Excluir uma categoria

A página SHALL permitir excluir uma categoria, promovendo suas subcategorias a categorias raiz e definindo como não identificados os lançamentos que a utilizavam.

#### Scenario: Confirmar a exclusão
- **WHEN** a pessoa aciona a exclusão de uma categoria na modal de edição
- **THEN** a página solicita confirmação, informando que os lançamentos ficarão sem identificação e que as subcategorias serão promovidas a categorias raiz

#### Scenario: Cancelar a exclusão
- **WHEN** a pessoa cancela a confirmação da exclusão
- **THEN** a categoria, seus vínculos e seus lançamentos permanecem inalterados

#### Scenario: Excluir uma categoria
- **WHEN** a pessoa confirma a exclusão de uma categoria
- **THEN** a categoria é removida, a modal fecha e a lista e as consolidações são atualizadas

#### Scenario: Excluir uma categoria com lançamentos
- **WHEN** a pessoa confirma a exclusão de uma categoria utilizada por lançamentos
- **THEN** os lançamentos permanecem armazenados com descrição, valor e data de criação inalterados e passam a ser apresentados como “Não identificado”

#### Scenario: Excluir uma categoria pai
- **WHEN** a pessoa confirma a exclusão de uma categoria que possui subcategorias
- **THEN** as subcategorias permanecem cadastradas como categorias raiz, mantendo seus demais campos e vínculos com lançamentos

#### Scenario: Excluir uma categoria com lançamentos e subcategorias
- **WHEN** a pessoa confirma a exclusão de uma categoria que possui lançamentos e subcategorias
- **THEN** os lançamentos ficam sem identificação e as subcategorias são promovidas a categorias raiz no mesmo efeito

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
- **THEN** a modal oferece somente nome, categoria pai, status, tipo, ícone e cor, sem tipo de custo, natureza do fluxo, observações ou qualquer outro campo da referência visual

### Requirement: Validar a hierarquia de um nível

O sistema SHALL impedir que a criação ou a edição de uma categoria crie mais de um nível de aninhamento ou um vínculo inválido.

#### Scenario: Vincular a uma categoria pai válida
- **WHEN** a pessoa escolhe como categoria pai uma categoria raiz que não é a própria categoria editada
- **THEN** a modal aceita o vínculo e permite salvar

#### Scenario: Recusar categoria pai que já é subcategoria
- **WHEN** a pessoa escolhe como categoria pai uma categoria que já possui categoria pai
- **THEN** a modal não oferece essa categoria como pai e não salva o vínculo

#### Scenario: Recusar categoria com subcategorias como filha
- **WHEN** a pessoa tenta definir uma categoria pai para uma categoria que possui subcategorias
- **THEN** a modal indica que a categoria possui subcategorias e não salva o vínculo

#### Scenario: Recusar uma categoria como pai de si mesma
- **WHEN** a pessoa tenta definir a própria categoria como sua categoria pai
- **THEN** a modal não oferece essa opção e não salva o vínculo

#### Scenario: Tornar a categoria raiz
- **WHEN** a pessoa remove a categoria pai de uma subcategoria sem subcategorias e salva
- **THEN** a categoria passa a ser uma categoria pai

### Requirement: Manter o tipo da subcategoria igual ao da categoria pai

O sistema SHALL garantir que toda subcategoria tenha o mesmo tipo da categoria pai, herdando o tipo do pai e propagando em cascata a alteração do tipo de uma categoria pai para suas subcategorias.

#### Scenario: Herdar o tipo ao definir a categoria pai
- **WHEN** a pessoa escolhe uma categoria pai para uma categoria
- **THEN** o tipo da categoria passa a ser o mesmo da categoria pai e o campo de tipo não permite um valor diferente

#### Scenario: Exibir o tipo herdado na edição
- **WHEN** a pessoa abre a modal de edição de uma subcategoria
- **THEN** o tipo apresentado é o mesmo da categoria pai e o campo de tipo está desabilitado

#### Scenario: Alterar o tipo do pai em cascata
- **WHEN** a pessoa altera o tipo de uma categoria pai que possui subcategorias e salva
- **THEN** todas as subcategorias passam a ter o novo tipo da categoria pai

#### Scenario: Recusar tipo divergente
- **WHEN** a pessoa tenta salvar uma subcategoria com tipo diferente do tipo da categoria pai
- **THEN** a modal indica a divergência e não salva a categoria

#### Scenario: Manter o tipo ao promover a categoria a raiz
- **WHEN** a pessoa remove a categoria pai de uma subcategoria e salva
- **THEN** a categoria mantém o tipo herdado e passa a permitir a alteração do próprio tipo

### Requirement: Manter a consistência entre status e hierarquia

O sistema SHALL impedir que uma categoria pai descontinuada possua subcategorias ativas e SHALL impedir que uma categoria pai com subcategorias ativas seja descontinuada.

#### Scenario: Recusar descontinuar categoria pai com subcategorias ativas
- **WHEN** a pessoa tenta descontinuar uma categoria pai que possui ao menos uma subcategoria ativa
- **THEN** a modal indica que a categoria possui subcategorias ativas e não salva a alteração de status

#### Scenario: Descontinuar categoria pai após desvincular as subcategorias
- **WHEN** todas as subcategorias ativas da categoria pai são promovidas a categorias raiz e a pessoa tenta descontinuar a categoria pai
- **THEN** a modal aceita a alteração de status e salva a categoria como descontinuada

#### Scenario: Descontinuar categoria pai após descontinuar as subcategorias
- **WHEN** todas as subcategorias ativas da categoria pai são descontinuadas e a pessoa tenta descontinuar a categoria pai
- **THEN** a modal aceita a alteração de status e salva a categoria como descontinuada

#### Scenario: Recusar subcategoria ativa em categoria pai descontinuada
- **WHEN** a pessoa escolhe uma categoria pai descontinuada para uma categoria ativa
- **THEN** a modal não oferece essa categoria pai ou indica que o vínculo é inválido e não salva

#### Scenario: Recusar reativação de subcategoria com pai descontinuado
- **WHEN** a pessoa tenta reativar uma subcategoria cuja categoria pai está descontinuada
- **THEN** a modal indica a inconsistência e não salva a alteração de status

#### Scenario: Permitir subcategoria descontinuada em categoria pai descontinuada
- **WHEN** a pessoa mantém ou define uma subcategoria descontinuada sob uma categoria pai descontinuada
- **THEN** a modal aceita o vínculo e permite salvar

### Requirement: Descontinuar categorias de identificação

A página SHALL permitir descontinuar e reativar uma categoria, impedindo que categorias descontinuadas sejam oferecidas para novos registros e preservando sua leitura em registros históricos e relatórios.

#### Scenario: Descontinuar uma categoria
- **WHEN** a pessoa altera o status de uma categoria para descontinuada e salva
- **THEN** a categoria passa a ser apresentada como descontinuada, com o status persistido, e a consolidação de descontinuadas é atualizada

#### Scenario: Reativar uma categoria
- **WHEN** a pessoa altera o status de uma categoria descontinuada para ativa e salva
- **THEN** a categoria passa a ser apresentada como ativa e volta a ser oferecida para novos registros

#### Scenario: Não oferecer categorias descontinuadas em novos registros
- **WHEN** a pessoa seleciona uma identificação para um novo lançamento ou para uma nova seleção em uma conferência de importação
- **THEN** as categorias descontinuadas não são oferecidas como opção

#### Scenario: Preservar categorias descontinuadas na leitura
- **WHEN** um lançamento já utiliza uma categoria descontinuada
- **THEN** a categoria continua sendo apresentada nos lançamentos existentes, nas consultas e nos relatórios, e continua disponível como filtro de registros históricos

### Requirement: Manter os lançamentos existentes ao criar ou editar categorias

A criação ou a edição de uma categoria SHALL NOT alterar os lançamentos que a utilizam, e os lançamentos e relatórios SHALL passar a exibir os atributos atualizados da categoria.

#### Scenario: Alterar o nome de uma categoria em uso
- **WHEN** a pessoa altera o nome de uma categoria utilizada por lançamentos existentes
- **THEN** os lançamentos mantêm seus vínculos e valores e passam a exibir o novo nome da categoria

#### Scenario: Alterar a categoria pai de uma categoria em uso
- **WHEN** a pessoa altera a categoria pai de uma categoria utilizada por lançamentos existentes
- **THEN** os lançamentos mantêm seus vínculos e passam a ser agrupados pela nova categoria pai na listagem

#### Scenario: Preservar o valor dos lançamentos
- **WHEN** qualquer campo de uma categoria é criado ou editado
- **THEN** os valores, as descrições e as datas dos lançamentos permanecem inalterados

### Requirement: Apresentar a página e a modal conforme a referência visual

A área de conteúdo da página SHALL seguir a organização visual da referência para título, ação de criação, consolidações, abas, filtro por tipo e lista hierárquica, e a modal SHALL seguir a referência para cabeçalho, campos e ações, usando as superfícies e a tipografia do tema ativo.

#### Scenario: Exibir a página
- **WHEN** a pessoa abre a página
- **THEN** o conteúdo apresenta o título e o subtítulo, a ação de criar identificação, as caixas de consolidação, a barra de abas com o filtro por tipo e a lista hierárquica em cartões coerentes com a referência

#### Scenario: Exibir as bordas dos blocos de categoria
- **WHEN** a lista apresenta categorias pai e subcategorias
- **THEN** os blocos possuem borda de 1px na cor `#272D36` e raio de arredondamento de 6px, e os badges usam formato pill

#### Scenario: Diferenciar o fundo das subcategorias
- **WHEN** uma subcategoria é apresentada dentro do grupo da categoria pai
- **THEN** seu fundo é mais claro que o fundo do bloco da categoria pai

#### Scenario: Exibir a barra de abas com o filtro por tipo
- **WHEN** a pessoa visualiza a barra de abas
- **THEN** a caixa dos botões possui área ampliada e o filtro por tipo aparece à direita, reorganizando-se abaixo em telas estreitas

#### Scenario: Distinguir categorias ativas e descontinuadas
- **WHEN** a lista apresenta categorias dos dois status
- **THEN** as categorias descontinuadas são apresentadas com tratamento visual atenuado e identificação de status, distinto das categorias ativas

#### Scenario: Aplicar transparência às categorias descontinuadas
- **WHEN** a lista apresenta uma categoria pai ou uma subcategoria descontinuada
- **THEN** o cartão da categoria pai descontinuada usa opacidade 0.9 e a subcategoria descontinuada usa opacidade 0.8, enquanto as categorias ativas permanecem com opacidade total

#### Scenario: Exibir a modal de criação ou edição
- **WHEN** a pessoa abre a modal em modo de criação ou de edição
- **THEN** a modal apresenta cabeçalho com a identificação da categoria, os campos de nome, categoria pai, status, tipo, ícone e cor e as ações de cancelar e salvar, além da ação de excluir no modo de edição, conforme a referência

#### Scenario: Não exibir valores agregados nem registros relacionados
- **WHEN** a pessoa visualiza a página ou a modal
- **THEN** não são apresentados valores agregados, quantidades de lançamentos ou registros contábeis relacionados a cada categoria

#### Scenario: Adaptar a composição a telas estreitas
- **WHEN** a página é apresentada em uma largura insuficiente para a composição lado a lado
- **THEN** as consolidações e a lista se reorganizam verticalmente sem ocultar informações ou ações
