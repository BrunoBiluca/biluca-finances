# Fase 2 - Re-design

**Objetivo**

Aplicar um novo design ao Biluca Finanças ao mesmo tempo que refatoramos o código para prepará-lo para futuras expansões de funcionalidades.

**Motivação**

Atualmente a aplicação tem um design muito ruim que prejudica a leitura das informações. Ter uma visualização mais moderna, com melhores escolhas de cores, tipografia espaçamento deve melhorar isso.

Junto a melhoria visual, também é a oportunidade de refatorar o projeto para melhorar a atual base de código em relação aos princípios de modularização, coesão, separação de responsabilidades e robustez.

## Hipóteses

- A nova versão deve ser mais atrativa visualmente
- A busca por informações deve ser facilitada
	- Exemplos
		- Buscar pelo gasto de uma identificação no mês deve ser mais fácil
		- Entender as comparações entre os meses
- O código gerado nessa fase deve ajudar a criação de futuras funcionalidades

## Escopo

> [!info]- Legenda
> ✅ feito
> 🟦 em andamento
> ⬛ não feito

- [[Referências visuais]]
- [[Referências sistêmicas]]

### Re-design de todos os elementos da aplicação

- ⬛ Home page
- ⬛ Relatório anual
- ⬛ Relatório mensal
- ⬛ Tabela de Prestação de contas
- ⬛ Modal de criação de registro de conta
- ⬛ Edição da tabela de Prestação de contas
- ⬛ Modal de conferência de importação de extratos
- ⬛ Modal de seleção de identificação

### [[DRP 07 - Controle de Identificações]]

- [[RF 07.01 - Exibição das identificações cadastradas]]
- [[RF 07.02 - Identificações abertas]]
- [[RF 07.03 - Identificações descontinuadas]]
- [[RF 07.04 - Remoção de Identificações]]
- [[RF 07.05 - Sub-Identificações]]
- [[RF 07.06 - Cadastro de Identificações]]
- [[RF 07.07 - Edição de Identificações]]

### Refatoração

- ⬛ Refatoração da aplicação para seguir os formato padrão de projetos de Front-end
- ⬛ Rever o processo de publicação de novas versões do projeto

### Backup de dados

- ⬛ Criar uma forma de manter um back-up de dados com Google Drive