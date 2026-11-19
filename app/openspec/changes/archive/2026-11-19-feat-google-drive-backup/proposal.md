# Proposal

## Why

Os dados da aplicação ficam armazenados apenas localmente em um banco SQLite, sem qualquer cópia externa. Uma falha de disco, troca de máquina ou perda do dispositivo apaga todo o histórico financeiro sem possibilidade de recuperação. Esta mudança adiciona backup automático no Google Drive para proteger os dados e permitir recuperação em outra instalação.

## What Changes

- Adicionar uma página de configurações com a opção de conectar ou não o backup ao Google Drive, incluindo a autenticação via navegador (OAuth) e a revogação do acesso.
- Exibir, na página inicial, o estado da sincronização com a última data de sincronização e a versão do banco de dados.
- Sincronizar o banco de dados SQLite para a pasta `biluca.com/Biluca Finanças` no Google Drive quando a aplicação é aberta.
- Separar os backups em uma subpasta por perfil de sincronização (`biluca.com/Biluca Finanças/<perfil>`), com nome de perfil fixo definido por configuração, para que o uso em desenvolvimento e o uso real não compartilhem o mesmo arquivo.
- Exibir uma modal com o progresso da sincronização e um botão para finalizar a aplicação quando o usuário a fecha.
- Encerrar a autorização e a sincronização com limite de tempo, devolvendo o controle à pessoa usuária e permitindo nova tentativa quando a permissão é negada, o navegador é fechado ou a sincronização falha.
- Exibir o motivo retornado pelo Google nas falhas de conexão e sincronização, registrando o detalhe técnico e o escopo concedido no log da aplicação.
- Oferecer resolução de conflito quando o arquivo local e o arquivo no Google Drive foram ambos alterados, com as opções manter o local ou atualizar com o do Google Drive.
- Manter o código de integração com o Google na pasta `lib/integrations`, expondo o acesso por interfaces definidas em `lib/core`.
- Embarcar o arquivo de credenciais OAuth no instalador Windows, resolvê-lo ao lado do executável e interromper o empacotamento quando ele não existir.

## Capabilities

### New Capabilities

- `google-drive-backup`: configuração do backup no Google Drive, autenticação da conta, sincronização do banco SQLite na abertura e no fechamento, exibição do estado de sincronização, resolução de conflitos e revogação do acesso.

### Modified Capabilities

Nenhuma.

## Impact

- Novo serviço de integração com o Google Drive em `lib/integrations`.
- Novas interfaces e regras de sincronização em `lib/core`.
- Nova página de configurações e modal de fechamento em `lib/app`.
- Alteração da página inicial para exibir o estado de sincronização.
- Alteração do fluxo de abertura e fechamento da aplicação (`main.dart`, `App.didRequestAppExit`, `tear_down.dart`).
- Layout remoto passa a ter uma subpasta por perfil de sincronização; a pasta existente sem perfil não é migrada automaticamente.
- Configuração externa do perfil de sincronização, com nome fixo e valor padrão, sem derivação automática do modo de build.
- Novas dependências para autenticação OAuth e acesso ao Google Drive, justificadas no design.
- Credenciais OAuth mantidas fora do repositório, por configuração segura, nunca no código-fonte.
- Instalador Windows passa a embarcar `secrets/google_oauth.json` em `{app}\secrets`, com diretório de trabalho fixado nos atalhos.
- Script de empacotamento passa a exigir o arquivo de credenciais antes de gerar o instalador.
