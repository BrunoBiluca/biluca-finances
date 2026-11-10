# accountability-import-verification Specification

## Purpose

Define como as pessoas conferem as entradas resultantes de uma importação de extrato antes de gravá-las, revisando novas entradas e registros duplicados, editando os lançamentos e acompanhando o saldo líquido do que será importado.

## Requirements

### Requirement: Apresentar o resumo da importação

A conferência SHALL apresentar, no topo do modal, o título da conferência, o nome do arquivo importado e o saldo líquido das novas entradas.

#### Scenario: Abrir a conferência
- **WHEN** a pessoa abre a conferência de uma importação
- **THEN** o topo do modal apresenta o título da conferência, o nome do arquivo importado e o saldo líquido

#### Scenario: Arquivo sem novas entradas
- **WHEN** o arquivo importado não possui novas entradas
- **THEN** o topo do modal apresenta o nome do arquivo e o saldo líquido igual a zero

### Requirement: Recalcular o saldo líquido

A conferência SHALL calcular o saldo líquido pela soma dos valores das novas entradas e SHALL recalculá-lo após editar, remover uma nova entrada ou desconsiderar uma duplicata.

#### Scenario: Editar o valor de uma nova entrada
- **WHEN** a pessoa edita e salva o valor de uma nova entrada
- **THEN** o saldo líquido apresenta a soma atualizada dos valores das novas entradas

#### Scenario: Remover uma nova entrada
- **WHEN** a pessoa remove uma nova entrada da importação
- **THEN** o saldo líquido deixa de considerar o valor da entrada removida

#### Scenario: Desconsiderar uma duplicata
- **WHEN** a pessoa desconsidera uma duplicata, tornando-a uma nova entrada
- **THEN** o saldo líquido passa a considerar o valor dessa entrada

### Requirement: Organizar a conferência em abas

A conferência SHALL organizar o corpo do modal em três abas — Novas Entradas, Registros Duplicados e Regras Aplicadas —, abrindo na aba Novas Entradas e exibindo a quantidade de registros em cada aba de dados.

#### Scenario: Abrir na aba de novas entradas
- **WHEN** a pessoa abre a conferência
- **THEN** a aba Novas Entradas está selecionada e exibe as novas entradas

#### Scenario: Alternar para registros duplicados
- **WHEN** a pessoa seleciona a aba Registros Duplicados
- **THEN** o corpo do modal exibe os registros duplicados

#### Scenario: Alternar para regras aplicadas
- **WHEN** a pessoa seleciona a aba Regras Aplicadas
- **THEN** o corpo do modal exibe a aba de regras aplicadas

#### Scenario: Exibir a quantidade de registros
- **WHEN** a conferência é apresentada
- **THEN** as abas de novas entradas e de registros duplicados exibem a quantidade de registros correspondente

### Requirement: Ocupar a altura vertical do modal

A conferência SHALL apresentar a tabela de cada aba de dados ocupando toda a altura vertical disponível no corpo do modal, rolando internamente quando os registros excederem o espaço visível.

#### Scenario: Muitos registros
- **WHEN** existem mais registros do que o espaço vertical disponível
- **THEN** a tabela ocupa o espaço disponível e apresenta rolagem vertical para os demais registros

#### Scenario: Poucos registros
- **WHEN** existem menos registros do que o espaço vertical disponível
- **THEN** a tabela continua ocupando a altura vertical total do corpo do modal

### Requirement: Exibir todas as novas entradas sem paginação

A aba Novas Entradas SHALL exibir todos os registros da importação em uma única tabela, sem paginação, filtros ou seleção de registros.

#### Scenario: Exibir todas as novas entradas
- **WHEN** a importação possui novas entradas
- **THEN** a tabela apresenta todas as novas entradas, independentemente da quantidade

#### Scenario: Não oferecer paginação
- **WHEN** a pessoa visualiza as novas entradas
- **THEN** a conferência não apresenta controles de paginação nem de carregamento de mais registros

#### Scenario: Não oferecer seleção
- **WHEN** a pessoa visualiza as novas entradas
- **THEN** a conferência não oferece seleção de registros e mantém todas as novas entradas destinadas à importação

### Requirement: Permitir editar os registros antes de importar

A conferência SHALL permitir editar a descrição, o valor e a identificação das novas entradas e dos registros duplicados, preservando as validações existentes, e SHALL gravar as alterações somente ao salvar a importação. As opções de identificação SHALL excluir categorias descontinuadas, exceto a identificação descontinuada já vinculada ao registro, que permanece disponível para ser mantida. A seleção de identificação SHALL permitir apenas escolher uma categoria existente, sem criar, editar ou excluir categorias.

#### Scenario: Editar uma nova entrada
- **WHEN** a pessoa altera a descrição, o valor ou a identificação de uma nova entrada e confirma a edição
- **THEN** a tabela apresenta a nova entrada atualizada

#### Scenario: Editar um registro duplicado
- **WHEN** a pessoa altera a descrição, o valor ou a identificação de um registro duplicado e confirma a edição
- **THEN** a tabela apresenta o registro duplicado atualizado

#### Scenario: Salvar as alterações
- **WHEN** a pessoa salva a importação após editar registros
- **THEN** as alterações confirmadas são gravadas junto com as novas entradas

#### Scenario: Cancelar a importação
- **WHEN** a pessoa cancela a conferência após editar registros
- **THEN** as alterações não são gravadas e nenhum registro é importado

#### Scenario: Não oferecer categoria descontinuada
- **WHEN** a pessoa abre o seletor de identificações de uma nova entrada ou de um registro duplicado
- **THEN** as categorias descontinuadas não são oferecidas como opção

#### Scenario: Manter categoria descontinuada já vinculada
- **WHEN** uma entrada da conferência já utiliza uma categoria descontinuada
- **THEN** o seletor apresenta essa categoria como a seleção atual e permite mantê-la ao salvar a importação

#### Scenario: Não oferecer gerenciamento de categorias
- **WHEN** a pessoa abre o seletor de identificações de uma entrada da conferência
- **THEN** o seletor não oferece ações de criar, editar ou excluir categorias, apenas a busca e a seleção de identificações existentes

### Requirement: Exibir os registros duplicados

A aba Registros Duplicados SHALL exibir todos os registros já existentes identificados na importação, com sua data de inserção, e SHALL permitir desconsiderar uma duplicata para importá-la como nova entrada.

#### Scenario: Exibir todos os registros duplicados
- **WHEN** a importação identifica registros duplicados
- **THEN** a tabela apresenta todos os registros duplicados com a data de inserção de cada um

#### Scenario: Desconsiderar uma duplicata
- **WHEN** a pessoa desconsidera uma duplicata
- **THEN** o registro deixa de aparecer na aba de duplicados e passa a ser exibido como nova entrada

### Requirement: Indicar regras aplicadas em construção

A aba Regras Aplicadas SHALL informar que a funcionalidade está em construção e que a explicação das regras ainda não está disponível, sem listar regras aplicadas.

#### Scenario: Consultar regras aplicadas
- **WHEN** a pessoa seleciona a aba Regras Aplicadas
- **THEN** o corpo do modal informa que a funcionalidade está em construção e que a explicação das regras ainda não está disponível

### Requirement: Seguir o tema ativo

A conferência SHALL usar as superfícies e a tipografia do tema ativo e SHALL apresentar o saldo líquido com a cor semântica de valor positivo, negativo ou neutro definida por AppColors.

#### Scenario: Exibir o saldo positivo
- **WHEN** o saldo líquido é maior que zero
- **THEN** o saldo é apresentado com a cor semântica de valor positivo do tema ativo

#### Scenario: Exibir o saldo negativo
- **WHEN** o saldo líquido é menor que zero
- **THEN** o saldo é apresentado com a cor semântica de valor negativo do tema ativo

#### Scenario: Exibir o saldo neutro
- **WHEN** o saldo líquido é igual a zero
- **THEN** o saldo é apresentado com a cor semântica de valor neutro do tema ativo

### Requirement: Preservar o fluxo de importação

A conferência SHALL manter o salvamento de todas as novas entradas e o fechamento sem gravação ao cancelar, sem alterar as regras de importação ou o descarte de duplicatas existentes.

#### Scenario: Salvar a importação
- **WHEN** a pessoa salva a conferência
- **THEN** todas as novas entradas, incluindo as duplicatas desconsideradas, são gravadas

#### Scenario: Cancelar a importação
- **WHEN** a pessoa cancela a conferência
- **THEN** a conferência fecha e nenhuma entrada é gravada

#### Scenario: Abrir a conferência a partir da importação
- **WHEN** a pessoa seleciona um extrato PDF para importar
- **THEN** a página importa o arquivo e abre a conferência redesenhada
