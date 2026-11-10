# Design

## Context

As identificações já existem em `AccountabilityIdentification`, são persistidas na tabela `accountability_identifications` e lidas por lançamentos, relatórios, filtros e pela conferência de importação. Não há categoria pai nem status: todas as categorias são oferecidas em qualquer seleção. O seletor da tabela acumula hoje a seleção e o gerenciamento de categorias (criar, renomear, trocar ícone, cor e tipo, e excluir); a mudança transfere esse gerenciamento para a nova página. A referência visual da página e da modal está em `openspec/sources/accountability-identification-manager-page/`. Ver `proposal.md` para a motivação e `specs/` para o contrato de comportamento.

A Constituição do projeto exige Flutter e Dart, código em inglês, organização por funcionalidade e teste unitário para toda regra de negócio.

### Premissas adotadas

1. As abas filtram cada categoria pelo próprio status. Como uma categoria pai descontinuada não pode ter subcategorias ativas, o único caso de hierarquia fora do grupo ocorre quando uma subcategoria descontinuada pertence a uma categoria pai ativa: na aba de descontinuadas, ela aparece como item de topo, identificando a categoria pai.
2. Uma categoria pai não pode ser descontinuada enquanto possuir subcategorias ativas. Não há cascata automática: para descontinuar o pai, a pessoa promove as subcategorias ativas a categorias raiz ou descontinua cada uma delas.
3. A recíproca também é garantida: uma categoria pai descontinuada não pode receber subcategorias ativas, e uma subcategoria com pai descontinuado não pode ser reativada. Categorias descontinuadas podem permanecer vinculadas a categorias pai descontinuadas.
4. A página cria, edita e exclui categorias. A modal cria e edita todos os campos editáveis do modelo — nome, categoria pai, status, tipo, ícone e cor — e, na edição, permite excluir. A exclusão é definitiva: os lançamentos vinculados passam a não identificados e as subcategorias são promovidas a categorias raiz, sempre após confirmação.
5. O seletor de identificações da tabela passa a servir somente para selecionar uma categoria existente, sem criar, editar ou excluir. O gerenciamento acontece apenas na nova página.
6. A regra de indisponibilidade para novos registros alcança a seleção em lançamentos, a edição na conferência de importação e a categorização automática. Um vínculo já existente com categoria descontinuada permanece válido e visível.
7. As bordas dos blocos de categoria usam sempre `#272D36`, com 1px e raio de 6px, independentemente do status ou do papel da categoria. A distinção entre ativa, descontinuada, pai e subcategoria continua nos badges e no tratamento de texto.
8. O tipo de uma subcategoria é herdado do pai. Alterar o tipo de uma categoria pai propaga o novo tipo em cascata para suas subcategorias. O filtro por tipo combina com a aba de status e os contadores das abas refletem o tipo selecionado; as consolidações do topo permanecem globais.

## Goals / Non-Goals

**Goals:**
- Centralizar a leitura, a criação, a edição e a exclusão das categorias em uma página navegável e coerente com a referência.
- Persistir categoria pai e status e aplicar a exclusão sem alterar descrição, valor ou data de criação dos lançamentos.
- Concentrar as regras de hierarquia, de consistência entre status e hierarquia, de igualdade de tipo e de disponibilidade em funções puras testáveis.
- Reduzir o seletor de identificações a uma única responsabilidade: selecionar uma categoria existente.
- Aplicar os tokens visuais das bordas, do fundo das subcategorias e da barra de abas com o filtro por tipo.

**Non-Goals:**
- Reordenar categorias pela nova página.
- Exibir valores agregados, quantidade de lançamentos ou registros relacionados.
- Adicionar tipo de custo, natureza do fluxo ou observações à modal.
- Alterar as regras de importação, a paginação da prestação de contas ou a leitura dos relatórios.
- Manter criação, edição ou exclusão de categorias no seletor da tabela.

## Decisions

### Acrescentar os campos ao modelo e ao SQLite

`AccountabilityIdentification` recebe `parentId` (anulável) e `discontinued` (booleano, padrão `false`), mantendo os campos atuais. A fábrica usada pelos fluxos existentes ganha parâmetros opcionais para não quebrar chamadas. `fromMap` tolera mapas antigos, sem as chaves novas, e `toMap` grava as colunas `parent_id` e `discontinued`.

A tabela recebe duas migrações aditivas:

- `ALTER TABLE accountability_identifications ADD COLUMN parent_id TEXT`
- `ALTER TABLE accountability_identifications ADD COLUMN discontinued INTEGER NOT NULL DEFAULT 0`

Não é criada chave estrangeira nova: o SQLite não permite adicionar uma restrição de chave estrangeira a uma tabela existente sem recriá-la, e a base atual não depende disso para a integridade das identificações. A integridade é garantida pelas regras de domínio e pelo repositório. A alternativa de uma tabela separada de hierarquia/status foi descartada por duplicar dados e exigir junções em todas as leituras de lançamentos e relatórios.

### Excluir uma categoria com segurança

A exclusão fica disponível no rodapé da modal de edição, em modo de edição apenas, com uma confirmação que explica os dois efeitos: os lançamentos vinculados ficarão sem identificação e as subcategorias serão promovidas a categorias raiz. Cancelar a confirmação não altera nada.

`deleteIdentification` executa uma transação no repositório:

1. define `identification_id = NULL` e atualiza `updatedAt` nos lançamentos da categoria;
2. define `parent_id = NULL` e atualiza `updatedAt` nas categorias filhas;
3. exclui a categoria.

A descrição, o valor e a data de criação dos lançamentos não mudam. A transação evita que uma falha parcial deixe lançamentos ou filhas apontando para uma categoria removida. A alternativa de confiar apenas na chave estrangeira `ON DELETE SET NULL` foi descartada porque o enforcement não é garantido pela aplicação e porque as filhas também precisam ser promovidas. A alternativa de bloquear a exclusão de categorias em uso foi descartada porque o produto definiu a desidentificação dos lançamentos.

Após o sucesso, a modal de edição fecha e a página recarrega a lista e as consolidações. Não há desfazer; a confirmação é a proteção da operação.

### Isolar as regras de negócio em funções puras

- `IdentificationHierarchyRules`, em `lib/core/accountability/validators/`, responde se um vínculo é válido e quais categorias podem ser pai de uma categoria: a candidata precisa existir, não pode ser a própria categoria, precisa ser raiz e a categoria editada não pode ter filhas. A lista de pais disponíveis considera o status escolhido: uma categoria ativa só aceita pai ativo; uma categoria descontinuada aceita pai ativo ou descontinuado.
- `IdentificationStatusRules`, em `lib/core/accountability/validators/`, valida a transição de status: descontinuar uma categoria com subcategorias ativas é inválido; reativar uma subcategoria cujo pai está descontinuado também é inválido; descontinuar uma categoria sem subcategorias ativas é sempre válido.
- `IdentificationAvailabilityRules`, em `lib/core/accountability/validators/`, calcula as opções de identificação para uma seleção: categorias ativas mais a identificação atual quando ela estiver descontinuada.
- `IdentificationTypeRules`, em `lib/core/accountability/validators/`, calcula o tipo herdado de uma subcategoria, valida a igualdade de tipo entre pai e filha e produz as categorias filhas com o tipo propagado quando o pai muda.
- `IdentificationConsolidation`, em `lib/core/accountability/models/`, calcula total, categorias pai, subcategorias e descontinuadas a partir da lista completa.

Essas funções são independentes de widgets e de SQLite, o que permite cobrir cada regra com testes unitários, conforme a Constituição.

### Usar um bloc próprio para a página

A página usa `IdentificationCategoriesBloc`, registrado como fábrica no contêiner de dependências, com os eventos de carregar, criar, atualizar e excluir uma identificação. O estado carrega a lista completa; a aba selecionada permanece no widget da página. O `AccountabilityBloc` existente não é reutilizado porque seu estado mistura lançamentos, paginação e busca, e suas atualizações de identificação recarregariam lançamentos sem necessidade.

Com a remoção do gerenciamento do seletor, os eventos `UpdateAccountabilityIdentification` e `DeleteAccountabilityIdentification` e seus tratadores no `AccountabilityBloc` ficam sem uso e são removidos. O repositório mantém `updateIdentification` e `deleteIdentification`, agora usados pelo novo bloc.

### Compor a listagem por grupos de categoria pai

A página carrega todas as categorias, aplica o filtro da aba e monta a exibição:

1. categorias raiz filtradas viram cabeçalhos de grupo;
2. subcategorias filtradas cujo pai também está visível são apresentadas dentro do grupo;
3. subcategorias filtradas cujo pai não está visível são apresentadas como itens de topo, com o nome da categoria pai;
4. dentro de cada status, categorias são ordenadas por nome; categorias ativas aparecem antes das descontinuadas.

As consolidações são calculadas sempre sobre a lista completa, independentemente da aba.

### Ordenar categorias descontinuadas por último

A ordenação usa primeiro o status — ativas antes das descontinuadas — e depois a descrição em ordem alfabética. A mesma regra é aplicada às categorias raiz e às subcategorias de cada grupo, inclusive quando uma subcategoria é exibida como item de topo por causa do filtro por tipo. Nas abas Ativas e Descontinuadas todas as categorias têm o mesmo status, então a ordem permanece alfabética.

A alternativa de manter a ordem apenas alfabética foi descartada porque mistura categorias em uso e categorias históricas na aba Todas. A alternativa de ordenar apenas as categorias raiz foi descartada porque o pedido também alcança a lista interna de subcategorias.

### Aplicar transparência às categorias descontinuadas

Cada cartão de categoria pai descontinuado é envolvido em uma opacidade de 0.9 e cada subcategoria descontinuada em 0.8, seguindo a referência (`opacity-90` e `opacity-80`). Categorias ativas permanecem com opacidade 1. A transparência é aplicada ao bloco inteiro, mantendo o texto, os badges e os controles legíveis.

### Abrir criação e edição em uma modal própria da funcionalidade

A modal é um widget da funcionalidade, em `lib/app/accountability_identifications/widgets/`, construído sobre `showDialog`, e não uma extensão do `BaseDialog` genérico. O mesmo widget atende aos modos de criação e de edição.

Os campos são os campos editáveis do modelo:

- nome, obrigatório, com validação de texto não vazio;
- categoria pai, com a opção "Nenhuma (categoria pai)" e apenas as categorias raiz elegíveis para o status escolhido; quando a categoria editada possui filhas, o controle é desabilitado com a explicação de que ela não pode ser subcategoria;
- status, com as opções Ativa e Descontinuada;
- tipo, com Despesa, Receita e Investimento;
- ícone, com pré-visualização e abertura do seletor de ícones já usado no projeto;
- cor, com pré-visualização e abertura do seletor de cores já usado no projeto.

Na criação, os padrões são status ativa, tipo despesa, sem categoria pai, ícone `Icons.help_outline` e a cor primária do tema. A criação pela ação do topo não define pai; a ação "Adicionar subcategoria" de um grupo ativo abre a modal com aquele pai selecionado e só é oferecida para categorias pai ativas. Criar uma subcategoria de uma categoria pai descontinuada continua possível pela ação do topo, escolhendo o pai e o status descontinuado. No modo de edição, o rodapé inclui a ação de excluir, separada das ações de cancelar e salvar. Salvar valida nome, hierarquia e consistência de status e persiste pelo bloc; erros permanecem na modal. Cancelar ou fechar descarta as alterações.

Os seletores de ícone e cor são campos da funcionalidade, usando `flutter_iconpicker` e `flutter_colorpicker` como o `TextBallon` já faz. Extrair esses seletores para `common/ui` foi descartado para não alterar um componente compartilhado por outras funcionalidades nesta mudança.

### Corrigir os campos e seletores da modal

Os campos da modal usam uma borda de 1px na cor `#272D36`. Em foco, a borda clareia para `#3A424C`; em erro, usa a cor de erro do tema. O mesmo tratamento é aplicado ao campo hexadecimal do seletor de cor. A seleção de status mantém a borda padrão e indica o estado pelo fundo e pelos ícones, usando a cor de erro quando a validação falhar.

O seletor de ícones passa a usar um catálogo próprio de ícones Material (`identificationIconCatalog`), porque a versão instalada do `flutter_iconpicker` expõe os mapas dos pacotes Material, FontAwesome e Cupertino vazios — por isso nenhum ícone era exibido. O catálogo é informado em `customIconPack`, com `iconPackModes` vazio, cor de ícone explícita (`onSurface`), fundo coerente com o tema, fundo de seleção destacado e limites de 520x420. O seletor mantém busca e atualiza a pré-visualização ao escolher.

O campo de categoria pai replica o formato da tabela de prestação de contas: cada opção e o valor selecionado exibem ícone, descrição e fundo tintado com a cor da categoria. A opção "Nenhuma (categoria pai)" usa ícone neutro. Para o valor selecionado é usado `selectedItemBuilder`, garantindo que o dropdown fechado mostre o mesmo formato das opções.

O seletor de cor deixa de ser um diálogo fixo de 340x420. Ele passa a ser um diálogo compacto com `ColorPicker` sem alpha, em orientação retrato, área de seleção reduzida, conteúdo em `SingleChildScrollView` e um campo de texto hexadecimal (`#RRGGBB`) para configuração direta. O campo valida o formato e atualiza a pré-visualização; o diálogo se limita à altura disponível e nunca força a modal a crescer.

### Manter a consistência entre status e hierarquia

A validação combinada é aplicada na modal e no domínio:

- ao descontinuar uma categoria pai, verificar se ela possui subcategorias ativas; se possuir, a modal informa que é necessário promover essas subcategorias a raiz ou descontinuá-las;
- ao ativar uma subcategoria, verificar se a categoria pai está ativa; se não estiver, a modal informa que é necessário reativar o pai ou remover o vínculo;
- ao escolher uma categoria pai para uma categoria ativa, oferecer apenas categorias pai ativas; para uma categoria descontinuada, oferecer categorias pai ativas ou descontinuadas.

A lista de pais é recalculada quando o status muda na modal, e uma seleção que se torne inválida é sinalizada antes de salvar.

### Aplicar os tokens visuais dos blocos e das abas

Os cartões e as linhas de subcategoria usam borda de 1px na cor `#272D36` e raio de 6px. Os badges de categoria pai, subcategoria e status usam formato pill. O fundo da subcategoria é obtido com uma sobreposição clara de baixa opacidade sobre a superfície do cartão pai, garantindo que seja mais claro tanto no tema escuro quanto no claro; não é usado um valor hexadecimal fixo para o fundo.

A caixa das abas recebe padding maior e os botões têm altura ampliada. O filtro por tipo fica no lado direito da caixa, com as opções Todos, Receita, Despesa e Investimento; em larguras estreitas, ele passa para baixo das abas. A cor `#272D36` é intencionalmente fixa por decisão de produto e fica restrita às bordas dos blocos de categoria.

### Filtrar a listagem por tipo

A página mantém o tipo selecionado em estado local, ao lado da aba de status. A lista aplica os dois filtros com E lógico. As consolidações do topo continuam calculadas sobre todas as categorias; os contadores das abas são recalculados sobre o tipo selecionado para corresponder ao que a lista exibe. A opção Todos limpa o filtro de tipo.

### Garantir o tipo da subcategoria

Na modal, o tipo de uma subcategoria é o mesmo da categoria pai e o campo fica desabilitado, com indicação de que o valor é herdado. Ao escolher ou trocar a categoria pai, o tipo da categoria passa a ser o tipo do novo pai; ao remover o vínculo, o tipo permanece e volta a ser editável.

Quando uma categoria raiz muda de tipo, o `IdentificationCategoriesBloc` atualiza em cascata o tipo de todas as suas subcategorias antes de recarregar a lista. A modal também valida a igualdade de tipo antes de salvar, como proteção para dados antigos divergentes. Categorias existentes com divergência não são migradas automaticamente; ao serem editadas, a modal normaliza o tipo para o do pai e o salvamento da raiz propaga o tipo para as filhas.

### Reduzir o seletor de identificações à seleção

`AccountabilityIdentificationSelector` passa a receber a lista de identificações, a identificação atual e um callback de seleção. Ele:

- aplica `IdentificationAvailabilityRules` para oferecer categorias ativas mais a identificação atual, quando descontinuada;
- mantém a busca por descrição e a mensagem de lista vazia;
- fecha a modal e devolve a identificação escolhida ao tocar em uma opção ou confirmar pelo teclado;
- não cria identificação quando a busca não encontra resultados;
- não oferece edição de nome, ícone, cor ou tipo nem exclusão;
- não depende mais do `AccountabilityBloc`.

`AccountabilityIdentificationLabel` passa a informar a identificação atual ao seletor. O dropdown de edição em linha da tabela continua apenas selecionando e usa a mesma regra de disponibilidade. A alternativa de manter os botões de gerenciamento desabilitados foi descartada por ainda sugerir duas superfícies de administração.

### Restringir as opções de identificação sem perder vínculos antigos

`IdentificationAvailabilityRules` é usado pelo seletor, pelo dropdown da edição em linha e pela conferência de importação. As opções são as categorias ativas mais a identificação atual daquele lançamento, mesmo que descontinuada, para que salvar uma edição sem trocar a identificação não apague o vínculo. A opção "Não identificado" continua disponível.

A categorização automática ignora categorias descontinuadas ao relacionar o nome previsto com as identificações; quando não há correspondência ativa, a entrada permanece sem identificação em vez de falhar. Filtros e relatórios continuam lendo todas as categorias, inclusive descontinuadas.

### Seguir a referência visual sem copiar valores fixos

A área de conteúdo segue a organização da referência: título e subtítulo, ação de criar identificação, quatro caixas de consolidação, barra de abas com filtro por tipo, lista em cartões agrupados e rodapé informativo opcional. A modal segue o cabeçalho, os campos e o rodapé da referência, incluindo os campos de ícone e cor e a ação de excluir no modo de edição. Superfícies, tipografia e demais cores vêm do tema ativo; a cor `#272D36` é a exceção definida para as bordas dos blocos. Categorias descontinuadas usam tratamento atenuado, nome riscado, selo de status e a transparência de 0.9 para o cartão pai e 0.8 para a subcategoria, sem depender apenas de cor.

Não são exibidos valores agregados, contagens de lançamentos ou registros relacionados por categoria. O layout se reorganiza verticalmente em telas estreitas.

### Navegação e composição

A página é registrada em `/identifications` e no menu lateral, após a prestação de contas, com o rótulo "Identificações". Ela usa o `AppLayout` com rolagem padrão, sem ocupar a altura fixa da tabela de prestação de contas.

## Risks / Trade-offs

- [A exclusão é definitiva e desidentifica lançamentos] → A modal de edição pede confirmação explicando os efeitos, o repositório executa tudo em transação e os testes cobrem lançamentos e filhas.
- [Remover o gerenciamento do seletor pode surpreender quem o usava] → A nova página passa a ser o local de gerenciamento, com item próprio no menu; a seleção continua funcionando no seletor.
- [A consistência entre status e hierarquia exige várias edições para descontinuar um pai com filhas] → A modal explica o bloqueio e as duas saídas válidas; cobrir os dois caminhos com testes.
- [O filtro de categorias descontinuadas na categorização automática reduz a taxa de identificação] → A entrada continua salvando sem identificação, comportamento já previsto para falha de categorização; cobrir com teste.
- [Categorias descontinuadas podem ter contraste insuficiente em algum tema] → Usar as cores do tema, manter o selo textual e validar a apresentação no tema escuro adotado pelos testes.
- [A cascata de tipo altera os lançamentos e relatórios de todas as subcategorias do pai] → A modal deixa claro que o tipo é herdado; o bloc atualiza as filhas em sequência antes de recarregar e os testes cobrem a propagação.
- [Categorias antigas podem ter tipo divergente do pai] → A modal normaliza o tipo da filha ao salvar e a alteração do pai propaga o novo tipo; nenhuma migração silenciosa é feita na leitura.
- [O filtro por tipo pode esconder categorias e deixar a lista vazia] → A página apresenta o estado vazio para a combinação de aba e tipo, e os contadores das abas refletem o tipo selecionado.
- [O catálogo próprio limita a variedade de ícones] → O catálogo cobre os ícones de categorias e finanças usados no design; novos ícones podem ser acrescentados ao mapa sem alterar o seletor.
- [O campo hexadecimal pode receber valores inválidos] → O formato é validado e a mensagem de erro é exibida sem fechar o seletor.
- [O seletor de cor compacto pode exigir rolagem em telas baixas] → O conteúdo fica em `SingleChildScrollView` e o diálogo se limita à altura disponível.
- [A opacidade de um cartão pai descontinuado e de uma subcategoria descontinuada se acumula] → O resultado segue a referência; a transparência é leve e o conteúdo continua legível. Validar a apresentação no tema escuro.
- [A ordenação por status pode parecer instável após editar um status] → A lista é recarregada após salvar e a ordenação por status e nome é determinística.
- [A migração é aditiva e não tem rollback de esquema] → Nenhum dado é removido; reverter o código deixa as colunas sem uso e os lançamentos intactos.

## Migration Plan

1. Acrescentar as duas migrações ao final da lista de `DBProvider`, elevando a versão do banco; registros existentes assumem `parent_id = NULL` e `discontinued = 0`.
2. Atualizar modelo, repositório e leituras antes de habilitar a página, para que mapas antigos e novos sejam aceitos.
3. Publicar a página com criação, edição e exclusão, depois remover o gerenciamento do seletor antigo.
4. Restringir as opções de identificação nos fluxos de lançamento e importação.
5. Em caso de rollback, reverter o código mantém as colunas adicionadas e nenhum vínculo ou lançamento é perdido; as categorias excluídas não são recuperadas.

## Open Questions

Nenhuma pergunta pendente que altere o contrato ou a abordagem.
