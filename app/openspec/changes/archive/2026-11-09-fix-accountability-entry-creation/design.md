# Design

## Context

Veja `proposal.md` para a motivação e `specs/accountability-ledger/spec.md` para os comportamentos requeridos. O formulário atual inicializa a data com hoje e o seletor restringe as escolhas de 2022 até hoje. Os campos usam `PrimaryTextField`, que valida somente texto exatamente vazio; o valor é convertido por `RealInputFormatter.parse`, que pode lançar uma exceção. No fluxo da página, a criação consulta a classe concreta `EmbeddedPredictService`, enquanto `setup()` registra a implementação sob `AccountabilityIdentificationPredictionService`. O BLoC persiste a entrada e atualiza os resultados, mas não publica um resultado explícito de criação bem-sucedida; a página já usa `FToast` e `BaseToast` para confirmar a importação.

## Goals / Non-Goals

**Goals:**
- Apresentar erros junto ao campo inválido e impedir que uma entrada incompleta ou inválida seja enviada.
- Converter valores válidos com o formatador existente sem propagar erro de parse para a interface.
- Resolver a categorização automática pelo contrato que a injeção de dependências já registra e ainda permitir salvar sem identificação automática.
- Informar sucesso somente após a persistência do novo registro ser confirmada.

**Non-Goals:**
- Alterar regras de categorização, persistência, edição ou o formato monetário aceito atualmente.
- Alterar a importação e conferência de extratos PDF.
- Alterar as condições ou o momento em que mensagens de sucesso, informação ou erro são exibidas.
- Adicionar dependências ou mudar o modelo de dados.

## Decisions

- **Validar no formulário antes de fechar o diálogo.** Manter o estado dos erros no formulário e validar os campos no salvamento; a descrição também deve ser avaliada após remover espaços nas extremidades. Isso evita enviar dados inválidos e permite corrigir cada campo sem perder o preenchimento. A validação da data deve respeitar as datas permitidas pelo seletor, que inicia com hoje e limita a escolha ao intervalo já oferecido.
- **Preservar o formatador para valores monetários.** Interpretar o texto com `RealInputFormatter` somente após verificar que não está vazio e tratar erros de conversão como validação do campo, não como exceção da ação de salvar. Valores finitos, incluindo zero e valores negativos, continuam válidos para representar lançamentos neutros ou despesas.
- **Injetar o serviço pelo contrato registrado.** O fluxo de nova entrada deve solicitar `AccountabilityIdentificationPredictionService`, evitando registrar outra instância ou acoplar a página à implementação concreta. Quando a categorização automática não produzir um resultado, o pedido original deve continuar disponível para persistência sem identificação.
- **Sinalizar a persistência bem-sucedida pelo BLoC.** Publicar um resultado explícito de criação somente depois de `repo.add` concluir. A interface consome esse resultado uma única vez e exibe `Registro criado com sucesso` no canto inferior direito; falhas de persistência não geram a confirmação.
- **Diferenciar categorias do toast.** `BaseToast` deve receber uma categoria semântica e usar destaque verde para sucesso, azul-claro para informação e vermelho para erro no texto, ícone e borda. Manter o fundo da aplicação (`Theme.of(context).scaffoldBackgroundColor`) e a tipografia do tema. Preferir tokens semânticos do tema e adicionar um token quando necessário, sem fixar cores no widget; a categoria não altera quando a mensagem é exibida.
- **Testar formulário e integração da página.** Cobrir campos vazios, texto de descrição em branco, valor inválido, datas válidas, o toast exato após persistência, posicionamento, cores das três categorias e estilos do tema, além da ausência de toast de sucesso em caso de falha. Incluir o fluxo com o serviço registrado somente sob a abstração e manter um teste de regressão da importação.

## Risks / Trade-offs

- [O formato aplicado pelo `RealInputFormatter` pode tornar valores inválidos difíceis de inserir pela interface.] → Testar a conversão com os formatos monetários aceitos e exercitar o caminho de validação com entradas inválidas sem depender apenas do formatador visual.
- [A categorização automática pode falhar ou retornar sem identificação.] → Tratar a identificação como opcional e manter o pedido original para salvar, conforme o requisito.
- [O intervalo de datas é atualmente fixado a partir de 2022.] → Validar usando o mesmo intervalo do seletor para evitar divergência entre datas selecionáveis e datas aceitas.
- [Um evento de sucesso emitido antes da persistência poderia exibir uma confirmação falsa.] → Emitir e consumir o resultado somente após `repo.add` concluir com sucesso.

## Migration Plan

Não há migração de dados. A alteração é compatível com os registros existentes; entradas novas passarão a ser enviadas somente após validação e poderão permanecer sem identificação quando a categorização automática não retornar uma.
