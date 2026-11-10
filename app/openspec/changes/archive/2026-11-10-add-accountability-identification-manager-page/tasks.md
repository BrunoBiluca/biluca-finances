# Tasks

## 1. Modelo e persistência

- [x] 1.1 Acrescentar `parentId` e `discontinued` a `AccountabilityIdentification`, com valores padrão e leitura tolerante a mapas antigos; verificar com teste unitário de `fromMap`/`toMap` para um mapa legado e para um mapa com os campos novos.
- [x] 1.2 Adicionar ao `DBProvider` as migrações `parent_id TEXT` e `discontinued INTEGER NOT NULL DEFAULT 0` e incluir os campos nas escritas e leituras de `SQLiteAccountabilityRepo`; verificar com testes de repositório que gravam e releem categoria pai, status, tipo, ícone e cor e que registros antigos assumem raiz e ativa.
- [x] 1.3 Fazer `deleteIdentification` executar em transação a desidentificação dos lançamentos da categoria, a promoção das categorias filhas a raízes e a exclusão da categoria; verificar com teste de repositório que os lançamentos permanecem com descrição, valor e data de criação, ficam sem identificação e que as filhas continuam existindo como raízes.
- [x] 1.4 Implementar `IdentificationHierarchyRules` com as validações de categoria pai (existente, raiz, diferente da própria categoria e sem filhas na categoria editada) e com a lista de pais elegíveis conforme o status da categoria; verificar cada regra com testes unitários, incluindo categoria ativa com pai descontinuado e categoria descontinuada com pai descontinuado.
- [x] 1.5 Implementar `IdentificationStatusRules` para impedir descontinuar uma categoria pai com subcategorias ativas e impedir reativar uma subcategoria cujo pai está descontinuado; verificar com testes unitários as transições válidas e inválidas e os dois caminhos de liberação (promover a raiz ou descontinuar as filhas).
- [x] 1.6 Implementar `IdentificationAvailabilityRules` e `IdentificationConsolidation`; verificar com testes unitários a exclusão de descontinuadas das opções, a manutenção da identificação atual descontinuada e as quatro contagens de consolidação.

## 2. Estado, navegação e página

- [x] 2.1 Criar `IdentificationCategoriesBloc` com eventos de carregar, criar, atualizar e excluir identificação, registrar a fábrica no contêiner e cobrir cada evento com teste de bloc usando repositório falso.
- [x] 2.2 Registrar a rota `/identifications` e o item "Identificações" no menu lateral; verificar com teste de widget que o item abre a página e mantém a navegação compartilhada.
- [x] 2.3 Montar a página com título, subtítulo, ação de criar identificação e as quatro caixas de consolidação; verificar com teste de widget os valores de total, categorias pai, subcategorias e descontinuadas e a atualização após uma criação, edição e exclusão.
- [x] 2.4 Implementar a barra de abas "Todas as categorias", "Categorias ativas" e "Categorias descontinuadas", abrindo na primeira e exibindo mensagem quando a aba estiver vazia; verificar com teste de widget cada filtro e a aba vazia.
- [x] 2.5 Implementar a lista hierárquica agrupada, a apresentação de subcategoria sem o pai visível como item de topo e o tratamento visual atenuado de categorias descontinuadas; verificar com teste de widget o agrupamento, a subcategoria fora do grupo, os selos de status e a ausência de valores agregados.
- [x] 2.6 Ajustar a composição para larguras estreitas; verificar com teste de widget em largura reduzida que consolidações, abas e lista continuam acessíveis sem erro de layout.

## 3. Modal de criação, edição e exclusão

- [x] 3.1 Criar a modal com cabeçalho, nome, categoria pai, status, tipo, ícone, cor e ações de cancelar, salvar e excluir (excluir somente na edição); verificar com teste de widget que os valores atuais são apresentados, que somente esses campos existem e que cancelar ou fechar não persiste.
- [x] 3.2 Persistir a edição de todos os campos (nome, categoria pai, status, tipo, ícone e cor) e atualizar lista e consolidações; verificar com teste de widget o salvamento de cada campo e o erro de nome vazio.
- [x] 3.3 Abrir a criação pela ação da página com nome vazio, sem pai, status ativa, tipo despesa, ícone e cor padrão, salvar uma categoria raiz e refletir na lista e nas consolidações; verificar com teste de widget o fluxo completo, o cancelamento e o nome obrigatório.
- [x] 3.4 Abrir a criação pela ação "Adicionar subcategoria" de uma categoria pai ativa, com o pai pré-selecionado, salvar e exibir a nova subcategoria no grupo; verificar com teste de widget a pré-seleção, a ausência da ação em categorias pai descontinuadas e o agrupamento após salvar.
- [x] 3.5 Filtrar as categorias pai elegíveis, desabilitar o controle para categorias com filhas e apresentar as mensagens das validações de hierarquia; verificar com testes de widget os cenários de pai inválido, categoria com filhas e remoção do vínculo para tornar a categoria raiz.
- [x] 3.6 Aplicar a consistência entre status e hierarquia: impedir descontinuar categoria pai com subcategoria ativa, permitir após promover as subcategorias a raiz ou descontinuá-las, impedir subcategoria ativa sob pai descontinuado e impedir reativação de subcategoria com pai descontinuado; verificar cada cenário com teste de widget e a mensagem apresentada.
- [x] 3.7 Implementar a exclusão a partir do rodapé da modal de edição, com confirmação que descreve a desidentificação dos lançamentos e a promoção das subcategorias; verificar com teste de widget a confirmação, o cancelamento sem efeitos, a remoção da categoria, a atualização da lista e das consolidações e o fechamento da modal.

## 4. Seletor, lançamentos e importação

- [x] 4.1 Reduzir `AccountabilityIdentificationSelector` à seleção: remover criação, edição de nome/ícone/cor/tipo e exclusão, remover a dependência do `AccountabilityBloc`, receber a identificação atual e aplicar `IdentificationAvailabilityRules`; verificar com teste de widget a busca, a seleção, a ausência de ações de gerenciamento, o filtro de descontinuadas e a manutenção da identificação atual descontinuada.
- [x] 4.2 Manter o dropdown da edição em linha apenas selecionando e usar a mesma regra de disponibilidade; verificar com teste de widget que categorias descontinuadas não são oferecidas em novas seleções e que o vínculo atual é preservado ao salvar.
- [x] 4.3 Aplicar a mesma restrição na conferência de importação; verificar com teste de widget que as opções de novas entradas e duplicatas excluem descontinuadas, mantêm a identificação descontinuada já vinculada e não oferecem gerenciamento de categorias.
- [x] 4.4 Ignorar categorias descontinuadas na categorização automática, deixando a entrada sem identificação quando não houver correspondência ativa; verificar com teste do serviço de previsão ou da função pura de disponibilidade usada por ele.
- [x] 4.5 Confirmar que filtros da prestação de contas e relatórios continuam lendo categorias descontinuadas; verificar com teste de widget que uma categoria descontinuada permanece entre os filtros de lançamentos.
- [x] 4.6 Confirmar que lançamentos da categoria excluída permanecem na tabela e são apresentados como "Não identificado"; verificar com teste de widget e com o teste de repositório da tarefa 1.3.
- [x] 4.7 Remover os eventos e tratadores `UpdateAccountabilityIdentification` e `DeleteAccountabilityIdentification` sem uso no `AccountabilityBloc`; verificar que `flutter analyze` não aponta referências e que os testes do bloc continuam passando.

## 5. Integração e validação

- [x] 5.1 Executar `flutter analyze` e corrigir os avisos introduzidos pela mudança; confirmar saída sem erros.
- [x] 5.2 Executar `flutter test` e confirmar que a suíte completa passa, incluindo os testes de repositório, regras, página, modal, exclusão, seletor, seletores e navegação.
- [x] 5.3 Executar `openspec validate "add-accountability-identification-manager-page" --type change --strict` e corrigir avisos ou erros dos artefatos.

## 6. Correções visuais

- [x] 6.1 Aplicar borda de 1px na cor `#272D36` e raio de 6px aos blocos de categoria e formato pill aos badges; verificar com teste de widget a espessura, a cor e o raio das bordas dos blocos, sem acoplar o teste a outros detalhes visuais.
- [x] 6.2 Tornar o fundo das subcategorias mais claro que o fundo do bloco da categoria pai; verificar com teste de widget que a luminância do fundo da subcategoria é maior que a do pai nos temas escuro e claro.
- [x] 6.3 Aumentar a caixa das abas e posicionar o filtro por tipo à direita, reorganizando-o abaixo em telas estreitas; verificar com teste de widget a presença dos controles, a ordem em largura ampla, a quebra em largura reduzida e a ausência de overflow.

## 7. Filtro por tipo

- [x] 7.1 Adicionar o estado do filtro por tipo com Todos, Receita, Despesa e Investimento, combinando-o com a aba de status e recalculando os contadores das abas; verificar com teste de widget a filtragem combinada, os contadores e a permanência das consolidações globais.
- [x] 7.2 Garantir a opção Todos e o estado vazio quando a combinação de aba e tipo não possuir categorias; verificar com teste de widget a limpeza do filtro e a mensagem de lista vazia.

## 8. Tipo da subcategoria

- [x] 8.1 Implementar `IdentificationTypeRules` com o tipo herdado do pai, a validação de igualdade e a produção das filhas com o tipo propagado; verificar cada regra com testes unitários, incluindo pai com e sem filhas.
- [x] 8.2 Atualizar a modal para herdar e bloquear o tipo da subcategoria, atualizar o tipo ao trocar a categoria pai e liberar a edição ao remover o vínculo; verificar com testes de widget os cenários de criação, edição e promoção a raiz.
- [x] 8.3 Propagar em cascata o tipo alterado de uma categoria pai para suas subcategorias no `IdentificationCategoriesBloc` antes de recarregar a lista; verificar com teste de bloc que todas as filhas são persistidas com o novo tipo.
- [x] 8.4 Validar e normalizar o tipo divergente ao salvar uma categoria com pai; verificar com teste que a modal bloqueia a divergência e que o salvamento mantém a igualdade de tipo.

## 9. Integração e validação das correções

- [x] 9.1 Executar `flutter analyze` e confirmar que as correções não introduziram erros.
- [x] 9.2 Executar `flutter test` e confirmar que a suíte completa passa, incluindo os novos testes de filtro, tipo e apresentação.
- [x] 9.3 Executar `openspec validate "add-accountability-identification-manager-page" --type change --strict` e corrigir avisos ou erros dos artefatos.

## 10. Ordenação e transparência das descontinuadas

- [x] 10.1 Ordenar as categorias raiz e as subcategorias com ativas antes das descontinuadas e, dentro de cada status, por descrição; verificar com teste de widget a posição dos grupos e das subcategorias na aba Todas, inclusive com filtro de tipo.
- [x] 10.2 Aplicar opacidade 0.9 às categorias pai descontinuadas e 0.8 às subcategorias descontinuadas, mantendo as ativas com opacidade 1; verificar com teste de widget que somente as descontinuadas recebem a transparência.

## 11. Integração e validação da ordenação e transparência

- [x] 11.1 Executar `flutter analyze` e confirmar que as novas alterações não introduziram erros.
- [x] 11.2 Executar `flutter test` e confirmar que a suíte completa passa, incluindo os testes de ordenação e transparência.
- [x] 11.3 Executar `openspec validate "add-accountability-identification-manager-page" --type change --strict` e corrigir avisos ou erros dos artefatos.

## 12. Correções dos campos e seletores da modal

- [x] 12.1 Aplicar borda de 1px na cor `#272D36` aos campos da modal, usar `#3A424C` no foco e a cor de erro do tema nas validações; verificar com teste de widget as bordas normal, de foco e de erro de um campo.
- [x] 12.2 Corrigir o seletor de ícones com um catálogo próprio de ícones Material, cor explícita, limites e seleção atualizando a pré-visualização; verificar com teste de widget que a grade exibe ícones e que a seleção altera o ícone da modal.
- [x] 12.3 Exibir ícone e cor no campo de categoria pai, no mesmo formato da tabela, inclusive no valor selecionado; verificar com teste de widget as opções e o valor escolhido.
- [x] 12.4 Compactar o seletor de cor com rolagem e campo hexadecimal, sem ultrapassar a área da modal; verificar com teste de widget a entrada hexadecimal, o salvamento e a ausência de overflow em altura reduzida.

## 13. Integração e validação da modal

- [x] 13.1 Executar `flutter analyze` e confirmar que as correções da modal não introduziram erros.
- [x] 13.2 Executar `flutter test` e confirmar que a suíte completa passa, incluindo os testes dos campos, ícones, categoria pai e cor.
- [x] 13.3 Executar `openspec validate "add-accountability-identification-manager-page" --type change --strict` e corrigir avisos ou erros dos artefatos.

## Workflow follow-up

- Arquivar a mudança após a revisão e a implementação aprovadas.
- Conferir a apresentação final da página e da modal contra `openspec/sources/accountability-identification-manager-page/` antes de arquivar.