# Constituição do Projeto

Estes princípios são regras não negociáveis para a evolução do projeto. Em caso de conflito com uma decisão ou implementação, a mudança deve ser ajustada ou explicitamente discutida antes de prosseguir.

## 1. Stack do projeto

- O projeto deve permanecer em Flutter e Dart.
- Usar as ferramentas de teste do ecossistema Flutter já adotadas pelo projeto.

## 2. Testes de regras de negócio

- Toda regra de negócio deve ter cobertura por teste unitário.
- Ao criar ou alterar uma regra de negócio, criar ou atualizar os testes correspondentes na mesma mudança.

## 3. Dependências

- Não adicionar dependências sem justificativa.
- Toda dependência nova deve ter sua necessidade e alternativas consideradas justificadas na proposta ou revisão da mudança.

## 4. Idioma do código

- Todo código deve ser escrito em inglês, incluindo identificadores, nomes de arquivos e comentários.

## 5. Idioma da documentação

- Toda documentação gerada ou atualizada deve ser escrita em português.

## 6. Organização do projeto

A organização deve representar o conteúdo e as funcionalidades do projeto, facilitando a navegação e mantendo cada responsabilidade próxima de seu domínio.

### Agrupar por funcionalidade

- Agrupar arquivos por funcionalidade ou caso de uso, em vez de reuni-los em pastas globais por tipo.
- Evitar pastas genéricas como `components`, `directives` e `services` na raiz. Subpastas por tipo são adequadas quando seus elementos pertencem a uma funcionalidade específica.
- Cada funcionalidade deve conter os componentes e auxiliares que só fazem sentido dentro dela. Por exemplo, a tabela de prestação de contas pode manter seus componentes de linha e células em `app/accountability_table/widgets/`.

### Um conceito por arquivo

- Cada arquivo deve representar um conceito ou componente coeso.
- Componentes com responsabilidades diferentes devem ser separados em arquivos distintos, mantendo nomes que expressem sua finalidade.

### Elementos genéricos compartilhados

- Usar `common` somente para código reutilizado por funcionalidades independentes e transversais à aplicação.
- `common/lib` pode conter algoritmos gerais e funções puras.
- `common/ui` pode conter componentes genéricos do design system, como campos de formulário, cards e tabelas.
- Não mover para `common` componentes que pertencem a uma única funcionalidade.

### Pastas principais

O código principal deve seguir esta organização por camada e responsabilidade:

```text
lib/
├── app/
├── auth/
├── common/
│   ├── lib/
│   └── ui/
├── core/
├── integrations/
└── testing/
```

- `app`: funcionalidades Flutter e sua apresentação para as pessoas usuárias, agrupadas por domínio e caso de uso.
- `auth`: autenticação e autorização.
- `common`: código compartilhado, organizado conforme os limites acima.
- `core`: núcleo abstrato do domínio, incluindo regras de negócio, interfaces, modelos, validações e gerenciamento de estado.
- `integrations`: comunicação com serviços e tecnologias externas, implementando as interfaces definidas no `core` quando aplicável.
- `testing`: ferramentas de desenvolvimento e suporte a testes que sejam compartilháveis, como utilitários e mocks.
- Os testes automatizados do Flutter devem continuar usando a estrutura convencional `test/` do projeto.

### Limites entre camadas

- Usar injeção de dependências para reduzir o acoplamento entre camadas.
- A raiz de composição da aplicação é responsável por registrar e fornecer as dependências necessárias.
- Dependências devem apontar para abstrações apropriadas; integrações externas não devem definir as regras de negócio do `core`.
