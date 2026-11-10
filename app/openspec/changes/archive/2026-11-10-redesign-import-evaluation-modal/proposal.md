# Proposal

## Why

O modal de conferência da importação de extratos ainda apresenta as novas entradas e as duplicidades em dois blocos empilhados, sem resumo do arquivo, sem separação por abas e sem aproveitar o padrão visual do tema ativo. Isso dificulta revisar o que será importado e editar os lançamentos antes de salvar.

## What Changes

- Redesenhar o modal de conferência da importação seguindo `openspec/sources/accountability-import-evaluation-modal/accountability-import-evaluation-modal.html`.
- Exibir no topo o título da conferência, o nome do arquivo importado e o saldo líquido das novas entradas.
- Organizar o corpo em três abas: **Novas Entradas**, **Registros Duplicados** e **Regras Aplicadas**.
- Renderizar as abas de dados com o mesmo componente `AccountabilityTable`, ocupando toda a altura vertical disponível do modal, sem paginação, filtros ou seleção de registros.
- Permitir editar descrição, valor e identificação dos registros antes de importar, preservando as validações e operações existentes.
- Exibir a aba **Regras Aplicadas** como “em construção”, sem detalhar regras.
- Aplicar as cores, superfícies e tipografia do tema ativo obtidas pelo `ThemeManager`, incluindo as cores semânticas de `AppColors` para o saldo líquido.
- Preservar o fluxo atual: todos os registros de Novas Entradas continuam sendo importados e o salvamento/cancelamento permanece igual.

## Capabilities

### New Capabilities
- `accountability-import-verification`: Conferência das entradas importadas, com resumo do arquivo, abas de novas entradas e duplicados, edição antes da importação e indicação de regras em construção.

### Modified Capabilities
- `accountability-ledger`: ajustar o cenário de importação e conferência para refletir que a conferência passa a seguir a apresentação redesenhada, mantendo o fluxo de importação.

## Impact

- Modal e componentes em `lib/app/accountability_import_verification/`.
- Página de prestação de contas em `lib/app/accountability_page/accountability_page.dart` para informar o nome do arquivo importado e abrir o novo modal.
- Reuso de `AccountabilityTable` em `lib/app/accountability_table/` e da paleta de `AppColors`/`ThemeManager` em `lib/app/themes/`.
- Testes de widget do modal e dos fluxos de importação existentes, seguindo as ferramentas Flutter já adotadas.
- Sem novas dependências e sem alteração das regras de importação, da persistência ou do formato de arquivo.
