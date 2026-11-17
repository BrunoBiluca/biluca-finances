# Spec Delta

## MODIFIED Requirements

### Requirement: Acessar a página de categorias pelo menu lateral

A aplicação SHALL oferecer a página "Identificações & Categorias" no menu lateral, com rota própria, mantendo a navegação compartilhada e as demais páginas disponíveis. O item destacado no menu SHALL corresponder à rota ativa, inclusive quando a navegação é iniciada fora do menu.

#### Scenario: Abrir a página pelo menu
- **WHEN** a pessoa seleciona o item de identificações no menu lateral
- **THEN** a aplicação abre a página de gerenciamento de categorias e marca esse item como selecionado

#### Scenario: Sincronizar o destaque após navegação externa ao menu
- **WHEN** a pessoa abre a página de identificações por um acesso rápido em outra página
- **THEN** o menu lateral marca "Identificações" como selecionado e, ao retornar, destaca a página de destino

#### Scenario: Manter a navegação compartilhada
- **WHEN** a página de gerenciamento de categorias está aberta
- **THEN** o menu lateral e a estrutura de layout do aplicativo continuam disponíveis, como nas demais páginas
