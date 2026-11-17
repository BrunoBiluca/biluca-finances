# Tasks

## 1. Persistência da descrição

- [x] 1.1 Adicionar um campo opcional de descrição auxiliar ao modelo `AccountabilityIdentification`, preservando o campo `description` como nome. Verificar por testes de unidade que criação, cópia, serialização e desserialização mantêm o novo texto.
- [x] 1.2 Adicionar uma migration SQLite com descrição vazia como default para registros existentes. Verificar por teste de repositório que identificações legadas continuam disponíveis com descrição vazia.
- [x] 1.3 Atualizar as operações de criação e edição no repositório SQLite para persistir o campo auxiliar. Verificar por testes de repositório que criar e editar descrição não altera os demais atributos da identificação.

## 2. Modal de criação e edição

- [x] 2.1 Adicionar um campo opcional de descrição à modal de criação e edição, inicializando-o com o valor existente ou vazio. Verificar por widget test que os modos de criação e edição exibem o valor correto.
- [x] 2.2 Conectar o campo à criação e à cópia da identificação, permitindo limpar a descrição. Verificar por widget test que salvar persiste a descrição e cancelar não persiste alterações.
- [x] 2.3 Garantir que o campo use o mesmo padrão visual dos campos existentes e permaneça dentro da área da modal. Verificar pela suíte de widget da modal e pela revisão visual dos estados normal e de foco.

## 3. Modal de seleção

- [x] 3.1 Exibir o nome e a descrição auxiliar das opções no modal de seleção. Verificar por widget test que opções com descrição mostram o texto auxiliar e opções sem descrição não exibem texto vazio.
- [x] 3.2 Manter a busca limitada ao nome da identificação. Verificar por teste que texto presente somente na descrição não amplia o resultado da busca.
- [x] 3.3 Garantir que as tags das tabelas continuem exibindo apenas ícone e nome dado por `description`. Verificar por widget tests que a descrição auxiliar não aparece nessas tags após alteração ou criação da identificação.

## 4. Página de identificações

- [x] 4.1 Exibir a descrição auxiliar em categorias pai e subcategorias da página de identificações, ocultando-a quando vazia. Verificar por widget tests que descrição, nome e demais badges permanecem consistentes.
- [x] 4.2 Atualizar os testes da página de identificações para criação e edição com descrição. Verificar por `flutter test test/app/accountability_identifications/accountability_identifications_page_test.dart` que os cenários passam.

## 5. Integração e regressão

- [x] 5.1 Atualizar os testes afetados do modelo, repositório e das modais. Verificar por `flutter test test/core/accountability test/integrations/sqlite test/app/accountability test/app/accountability_identifications` que os testes passam.
- [x] 5.2 Executar análise e testes focados da funcionalidade. Verificar por `flutter analyze` e pela seleção dos testes relacionados que não há novos diagnósticos ou regressões.
