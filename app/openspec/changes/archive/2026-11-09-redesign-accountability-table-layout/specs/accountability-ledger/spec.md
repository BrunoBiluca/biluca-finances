# Spec Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
