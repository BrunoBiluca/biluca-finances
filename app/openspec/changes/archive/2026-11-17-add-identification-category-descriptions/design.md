# Design

## Context

A aplicação já representa categorias e subcategorias pelo mesmo modelo `AccountabilityIdentification` e persiste esse modelo em SQLite. O nome atual usa o campo `description`, que é a designação exibida. A mudança precisa adicionar um texto auxiliar distinto sem reutilizar ou sobrescrever esse campo existente.

## Goals / Non-Goals

**Goals:**
- Acrescentar uma descrição opcional ao modelo e à tabela local.
- Permitir criar e editar essa descrição na modal de identificações.
- Exibir o texto auxiliar no modal de seleção.
- Exibir o texto auxiliar nos cards e itens da página de identificações.
- Garantir compatibilidade com bancos e objetos existentes.
- Cobrir o comportamento com testes unitários e de widgets.

**Non-Goals:**
- Alterar nome, categoria pai, status, tipo, ícone ou cor além do comportamento já existente.
- Alterar critérios de busca do modal de seleção.
- Adicionar descrição a lançamentos, relatórios ou qualquer entidade diferente de identificações.

## Decisions

- Adicionar ao modelo um campo opcional de texto auxiliar, separado da propriedade `description` que representa o nome.
- Tratar `null` ou valor ausente no mapeamento SQLite como string vazia para manter compatibilidade com objetos antigos.
- Incluir uma coluna opcional na tabela SQLite por migration, com valor padrão vazio para registros existentes.
- Adicionar um controller independente na modal de edição e reutilizar o mesmo fluxo de save/cancel.
- Reutilizar o `TextBallon` ou outro componente já usado no modal de seleção, adicionando uma linha auxiliar somente quando houver texto não vazio.
- Renderizar `descriptionDetail` nos cards de categoria pai e nos itens de subcategoria da página de identificações, usando o padrão de texto secundário do tema.
- Manter os widgets de tag das tabelas vinculados ao ícone e à propriedade `description` do nome, sem ler ou renderizar a descrição auxiliar.
- Não incluir a descrição no critério de filtro por nome; manter a busca atual.

## Risks / Trade-offs

- [Migração SQLite não executada em todas as bases] → Validar a inicialização das migrations e cobrir o banco de memória com o novo campo.
- [Descrição confundir-se com o nome existente] → Separar claramente os conceitos no modelo, na UI e nos nomes dos controllers.
- [Espaço insuficiente no modal de seleção] → Limitar o texto auxiliar a uma ou duas linhas conforme o padrão visual dos widgets existentes.
- [Registro legado sem campo] → Normalizar o valor para vazio no deserializador e no modelo.

## Migration Plan

Adicionar uma migration SQLite que cria/atualiza a coluna da descrição com default vazio. Não remover nem renomear a coluna `description` usada pelo nome da identificação. A implantação não exige migração externa ou alteração de APIs.
