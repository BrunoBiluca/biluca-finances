# Tasks

## 1. Estrutura do catálogo

- [x] 1.1 Criar `docs/Projeto/Fase 2 - Re-design/Melhorias priorizadas.md` com título, resumo do objetivo, data da avaliação e seção "Critério de pontuação" descrevendo a fórmula (impacto 0–4 + alcance 0–3 + facilidade 0–3, limitada a 1–10) e verificando que o arquivo abre no Obsidian sem links quebrados
- [x] 1.2 Adicionar ao documento a seção "Como usar este catálogo", com o ciclo de status (`proposta` → `selecionada` → `em implementação` → `implementada`; ou `descartada`), a regra de IDs estáveis e a orientação de que uma seleção vira uma mudança OpenSpec citando os IDs, verificando que o texto cobre as quatro transições e a regra de não renumerar
- [x] 1.3 Registrar a decisão de escopo com a data e as listas de selecionadas (U02, U05, U07, U09, U10, U11, U12, U13 e C01–C16) e descartadas (U01, U03, U04, U06 e U08, com o motivo "não selecionada nesta rodada"), conferindo que as duas listas cobrem os 29 itens sem repetição

## 2. Melhorias de experiência de uso

- [x] 2.1 Registrar a tabela U01–U07 com ID, título, nota, esforço, evidência, dependências e status da decisão (`selecionada` para U02, U05 e U07; `descartada` para U01, U03, U04 e U06), conferindo que cada linha tem nota entre 1 e 10 e evidência com arquivo ou símbolo
- [x] 2.2 Registrar a tabela U08–U13 com os mesmos campos e as mesmas conferências, marcando U08 como `descartada` e U09–U13 como `selecionada`

## 3. Melhorias de código

- [x] 3.1 Registrar a tabela C01–C08 com ID, título, nota, esforço, evidência, dependências e status `selecionada`, conferindo nota entre 1 e 10 e evidência com arquivo ou símbolo
- [x] 3.2 Registrar a tabela C09–C16 com os mesmos campos e conferências, garantindo que os 16 itens de código estejam presentes, todos como `selecionada` e sem IDs repetidos

## 4. Ondas, dependências e rastreabilidade

- [x] 4.1 Adicionar a seção "Ondas recomendadas" com as quatro ondas apenas de itens selecionados — Onda 1 (C01, C02, C05, C11, C12, C13, C14, C15), Onda 2 (C03, C04, C06, C07, C09, C10, C16), Onda 3 (U02, U05, U07, U09, U10, U11) e Onda 4 (U12, U13, C08) — verificando que cada item selecionado aparece em exatamente uma onda e que nenhum item descartado aparece nelas
- [x] 4.2 Adicionar a seção "Dependências" com as relações registradas no design (U02←C04/C10, U07←C10, U11←C03/C09, U12←C10, U13←C04, U05 junto de C03/C06) e conferir que nenhuma dependência cita ID inexistente ou descartado

## 5. Integração com a documentação e verificação final

- [x] 5.1 Vincular o catálogo na seção de escopo de `docs/Projeto/Fase 2 - Re-design/Fase 2 - Re-design.md` com wikilink para `[[Melhorias priorizadas]]` e verificar que o link resolve no Obsidian
- [x] 5.2 Revisar o documento final conferindo que há 13 itens de experiência e 16 de código catalogados, com 8 + 16 marcados como `selecionada`, 5 como `descartada` com motivo, notas válidas, evidências rastreáveis e nenhuma alteração em `lib/`, `test/` ou `pubspec.yaml`
- [x] 5.3 Executar `openspec validate "catalog-project-improvements" --type change --strict` e verificar que a mudança é considerada válida

## Workflow follow-up

- Iniciar a mudança de implementação da Onda 1 (C01, C02, C05, C11, C12, C13, C14, C15), pré-requisito de baixo risco das demais ondas.
- Para cada onda selecionada, criar a mudança de implementação citando os IDs no `proposal.md`.
- Ao arquivar cada mudança de implementação, atualizar o status dos itens correspondentes no catálogo para `implementada`.
- Arquivar esta mudança após a revisão do projeto.
