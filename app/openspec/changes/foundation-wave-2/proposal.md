# Proposal

## Why

A Onda 2 ("fundação") do catálogo [Melhorias priorizadas](../../../../docs/Projeto/Fase%202%20-%20Re-design/Melhorias%20priorizadas.md) constrói a base sobre a qual as ondas de experiência (3 e 4) serão executadas: tratamento de falhas de repositório no `AccountabilityBloc`, tipagem forte da tabela e dos relatórios, tokens de tema em vez de cores fixas, componente de carregamento com erro e nova tentativa, camada de preferências persistidas e reforço de testes. Hoje o aplicativo engole falhas de banco sem informar a pessoa, espalha `dynamic` pela tabela e pelos relatórios, usa cores fixas que ignoram o tema ativo e reinicia as preferências a cada abertura — débitos que tornam as próximas ondas arriscadas.

## What Changes

Implementa os itens C03, C04, C06, C07, C09, C10 e C16 do catálogo, citando os IDs no código e nos testes:

- **C03 — Tratar falhas de repositório no `AccountabilityBloc`:** capturar falhas de busca, criação, edição e exclusão e expor um estado de erro com mensagem e ação de nova tentativa na interface.
- **C04 — Substituir cores fixas por tokens do tema, sem `GetIt` dentro de widgets:** mapear `Color(0xFF...)` e `Colors.grey.shade800` para os tokens semânticos do tema ativo e remover o acesso a `GetIt`/`ThemeManager` dentro dos widgets.
- **C06 — Remover `dynamic` da tabela, dos relatórios e dos temas de comparação:** tipar `AccountabilityTable`, `AccountabilityTableRow` e os temas retornados por `values_comparison.dart`.
- **C07 — Dividir `identification_edit_modal.dart` em componentes coesos:** separar formulário, seletor de status, seletor de tipo, campos de ícone/cor, catálogo de ícones e diálogo de cor.
- **C09 — Tipar e melhorar o `FutureHandler`:** tornar o componente genérico, remover `setState` em `initState` e o contorno `hideLoading`, e apresentar erro com ação de nova tentativa.
- **C10 — Criar camada de preferências persistidas:** armazenar e restaurar localmente o modo de aparência, o estado da barra lateral e o mês/ano selecionados nos relatórios.
- **C16 — Fortalecer testes (parte de falhas):** cobrir falhas de repositório no `AccountabilityBloc`; a remoção do mascaramento de overflow fica para a Onda 4 (U13).

## Capabilities

### New Capabilities

- `app-preferences`: persistência e restauração das preferências da aplicação (modo de aparência, estado recolhido da barra lateral e mês/ano selecionados nos relatórios) entre sessões.

### Modified Capabilities

- `accountability-ledger`: informar falhas de repositório na página Prestação de Contas, com mensagem de erro e ação de recuperação.
- `accountability-reports`: apresentar falha de carregamento dos relatórios com ação de nova tentativa.

## Impact

- `lib/core/accountability/bloc/` (estado de falha) e `lib/app/accountability_page/` (exibição do erro) — C03.
- `lib/app/themes/`, `lib/app/accountability_table/`, `lib/app/app_layout/sidebar/`, `lib/app/accountability_monthly_report/`, `lib/app/accountability_yearly_report/`, `lib/common/ui/` (tokens de tema) — C04.
- `lib/app/accountability_table/` e `lib/common/ui/reports/values_comparison.dart` (tipagem) — C06.
- `lib/app/accountability_identifications/widgets/` (divisão do modal) — C07.
- `lib/common/ui/reports/future_handler.dart` e seus usos nos relatórios — C09.
- `lib/core/preferences/` (nova camada), `lib/app/app.dart`, `pubspec.yaml` (dependência de persistência local) — C10.
- `test/` (novos testes de falha e ajustes de tipagem) — C16.
- Sem mudança de schema de banco de dados nem de contrato de publicação.
