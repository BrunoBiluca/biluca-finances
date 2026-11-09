# Proposal

## Why

A edição em linha da tabela de prestação de contas funciona, mas seus campos e a identificação não têm o acabamento visual da referência fornecida. A atualização deve melhorar a leitura do estado de edição e a distinção visual dos valores e identificações sem alterar os fluxos existentes.

## What Changes

- Atualizar a apresentação dos campos de edição em linha conforme `openspec/sources/accountability-table-page/code.html`, sem incluir rótulos individuais acima dos campos.
- Aplicar à coluna de valores as cores semânticas da paleta `AppColors`, distinguindo valores positivos, negativos e neutros.
- Redesenhar o selo `AccountabilityIdentificationLabel` e as opções do seletor de identificações; cada opção exibirá ícone, cor e descrição.
- Exibir o indicador “Editando” no canto superior da linha que está sendo editada.
- Preservar integralmente o comportamento atual de edição, validação, salvamento, cancelamento e demais operações da tabela.

## Capabilities

### New Capabilities

### Modified Capabilities
- `accountability-ledger`: especificar a apresentação da linha e dos campos durante a edição, as cores dos valores e a apresentação de identificações na tabela e no seletor.

## Impact

- Interface Flutter em `lib/app/accountability_table/`, incluindo a tabela, o selo e o seletor de identificações.
- Cores disponibilizadas por `AppColors` nos temas existentes.
- Testes de widgets da prestação de contas para confirmar a nova apresentação e preservar os fluxos de edição.
- Sem alterações planejadas a regras de negócio, APIs, dependências ou fluxo de importação.
