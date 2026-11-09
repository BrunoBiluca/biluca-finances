# Tasks

## 1. Validar o formulário de nova entrada

- [x] 1.1 Validar descrição não vazia após remover espaços, valor monetário presente e interpretável e data dentro do intervalo permitido; exibir os erros no formulário e mantê-lo aberto quando inválido. Criar `test/app/accountability/accountability_new_entry_form_test.dart` e verificar campos ausentes, descrição em branco, valor inválido, valores válidos (incluindo zero e negativo), data válida e envio dos três campos.

## 2. Corrigir e testar a criação pela página

- [x] 2.1 Resolver a categorização automática por `AccountabilityIdentificationPredictionService`, mantendo o pedido original quando a previsão não retornar resultado; atualizar o teste de página para registrar somente a abstração e verificar a criação de uma entrada válida sem exceção.
- [x] 2.2 Sinalizar no BLoC a criação somente após `repo.add` concluir e exibir uma única vez o toast "Registro criado com sucesso" no canto inferior direito; usar destaque verde para sucesso, azul-claro para informação e vermelho para erro no texto, ícone e borda, mantendo fundo igual ao `scaffoldBackgroundColor` e tipografia do tema ativo. Testar as três categorias sem alterar quando cada mensagem é exibida e confirmar ausência de toast de sucesso em caso de falha.
- [x] 2.3 Executar os testes Flutter do toast, da página e do formulário e confirmar que cobrem mensagem, posição, cores das três categorias e estilos do tema, além dos fluxos de formulário, criação e importação de extratos.
