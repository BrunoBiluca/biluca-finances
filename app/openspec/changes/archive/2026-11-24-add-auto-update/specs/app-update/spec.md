# Spec Delta

## Purpose

Mantém a aplicação atualizada a partir dos releases publicados no GitHub: identifica versões mais recentes, notifica a pessoa usuária, baixa o instalador e encerra a aplicação para concluir a instalação pelo wizard do Inno Setup.

## ADDED Requirements

### Requirement: Verificar a versão na abertura da aplicação

A aplicação SHALL verificar a versão mais recente publicada no GitHub Releases ao ser aberta, comparando-a com a versão instalada, sem impedir a navegação ou o uso das demais funcionalidades.

#### Scenario: Abrir com versão mais recente disponível
- **WHEN** a aplicação é aberta e existe uma versão publicada superior à instalada
- **THEN** a aplicação identifica a atualização disponível e passa a apresentá-la nas páginas que exibem informações de versão

#### Scenario: Abrir já na versão mais recente
- **WHEN** a aplicação é aberta e a versão publicada é igual à instalada
- **THEN** a aplicação não apresenta aviso de atualização e continua utilizável normalmente

#### Scenario: Verificação em andamento
- **WHEN** a verificação de versão ainda está em andamento
- **THEN** as páginas informam que a verificação está em andamento e a navegação continua disponível

#### Scenario: Falha na verificação
- **WHEN** a verificação de versão falha por falta de conexão, indisponibilidade do serviço ou exceder o tempo limite
- **THEN** a aplicação abre e permanece utilizável, sem apresentar aviso de versão disponível

### Requirement: Comparar versões publicadas com a versão instalada

A aplicação SHALL determinar a existência de atualização comparando os números de versão no formato `major.minor.patch`, considerando atualização apenas quando a versão publicada for superior à instalada.

#### Scenario: Publicação posterior à instalada
- **WHEN** a versão publicada é superior à instalada em qualquer dos componentes de versão
- **THEN** a atualização é considerada disponível

#### Scenario: Publicação igual à instalada
- **WHEN** a versão publicada é igual à instalada
- **THEN** nenhuma atualização é considerada disponível

#### Scenario: Publicação anterior à instalada
- **WHEN** a versão instalada é superior à versão publicada, como em uma compilação local mais nova
- **THEN** nenhuma atualização é considerada disponível

#### Scenario: Publicação com prefixo na versão
- **WHEN** a versão publicada é identificada com o prefixo `v`, como `v2.1.0`
- **THEN** o prefixo é desconsiderado e a comparação usa o número de versão

#### Scenario: Publicação com versão não reconhecida
- **WHEN** a versão publicada não segue o formato `major.minor.patch`
- **THEN** a verificação termina como falha e nenhuma atualização é considerada disponível

### Requirement: Notificar a versão disponível na página inicial

Quando existir uma atualização disponível, a página inicial SHALL exibir uma notificação com a versão instalada, a versão disponível e uma ação para iniciar a atualização.

#### Scenario: Notificar atualização disponível
- **WHEN** a pessoa abre a página inicial com uma atualização disponível
- **THEN** a página inicial apresenta a notificação com as versões instalada e disponível e a ação para atualizar

#### Scenario: Não notificar sem atualização
- **WHEN** a pessoa abre a página inicial sem atualização disponível ou com a verificação em falha
- **THEN** a página inicial não apresenta notificação de atualização

#### Scenario: Atualizar a partir da página inicial
- **WHEN** a pessoa aciona a ação de atualizar na notificação da página inicial
- **THEN** a aplicação inicia o download do instalador da versão disponível

### Requirement: Exibir informações e ações de atualização nas configurações

A página de configurações SHALL exibir a versão instalada, a versão mais recente verificada e as ações de verificar novamente e de atualizar.

#### Scenario: Exibir versões com atualização disponível
- **WHEN** a pessoa abre a página de configurações com uma atualização disponível
- **THEN** a página apresenta a versão instalada, a versão disponível e as ações de verificar novamente e de atualizar

#### Scenario: Exibir versões sem atualização disponível
- **WHEN** a pessoa abre a página de configurações sem atualização disponível
- **THEN** a página apresenta a versão instalada, informa que a aplicação está atualizada e mantém a ação de verificar novamente, sem a ação de atualizar

#### Scenario: Verificar novamente
- **WHEN** a pessoa aciona a ação de verificar novamente
- **THEN** a aplicação consulta a versão publicada e atualiza as versões apresentadas

#### Scenario: Falha ao verificar novamente
- **WHEN** a verificação acionada pela página de configurações falha
- **THEN** a página apresenta o motivo da falha e mantém a ação de verificar novamente disponível

### Requirement: Baixar o instalador da versão disponível

A aplicação SHALL baixar o instalador do release da versão disponível e apresentar o progresso do download, mantendo a aplicação utilizável durante a operação.

#### Scenario: Iniciar o download
- **WHEN** a pessoa aciona a ação de atualizar
- **THEN** a aplicação baixa o instalador do release e apresenta o progresso do download

#### Scenario: Impedir atualizações concorrentes
- **WHEN** um download está em andamento
- **THEN** as ações de atualizar permanecem indisponíveis até o download terminar

#### Scenario: Download concluído
- **WHEN** o download do instalador termina com sucesso
- **THEN** a aplicação informa que a atualização está pronta e oferece a ação de fechar a aplicação para atualizar

#### Scenario: Release sem instalador anexado
- **WHEN** o release da versão disponível não contém o instalador esperado
- **THEN** o download não é iniciado, a página informa que o instalador não foi encontrado e a aplicação continua utilizável

#### Scenario: Falha no download
- **WHEN** o download falha por falta de conexão, indisponibilidade do serviço ou exceder o tempo limite
- **THEN** a aplicação permanece aberta, informa o motivo da falha e permite uma nova tentativa

#### Scenario: Nova tentativa de download
- **WHEN** a pessoa repete a atualização após um download incompleto
- **THEN** o download recomeça e a aplicação não considera o arquivo incompleto como pronto para instalação

### Requirement: Encerrar a aplicação para concluir a atualização

Ao confirmar a atualização com o instalador baixado, a aplicação SHALL executar o fluxo de fechamento existente e abrir o wizard do Inno Setup somente depois que o processo da aplicação terminar.

#### Scenario: Confirmar a atualização
- **WHEN** a pessoa confirma a atualização com o instalador baixado
- **THEN** a aplicação executa o fluxo de fechamento definido e encerra o próprio processo

#### Scenario: Fechamento com backup configurado
- **WHEN** a atualização é confirmada com o backup configurado
- **THEN** a sincronização de fechamento é executada antes de a aplicação encerrar

#### Scenario: Abrir o wizard após o encerramento
- **WHEN** a aplicação encerra para atualizar
- **THEN** o wizard do Inno Setup com o instalador baixado é aberto apenas após o término do processo da aplicação

#### Scenario: Fechamento não autorizado
- **WHEN** o fluxo de fechamento não permite o encerramento da aplicação
- **THEN** a aplicação permanece aberta e o instalador não é aberto

#### Scenario: Falha ao abrir o instalador
- **WHEN** não é possível abrir o instalador após o fluxo de fechamento
- **THEN** a aplicação permanece aberta, informa o motivo da falha e mantém a tentativa de atualização disponível

#### Scenario: Reabrir após a instalação
- **WHEN** a pessoa conclui o wizard de atualização
- **THEN** a aplicação atualizada é aberta com a nova versão instalada

### Requirement: Restringir a atualização automática ao Windows

A aplicação SHALL verificar e oferecer atualização somente na plataforma cujo instalador é gerado pelo Inno Setup.

#### Scenario: Execução no Windows
- **WHEN** a aplicação é aberta no Windows
- **THEN** a verificação de versão é realizada e as páginas oferecem as ações de atualização

#### Scenario: Execução em outra plataforma
- **WHEN** a aplicação é aberta em uma plataforma sem instalador Inno Setup
- **THEN** a verificação não é realizada, as páginas não apresentam ações de atualização e a aplicação funciona normalmente

### Requirement: Informar e registrar as falhas da atualização

Quando uma etapa da atualização falha, a aplicação SHALL apresentar o motivo à pessoa usuária e registrar o detalhe técnico no log, sem interromper o uso da aplicação.

#### Scenario: Apresentar o motivo da falha
- **WHEN** a verificação, o download ou a abertura do instalador falha
- **THEN** a aplicação apresenta uma mensagem com o motivo retornado pelo serviço ou pela falha local

#### Scenario: Registrar o detalhe técnico
- **WHEN** uma etapa da atualização falha
- **THEN** o log da aplicação registra o detalhe técnico da falha

#### Scenario: Manter a aplicação utilizável após a falha
- **WHEN** uma etapa da atualização falha
- **THEN** a pessoa continua com acesso às funcionalidades da aplicação e ao menos uma das páginas oferece nova tentativa
