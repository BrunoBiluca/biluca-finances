# Proposal

## Why

As identificações usadas nos lançamentos só podem ser administradas pelo seletor da tabela de prestação de contas, sem hierarquia nem estado de descontinuação. Isso impede organizar categorias em pai e subcategoria e retirar categorias antigas de circulação sem perder o histórico que os relatórios precisam continuar lendo.

## What Changes

- Criar a página "Identificações & Categorias", acessível pelo menu lateral como as demais páginas, com rota própria.
- Apresentar no topo as caixas de consolidação de total de categorias, categorias pai, subcategorias e categorias descontinuadas.
- Listar todas as identificações em uma hierarquia de um único nível, com subcategorias agrupadas sob sua categoria pai.
- Dividir a lista em três abas — Todas as categorias (padrão), Categorias ativas e Categorias descontinuadas.
- Permitir criar e editar uma identificação em modal própria, com nome, categoria pai, status de descontinuação, tipo, ícone e cor.
- Aplicar às bordas dos blocos de categoria 1px na cor `#272D36` e raio de 6px, badges em pill e fundo mais claro nas subcategorias em relação ao bloco pai.
- Aumentar a barra de abas e acrescentar, à direita, um filtro por tipo com as opções Todos, Receita, Despesa e Investimento, combinado com a aba de status.
- Garantir que toda subcategoria tenha o mesmo tipo da categoria pai, herdando o tipo e propagando em cascata a alteração do tipo do pai para as subcategorias.
- Ordenar as categorias descontinuadas por último na aba Todas as categorias, tanto entre categorias raiz quanto entre as subcategorias de cada grupo, mantendo a ordem alfabética dentro de cada status.
- Aplicar um leve efeito de transparência às categorias descontinuadas, conforme a referência: 0.9 no cartão da categoria pai e 0.8 na subcategoria.
- Corrigir os campos e seletores da modal: bordas `#272D36` (foco mais claro e erro na cor do tema), seletor de ícones Material funcional, categoria pai com ícone e cor no padrão da tabela e seletor de cor compacto com rolagem e entrada hexadecimal.
- Permitir excluir uma categoria pela modal de edição, com confirmação; ao excluir, os lançamentos vinculados passam a não identificados e as subcategorias são promovidas a categorias raiz.
- Validar a hierarquia: uma categoria só pode ser filha de uma categoria raiz, uma categoria com filhas não pode se tornar filha e nenhuma categoria pode ser filha de si mesma.
- Impedir que uma categoria pai seja descontinuada enquanto possuir subcategorias ativas; para descontinuá-la, as subcategorias devem ser promovidas a categorias raiz ou também descontinuadas.
- Acrescentar ao modelo de identificação a categoria pai e o estado de descontinuação, persistidos no SQLite por migração.
- Deixar de oferecer categorias descontinuadas em novos registros — seleção de identificação nos lançamentos e na conferência de importação e categorização automática —, preservando sua leitura em relatórios e em registros que já as utilizam.
- Deixar o seletor de identificações apenas para seleção, removendo dele a criação, a edição e a exclusão de categorias.
- Cobrir as novas regras de negócio com testes unitários e a página e a modal com testes de widget.

## Capabilities

### New Capabilities

- `accountability-identifications`: estrutura de categorias de identificação, hierarquia de um nível, estado de descontinuação, igualdade de tipo entre pai e subcategoria, consolidações, abas, filtro por tipo e criação, edição e exclusão em modal.

### Modified Capabilities

- `accountability-ledger`: o seletor passa a ser apenas de seleção, com opções restritas a categorias ativas e sem criar, editar ou excluir categorias, preservando a exibição de uma identificação já vinculada.
- `accountability-import-verification`: a seleção de identificação na conferência passa a excluir categorias descontinuadas e a não oferecer gerenciamento de categorias.

## Impact

- Nova funcionalidade Flutter em `lib/app/accountability_identifications/`, com página e modal de criação, edição e exclusão, registrada em `lib/app/routes.dart` e no menu de `lib/app/app_layout/sidebar/`.
- Modelo `AccountabilityIdentification` e contrato `AccountabilityRepo` em `lib/core/accountability/`.
- Persistência e migração em `lib/integrations/sqlite/`, incluindo as novas colunas de categoria pai e descontinuação.
- Seletor de identificações da tabela, que perde a criação, a edição e a exclusão de categorias e passa a ser apenas de seleção.
- Exclusão de categorias com desidentificação dos lançamentos e promoção das subcategorias a raízes, implementada no repositório.
- Conferência de importação e categorização automática.
- Ajustes visuais dos blocos, da barra de abas, do filtro por tipo, da ordenação das descontinuadas e da transparência em `lib/app/accountability_identifications/`.
- Regra de herança e cascata de tipo em `lib/core/accountability/`, com atualização das subcategorias pelo bloc da página.
- Testes unitários, de repositório e de widget nas estruturas já existentes em `test/`.
- Sem novas dependências; a mudança deve continuar restrita a Flutter e Dart.
