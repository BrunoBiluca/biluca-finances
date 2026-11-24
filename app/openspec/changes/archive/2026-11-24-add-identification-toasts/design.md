# Design

## Context

A página de identificações ([accountability_identifications_page.dart](../../../../lib/app/accountability_identifications/accountability_identifications_page.dart)) recebe criação, edição e exclusão por meio de `IdentificationCategoriesBloc`. As operações são assíncronas: o modal chama `bloc.add(...)` e fecha antes de a persistência ser concluída, então o retorno visual precisa nascer do resultado da operação, não do fechamento do modal.

O projeto já possui um design system de toasts em [base_toast.dart](../../../../lib/common/ui/base_toast.dart) (`BaseToast` + `BaseToastType`), registrado no `GetIt` como `FToast`, e a página de prestação de contas já usa esse padrão com um contador de versão no estado e um `BlocListener`. A mudança reutiliza essa infraestrutura.

## Goals / Non-Goals

**Goals:**
- Confirmar visualmente o sucesso de criação, edição e exclusão de identificações.
- Manter o retorno visual desacoplado das operações existentes.

**Non-Goals:**
- Alterar o fluxo de criação, edição ou exclusão.
- Adicionar toasts de erro ou de validação.
- Introduzir novas dependências.

## Decisions

### Sinalizar o sucesso por contadores de versão no estado

O estado `IdentificationCategoriesState` ganha três contadores — `creationVersion`, `updateVersion` e `deletionVersion` — incrementados pelo bloc após a operação e a recarga concluírem com sucesso.

- **Alternativa considerada:** exibir o toast nos callbacks `onSave`/`onDelete` do modal. Rejeitada porque os callbacks disparam antes de a persistência terminar e o contexto do modal é destruído ao fechar.
- **Alternativa considerada:** estados dedicados de sucesso (por exemplo, `IdentificationCreated`). Rejeitada por adicionar complexidade ao fluxo de estados sem ganho: o padrão de contador já é usado pela página de prestação de contas.

### Exibir os toasts em um `BlocListener` na página

A página passa a envolver o `BlocBuilder` com um `BlocListener` que escuta mudanças nos três contadores e dispara `GetIt.I<FToast>().showToast(...)` com `BaseToast`.

- Tipo `BaseToastType.success`, gravidade `ToastGravity.BOTTOM_RIGHT` e duração de 2 segundos, consistentes com o toast de sucesso já existente.
- Mensagens em português: "Identificação criada com sucesso", "Identificação atualizada com sucesso" e "Identificação excluída com sucesso".

### Não alterar os eventos nem o fluxo das operações

Os eventos `CreateIdentificationCategory`, `UpdateIdentificationCategory` e `DeleteIdentificationCategory` continuam com o mesmo contrato. O incremento do contador ocorre após `_reload`, o que garante que o toast reflita uma operação já persistida.

## Risks / Trade-offs

- [Toast acionado em reabertura da página por estado inicial] → Mitigação: os contadores começam em zero e o `BlocListener` usa `listenWhen` comparando o valor anterior com o atual; apenas incrementos reais disparam o toast.
- [Contadores se misturarem com a recarga de carga inicial] → Mitigação: o incremento ocorre somente nos handlers de criação, edição e exclusão, nunca em `LoadIdentificationCategories`.
