# Design

## Context

A página atual é composta por `AccountabilityPage`, `AccountabilityTable` e `AccountabilityBloc`. O bloco carrega inicialmente 100 lançamentos e recarrega listas maiores ao solicitar mais resultados. O repositório oferece consultas paginadas e consulta por identificação, mas ainda não combina texto de busca, categoria e paginação em uma única consulta. A tabela edita campos existentes por ações nas células; o modelo de lançamento é mutável.

A referência descreve uma área de conteúdo com título e ações, barra de pesquisa, filtros em forma de chips e tabela em um painel. O projeto já possui o tema Obsidian Wealth e as cores tipográficas correspondentes. A navegação lateral pertence ao layout compartilhado e não faz parte deste redesign.

Ver os requisitos completos em `specs/accountability-ledger/spec.md` e a motivação em `proposal.md`.

## Goals / Non-Goals

**Goals:**

- Integrar a busca e o filtro por categoria à consulta paginada, cobrindo toda a base local.
- Reutilizar o tema e os componentes existentes sempre que possível.
- Permitir edição na linha com confirmação e cancelamento sem alterar o objeto persistido antes de salvar.
- Preservar operações já existentes e não exigir migração de dados.

**Non-Goals:**

- Alterar a sidebar, rotas ou o layout compartilhado.
- Mudar ou ampliar o fluxo de importação de extratos em PDF.
- Adicionar edição de data, anexos, novos formatos de importação ou dependências.

## Decisions

### Filtrar na consulta SQLite antes de paginar

Adicionar suporte à busca textual e à categoria na interface do repositório de lançamentos. A implementação SQLite deve aplicar os critérios antes de `LIMIT` e `OFFSET`, incluindo descrição original/alternativa, categoria e valor apresentado em formato monetário brasileiro. Consultas devem usar parâmetros vinculados. A paginação deve solicitar apenas o próximo lote, sem recarregar novamente todos os lotes anteriores; o bloco mantém os critérios ativos e reinicia o deslocamento quando eles mudam.

Alternativa considerada: carregar todos os lançamentos e filtrar em memória. Foi descartada porque a busca precisa cobrir lançamentos ainda não carregados e a quantidade total pode crescer; filtrar no SQLite evita transferir e manter toda a base na página.

### Manter critérios e progresso de paginação no estado da página

O estado da prestação de contas deve representar o texto de busca, a categoria selecionada, os resultados atuais e se há mais resultados. A categoria inicial é “Todas”; selecionar uma categoria não apaga o texto digitado. Alterar qualquer critério inicia uma nova consulta desde o primeiro lote. Consultas antigas que terminarem depois de uma alteração não devem substituir resultados mais recentes.

Alternativa considerada: manter filtros somente no widget. Foi descartada porque carregar mais, atualizar após editar/excluir e redefinir a lista precisam usar os mesmos critérios ativos.

### Editar com rascunho local por linha

Ao iniciar a edição, a tabela deve manter um rascunho separado do lançamento persistido. Salvar encaminha o rascunho pelo evento de atualização existente; cancelar descarta o rascunho. Após salvar, a lista é consultada novamente com os critérios atuais; um registro que deixou de corresponder aos critérios desaparece dos resultados sem ser removido da base.

Alternativa considerada: alterar o modelo compartilhado enquanto os campos são digitados. Foi descartada porque cancelar a edição poderia deixar alterações visíveis ou acidentalmente persistidas.

### Adaptar a referência ao tema e ao escopo existentes

Compor o conteúdo da página com cabeçalho, ações existentes, controles de busca/categoria e tabela em painel, usando o `ThemeData` e os componentes Flutter atuais. Usar rolagem horizontal para os chips quando não couberem. Manter a navegação compartilhada intacta e não copiar a sidebar fixa da imagem para a página.

Alternativa considerada: embutir a página HTML ou adicionar Tailwind/fontes como dependências. Foi descartada porque a aplicação é Flutter nativa e já dispõe de tema compatível; incorporar a referência web duplicaria a navegação e acrescentaria dependências sem necessidade.

## Risks / Trade-offs

- **Consultas com busca parcial podem percorrer muitos registros** → Aplicar critérios no SQLite, parametrizar os valores e medir o desempenho com a base de testes; considerar índices somente se houver evidência de necessidade.
- **Alterações rápidas nos filtros podem concluir fora de ordem** → Identificar cada solicitação e ignorar respostas obsoletas antes de atualizar o estado.
- **O valor pode ser digitado em notação brasileira ou simples** → Normalizar a entrada para permitir localizar valores pelo formato monetário apresentado, sem mudar os valores persistidos.
- **A tela pode ficar apertada em janelas estreitas** → Permitir rolagem horizontal na tabela e nos chips e adaptar o cabeçalho sem modificar o layout global.

## Migration Plan

Não há migração de banco: a mudança altera consultas e estado de apresentação, sem alterar o esquema SQLite. A importação PDF e a persistência existente permanecem disponíveis.
