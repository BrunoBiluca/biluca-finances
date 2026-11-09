# Design

## Context

`AccountabilityTable` já controla edição em linha para descrição, valor e identificação, enquanto a coluna de data continua somente para leitura. A exibição das identificações está dividida entre `AccountabilityIdentificationLabel` e o seletor usado na edição. Os temas expõem as cores semânticas de valores positivos, negativos e neutros. Ver `proposal.md` e `specs/accountability-ledger/spec.md` para motivação e contrato.

## Goals / Non-Goals

**Goals:**
- Aplicar o tratamento visual da referência aos campos atualmente editáveis e destacar a linha em edição.
- Usar cores semânticas do tema para valores e a cor configurada em cada identificação nos respectivos elementos visuais.
- Manter os dados, callbacks e o ciclo atual de edição sem mudanças.

**Non-Goals:**
- Tornar a data editável ou adicionar controles de fluxo, anexos ou outras funções ilustradas na referência.
- Adicionar rótulos sobre os campos; as colunas continuam identificando cada campo.
- Alterar criação, exclusão, pesquisa, paginação, importação ou manutenção de identificações.

## Decisions

- **Manter a edição na estrutura atual da tabela.** Aplicar estilos de campo e destaque somente ao estado de edição existente, posicionando o selo “Editando” no início da linha, junto à primeira coluna. Isso reaproveita o controlador e os callbacks atuais, em vez de introduzir outra forma de edição ou mudar a estrutura de dados da tabela.
- **Usar a paleta do tema pelo sinal do valor.** Valores maiores que zero usam a cor semântica positiva; menores que zero, a negativa; zero, a neutra. A mesma regra se aplica à apresentação do valor na linha e no campo de edição. Isso evita cores fixas da referência que não acompanham o tema ativo.
- **Usar a cor própria da identificação no selo e no seletor.** O selo compacto conserva ícone e descrição; as opções do seletor exibem ícone colorido e descrição, com a cor da identificação discernível em cada item. Para a opção “Não identificado”, manter a descrição e usar um tratamento neutro. Isso distingue as categorias sem depender apenas de texto ou de cor. A cor de fundo do campo deve seguir o mesmo padrão que os demais campos de entrada.
- **Restringir o alinhamento visual ao pedido.** Adotar fundos, contornos, espaçamentos e destaque de foco inspirados nos campos existentes na referência, omitindo seus subtítulos por campo e controles que não existem no fluxo atual.

## Risks / Trade-offs

- [O destaque pode ser menos legível em um dos temas ativos] → Usar cores e superfícies do tema e validar o estado de edição no tema escuro adotado pelos testes e nos demais temas disponíveis.
- [A linha editável pode precisar de mais altura para acomodar o selo e os campos] → Ajustar a altura apenas para o estado de edição e verificar que tabela, rolagem e ações continuam acessíveis.
- [A cor de uma identificação pode ter contraste insuficiente com o fundo] → Aplicar a cor como acento e usar uma superfície tintada/contorno, preservando contraste legível para o texto.

## Migration Plan

Não há migração de dados nem mudança de dependências. A alteração é visual e pode ser revertida nos widgets sem afetar lançamentos existentes ou sua persistência.
