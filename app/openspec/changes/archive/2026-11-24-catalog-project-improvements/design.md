# Design

## Context

Ver `proposal.md` — Why. A avaliação foi feita sobre `lib/`, `test/` e `docs/` com `flutter analyze` (12 problemas) e leitura dirigida das telas, dos blocs e dos serviços. O projeto já mantém documentação de produto em `docs/` (formato Obsidian, com wikilinks) e usa OpenSpec para mudanças de comportamento. Não existe hoje um backlog único de melhorias: a Fase 2 lista itens amplos ("Re-design de todos os elementos", "Refatoração") sem valor, evidência ou critério de ordenação.

Restrições relevantes:

- Documentação em português e código em inglês (constituição, seções 4 e 5).
- Nenhuma dependência nova sem justificativa.
- O catálogo precisa sobreviver à implementação parcial e à mudança de prioridades.

## Goals / Non-Goals

**Goals:**

- Registrar as 29 melhorias com identificador estável, nota, esforço, evidência e dependências.
- Registrar a decisão de escopo: 8 melhorias de experiência (U02, U05, U07, U09, U10, U11, U12, U13) e 16 de código (C01–C16) selecionadas; U01, U03, U04, U06 e U08 descartadas nesta rodada.
- Permitir que o responsável ajuste a seleção sem precisar abrir código.
- Deixar explícito como um item selecionado se transforma em mudança implementável.

**Non-Goals:**

- Implementar qualquer item do catálogo nesta mudança.
- Definir requisitos de comportamento detalhados (cada item terá sua própria mudança e spec).
- Substituir o `DRP`/`RF` de produto; o catálogo complementa esses documentos com prioridade e evidência técnica.

## Decisions

1. **Documento único versionado em `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md`**, em vez de issues ou de uma mudança por item.
   - Motivo: a documentação do projeto já é versionada e consultada no Obsidian; um único arquivo mantém a comparação entre itens e evita 29 mudanças OpenSpec simultâneas.
   - Alternativas: issues no GitHub (exigiria sair do repositório e não é usada hoje); uma mudança OpenSpec por item (burocracia e fragmentação antes da seleção).

2. **Identificadores estáveis com prefixo de escopo: `U01`–`U13` (usuário) e `C01`–`C16` (código).**
   - Motivo: permite citar itens em commits, propostas e conversas sem ambiguidade.
   - Regra: IDs não são reutilizados nem renumerados; itens descartados permanecem no histórico com o status correspondente.

3. **Nota composta por três critérios, limitada a 1–10:** impacto (0–4) + frequência de uso ou alcance (0–3) + facilidade e baixo risco (0–3).
   - Motivo: torna a nota reproduzível e permite recalcular quando o contexto mudar.
   - Alternativas: esforço invertido como única métrica (ignora valor); votação subjetiva (não reproduzível).

4. **Evidência ancorada em arquivo e símbolo, não em número de linha.**
   - Motivo: números de linha envelhecem a cada refatoração; símbolos e nomes de arquivo permanecem rastreáveis.
   - Alternativa descartada: `arquivo:linha`, usado apenas durante a avaliação.

5. **Ciclo de status por item: `proposta` → `selecionada` → `em implementação` → `implementada`; ou `descartada`.**
   - Motivo: a decisão do responsável fica registrada no documento, sem depender de memória ou de conversa.
   - Somente uma pessoa responsável altera `proposta` para `selecionada` ou `descartada`.
   - Primeira seleção registrada: `selecionada` para U02, U05, U07, U09, U10, U11, U12, U13 e C01–C16; `descartada` para U01, U03, U04, U06 e U08, com o motivo "não selecionada nesta rodada".

6. **Rastreabilidade por mudanças OpenSpec, não por tarefas soltas:** itens selecionados são agrupados em mudanças por onda e o `proposal.md` dessas mudanças cita os IDs.
   - Motivo: mantém o fluxo já adotado no projeto (proposta → implementação → arquivo) e evita duplicar especificação.
   - Consequência: a Onda 1 (C01, C02, C05, C11, C12, C13, C14, C15) deve ser a primeira mudança de implementação, por ser pré-requisito de baixo risco das demais.
   - Consequência: ao arquivar a mudança de implementação, os itens correspondentes são marcados como `implementada` no catálogo (tarefa de follow-up no `tasks.md` da mudança).

7. **Ondas são sugestões de ordenação, não compromisso de escopo.** Elas agrupam itens por dependência técnica e risco e foram recalculadas para conter apenas os itens selecionados.

## Risks / Trade-offs

- Catálogo desatualizado depois de implementações → toda mudança que citar IDs inclui a atualização do status no seu `tasks.md`; a revisão do arquivamento confere o catálogo.
- Notas percebidas como subjetivas → critério explícito e a mesma régua para todos os itens; a nota pode ser revista com justificativa no próprio documento.
- Evidências perdem validade após refatorações → âncoras por símbolo e revisão do catálogo ao fim de cada onda.
- Excesso de itens pode dispersar a decisão → o documento agrupa em quatro ondas e destaca os de nota 8 ou superior como candidatos naturais ao primeiro ciclo.
- Escopo selecionado grande (24 itens) → executar por ondas, começando pela Onda 1 de estabilização, e atualizar o catálogo ao fim de cada onda.
- Duplicação com `docs/Produto/Backlog desqualificado.md` → o catálogo trata apenas de melhorias aceitas para avaliação; itens recusados vão para o backlog desqualificado, com o motivo.

## Migration Plan

Não se aplica: a mudança cria e vincula documentação, sem alteração de código, dados ou dependências. Reversão é a remoção do documento e do link.

## Open Questions

Nenhuma. A primeira seleção foi registrada; novas seleções podem ser feitas a qualquer momento sem alterar a estrutura do catálogo.
