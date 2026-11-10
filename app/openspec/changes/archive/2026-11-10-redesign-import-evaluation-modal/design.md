# Design

## Context

O modal atual em `lib/app/accountability_import_verification/accountability_import_verification.dart` usa `BaseDialog` (um `AlertDialog`) com uma área rolável e duas tabelas de altura fixa (400 px), uma para novas entradas e outra para duplicados. A página `AccountabilityPage` já envolve o modal em um `BlocProvider<AccountabilityBloc>`, carrega as identificações e chama `importService.import(file)` antes de abri-lo.

O `AccountabilityTable` já suporta edição em linha (`enableInlineEditing`), lista de identificações, data de inserção, ícone e texto da ação de remoção, e ocupa a altura disponível quando recebe uma restrição de altura. Os temas registrados em `ThemeManager` expõem superfícies, tipografia e as cores semânticas `AppColors` usadas pelos valores da tabela. O `AccountabilityImportService` mantém `entries` e `duplicatedEntries` e não armazena o nome do arquivo importado.

A referência visual está em `openspec/sources/accountability-import-evaluation-modal/accountability-import-evaluation-modal.html`. Ver `proposal.md` para a motivação e os deltas de especificação para o contrato de comportamento.

## Goals / Non-Goals

**Goals:**
- Estruturar o modal em cabeçalho, abas, corpo expansível e rodapé, com a tabela ocupando todo o espaço vertical disponível.
- Exibir nome do arquivo e saldo líquido das novas entradas, recalculado a cada alteração confirmada.
- Reaproveitar o `AccountabilityTable` e o padrão de edição em linha já usado na página principal.
- Usar as superfícies, tipografia e cores semânticas do tema ativo.
- Preservar o salvamento de todas as novas entradas, o descarte de duplicatas e o cancelamento sem gravação.

**Non-Goals:**
- Filtros, seleção de registros, paginação ou carregamento incremental.
- Explicação ou listagem das regras aplicadas.
- Alterações nas regras de importação, no serviço de importação, na persistência ou no formato do arquivo.
- Controles da referência que não existem no fluxo atual, como o checkbox de aprendizado de padrões e a categorização em massa.
- Alterar os campos editáveis ou as validações da tabela.

## Decisions

- **Trocar `BaseDialog` por `Dialog` com restrições explícitas de tamanho.** O `AlertDialog` não acompanha a altura necessária para as abas e a tabela. O novo modal usa um `Dialog` com `insetPadding`, largura máxima de 1400 px, altura de 92% da viewport limitada a 960 px e um `Column` com cabeçalho, abas, `Expanded` para o corpo e rodapé. O `dialogTheme` do tema ativo fornece fundo, borda e arredondamento. Alternativa considerada: manter o `BaseDialog` e aumentar as alturas fixas, mas isso impediria a tabela de ocupar todo o espaço vertical e de se adaptar à viewport.

- **Receber o nome do arquivo pela página, sem alterar o serviço de importação.** `AccountabilityImportVerification` passa a aceitar um `sourceFileName` informado por `AccountabilityPage.importEntries` a partir de `result.files.single.name`. O modal usa um texto padrão quando o nome não é informado, para permitir testes e reuso. Alternativa considerada: guardar o arquivo ou o nome no `AccountabilityImportService`, o que mudaria a interface do núcleo e os testes de importação sem necessidade para a apresentação.

- **Derivar o saldo líquido das novas entradas.** O saldo é a soma de `service.entries[].value`, calculada no `build`; `setState` após edição, remoção ou `cancelDuplication` força o recálculo. As cores vêm de `ThemeManager.getCurrentTheme(context).colors` (positivo, negativo, neutro), como já ocorre na coluna de valores. A cor não é fixa na referência, pois deve acompanhar o tema ativo. Rascunhos de edição não alteram o saldo enquanto não forem confirmados.

- **Usar `DefaultTabController`, `TabBar` e `TabBarView` dentro de um `Expanded`.** As três abas são Novas Entradas (índice inicial), Registros Duplicados e Regras Aplicadas. O `TabBar` usa o `tabBarTheme` do tema e cada aba de dados exibe a quantidade de registros. O `TabBarView` recebe altura limitada do `Expanded`; cada aba de dados é a própria `AccountabilityTable` com preenchimento ao redor, e a aba de regras é um `Center` com o aviso de construção. Alternativa considerada: um `IndexedStack` controlado manualmente, mas o `TabBarView` aproveita o tema e mantém a navegação padrão.

- **Reutilizar o `AccountabilityTable` com edição em linha.** Passar `enableInlineEditing: true`, `identifications` vindas de `AccountabilityBloc`, `onUpdate` e `onRemove` atuais. Isso expõe a ação de editar na tabela, mantém as mesmas validações e reaproveita o seletor de identificações, sem introduzir novos campos. Para a aba de duplicados, manter `showInsertedAt: true`, o ícone de seta para cima e o texto “Desconsiderar duplicata”. Alternativa considerada: manter a edição por toque em diálogos, que funciona, mas não acompanha a referência nem o padrão visual já adotado na página principal.

- **Não habilitar seleção, filtros ou paginação.** O modal deve receber todas as entradas e todos os duplicados e não deve informar `onLoadMore`. Assim, a tabela lista todos os registros, e todas as novas entradas continuam sendo importadas sem checkboxes.

- **Separar as responsabilidades visuais em widgets da funcionalidade.** O arquivo principal mantém o estado e a orquestração; cabeçalho, abas/corpo e aviso de regras ficam em `lib/app/accountability_import_verification/widgets/`. Isso segue a organização por funcionalidade da constituição do projeto, que já usa `widgets/` em `accountability_table`.

- **Manter o `BlocProvider` na página.** O modal depende de `AccountabilityBloc` para carregar as identificações usadas pelo selo e pelo seletor. A página continua fornecendo o bloco ao redor do modal, e o modal lê `AccountabilityState.identifications` para repassar à tabela.

- **Preservar os rodapés existentes.** As ações continuam sendo “Cancelar” (fecha sem chamar `save`) e “Salvar” (chama `service.save()` e fecha). O contador de entradas pode ser exibido como informação, mas nenhuma nova ação de salvamento é introduzida.

- **Manter a consistência visual dos botões do rodapé.** O botão “Salvar” usa o mesmo `borderRadius` do botão contornado do tema (8 px), conforme o padrão já adotado na página, e inclui um ícone de confirmação. Novos botões preenchidos do modal devem seguir esse mesmo raio.

## Risks / Trade-offs

- [O modal muito alto pode ficar apertado em viewports pequenas] → Usar altura relativa à viewport, `insetPadding` e rolagem interna da tabela; verificar em testes de widget com alturas diferentes.
- [A tabela tem largura mínima de 900 px e pode exigir rolagem horizontal em telas estreitas] → Preservar a rolagem horizontal existente do `AccountabilityTable` e validar que o modal não gera overflow.
- [Editar um lançamento pendente de importação pode não persistir se o fluxo de salvamento não for mantido] → Reutilizar o mesmo `onUpdate` sobre `AccountabilityEntryRequest` e cobrir com teste de widget o salvamento após a edição.
- [O saldo líquido pode ficar inconsistente se o estado não for reconstruído após alterações] → Recalcular no `build` a partir da lista do serviço e chamar `setState` nos callbacks de atualização e remoção.
- [A dependência do `AccountabilityBloc` para identificações pode quebrar quando o modal for usado isoladamente] → Manter o `BlocProvider` na página e cobrir o modal nos testes com um bloco de teste.
- [A referência usa cores fixas que não acompanham o tema] → Usar `Theme.of(context)`, `ThemeManager` e `AppColors`; não copiar os valores hexadecimais da referência.

## Migration Plan

Não há migração de dados, alteração de esquema ou nova dependência. A mudança é de apresentação e de interação do modal, pode ser revertida apenas nos widgets da funcionalidade e não altera o serviço de importação nem os lançamentos persistidos.
