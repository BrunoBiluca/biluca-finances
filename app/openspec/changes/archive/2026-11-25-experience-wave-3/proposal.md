# Proposal

## Why

A Onda 3 ("experiência") do catálogo [Melhorias priorizadas](../../../../docs/Projeto/Fase%202%20-%20Re-design/Melhorias%20priorizadas.md) entrega as melhorias de experiência de uso apoiadas na fundação construída na Onda 2: seletor de aparência, filtros de período e de faixa de valor, manutenção do mês/ano selecionado, importação com progresso e falha visível, identificação prevista no formulário e estados vazios/erro com ação. Hoje o aplicativo aplica o tema apenas na inicialização (e o tema claro nunca é usado), a tabela só filtra por texto e categoria, os relatórios reiniciam a seleção a cada abertura, a importação aguarda sem indicador nem tratamento de falha, a categorização automática é aplicada silenciosamente após o formulário e os estados vazios são textos sem ação.

## What Changes

Implementa os itens U02, U05, U07, U09, U10 e U11 do catálogo, citando os IDs no código e nos testes:

- **U02 — Seletor de aparência (claro, escuro, sistema) com persistência:** adicionar seção de aparência em Configurações para escolher o modo, aplicar a mudança imediatamente em tempo de execução e persistir via `PreferencesService`; aplicar corretamente o tema claro já existente (`ObsidianWealthLightTheme`). Antecipa também a persistência do estado recolhido da barra lateral (parte do U12), que já é exigida pela capability `app-preferences`.
- **U05 — Filtros de período e de faixa de valor na tabela, com contagem de resultados:** permitir filtrar os lançamentos por data inicial/final e por valor mínimo/máximo, combináveis com a busca textual e as categorias, e exibir a quantidade de resultados correspondentes.
- **U07 — Manter mês e ano selecionados ao navegar entre páginas:** os relatórios mensal e anual passam a restaurar a seleção persistida em `PreferencesService` e a gravá-la ao alterar, em vez de sempre selecionar o período mais recente ou o primeiro da lista.
- **U09 — Importação com progresso, resumo de resultado e falha visível:** exibir indicador de progresso durante o processamento do arquivo, tratar a falha com mensagem e nova tentativa e gravar as novas entradas em uma única transação.
- **U10 — Exibir e permitir ajustar a identificação prevista no formulário de nova entrada:** o formulário mostra a identificação prevista pela categorização automática e permite trocá-la antes de salvar.
- **U11 — Estados vazios e de erro com ação de recuperação:** estados vazios informativos com ação relevante (criar entrada ou limpar filtros); a parte de erro com nova tentativa já foi entregue na Onda 2 (C03/C09).

## Capabilities

### New Capabilities

Nenhuma.

### Modified Capabilities

- `app-preferences`: adicionar a escolha do modo de aparência (claro, escuro ou sistema) em Configurações, com aplicação imediata e persistência entre sessões. Esta capability foi introduzida pela Onda 2 (`foundation-wave-2`) e ainda não foi arquivada; a Onda 3 a estende com o requisito de seleção.
- `accountability-ledger`: adicionar filtros por período e por faixa de valor com contagem de resultados, a apresentação e o ajuste da identificação prevista no formulário de nova entrada e estados vazios com ação de recuperação.
- `accountability-reports`: adicionar a manutenção do mês e do ano selecionados ao navegar entre páginas e entre sessões.
- `accountability-import-verification`: adicionar indicador de progresso durante a importação, falha visível com recuperação e salvamento transacional das novas entradas.

## Impact

- `lib/app/settings/` e `lib/app/app.dart` (seção de aparência e aplicação reativa do tema) — U02.
- `lib/app/themes/theme_setup.dart` (aplicar o tema claro) — U02.
- `lib/core/accountability/bloc/`, `lib/core/accountability/services/`, `lib/integrations/sqlite/sqlite_accountability_repo.dart` (filtros de período e valor, contagem) e `lib/app/accountability_page/` (controles de filtro e contagem) — U05.
- `lib/app/accountability_monthly_report/` e `lib/app/accountability_yearly_report/` (restauração e persistência da seleção) — U07.
- `lib/app/accountability_page/accountability_page.dart` e `lib/core/accountability_import/services/` / `lib/integrations/sqlite/sqlite_accountability_import_service.dart` (progresso, falha e transação da importação) — U09.
- `lib/app/accountability_new_entry_form/` (exibição e ajuste da identificação prevista) — U10.
- `lib/app/accountability_page/accountability_page.dart` (estados vazios com ação) — U11.
- `test/` (novos e ajustados testes de widget, bloc e serviço para os comportamentos acima).
- Sem mudança de schema de banco de dados nem de contrato de publicação.
