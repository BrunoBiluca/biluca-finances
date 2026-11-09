# Proposal

## Why

Ao criar uma nova entrada, a página solicita `EmbeddedPredictService` ao GetIt, embora a configuração registre o serviço sob sua abstração `AccountabilityIdentificationPredictionService`; isso causa uma exceção antes de a entrada ser adicionada. Além disso, o formulário bloqueia apenas valores vazios e não apresenta validações consistentes para descrição, valor e data.

## What Changes

- Corrigir a resolução do serviço de previsão de identificação no fluxo de criação para usar o tipo registrado na injeção de dependências.
- Validar os campos obrigatórios do formulário de nova entrada e apresentar erros junto aos campos quando a descrição estiver vazia, o valor estiver vazio ou inválido, ou a data não for válida.
- Impedir o envio de uma entrada inválida e manter a criação, inclusive a categorização automática já existente quando aplicável.
- Exibir, no canto inferior direito, um toast com a mensagem "Registro criado com sucesso" somente depois que a persistência do novo registro for concluída. Os toasts devem usar destaque verde para sucesso, azul-claro para informação e vermelho para erro, mantendo o fundo da aplicação e a tipografia do tema ativo.
- Preservar o fluxo de importação de extratos e demais operações da página.

## Capabilities

### New Capabilities

Nenhuma.

### Modified Capabilities

- `accountability-ledger`: definir requisitos para criar entradas com descrição, valor e data válidos e concluir o fluxo sem erro de resolução do serviço de previsão.

## Impact

- Formulário de nova entrada e callback de criação em `lib/app/accountability_new_entry_form/` e `lib/app/accountability_page/accountability_page.dart`.
- Tipo da abstração já registrado em `lib/di_container.dart`, interface e resultado de criação do BLoC em `lib/core/accountability/`.
- Toasts na interface, seguindo o padrão existente de `FToast`: destaque semântico por categoria (sucesso, informação ou erro), fundo da aplicação, tipografia do tema ativo e borda na cor de destaque.
- Testes de widget da página e do formulário.
- Nenhuma mudança de API externa ou de dependências; importação PDF permanece fora do escopo de comportamento.
