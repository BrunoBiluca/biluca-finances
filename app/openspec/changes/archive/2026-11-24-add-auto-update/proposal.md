# Proposal

## Why

Atualmente a atualização depende inteiramente da pessoa: ela precisa descobrir que existe uma versão nova, baixar o instalador publicado no GitHub Releases, fechar a aplicação por conta própria e executar o instalador. Sem aviso na aplicação, versões antigas continuam em uso por tempo indeterminado, inclusive com correções de problemas já resolvidos.

## What Changes

- Verificar, na abertura da aplicação, a versão mais recente publicada no GitHub Releases e comparar com a versão instalada.
- Exibir uma notificação na página inicial quando existir uma versão mais recente disponível.
- Exibir na página de configurações a versão atual, a versão mais recente, a opção de verificar novamente e a opção de atualizar.
- Baixar o instalador gerado pelo Inno Setup a partir do release publicado, encerrar a aplicação executando o fluxo de fechamento já existente (incluindo a sincronização do backup) e abrir o wizard do Inno Setup para concluir a atualização.
- Manter o processo de publicação como responsabilidade da pessoa desenvolvedora (`build.ps1`), sem alterar o empacotamento; o instalador continua sendo gerado pelo Inno Setup e anexado ao release com o nome `biluca-financas-setup-<versão>.exe`.
- Restringir a atualização a partir da aplicação ao Windows, única plataforma com instalador Inno Setup; nas demais plataformas a verificação fica indisponível, sem impedir o uso da aplicação.
- Falhas de verificação, download ou abertura do instalador não interrompem a aplicação: a página informa o motivo e mantém nova tentativa disponível.

## Capabilities

### New Capabilities

- `app-update`: verificação da versão publicada no GitHub Releases na abertura, notificação de versão disponível, download do instalador e encerramento da aplicação para concluir a atualização pelo wizard do Inno Setup.

### Modified Capabilities

Nenhuma.

## Impact

- Novo `lib/core/app_update/` com modelos de versão e release, regra de comparação de versões, interface de serviço e `AppUpdateBloc`.
- Novo código em `lib/integrations/` para consultar o GitHub Releases e para baixar e abrir o instalador no Windows.
- Página inicial (`lib/app/home/`) passa a exibir a notificação de atualização disponível.
- Página de configurações (`lib/app/settings/`) passa a exibir versões e as ações de verificar e atualizar.
- Abertura da aplicação (`main.dart`) passa a disparar a verificação de versão; encerramento passa a poder ocorrer a pedido da atualização, reaproveitando o fluxo de fechamento existente.
- `setup.iss` e `build.ps1` permanecem com o mesmo processo de publicação, mas o nome do arquivo do instalador anexado ao release passa a ser um contrato consumido pela aplicação e precisa ser documentado.
- Nenhuma dependência nova: a verificação e o download usam `http`, a versão instalada usa `package_info_plus` e o diretório temporário usa `path_provider`.
- Sem alteração de esquema do banco de dados e sem migração de dados.
- Documentação afetada: `docs/Sistema/Publicação.md` (contrato do release consumido pela aplicação) e `docs/Sistema/Arquitetura.md` (organização do novo código).
