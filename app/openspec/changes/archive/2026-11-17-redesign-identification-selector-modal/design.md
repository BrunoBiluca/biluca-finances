# Design

## Context

Consulte `proposal.md` para a motivação e `specs/accountability-ledger/spec.md` para o contrato de comportamento. O seletor atual usa `BaseDialog`, recebe as identificações e a identificação atual e é aberto pelo selo da célula da tabela. A linha já dispõe da descrição e do valor do lançamento, mas esses dados não chegam ao seletor. A rota `/identifications` já abre a página dedicada de configurações.

A referência HTML usa um cabeçalho com resumo do lançamento, busca, lista rolável e rodapé. Ela também mostra controles de criação, edição e exclusão que não devem ser levados para este seletor.

## Goals / Non-Goals

**Goals:**

- Reorganizar o conteúdo do seletor para manter cabeçalho e resumo do lançamento distintos da área rolável de resultados, com cabeçalho e rodapé na cor do fundo da página e maior espaçamento para o conteúdo.
- Exibir nome e descrição auxiliar das identificações sem sacrificar a navegação por lista longa.
- Manter busca, seleção imediata e navegação por teclado, adicionando acesso à página dedicada.

**Non-Goals:**

- Criar ou alterar categorias, subcategorias, filtros por tipo ou regras de disponibilidade.
- Mudar a página de gerenciamento, a persistência dos lançamentos ou o comportamento de edição da tabela.
- Adicionar testes que verifiquem apenas detalhes de aparência.

## Decisions

1. **Manter o seletor no fluxo atual de diálogo.** Reutilizar o acionamento pela célula de identificação e o `MouseBackButtonListener`. Usar um `Dialog` local em vez de `BaseDialog`, pois o componente compartilhado não expõe superfícies independentes para cabeçalho e rodapé. Manter a superfície e a forma fornecidas pelo tema do diálogo, aplicando `Theme.scaffoldBackgroundColor` às faixas de cabeçalho e rodapé.

2. **Separar visualmente o conteúdo das faixas.** Manter o cabeçalho e o rodapé fora da área rolável e acrescentar padding vertical entre essas faixas e a busca/lista, preservando os limites responsivos do modal.

3. **Passar o contexto do registro a partir da linha.** Encaminhar ao seletor a descrição apresentada na tabela e o valor numérico do lançamento, formatando o valor com o formatador existente. Assim, o modal não precisa conhecer nem buscar novamente o modelo do lançamento.

4. **Usar a navegação existente para configurações.** O acesso do modal leva à rota `/identifications`, sem adicionar operações de gerenciamento à lista. Fechar o diálogo antes de navegar evita deixar um overlay aberto sobre a página de configuração e mantém a página de lançamentos como destino de retorno.

5. **Derivar o destaque lateral da rota ativa.** O menu não deve manter uma cópia local independente da página selecionada; deve usar a localização atual do GoRouter para identificar o item destacado. Isso mantém o menu correto ao navegar via `push` do modal e ao voltar.

6. **Preservar a busca e a navegação do seletor.** Manter a busca existente por nome e a seleção por toque. Setas para cima/baixo atualizam o destaque e mantêm a opção destacada visível; a navegação percorre resultados filtrados, envolve nos extremos e Enter seleciona somente quando existe uma opção destacada. Não adotar os chips da referência: seus grupos não correspondem diretamente aos tipos existentes no domínio e não foram solicitados.

7. **Manter o limite entre seleção e gerenciamento.** As opções continuam apresentando os atributos e a descrição auxiliar já suportados, mas não incluem botões de criar, editar ou excluir. A página dedicada continua sendo o único lugar para administrar categorias.

## Risks / Trade-offs

- **Descrições ou nomes longos podem pressionar a largura do modal.** Usar dimensões limitadas pelo espaço disponível, permitir quebra de texto nos detalhes e manter a lista rolável; validar em tamanhos estreitos com testes de comportamento, sem assertivas de pixels.
- **A navegação ao sair do diálogo pode deixar a localização de retorno ambígua.** Usar a pilha de navegação existente para voltar à página de lançamentos e cobrir o acionamento do acesso em teste de navegação.
- **A navegação por teclado pode destacar uma opção fora da tela após uma busca.** Reiniciar o destaque quando os resultados mudarem e manter a opção ativa visível durante o movimento pelas setas.

## Migration Plan

Não há migração de dados nem mudança de dependências. A implementação altera apenas a apresentação e a passagem de contexto no fluxo da tabela; rollback consiste em reverter essas alterações e o delta correspondente, preservando o formato dos lançamentos.

## Open Questions

Nenhuma.
