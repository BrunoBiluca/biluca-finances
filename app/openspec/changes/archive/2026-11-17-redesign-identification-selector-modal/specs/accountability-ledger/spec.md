# Spec Delta

## MODIFIED Requirements

### Requirement: Apresentar identificações com seus atributos

A tabela SHALL exibir a identificação como selo compacto com ícone, descrição e cor. O seletor SHALL seguir a referência, usar no cabeçalho e rodapé a cor do fundo da página com maior espaçamento em relação ao conteúdo, manter visíveis o título e o resumo do lançamento, apresentar nomes e descrições auxiliares, oferecer acesso à página dedicada e preservar busca e navegação por teclado. SHALL permitir apenas seleção de categorias ativas, preservando a atual descontinuada, sem ações de gerenciamento.

#### Scenario: Apresentar identificação na linha
- **WHEN** um lançamento possui identificação
- **THEN** seu selo mostra o ícone e a descrição da identificação em um tratamento visual que usa sua cor

#### Scenario: Escolher identificação durante a edição
- **WHEN** a pessoa abre o seletor de identificações na edição em linha
- **THEN** cada opção mostra o ícone, a cor e a descrição da identificação correspondente

#### Scenario: Exibir o contexto do lançamento
- **WHEN** a pessoa abre o seletor para um lançamento
- **THEN** o cabeçalho mantém visíveis o título do seletor, a descrição do lançamento e seu valor formatado

#### Scenario: Diferenciar cabeçalho e rodapé do conteúdo
- **WHEN** a pessoa abre o seletor
- **THEN** o cabeçalho e o rodapé usam a cor de fundo da página e ficam separados do conteúdo por espaçamento ampliado

#### Scenario: Manter nomes e descrições das opções legíveis
- **WHEN** a pessoa consulta as identificações disponíveis
- **THEN** cada opção exibe seu nome e, quando não vazia, sua descrição auxiliar sem texto cortado ou oculto

#### Scenario: Pesquisar identificações
- **WHEN** a pessoa informa texto no campo de busca
- **THEN** o seletor filtra as identificações disponíveis pelos nomes correspondentes e continua permitindo selecionar um resultado

#### Scenario: Navegar pelas opções usando o teclado
- **WHEN** a pessoa usa as setas para cima ou para baixo e confirma com Enter
- **THEN** o destaque percorre as opções disponíveis, incluindo a passagem entre o primeiro e o último item, e Enter seleciona a opção destacada

#### Scenario: Acessar as configurações de identificações
- **WHEN** a pessoa aciona o acesso às configurações no seletor
- **THEN** a aplicação abre a página dedicada de identificações e categorias

#### Scenario: Indicar a identificação atual
- **WHEN** a pessoa abre o seletor para um lançamento que já possui identificação
- **THEN** somente a opção dessa identificação apresenta o ícone de check ao seu lado

#### Scenario: Manter lançamento sem identificação
- **WHEN** a pessoa escolhe a opção sem identificação
- **THEN** a seleção continua disponível e o lançamento mantém o estado “Não identificado”

#### Scenario: Não oferecer categoria descontinuada
- **WHEN** a pessoa abre o seletor de identificações para escolher uma nova identificação
- **THEN** as categorias descontinuadas não são oferecidas como opção

#### Scenario: Manter categoria descontinuada já vinculada
- **WHEN** o lançamento já utiliza uma categoria descontinuada
- **THEN** o seletor apresenta essa categoria como a seleção atual e permite mantê-la ao salvar a edição

#### Scenario: Selecionar uma identificação
- **WHEN** a pessoa seleciona uma identificação no seletor
- **THEN** a identificação é aplicada ao lançamento e o seletor fecha

#### Scenario: Não oferecer gerenciamento de categorias
- **WHEN** a pessoa abre o seletor de identificações
- **THEN** o seletor não oferece ações de criar, editar ou excluir categorias, apenas a busca, o acesso à página dedicada e a seleção de identificações existentes
