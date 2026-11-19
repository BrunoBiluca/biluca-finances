# google-drive-backup Specification

## Purpose

Permite configurar um backup do banco de dados SQLite no Google Drive, sincronizando os dados na abertura e no fechamento da aplicação, com resolução de conflitos e exibição do estado de sincronização.

## Requirements

### Requirement: Conectar o backup ao Google Drive

A aplicação SHALL permitir conectar uma conta do Google Drive pela página de configurações, abrindo o navegador para que a pessoa autorize o aplicativo a salvar os dados.

#### Scenario: Iniciar a conexão
- **WHEN** a pessoa aciona o botão "Conectar ao Google Drive" na página de configurações
- **THEN** a aplicação abre o navegador para que a pessoa permita ao aplicativo salvar os dados

#### Scenario: Autorizar o acesso
- **WHEN** a pessoa concede a permissão no navegador
- **THEN** a aplicação volta com o backup configurado e passa a exibir as informações da conexão

#### Scenario: Não autorizar o acesso
- **WHEN** a pessoa nega ou cancela a autorização no navegador
- **THEN** o backup permanece não configurado, a página apresenta o motivo da falha e a aplicação continua funcionando normalmente

#### Scenario: Abandonar a autorização no navegador
- **WHEN** a pessoa fecha o navegador ou deixa de concluir a autorização
- **THEN** a tentativa de conexão é encerrada dentro do tempo limite, o backup permanece não configurado e a página informa que a autorização não foi concluída

#### Scenario: Permissão do Google Drive não concedida
- **WHEN** o Google concede a autorização sem a permissão de acesso ao Google Drive
- **THEN** a conexão não é configurada e a página explica qual permissão precisa ser concedida

#### Scenario: Tentar conectar novamente após uma falha
- **WHEN** uma tentativa de conexão termina sem sucesso
- **THEN** a aplicação libera uma nova tentativa de conexão sem exigir reinício

### Requirement: Manter o backup opcional

O backup no Google Drive SHALL ser opcional, permitindo que a pessoa use a aplicação normalmente sem configurar a sincronização.

#### Scenario: Usar a aplicação sem backup
- **WHEN** o backup não está configurado
- **THEN** a aplicação funciona normalmente, sem sincronizar dados com o Google Drive

#### Scenario: Oferecer a configuração quando não configurado
- **WHEN** o backup não está configurado
- **THEN** a página de configurações apresenta a opção "Conectar ao Google Drive" para iniciar a configuração

#### Scenario: Manter a conexão disponível após uma falha
- **WHEN** uma conexão ou sincronização falha
- **THEN** a aplicação continua utilizável e a opção de conectar permanece disponível

### Requirement: Exibir as informações da conexão configurada

Quando o backup está configurado, a página de configurações SHALL exibir as informações gerais da conexão e uma opção para revogar a sincronia.

#### Scenario: Exibir uma conexão configurada
- **WHEN** a pessoa abre a página de configurações com o backup configurado
- **THEN** a página apresenta as informações gerais da conta conectada e a opção de revogar a sincronia

#### Scenario: Revogar a sincronia
- **WHEN** a pessoa aciona a opção de revogar a sincronia
- **THEN** a aplicação revoga o acesso, volta a tratar o backup como não configurado e deixa de sincronizar os dados

### Requirement: Exibir o estado da sincronização na página inicial

A página inicial SHALL exibir o estado da sincronização com a última data de sincronização e a versão do banco de dados.

#### Scenario: Exibir estado após sincronização
- **WHEN** uma sincronização é concluída com sucesso
- **THEN** a página inicial apresenta a última data de sincronização e a versão do banco de dados

#### Scenario: Exibir estado sem backup configurado
- **WHEN** o backup não está configurado
- **THEN** a página inicial indica que não há backup configurado, sem apresentar data de sincronização

### Requirement: Exibir o horário da sincronização no fuso da máquina

A aplicação SHALL apresentar o horário da última sincronização no fuso horário local da máquina, tanto na página inicial quanto na página de configurações.

#### Scenario: Exibir o horário local na página inicial
- **WHEN** uma sincronização é concluída e o fuso da máquina difere de UTC
- **THEN** a página inicial apresenta o horário da última sincronização no fuso local, e não em UTC

#### Scenario: Exibir o horário local nas configurações
- **WHEN** a pessoa abre a página de configurações com o backup configurado
- **THEN** a última sincronização é apresentada no fuso local da máquina

#### Scenario: Refletir a mudança de fuso da máquina
- **WHEN** o fuso horário da máquina é alterado entre sincronizações
- **THEN** o horário apresentado segue o novo fuso local, preservando o instante da sincronização

### Requirement: Sincronizar ao abrir a aplicação

A aplicação SHALL sincronizar o banco de dados com o Google Drive quando é aberta, caso o backup esteja configurado.

#### Scenario: Abrir com backup configurado
- **WHEN** a aplicação é aberta com o backup configurado
- **THEN** a aplicação sincroniza o banco de dados local com o Google Drive antes de ficar pronta para uso

#### Scenario: Abrir sem backup configurado
- **WHEN** a aplicação é aberta sem o backup configurado
- **THEN** a aplicação fica pronta para uso sem realizar sincronização

#### Scenario: Falha de sincronização na abertura
- **WHEN** a sincronização na abertura falha por indisponibilidade de rede ou do Google Drive
- **THEN** a aplicação abre normalmente e a página inicial reflete o estado de sincronização sem descartar os dados locais

### Requirement: Sincronizar ao fechar a aplicação com modal de progresso

Ao fechar a aplicação com o backup configurado, a aplicação SHALL exibir uma modal com o progresso da sincronização e um botão para a pessoa finalizar a aplicação.

#### Scenario: Exibir a modal ao fechar
- **WHEN** a pessoa fecha a aplicação com o backup configurado
- **THEN** a aplicação apresenta uma modal com o processo de sincronização e um botão para finalizar a aplicação

#### Scenario: Finalizar a aplicação após a sincronização
- **WHEN** a pessoa aciona o botão para finalizar a aplicação na modal
- **THEN** a aplicação conclui o fechamento após a sincronização

#### Scenario: Falha ou demora na sincronização ao fechar
- **WHEN** a sincronização ao fechar falha ou excede o tempo limite
- **THEN** a modal apresenta o motivo da falha e mantém o botão para finalizar a aplicação disponível

#### Scenario: Fechar sem backup configurado
- **WHEN** a pessoa fecha a aplicação sem o backup configurado
- **THEN** a aplicação fecha sem apresentar a modal de sincronização

### Requirement: Resolver conflitos entre o arquivo local e o do Google Drive

Quando o arquivo local e o arquivo no Google Drive foram ambos alterados, a aplicação SHALL oferecer à pessoa a escolha entre manter o local ou atualizar com o do Google Drive.

#### Scenario: Detectar conflito
- **WHEN** o arquivo local foi alterado e o arquivo no Google Drive também foi alterado
- **THEN** a aplicação apresenta as opções de manter o local ou atualizar com o do Google Drive

#### Scenario: Manter o local
- **WHEN** a pessoa escolhe manter o arquivo local
- **THEN** a aplicação preserva o banco de dados local e sincroniza essa versão para o Google Drive

#### Scenario: Atualizar com o do Google Drive
- **WHEN** a pessoa escolhe atualizar com o do Google Drive
- **THEN** a aplicação substitui o banco de dados local pela versão do Google Drive

### Requirement: Usar a pasta de sincronia no Google Drive

A sincronização SHALL usar a pasta `biluca.com/Biluca Finanças` no Google Drive, com uma subpasta por perfil de sincronização.

#### Scenario: Criar a pasta de sincronia
- **WHEN** o backup é configurado e a pasta de sincronia ainda não existe
- **THEN** a aplicação cria ou localiza a pasta `biluca.com/Biluca Finanças` e, dentro dela, a subpasta do perfil ativo

#### Scenario: Salvar na pasta de sincronia
- **WHEN** a aplicação realiza uma sincronização
- **THEN** o banco de dados é armazenado dentro da subpasta do perfil ativo em `biluca.com/Biluca Finanças`

#### Scenario: Localizar a pasta existente
- **WHEN** a aplicação procura pastas no Google Drive para sincronizar os dados
- **THEN** a busca considera somente pastas criadas pela própria aplicação, sem depender do acesso à pasta raiz do Meu Drive

### Requirement: Separar os backups por perfil de sincronização

A aplicação SHALL identificar cada backup pelo nome de perfil definido em sua configuração, usando um nome fixo com valor padrão e sem derivá-lo do modo de build.

#### Scenario: Usar o perfil configurado
- **WHEN** a aplicação inicia uma sincronização
- **THEN** utiliza o nome de perfil definido na configuração, ou o valor padrão quando não houver configuração

#### Scenario: Isolar desenvolvimento do uso real
- **WHEN** duas instalações usam perfis diferentes
- **THEN** cada uma mantém seu próprio arquivo remoto, sem alterar ou conflitar com o backup da outra

#### Scenario: Exibir o perfil ativo
- **WHEN** a pessoa abre a página de configurações com o backup configurado
- **THEN** a página apresenta o perfil de sincronização em uso junto às informações da conexão

### Requirement: Informar falhas de conexão e sincronização

Quando uma operação no Google Drive falha, a aplicação SHALL apresentar o motivo da falha, preservar os dados locais e registrar o detalhe técnico no log sem expor tokens de acesso.

#### Scenario: Exibir o motivo da falha
- **WHEN** o Google rejeita uma operação de conexão ou sincronização
- **THEN** a aplicação apresenta uma mensagem com o motivo retornado pelo serviço

#### Scenario: Preservar os dados locais
- **WHEN** uma sincronização falha
- **THEN** os dados locais permanecem inalterados e a página inicial reflete o estado de falha

#### Scenario: Registrar detalhes técnicos
- **WHEN** uma operação falha ou uma conexão é concluída
- **THEN** o log registra o detalhe técnico da falha e os escopos concedidos, sem registrar tokens de acesso

### Requirement: Entregar as credenciais do Google com a instalação

A instalação Windows SHALL incluir o arquivo de credenciais OAuth, e a aplicação SHALL localizá-lo ao lado do executável, independentemente do diretório de trabalho usado para abrir o programa.

#### Scenario: Conectar após instalar
- **WHEN** a pessoa instala a aplicação e aciona a conexão com o Google Drive
- **THEN** as credenciais são encontradas a partir dos arquivos instalados e a conexão é concluída

#### Scenario: Abrir por outro diretório de trabalho
- **WHEN** a aplicação é iniciada a partir de um diretório diferente da pasta de instalação
- **THEN** as credenciais continuam sendo encontradas ao lado do executável

#### Scenario: Credenciais ausentes
- **WHEN** o arquivo de credenciais não existe em nenhum dos caminhos consultados
- **THEN** a conexão falha com uma mensagem que informa o caminho esperado do arquivo
