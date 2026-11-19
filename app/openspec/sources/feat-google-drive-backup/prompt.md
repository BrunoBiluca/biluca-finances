# Backup dos dados no Google Drive

Objetivo:

Queria uma solução para conseguir cadastrar uma conta do Google Drive e fazer a sincronização dos dados armazenados no banco de dados SQLite utilizado.

Requisitos:

- Sincronizar os dados quando o usuário abre e fecha a aplicação
  - Exibir na página principal o estado de sincronização, com última data de sincronização e versão do banco de dados
  - Quando o usuário fecha a aplicação, deve exibir uma modal mostrando o processo de sincronização e um botão para o usuário finalmente finalizar a aplicação
- Em caso de conflito, ou seja, o arquivo local foi alterado e o arquivo no Google Drive também, dar ao usuário a opção de escolher o que ele quer fazer. Opções: manter o local, atualizar com o do Google Drive.
- O usuário tem a opção de configurar ou não o backup com o Google Drive
  - Uma página de configurações deve ser criada para isso
  - Será disponibilizado um botão "Conectar ao Google Drive" para iniciar o processo. Depois de clicado o aplicativo abre o navegador para o que o usuário permita ao aplicativo salvar os dados.
- Quando o backup de dados está configurado, deve exibir na tela de configurações as informações gerais da conexão e também uma opção para revogar essa sincronia
- A pasta de sincronia no google drive deve ser 'biluca.com/Biluca Finanças'

Fora de escopo:

- Usar outros recursos de cloud do Google
- Fazer a sincronização enquanto o usuário utiliza a aplicação

Arquitetura:

- Código de integração com a API do Google deve ser mantido na pasta /integrations
- Código dentro dos componentes deve utilizar interfaces mantidas na pasta /core
- Não devem ser feitos testes para a borda do sistema, apenas para elementos internos ao sistema como widgets, serviços, funções úteis...
- Tentar reutilizar componentes que são utilizados em vários pontos da aplicação. Os componentes devem seguir a semântica da aplicação.